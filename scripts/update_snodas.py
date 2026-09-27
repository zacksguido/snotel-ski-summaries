"""
Extract daily SNODAS snow water equivalent (SWE) at fixed points and store it as small CSV files.

SNODAS (NOAA National Operational Hydrologic Remote Sensing Center) is a daily, ~1 km modeled
snowpack product for the lower 48 states, archived at NSIDC (dataset G02158) from Oct 2003 on.
Each day is one .tar file; inside, the SWE grid (product code 1034) is a gzipped flat binary of
big-endian 16-bit integers with a text header describing the grid.

Usage:
    python scripts/update_snodas.py                 # add any missing days (daily run)
    python scripts/update_snodas.py --max-minutes 300   # long backfill run

Output: docs/data/snodas/<key>.csv  with columns date,swe_in
"""

import argparse
import gzip
import io
import math
import sys
import tarfile
import time
from datetime import date, datetime, timedelta, timezone
from pathlib import Path

import requests

ROOT = Path(__file__).resolve().parent.parent
OUT_DIR = ROOT / "docs" / "data" / "snodas"
BASE = "https://noaadata.apps.nsidc.org/NOAA/G02158/masked"
FIRST_DAY = date(2003, 10, 1)        # masked archive begins Sep 30, 2003; water year 2004 starts Oct 1

# Points to extract: key -> (latitude, longitude). Keys match STATIONS in make_figures.py.
POINTS = {
    "killington": (43.6176, -72.8034),
    "stowe": (44.5300, -72.7800),
}

MONTHS = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

# Grid used if a day's header can't be read. The masked grid shifted by half a cell on 2013-10-01.
FALLBACK_OLD = dict(ncols=6935, nrows=3351, xmin=-124.733333333333, ymax=52.875, dx=0.00833333333333333,
                    dy=0.00833333333333333, nodata=-9999, slope=0.001, intercept=0.0)
FALLBACK_NEW = dict(FALLBACK_OLD, xmin=-124.733749999999, ymax=52.8745833333323)


def tar_url(d: date) -> str:
    return f"{BASE}/{d.year}/{d.month:02d}_{MONTHS[d.month - 1]}/SNODAS_{d:%Y%m%d}.tar"


def parse_header(text: str) -> dict:
    """Read the grid geometry and scaling from a SNODAS .txt header."""
    kv = {}
    for line in text.splitlines():
        if ":" in line:
            k, _, v = line.partition(":")
            kv[k.strip().lower()] = v.strip()

    def num(*names):
        for n in names:
            if n in kv:
                try:
                    return float(kv[n])
                except ValueError:
                    pass
        return None

    out = dict(
        ncols=num("number of columns"), nrows=num("number of rows"),
        xmin=num("minimum x-axis coordinate"), ymax=num("maximum y-axis coordinate"),
        dx=num("x-axis resolution"), dy=num("y-axis resolution"),
        nodata=num("no data value"), slope=num("data slope"), intercept=num("data intercept"),
    )
    if None in (out["ncols"], out["nrows"], out["xmin"], out["ymax"], out["dx"], out["dy"]):
        return {}
    out["ncols"], out["nrows"] = int(out["ncols"]), int(out["nrows"])
    out["nodata"] = -9999 if out["nodata"] is None else out["nodata"]
    # SWE is stored as millimetres (NSIDC documents a scale factor of 1000 -> metres); use that
    # regardless of how a given year's header words it, and take only the grid geometry from the header
    out["slope"], out["intercept"] = 0.001, 0.0
    return out


def values_at(grid: bytes, hdr: dict, points: dict) -> dict:
    """SWE in inches at each (lat, lon), or None for missing/no-data."""
    out = {}
    for key, (lat, lon) in points.items():
        col = math.floor((lon - hdr["xmin"]) / hdr["dx"])
        row = math.floor((hdr["ymax"] - lat) / hdr["dy"])
        if not (0 <= col < hdr["ncols"] and 0 <= row < hdr["nrows"]):
            out[key] = None
            continue
        i = (row * hdr["ncols"] + col) * 2
        raw = int.from_bytes(grid[i:i + 2], "big", signed=True)
        if raw == hdr["nodata"] or raw < 0:
            out[key] = None
        else:
            meters = raw * hdr["slope"] + hdr["intercept"]
            out[key] = round(meters * 39.3701, 1)
    return out


def read_day(d: date, session: requests.Session) -> dict | None:
    """Download one day's SNODAS tar and return {key: swe_in}. None if the file doesn't exist."""
    r = session.get(tar_url(d), timeout=(10, 120))
    if r.status_code == 404:
        return None
    r.raise_for_status()
    with tarfile.open(fileobj=io.BytesIO(r.content)) as tar:
        names = tar.getnames()
        dat = next((n for n in names if "ssmv11034" in n and n.endswith(".dat.gz")), None)
        if dat is None:
            return None
        grid = gzip.decompress(tar.extractfile(dat).read())
        hdr = {}
        txt = next((n for n in names if "ssmv11034" in n and (n.endswith(".txt.gz") or n.endswith(".Hdr.gz"))), None)
        if txt:
            hdr = parse_header(gzip.decompress(tar.extractfile(txt).read()).decode("latin-1"))
    if not hdr:
        hdr = FALLBACK_NEW if d >= date(2013, 10, 1) else FALLBACK_OLD
    if len(grid) < hdr["ncols"] * hdr["nrows"] * 2:
        return None
    return values_at(grid, hdr, POINTS)


def load(key: str) -> dict:
    p = OUT_DIR / f"{key}.csv"
    if not p.exists():
        return {}
    rows = {}
    for line in p.read_text().splitlines()[1:]:
        d, _, v = line.partition(",")
        if d:
            rows[d] = v
    return rows


def save(key: str, rows: dict) -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    lines = ["date,swe_in"] + [f"{d},{rows[d]}" for d in sorted(rows)]
    (OUT_DIR / f"{key}.csv").write_text("\n".join(lines) + "\n")


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--max-minutes", type=float, default=10, help="stop after this long (resume next run)")
    args = ap.parse_args()
    deadline = time.time() + args.max_minutes * 60

    data = {k: load(k) for k in POINTS}
    # Days not yet stored for every point (a day that returned "no file" is stored as blank)
    today = datetime.now(timezone.utc).date()
    todo, d = [], FIRST_DAY
    while d <= today:
        ds = d.isoformat()
        if any(ds not in data[k] for k in POINTS):
            todo.append(d)
        d += timedelta(days=1)
    # Newest days first, so the current season is filled before the long history
    todo.sort(reverse=True)
    print(f"{len(todo)} day(s) to fetch")

    session = requests.Session()
    session.headers["User-Agent"] = "snotel-ski-summaries"
    done = errors = 0
    for d in todo:
        if time.time() > deadline:
            break
        try:
            vals = read_day(d, session)
        except Exception as err:
            errors += 1
            print(f"  ! {d}: {err}", file=sys.stderr)
            if errors >= 20:
                break
            continue
        if vals is None:
            # Not posted yet (recent days) -> try again next run; missing in the archive -> record blank
            if (today - d).days <= 3:
                continue
            vals = {k: None for k in POINTS}
        for k in POINTS:
            data[k][d.isoformat()] = "" if vals[k] is None else f"{vals[k]}"
        done += 1
        if done % 100 == 0:
            for k in POINTS:
                save(k, data[k])
            print(f"  {done} days done (at {d})")
    for k in POINTS:
        save(k, data[k])
    left = len(todo) - done
    print(f"Fetched {done} day(s); {left} remaining; {errors} error(s)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
