"""One-off test: does Open-Meteo's ECMWF snowfall change with the `elevation` parameter?

For each station, request the same forecast three ways and compare 7-day totals:
  A) elevation = station elevation (what the site uses)
  B) elevation = nan  (downscaling off; model grid-cell height)
  C) elevation = station elevation + 1000 m (a big change, to make any effect obvious)
Writes tests/elevation_test.json.
"""
import json
from pathlib import Path
import requests

ROOT = Path(__file__).resolve().parent.parent
locs = json.loads((ROOT / "docs/figures/locations.json").read_text())["stations"]
pts = [s for s in locs if s.get("lat") is not None and (s.get("nrcs_elev") or s.get("elev"))]

def get(elev_list, model="ecmwf_ifs025"):
    p = {"latitude": ",".join(f"{s['lat']:.4f}" for s in pts),
         "longitude": ",".join(f"{s['lon']:.4f}" for s in pts),
         "hourly": "snowfall,precipitation,rain,temperature_2m",
         "models": model, "forecast_days": 8, "timezone": "UTC",
         "elevation": ",".join(elev_list)}
    r = requests.get("https://api.open-meteo.com/v1/forecast", params=p, timeout=60)
    r.raise_for_status()
    d = r.json()
    return d if isinstance(d, list) else [d]

m = [ (s.get("nrcs_elev") or s["elev"]) * 0.3048 for s in pts ]
A = get([f"{x:.0f}" for x in m])
B = get(["nan"] * len(pts))
C = get([f"{x + 1000:.0f}" for x in m])

def summ(loc):
    h = loc["hourly"]
    tot = lambda k: round(sum(v for v in h[k] if v is not None), 2)
    t = [v for v in h["temperature_2m"] if v is not None]
    return dict(elevation_m=loc.get("elevation"), snowfall_cm=tot("snowfall"), precip_mm=tot("precipitation"),
                rain_mm=tot("rain"), mean_temp_c=round(sum(t) / len(t), 2) if t else None,
                units=loc.get("hourly_units"))

out = []
for s, a, b, c in zip(pts, A, B, C):
    out.append(dict(key=s["key"], station=s["station"], station_elev_ft=s.get("nrcs_elev") or s["elev"],
                    A_station=summ(a), B_grid=summ(b), C_plus1000m=summ(c),
                    grid_cell_lat_lon=[b.get("latitude"), b.get("longitude")],
                    station_cell_lat_lon=[a.get("latitude"), a.get("longitude")]))
(ROOT / "tests/elevation_test.json").write_text(json.dumps(out, indent=1))
print("done", len(out))
