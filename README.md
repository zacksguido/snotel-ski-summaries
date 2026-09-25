# SNOTEL Ski Summaries

Daily snow water equivalent (SWE) at NRCS SNOTEL stations near western ski areas, compared with each station's period-of-record median.

- **Website:** https://zacksguido.github.io/snotel-ski-summaries/
- **Script:** `scripts/make_figures.py` (Python port of `SkiMtnPlots2.m`)
- **Schedule:** `.github/workflows/daily.yml` runs the script every day at 7:00 AM Arizona time and commits new figures to `docs/figures/`.
- **Data:** USDA NRCS National Water and Climate Center.

Run locally: `pip install -r requirements.txt && python scripts/make_figures.py`
