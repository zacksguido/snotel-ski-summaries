"""
Snowfall forecast for every station from the ECMWF model, via the Open-Meteo API.

Reads station coordinates from docs/figures/locations.json (written by make_figures.py) and
writes docs/data/forecast.json with forecast snowfall totals for the next 1, 3, 5 and 7 days
(24, 72, 120 and 168 hours from the time of the run).

Forecast snowfall is NEW SNOW DEPTH (inches of snow), not snow water equivalent.
Weather data by Open-Meteo.com (CC BY 4.0), model: ECMWF IFS.
"""

import json
import sys
from datetime import datetime, timedelta, timezone
from pathlib import Path

import requests

ROOT = Path(__file__).resolve().parent.parent
LOCATIONS = ROOT / "docs" / "figures" / "locations.json"
OUT = ROOT / "docs" / "data" / "forecast.json"

API = "https://api.open-meteo.com/v1/forecast"
MODELS = ["ecmwf_ifs025", "ecmwf_ifs"]     # tried in order
HOURS = (24, 72, 120, 168)


def fetch(points: list, model: str, use_elev: bool) -> list:
    params = {
        "latitude": ",".join(f"{p['lat']:.4f}" for p in points),
        "longitude": ",".join(f"{p['lon']:.4f}" for p in points),
        "hourly": "snowfall",
        "models": model,
        "forecast_days": 8,
        "timezone": "UTC",
    }
    if use_elev:
        # Forecast at the station's own elevation (metres), so mountain temperatures/snow levels are right
        params["elevation"] = ",".join(f"{p['elev_ft'] * 0.3048:.0f}" for p in points)
    r = requests.get(API, params=params, timeout=(10, 60), headers={"User-Agent": "snotel-ski-summaries"})
    r.raise_for_status()
    data = r.json()
    return data if isinstance(data, list) else [data]


def totals(loc: dict, now: datetime) -> dict:
    unit = loc.get("hourly_units", {}).get("snowfall", "cm")
    to_in = {"cm": 1 / 2.54, "mm": 1 / 25.4, "inch": 1.0, "in": 1.0}.get(unit, 1 / 2.54)
    times = loc["hourly"]["time"]
    snow = loc["hourly"]["snowfall"]
    out, start = {}, now.replace(minute=0, second=0, microsecond=0)
    for h in HOURS:
        end = start + timedelta(hours=h)
        vals = [v for t, v in zip(times, snow)
                if v is not None and start <= datetime.fromisoformat(t).replace(tzinfo=timezone.utc) < end]
        # Only report a total if the model covers the whole window
        last = datetime.fromisoformat(times[-1]).replace(tzinfo=timezone.utc) if times else start
        out[f"f{h // 24}"] = round(sum(vals) * to_in, 1) if last >= end - timedelta(hours=1) else None
    # Daily breakdown for the next 7 days (UTC days), for possible charts later
    daily = []
    for d in range(7):
        a = start + timedelta(hours=24 * d)
        b = a + timedelta(hours=24)
        daily.append(round(sum(v for t, v in zip(times, snow) if v is not None and
                               a <= datetime.fromisoformat(t).replace(tzinfo=timezone.utc) < b) * to_in, 1))
    out["daily"] = daily
    return out


def main() -> int:
    locs = json.loads(LOCATIONS.read_text())
    resorts_by_key = {}
    for r in locs["resorts"]:
        for k in r["stations"]:
            resorts_by_key.setdefault(k, []).append(r["name"])
    points = []
    for s in locs["stations"]:
        if s.get("lat") is None:
            continue
        elev = s.get("nrcs_elev") or s.get("elev")
        points.append(dict(key=s["key"], station=s["station"], ski_area=", ".join(resorts_by_key.get(s["key"], [])),
                           region=s["region"], variable=s.get("variable", "WTEQ"),
                           lat=s["lat"], lon=s["lon"], elev_ft=elev))

    now = datetime.now(timezone.utc)
    with_elev = [p for p in points if p["elev_ft"]]
    without = [p for p in points if not p["elev_ft"]]
    rows, used_model = [], None
    for model in MODELS:
        try:
            got = []
            for group, use_elev in ((with_elev, True), (without, False)):
                if group:
                    got += list(zip(group, fetch(group, model, use_elev)))
            used_model = model
            break
        except Exception as err:
            print(f"  ! Open-Meteo ({model}): {err}", file=sys.stderr)
    if used_model is None:
        print("No forecast available; keeping the previous file", file=sys.stderr)
        return 0

    for p, loc in got:
        t = totals(loc, now)
        rows.append(dict(key=p["key"], station=p["station"], ski_area=p["ski_area"], region=p["region"],
                         variable=p["variable"], lat=p["lat"], lon=p["lon"],
                         elev_ft=p["elev_ft"], grid_elev_ft=round(loc.get("elevation", 0) / 0.3048) if loc.get("elevation") is not None else None,
                         **t))
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps(dict(issued=now.strftime("%Y-%m-%dT%H:%MZ"), model=used_model,
                                   hours=list(HOURS), stations=rows), indent=1) + "\n")
    print(f"Forecast: {len(rows)} stations from {used_model}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
