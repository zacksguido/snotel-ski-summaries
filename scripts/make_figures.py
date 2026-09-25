"""
Snow water equivalent (SWE) summaries for SNOTEL stations near western ski areas.

Python port of SkiMtnPlots2.m (Zack Guido, January 2024). For each station it
plots the current water year's SWE against the period-of-record median SWE and
reports the latest value as a percent of median. One PNG is written per region
to docs/figures/.

Data: USDA NRCS National Water and Climate Center (SNOTEL / BC snow pillows).
"""

import io
import json
import os
import sys
import warnings
from datetime import date, datetime, timezone
from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402
import numpy as np  # noqa: E402
import pandas as pd  # noqa: E402
import requests  # noqa: E402
from matplotlib.lines import Line2D  # noqa: E402
from matplotlib.ticker import MaxNLocator  # noqa: E402

OUT_DIR = Path(__file__).resolve().parent.parent / "docs" / "figures"

# Optional: folder of pre-downloaded CSVs named <station key>.csv (for testing offline)
LOCAL_DATA_DIR = os.environ.get("SNOTEL_LOCAL_DATA_DIR")

SITE_PLOTS = "https://nwcc-apps.sc.egov.usda.gov/awdb/site-plots/POR/WTEQ/"
REPORT = "https://wcc.sc.egov.usda.gov/reportGenerator/view_csv/"

# ---------------------------------------------------------------------------
# Stations
#   kind "plot"   = NRCS site-plots CSV (one column per water year, rows Oct 1-Sep 30)
#   kind "report" = NRCS report-generator CSV (one long daily date/value series)
# ---------------------------------------------------------------------------
STATIONS = {
    # --- Utah ---
    "snowbird":   dict(title="Snowbird", station="Snowbird", elev=9710, kind="plot", url=SITE_PLOTS + "UT/Snowbird.csv"),
    "alta":       dict(title="Alta", station="Brighton", elev=8790, kind="plot", url=SITE_PLOTS + "UT/Brighton.csv"),
    "powder":     dict(title="Powder Mtn", station="Little Bear", elev=6540, kind="plot", url=SITE_PLOTS + "UT/Little%20Bear.csv"),
    "solitude":   dict(title="Solitude", station="Mill-D North", elev=8940, kind="plot", url=SITE_PLOTS + "UT/Mill-D%20North.csv"),
    # --- Wyoming & Montana ---
    "jackson":    dict(title="Jackson", station="Phillips Bench", elev=8160, kind="plot", url=SITE_PLOTS + "WY/Phillips%20Bench.csv"),
    "targhee":    dict(title="Targee", station="Grand Targhee", elev=9260, kind="plot", url=SITE_PLOTS + "WY/Grand%20Targhee.csv"),
    "bigsky":     dict(title="Big Sky", station="Lone Mountain", elev=8810, kind="plot", url=SITE_PLOTS + "MT/Lone%20Mountain.csv"),
    "bridger":    dict(title="Bridger", station="Sacajawea", elev=6610, kind="plot", url=SITE_PLOTS + "MT/Sacajawea.csv"),
    # --- Mount Bachelor, OR ---
    "mckenzie":   dict(title="Mckensize (NNE)", station="Mckenzie", elev=4470, kind="plot", url=SITE_PLOTS + "OR/Mckenzie.csv"),
    "threecreek": dict(title="Three Creek (NE)", station="Three Creeks Meadow", elev=5680, kind="plot", url=SITE_PLOTS + "OR/Three%20Creeks%20Meadow.csv"),
    "roaring":    dict(title="Roaring River (NW)", station="Roaring River", elev=4690, kind="plot", url=SITE_PLOTS + "OR/Roaring%20River.csv"),
    "irish":      dict(title="Irish Taylor (SSW)", station="Irish Taylor", elev=5540, kind="plot", url=SITE_PLOTS + "OR/Irish%20Taylor.csv"),
    # --- California ---
    "mammoth":    dict(title="Mammoth Pass", station="Mammoth Pass (MHP)", elev=9400, kind="report",
                       url=REPORT + "customMultiTimeSeriesGroupByStationReport/daily/start_of_period/"
                           "MHP:CA:MSNT%257Cid=%2522%2522%257Cname/POR_BEGIN,POR_END/WTEQ::value?fitToScreen=false"),
    "kirkwood":   dict(title="Kirkwood", station="Carson Pass", elev=8360, kind="plot", url=SITE_PLOTS + "CA/Carson%20Pass.csv"),
    "heavenly":   dict(title="Heavenly", station="Heavenly Valley", elev=8540, kind="plot", url=SITE_PLOTS + "CA/Heavenly%20Valley.csv"),
    "palisades":  dict(title="Palisades", station="Palisades Tahoe", elev=8010, kind="plot", url=SITE_PLOTS + "CA/Palisades%20Tahoe.csv"),
    # --- BC & Idaho ---
    "whistler_n": dict(title="Whistler (North, Tenquille Lake)", station="Tenquille Lake (1D06P)", elev=5476, kind="report",
                       url=REPORT + "customSingleStationReport/daily/start_of_period/"
                           "1D06P:BC:MSNT%257Cid=%2522%2522%257Cname/POR_BEGIN,POR_END/WTEQ::value?fitToScreen=false"),
    "whistler_w": dict(title="Whistler (West, Squamish Upper)", station="Squamish Upper (3A25P)", elev=4551, kind="report",
                       url=REPORT + "customChartReport/daily/start_of_period/"
                           "3A25P:BC:MSNT%257Cid=%2522%2522%257Cname/POR_BEGIN,POR_END/WTEQ::value"
                           "?fitToScreen=false&useLogScale=false"),
    "revelstoke": dict(title="Revelstoke", station="Mount Revelstoke (2A06P)", elev=5807, kind="report",
                       url=REPORT + "customMultiTimeSeriesGroupByStationReport/daily/start_of_period/"
                           "2A06P:BC:MSNT%257Cid=%2522%2522%257Cname/POR_BEGIN,POR_END/WTEQ::value?fitToScreen=false"),
    "schweitzer": dict(title="Schweitzer", station="Schweitzer Basin", elev=6090, kind="plot", url=SITE_PLOTS + "ID/Schweitzer%20Basin.csv"),
    # --- Colorado (north-central) ---
    "steamboat":  dict(title="Steamboat", station="Dry Lake", elev=8240, kind="plot", url=SITE_PLOTS + "CO/Dry%20Lake.csv"),
    "abasin":     dict(title="A-Basin", station="Grizzly Peak", elev=11110, kind="plot", url=SITE_PLOTS + "CO/Grizzly%20Peak.csv"),
    "vail":       dict(title="Vail", station="Vail Mountain", elev=10290, kind="plot", url=SITE_PLOTS + "CO/Vail%20Mountain.csv"),
    "aspen":      dict(title="Aspen", station="Independence Pass", elev=10570, kind="plot", url=SITE_PLOTS + "CO/Independence%20Pass.csv"),
    # --- Colorado (south-central) ---
    "crested":    dict(title="Crested Butte", station="Butte", elev=10190, kind="plot", url=SITE_PLOTS + "CO/Butte.csv"),
    "telluride":  dict(title="Telluride", station="Red Mountain Pass", elev=11060, kind="plot", url=SITE_PLOTS + "CO/Red%20Mountain%20Pass.csv"),
    "silverton":  dict(title="Silverton", station="Molas Lake", elev=10610, kind="plot", url=SITE_PLOTS + "CO/Molas%20Lake.csv"),
    "wolfcreek":  dict(title="Wolf Creek", station="Wolf Creek Summit", elev=10930, kind="plot", url=SITE_PLOTS + "CO/Wolf%20Creek%20Summit.csv"),
    # --- Washington ---
    "crystal":    dict(title="Crystal Mountain", station="Morse Lake", elev=5400, kind="plot", url=SITE_PLOTS + "WA/Morse%20Lake.csv"),
    "stevens":    dict(title="Stevens Pass", station="Stevens Pass", elev=3940, kind="plot", url=SITE_PLOTS + "WA/Stevens%20Pass.csv"),
    "baker":      dict(title="Mount Baker", station="Wells Creek", elev=4040, kind="plot", url=SITE_PLOTS + "WA/Wells%20Creek.csv"),
}

# One figure per region: (file name, heading, station keys top to bottom)
REGIONS = [
    ("utah", "UTAH", ["snowbird", "alta", "powder", "solitude"]),
    ("wyoming-montana", "WYOMING & MONTANA", ["jackson", "targhee", "bigsky", "bridger"]),
    ("mount-bachelor", "MOUNT BACHELOR", ["mckenzie", "threecreek", "roaring", "irish"]),
    ("california", "CALIFORNIA", ["mammoth", "kirkwood", "heavenly", "palisades"]),
    ("bc-idaho", "BC & IDAHO", ["whistler_n", "whistler_w", "revelstoke", "schweitzer"]),
    ("colorado-north", "Colorado (north-central)", ["steamboat", "abasin", "vail", "aspen"]),
    ("colorado-south", "Colorado (South-Central)", ["crested", "telluride", "silverton", "wolfcreek"]),
    ("washington", "Washington", ["crystal", "stevens", "baker"]),
]

# Styling (same RGB values as the MATLAB version)
MEDIAN_FILL = (222 / 255, 235 / 255, 247 / 255)
CURRENT_LINE = (33 / 255, 113 / 255, 181 / 255)
TITLE_COLOR = (236 / 255, 112 / 255, 20 / 255)
XTICKS = [1, 32, 62, 93, 124, 152, 183, 213, 244, 274, 305, 336, 366]
XLABELS = ["Oct1", "Nov1", "Dec1", "Jan1", "Feb1", "Mar1", "Apr1", "May1",
           "Jun1", "Jul1", "Aug1", "Sep1", "Sep30"]

# 366 water-year days, Oct 1 .. Sep 30, including Feb 29 (same rows as the NRCS site-plots files)
WY_DAYS = pd.date_range("1999-10-01", "2000-09-30", freq="D").strftime("%m-%d").tolist()


def current_water_year(today: date) -> int:
    """Water year runs Oct 1 - Sep 30 and is named for the year it ends in."""
    return today.year + 1 if today.month >= 10 else today.year


def fetch_csv(key: str, url: str) -> str:
    if LOCAL_DATA_DIR:
        return (Path(LOCAL_DATA_DIR) / f"{key}.csv").read_text()
    r = requests.get(url, timeout=120, headers={"User-Agent": "snotel-ski-summaries"})
    r.raise_for_status()
    return r.text


def wide_from_site_plot(text: str) -> tuple[pd.DataFrame, int]:
    """Site-plots CSV -> table of 366 water-year days x water-year columns."""
    df = pd.read_csv(io.StringIO(text), dtype={"date": str})
    year_cols = [c for c in df.columns if str(c).strip().isdigit()]
    wide = df.set_index("date")[year_cols].apply(pd.to_numeric, errors="coerce")
    wide.columns = [int(c) for c in year_cols]
    wide = wide.reindex(WY_DAYS)
    por = max(wide.columns) - min(wide.columns) + 1   # endyr - styr + 1, as in the MATLAB
    return wide, por


def wide_from_report(text: str) -> tuple[pd.DataFrame, int]:
    """Report-generator CSV (long daily series) -> same wide layout as site-plots."""
    df = pd.read_csv(io.StringIO(text), comment="#")
    df.columns = ["date", "swe"]
    s = pd.Series(pd.to_numeric(df["swe"], errors="coerce").values,
                  index=pd.to_datetime(df["date"])).sort_index()
    s = s.reindex(pd.date_range(s.index.min(), s.index.max(), freq="D"))  # fill gaps with NaN

    # Start at the first Oct 1 on/after the first observation (drops the partial first year)
    first = s.index.min()
    start_year = first.year if (first.month, first.day) <= (10, 1) else first.year + 1
    s = s[s.index >= pd.Timestamp(start_year, 10, 1)]

    frame = pd.DataFrame({
        "swe": s.values,
        "wy": [d.year + 1 if d.month >= 10 else d.year for d in s.index],
        "mmdd": s.index.strftime("%m-%d"),
    })
    wide = frame.pivot(index="mmdd", columns="wy", values="swe").reindex(WY_DAYS)
    return wide, None  # POR set below (complete years only, as in the MATLAB)


def fill_feb29(wide: pd.DataFrame) -> pd.DataFrame:
    """Non-leap years have no Feb 29; fill it with the Feb 28 / Mar 1 average so lines don't break."""
    i = WY_DAYS.index("02-29")
    row = wide.iloc[i]
    wide.iloc[i] = row.fillna((wide.iloc[i - 1] + wide.iloc[i + 1]) / 2)
    return wide


def summarize(key: str, today: date) -> dict:
    st = STATIONS[key]
    text = fetch_csv(key, st["url"])
    if st["kind"] == "plot":
        wide, por = wide_from_site_plot(text)
    else:
        wide, por = wide_from_report(text)

    wide = fill_feb29(wide)
    wy = current_water_year(today)
    cur_year = wy if wy in wide.columns else max(wide.columns)
    hist = wide[[c for c in wide.columns if c < cur_year]]
    if por is None:
        por = hist.shape[1]

    with warnings.catch_warnings():
        warnings.simplefilter("ignore", category=RuntimeWarning)  # all-NaN days (e.g. Feb 29)
        median = np.nanmedian(hist.to_numpy(dtype=float), axis=1)

    current = wide[cur_year].to_numpy(dtype=float) if cur_year == wy else np.full(366, np.nan)
    valid = np.flatnonzero(~np.isnan(current))

    pct, updated = None, None
    if valid.size:
        i = valid[-1]                                   # last day with data
        updated = datetime.strptime("2000-" + WY_DAYS[i], "%Y-%m-%d").strftime("%b-%d")
        if median[i] > 0:
            pct = round(current[i] / median[i] * 100, 1)

    return dict(title=st["title"], station=st["station"], elev=st["elev"], por=por,
                median=median, current=current, pct=pct, updated=updated)


def draw_panel(ax, s: dict) -> None:
    x = np.arange(1, 367)
    med = np.nan_to_num(s["median"], nan=0.0)
    ax.fill_between(x, 0, med, facecolor=MEDIAN_FILL, edgecolor="black", linewidth=0.6)
    ax.plot(x, s["current"], linewidth=6, color=CURRENT_LINE, solid_capstyle="butt")

    ax.set_xlim(-5, 371)
    data_max = np.nanmax(np.concatenate([med, np.nan_to_num(s["current"])]))
    top = MaxNLocator(nbins=5).tick_values(0, max(data_max * 1.05, 1))[-1]
    ax.set_ylim(0, top)
    ax.set_xticks(XTICKS, XLABELS)
    ax.grid(axis="x", color="0.85")
    ax.set_axisbelow(True)
    ax.set_ylabel("SWE (inches)", fontsize=14)
    ax.set_title(s["title"], fontsize=24, color=TITLE_COLOR)

    pct_text = f"{s['pct']:g}%" if s["pct"] is not None else "--"
    ax.text(0.03, 0.86, pct_text, fontsize=18, transform=ax.transAxes, va="top")
    ax.text(0.03, 0.64, "of median SWE", fontsize=12, transform=ax.transAxes, va="top")
    ax.text(0.98, 0.86,
            f"POR = {s['por']} yrs\nElev. = {s['elev']} ft\nUpdated: {s['updated'] or '--'}",
            fontsize=11, transform=ax.transAxes, va="top", ha="right", linespacing=1.3)


def draw_error_panel(ax, title: str, err: Exception) -> None:
    ax.set_title(title, fontsize=24, color=TITLE_COLOR)
    ax.text(0.5, 0.5, "Data unavailable today", ha="center", va="center",
            fontsize=14, color="0.4", transform=ax.transAxes)
    ax.set_xticks([])
    ax.set_yticks([])
    print(f"  ! {title}: {err}", file=sys.stderr)


def main() -> int:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    today = date.today()
    wy = current_water_year(today)
    legend_label = f"Water year {wy} (Oct 1, {wy - 1} – Sep 30, {wy})"
    failures = 0

    for fname, heading, keys in REGIONS:
        print(f"{heading}")
        fig, axes = plt.subplots(len(keys), 1, figsize=(8, 10))
        # Region name is shown in the webpage tab, so no heading on the figure itself
        fig.subplots_adjust(top=0.9, bottom=0.04, left=0.11, right=0.97, hspace=0.6)
        fig.legend(handles=[Line2D([], [], color=CURRENT_LINE, linewidth=6, label=legend_label)],
                   loc="upper center", bbox_to_anchor=(0.54, 0.995), frameon=False, fontsize=13)
        for ax, key in zip(np.atleast_1d(axes), keys):
            try:
                s = summarize(key, today)
                draw_panel(ax, s)
                print(f"  {s['title']}: {s['pct']}% of median (updated {s['updated']})")
            except Exception as err:  # keep going if one station fails
                failures += 1
                draw_error_panel(ax, STATIONS[key]["title"], err)
        fig.savefig(OUT_DIR / f"{fname}.png", dpi=150)
        plt.close(fig)

    stations = {fname: [dict(site=STATIONS[k]["title"], station=STATIONS[k]["station"],
                             url=STATIONS[k]["url"]) for k in keys]
                for fname, _, keys in REGIONS}
    (OUT_DIR / "stations.json").write_text(json.dumps(stations, indent=2) + "\n")

    stamp = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M UTC")
    (OUT_DIR / "last_updated.txt").write_text(stamp + "\n")
    print(f"Done ({failures} station(s) failed). {stamp}")
    # Fail the run only if every station failed (e.g., NRCS is down)
    return 1 if failures == len(STATIONS) else 0


if __name__ == "__main__":
    sys.exit(main())
