// Shared SWE chart drawing for the Snow charts and Archive pages.
// Draws: shaded median of other seasons, a thick main-year line, optional
// comparison lines, and a hover/touch crosshair with a tooltip.
(function () {
  const TICKS = [[0, "Oct1"], [31, "Nov1"], [61, "Dec1"], [92, "Jan1"], [123, "Feb1"], [152, "Mar1"], [183, "Apr1"],
                 [213, "May1"], [244, "Jun1"], [274, "Jul1"], [305, "Aug1"], [336, "Sep1"], [365, "Sep30"]];
  const MONTHS = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
  const FEB29 = 151, APR1 = 183;
  const BLUE = "#2171b5";
  const COMPARE_COLORS = ["#eb6834", "#1baf7a", "#eda100", "#e87ba4", "#4a3aa7"];   // fixed order

  const isLeap = y => (y % 4 === 0 && y % 100 !== 0) || y % 400 === 0;

  // Calendar date for day i (0 = Oct 1) of water year wy
  function dayDate(i, wy) {
    const d = new Date(Date.UTC(1999, 9, 1 + i));        // template water year 1999-2000 includes Feb 29
    return { m: d.getUTCMonth(), d: d.getUTCDate(), y: d.getUTCMonth() >= 9 ? wy - 1 : wy };
  }
  const fmt = (i, wy, withYear = true) => {
    const t = dayDate(i, wy);
    return `${MONTHS[t.m]} ${t.d}` + (withYear ? `, ${t.y}` : "");
  };

  function median(arr) {
    const v = arr.filter(x => x != null).sort((a, b) => a - b);
    if (!v.length) return null;
    const m = v.length >> 1;
    return v.length % 2 ? v[m] : (v[m - 1] + v[m]) / 2;
  }

  // One season's series. In non-leap years the Feb 29 slot holds the Feb 28 / Mar 1 average
  // (filled by the daily script) so lines don't break; the tooltip skips that day.
  function series(data, wy) {
    const s = data.years[wy];
    return s ? s.slice() : null;
  }

  // Day-by-day median over the given seasons
  function medianOf(data, years) {
    return Array.from({ length: 366 }, (_, i) => median(years.map(y => data.years[y][i])));
  }

  const f1 = v => v == null ? "—" : v.toFixed(1) + " in";
  const esc = s => String(s).replace(/[&<>"]/g, c => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" }[c]));

  // opts: { med, main: {label, s}, compares: [{label, s, color}], wy, height, markIdx, nowIdx, ariaLabel }
  function render(card, opts) {
    const W = 800, H = opts.height || 380, M = { l: 56, r: 16, t: 14, b: 40 };
    const { med, main, compares = [], wy } = opts;
    const all = [...med, ...main.s, ...compares.flatMap(c => c.s)].filter(v => v != null);
    const maxV = Math.max(1, ...all) * 1.05;
    const step = [1, 2, 5, 10, 20, 25, 50].find(s => maxV / s <= 5) || 100;
    const top = Math.ceil(maxV / step) * step;
    const x = i => M.l + (i / 365) * (W - M.l - M.r);
    const y = v => H - M.b - (v / top) * (H - M.t - M.b);
    const path = s => {
      let d = "", pen = false;
      s.forEach((v, i) => { if (v == null) { pen = false; return; } d += (pen ? "L" : "M") + x(i).toFixed(1) + "," + y(v).toFixed(1); pen = true; });
      return d;
    };
    let area = `M${x(0)},${y(0)}`;
    med.forEach((v, i) => { area += `L${x(i).toFixed(1)},${y(v ?? 0).toFixed(1)}`; });
    area += `L${x(365)},${y(0)}Z`;

    let g = "";
    for (const [i] of TICKS) g += `<line x1="${x(i)}" x2="${x(i)}" y1="${M.t}" y2="${H - M.b}" stroke="#e3e6ea"/>`;
    for (let v = 0; v <= top; v += step) g += `<text x="${M.l - 8}" y="${y(v) + 4}" text-anchor="end" font-size="12" fill="#1f2328">${v}</text>`;
    for (const [i, lab] of TICKS) g += `<text x="${x(i)}" y="${H - M.b + 18}" text-anchor="middle" font-size="12" fill="#1f2328">${lab}</text>`;
    g += `<text transform="translate(16 ${(H - M.b + M.t) / 2}) rotate(-90)" text-anchor="middle" font-size="13" fill="#1f2328">SWE (inches)</text>`;
    g += `<path d="${area}" fill="#deebf7"/><path d="${path(med)}" fill="none" stroke="#1f2328" stroke-width="1"/>`;
    if (opts.nowIdx != null && opts.nowIdx >= 0) {
      g += `<line x1="${x(opts.nowIdx)}" x2="${x(opts.nowIdx)}" y1="${M.t}" y2="${H - M.b}" stroke="#662506" stroke-width="1.2" stroke-dasharray="4 3"/>`;
    }
    for (const c of compares) g += `<path d="${path(c.s)}" fill="none" stroke="${c.color}" stroke-width="2.5" stroke-linejoin="round"/>`;
    g += `<path d="${path(main.s)}" fill="none" stroke="${BLUE}" stroke-width="4" stroke-linejoin="round" stroke-linecap="round"/>`;
    if (opts.markIdx != null && main.s[opts.markIdx] != null) {
      g += `<circle cx="${x(opts.markIdx)}" cy="${y(main.s[opts.markIdx])}" r="5" fill="#fff" stroke="#662506" stroke-width="2"/>`;
    }
    g += `<rect x="${M.l}" y="${M.t}" width="${W - M.l - M.r}" height="${H - M.t - M.b}" fill="none" stroke="#1f2328"/>`;
    g += `<g class="hv" style="display:none"><line class="hl" y1="${M.t}" y2="${H - M.b}" stroke="#57606a" stroke-dasharray="3 3"/>` +
         compares.map((c, k) => `<circle class="hc${k}" r="4" fill="${c.color}" stroke="#fff" stroke-width="2"/>`).join("") +
         `<circle class="hm" r="4" fill="#fff" stroke="#1f2328" stroke-width="1.5"/><circle class="hs" r="5" fill="${BLUE}" stroke="#fff" stroke-width="2"/></g>`;
    g += `<rect class="hit" x="${M.l}" y="${M.t}" width="${W - M.l - M.r}" height="${H - M.t - M.b}" fill="transparent"/>`;

    let svg = card.querySelector("svg.swe"), tip = card.querySelector(".swe-tip");
    if (!svg) {
      svg = document.createElementNS("http://www.w3.org/2000/svg", "svg");
      svg.setAttribute("class", "swe");
      svg.setAttribute("role", "img");
      card.appendChild(svg);
    }
    if (!tip) { tip = document.createElement("div"); tip.className = "swe-tip"; card.appendChild(tip); }
    svg.setAttribute("viewBox", `0 0 ${W} ${H}`);
    svg.setAttribute("aria-label", opts.ariaLabel || "Snow water equivalent chart");
    svg.innerHTML = g;

    const hover = svg.querySelector(".hv");
    const move = ev => {
      const pt = ev.touches ? ev.touches[0] : ev;
      const r = svg.getBoundingClientRect();
      let i = Math.round(((pt.clientX - r.left) * W / r.width - M.l) / (W - M.l - M.r) * 365);
      i = Math.max(0, Math.min(365, i));
      if (i === FEB29 && !isLeap(Number(wy))) i = 150;
      hover.style.display = "";
      const hl = svg.querySelector(".hl"); hl.setAttribute("x1", x(i)); hl.setAttribute("x2", x(i));
      const place = (sel, v) => { const c = svg.querySelector(sel); if (v == null) c.style.display = "none"; else { c.style.display = ""; c.setAttribute("cx", x(i)); c.setAttribute("cy", y(v)); } };
      place(".hs", main.s[i]); place(".hm", med[i]); compares.forEach((c, k) => place(".hc" + k, c.s[i]));
      const pct = v => (v != null && med[i] > 0) ? ` (${Math.round(v / med[i] * 100)}%)` : "";
      let h = `<b>${fmt(i, Number(wy), false)}</b><i style="background:${BLUE}"></i>${esc(main.label)}: ${f1(main.s[i])}${pct(main.s[i])}`;
      for (const c of compares) h += `<br><i style="background:${c.color}"></i>${esc(c.label)}: ${f1(c.s[i])}${pct(c.s[i])}`;
      h += `<br><i style="background:#9ecae1"></i>Median: ${f1(med[i])}`;
      tip.innerHTML = h; tip.style.display = "block";
      const cr = card.getBoundingClientRect();
      const px = r.left - cr.left + x(i) * r.width / W;
      tip.style.left = (px + 14 + tip.offsetWidth > cr.width ? px - 14 - tip.offsetWidth : px + 14) + "px";
      tip.style.top = (r.top - cr.top + 24) + "px";
    };
    const leave = () => { hover.style.display = "none"; tip.style.display = "none"; };
    const hit = svg.querySelector(".hit");
    hit.addEventListener("mousemove", move); hit.addEventListener("mouseleave", leave);
    hit.addEventListener("touchstart", move, { passive: true }); hit.addEventListener("touchmove", move, { passive: true });
  }

  window.SWE = { render, series, medianOf, median, fmt, isLeap, f1, esc, BLUE, COMPARE_COLORS, FEB29, APR1, MONTHS };
})();
