"""One-off: compare the Mount Mansfield summit snow stake (NWS COOP USC00435416) with SNODAS near Stowe.

Writes tests/stake_compare.json with:
  - stake: full daily snow depth record (inches) from ACIS
  - snodas: for each day Nov 1 2025 - May 31 2026, a 7x7 block of SNODAS snow depth and SWE (inches)
    centred on the Stowe SNODAS point, plus the row/col of the block's top-left cell
"""
import gzip, io, json, math, sys, tarfile, time
from datetime import date, timedelta
from pathlib import Path
import requests

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / "scripts"))
import update_snodas as u

OUT = ROOT / "tests" / "stake_compare.json"
LAT, LON = u.POINTS["stowe"]
HALF = 3
START, END = date(2025, 11, 1), date(2026, 5, 31)
t0 = time.time()

res = {"stake_meta": None, "stake": None, "snodas": {}, "errors": []}

# Stake record from ACIS
try:
    r = requests.post("https://data.rcc-acis.org/StnMeta",
                      json={"sids": "USC00435416", "meta": "name,sids,ll,elev,valid_daterange", "elems": "snwd"}, timeout=60)
    res["stake_meta"] = r.json()
    r = requests.post("https://data.rcc-acis.org/StnData",
                      json={"sid": "USC00435416", "sdate": "1954-10-01", "edate": "2026-09-30", "elems": "snwd"}, timeout=120)
    res["stake"] = r.json().get("data")
except Exception as e:
    res["errors"].append(f"acis: {e}")

s = requests.Session()
s.headers["User-Agent"] = "snotel-ski-summaries"
d = START
while d <= END and time.time() - t0 < 40 * 60:
    try:
        r = s.get(u.tar_url(d), timeout=(10, 120))
        if r.status_code != 200:
            res["errors"].append(f"{d}: http {r.status_code}")
            d += timedelta(days=1); continue
        rec = {}
        with tarfile.open(fileobj=io.BytesIO(r.content)) as tar:
            names = tar.getnames()
            for label, code in (("swe", "ssmv11034"), ("depth", "ssmv11036")):
                dat = next((n for n in names if code in n and n.endswith(".dat.gz")), None)
                txt = next((n for n in names if code in n and n.endswith(".txt.gz")), None)
                if not dat:
                    continue
                grid = gzip.decompress(tar.extractfile(dat).read())
                hdr = u.parse_header(gzip.decompress(tar.extractfile(txt).read()).decode("latin-1")) if txt else {}
                hdr = hdr or u.FALLBACK_NEW
                col = math.floor((LON - hdr["xmin"]) / hdr["dx"]); row = math.floor((hdr["ymax"] - LAT) / hdr["dy"])
                block = []
                for dr in range(-HALF, HALF + 1):
                    line = []
                    for dc in range(-HALF, HALF + 1):
                        i = ((row + dr) * hdr["ncols"] + (col + dc)) * 2
                        v = int.from_bytes(grid[i:i + 2], "big", signed=True)
                        line.append(None if v < 0 else round(v / 1000 * 39.3701, 1))
                    block.append(line)
                rec[label] = block
                rec["origin"] = [row - HALF, col - HALF]
                rec["geom"] = {k: hdr[k] for k in ("xmin", "ymax", "dx", "dy")}
        res["snodas"][d.isoformat()] = rec
    except Exception as e:
        res["errors"].append(f"{d}: {e}")
    d += timedelta(days=1)

OUT.write_text(json.dumps(res, separators=(",", ":")) + "\n")
print(f"{len(res['snodas'])} days; {len(res['errors'])} errors; stake rows {len(res['stake'] or [])}")
