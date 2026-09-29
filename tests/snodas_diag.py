"""One-off diagnostic for the Stowe SNODAS values. Writes tests/snodas_diag.json.

For several dates before/after the Dec 2025 jump: list the tar contents, record the SWE (1034) and
snow depth (1036) headers' grid geometry, and the 3x3 neighbourhood of values around each point."""
import gzip, io, json, math, sys, tarfile
from datetime import date
from pathlib import Path
import requests

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / "scripts"))
import update_snodas as u

DATES = [date(2025, 3, 1), date(2025, 12, 15), date(2025, 12, 20), date(2025, 12, 25), date(2025, 12, 28),
         date(2026, 1, 1), date(2026, 2, 1), date(2026, 3, 1), date(2026, 4, 1), date(2023, 3, 15)]
KEYS = {"swe": "ssmv11034", "depth": "ssmv11036"}

out = []
s = requests.Session()
for d in DATES:
    rec = {"date": d.isoformat(), "url": u.tar_url(d)}
    try:
        r = s.get(u.tar_url(d), timeout=120)
        rec["http"] = r.status_code
        if r.status_code != 200:
            out.append(rec); continue
        with tarfile.open(fileobj=io.BytesIO(r.content)) as tar:
            names = tar.getnames()
            rec["files"] = names
            for label, code in KEYS.items():
                dat = next((n for n in names if code in n and n.endswith(".dat.gz")), None)
                txt = next((n for n in names if code in n and (n.endswith(".txt.gz") or n.endswith(".Hdr.gz"))), None)
                info = {"dat": dat, "hdr": txt}
                if not dat:
                    rec[label] = info; continue
                grid = gzip.decompress(tar.extractfile(dat).read())
                info["bytes"] = len(grid)
                hdr_text = gzip.decompress(tar.extractfile(txt).read()).decode("latin-1") if txt else ""
                keep = [l for l in hdr_text.splitlines() if any(k in l.lower() for k in (
                    "columns", "rows", "minimum x", "maximum y", "minimum y", "maximum x", "resolution", "no data",
                    "slope", "intercept", "data units", "scale", "benchmark", "description", "data type", "byte order"))]
                info["header_lines"] = keep
                hdr = u.parse_header(hdr_text) or (u.FALLBACK_NEW if d >= date(2013, 10, 1) else u.FALLBACK_OLD)
                info["geometry"] = {k: hdr[k] for k in ("ncols", "nrows", "xmin", "ymax", "dx", "dy")}
                info["expected_bytes"] = hdr["ncols"] * hdr["nrows"] * 2
                pts = {}
                for key, (lat, lon) in u.POINTS.items():
                    col = math.floor((lon - hdr["xmin"]) / hdr["dx"]); row = math.floor((hdr["ymax"] - lat) / hdr["dy"])
                    block = []
                    for dr in (-1, 0, 1):
                        line = []
                        for dc in (-1, 0, 1):
                            i = ((row + dr) * hdr["ncols"] + (col + dc)) * 2
                            v = int.from_bytes(grid[i:i + 2], "big", signed=True)
                            line.append(None if v < 0 else round(v / 1000 * 39.3701, 1))
                        block.append(line)
                    pts[key] = {"row": row, "col": col, "block_inches": block}
                info["points"] = pts
                rec[label] = info
    except Exception as e:
        rec["error"] = repr(e)
    out.append(rec)
    print(d, rec.get("http"), rec.get("error", ""))
(ROOT / "tests/snodas_diag.json").write_text(json.dumps(out, indent=1))
