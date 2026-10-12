// Browser side of the UI preview: lays out a dumped Roblox GUI tree the way
// Roblox does (UDim2 + AnchorPoint, UIListLayout, UIGridLayout, UIPadding,
// UIScale, size constraints) and draws it with HTML/CSS (UICorner, UIStroke,
// UIGradient, scaled text with stroke, images).

const SCREEN = { w: 1920, h: 1080, inset: 58 };
const GUI = new Set(['Frame', 'TextLabel', 'TextButton', 'TextBox', 'ImageLabel', 'ImageButton', 'ScrollingFrame', 'ViewportFrame', 'CanvasGroup']);
const TEXT = new Set(['TextLabel', 'TextButton', 'TextBox']);
const IMAGE = new Set(['ImageLabel', 'ImageButton']);

const P = (n, k, d) => (n.p[k] === undefined ? d : n.p[k]);
const ud2 = (n, k, d) => (n.p[k] ? n.p[k].v : d);
const child = (n, cls) => n.k.find((c) => c.c === cls && P(c, 'Enabled', true) !== false);
const rgb = (c, a = 1) => `rgba(${Math.round(c[0] * 255)},${Math.round(c[1] * 255)},${Math.round(c[2] * 255)},${a})`;
const col = (n, k, d) => (n.p[k] ? n.p[k].v : d);

function fontFamily(name) {
  if (!name) return '"Fredoka One"';
  if (/Fredoka/.test(name)) return '"Fredoka One", "Noto Color Emoji"';
  if (/Gotham|Montserrat/.test(name)) return '"DejaVu Sans", "Noto Color Emoji"';
  return '"Liberation Sans", "DejaVu Sans", "Noto Color Emoji"';
}
function fontWeight(name) {
  return /Bold|Black|Heavy|Fredoka/.test(name || '') ? 700 : 400;
}

function escapeHtml(s) {
  return s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
}
function richText(s) {
  let h = escapeHtml(s);
  h = h.replace(/&lt;br\s*\/?&gt;/g, '<br>');
  h = h.replace(/&lt;b&gt;/g, '<b>').replace(/&lt;\/b&gt;/g, '</b>');
  h = h.replace(/&lt;i&gt;/g, '<i>').replace(/&lt;\/i&gt;/g, '</i>');
  h = h.replace(/&lt;font ([^&]*)&gt;/g, (_, attrs) => {
    let style = '';
    const c = attrs.match(/color="([^"]+)"/);
    if (c) style += `color:${c[1]};`;
    const z = attrs.match(/size="(\d+)"/);
    if (z) style += `font-size:${z[1]}px;`;
    return `<span style="${style}">`;
  });
  h = h.replace(/&lt;\/font&gt;/g, '</span>');
  h = h.replace(/&lt;stroke[^&]*&gt;|&lt;\/stroke&gt;/g, '');
  return h;
}
function displayText(n) {
  const raw = String(P(n, 'Text', '')).replace(//g, '⏣');
  return P(n, 'RichText', false) ? richText(raw) : escapeHtml(raw).replace(/\n/g, '<br>');
}

// ---------- layout ----------
// Content extent of a frame whose children are stacked by a UIListLayout
// (for AutomaticSize).
function listContent(n, w, h) {
  const list = child(n, 'UIListLayout');
  if (!list) return null;
  const vertical = P(list, 'FillDirection', 'Vertical') === 'Vertical';
  const [pl, pt, pr, pb] = padding(n, w, h);
  const kids = visibleGuiChildren(n);
  const pad = list.p.Padding ? list.p.Padding.v[1] : 0;
  let main = 0;
  let cross = 0;
  for (const c of kids) {
    const [cw, ch] = sizeOf(c, w - pl - pr, h - pt - pb);
    main += vertical ? ch : cw;
    cross = Math.max(cross, vertical ? cw : ch);
  }
  main += pad * Math.max(kids.length - 1, 0);
  return vertical ? [cross + pl + pr, main + pt + pb] : [main + pl + pr, cross + pt + pb];
}

function sizeOf(n, pw, ph) {
  const s = ud2(n, 'Size', [0, 100, 0, 100]);
  let w = pw * s[0] + s[1];
  let h = ph * s[2] + s[3];
  const auto = P(n, 'AutomaticSize', 'None');
  if (auto !== 'None' && n.c !== 'ScrollingFrame') {
    const content = listContent(n, w, h);
    if (content) {
      if (auto === 'Y' || auto === 'XY') h = Math.max(h, content[1]);
      if (auto === 'X' || auto === 'XY') w = Math.max(w, content[0]);
    }
  }
  const sc = child(n, 'UISizeConstraint');
  if (sc) {
    const mn = col(sc, 'MinSize', [0, 0]);
    const mx = col(sc, 'MaxSize', [1e9, 1e9]);
    w = Math.min(Math.max(w, mn[0]), mx[0]);
    h = Math.min(Math.max(h, mn[1]), mx[1]);
  }
  const ar = child(n, 'UIAspectRatioConstraint');
  if (ar) {
    const r = P(ar, 'AspectRatio', 1);
    const dom = P(ar, 'DominantAxis', 'Width');
    if (P(ar, 'AspectType', 'FitWithinMaxSize') === 'ScaleWithParentSize') {
      if (dom === 'Width') h = w / r; else w = h * r;
    } else {
      if (w / h > r) w = h * r; else h = w / r;
    }
  }
  return [Math.max(w, 0), Math.max(h, 0)];
}

function padding(n, w, h) {
  const p = child(n, 'UIPadding');
  if (!p) return [0, 0, 0, 0];
  const u = (k, base) => (p.p[k] ? p.p[k].v[0] * base + p.p[k].v[1] : 0);
  return [u('PaddingLeft', w), u('PaddingTop', h), u('PaddingRight', w), u('PaddingBottom', h)];
}

function visibleGuiChildren(n) {
  return n.k.filter((c) => GUI.has(c.c) && P(c, 'Visible', true));
}

// Returns [{node, x, y, w, h}] for children inside a content box.
function layoutChildren(n, cw, ch) {
  const kids = visibleGuiChildren(n);
  const list = child(n, 'UIListLayout');
  const grid = child(n, 'UIGridLayout');
  const sorted = (arr) => arr.map((c, i) => [c, i]).sort((a, b) => (P(a[0], 'LayoutOrder', 0) - P(b[0], 'LayoutOrder', 0)) || (P(list || grid, 'SortOrder', 'LayoutOrder') === 'Name' ? a[0].n.localeCompare(b[0].n) : a[1] - b[1])).map((x) => x[0]);
  if (list) {
    const vertical = P(list, 'FillDirection', 'Vertical') === 'Vertical';
    const pad = list.p.Padding ? list.p.Padding.v[0] * (vertical ? ch : cw) + list.p.Padding.v[1] : 0;
    const items = sorted(kids).map((c) => ({ node: c, size: sizeOf(c, cw, ch) }));
    const total = items.reduce((s, it) => s + (vertical ? it.size[1] : it.size[0]), 0) + pad * Math.max(items.length - 1, 0);
    const mainAlign = vertical ? P(list, 'VerticalAlignment', 'Top') : P(list, 'HorizontalAlignment', 'Left');
    const crossAlign = vertical ? P(list, 'HorizontalAlignment', 'Left') : P(list, 'VerticalAlignment', 'Top');
    const mainSpace = vertical ? ch : cw;
    let cursor = mainAlign === 'Center' ? (mainSpace - total) / 2 : (mainAlign === 'Bottom' || mainAlign === 'Right') ? mainSpace - total : 0;
    const out = [];
    for (const it of items) {
      const [w, h] = it.size;
      const crossSpace = vertical ? cw : ch;
      const crossSize = vertical ? w : h;
      const cross = crossAlign === 'Center' ? (crossSpace - crossSize) / 2 : (crossAlign === 'Right' || crossAlign === 'Bottom') ? crossSpace - crossSize : 0;
      out.push(vertical ? { node: it.node, x: cross, y: cursor, w, h } : { node: it.node, x: cursor, y: cross, w, h });
      cursor += (vertical ? h : w) + pad;
    }
    return { items: out, content: total };
  }
  if (grid) {
    const cell = ud2(grid, 'CellSize', [0, 100, 0, 100]);
    const cp = ud2(grid, 'CellPadding', [0, 5, 0, 5]);
    const w = cw * cell[0] + cell[1];
    const h = ch * cell[2] + cell[3];
    const px = cw * cp[0] + cp[1];
    const py = ch * cp[2] + cp[3];
    const horizontal = P(grid, 'FillDirection', 'Horizontal') === 'Horizontal';
    const maxCells = P(grid, 'FillDirectionMaxCells', 0);
    let perLine = horizontal ? Math.max(1, Math.floor((cw + px) / (w + px))) : Math.max(1, Math.floor((ch + py) / (h + py)));
    if (maxCells > 0) perLine = Math.min(perLine, maxCells);
    const items = sorted(kids);
    const lines = Math.ceil(items.length / perLine);
    const cols = horizontal ? Math.min(perLine, items.length) : lines;
    const rows = horizontal ? lines : Math.min(perLine, items.length);
    const blockW = cols * w + Math.max(cols - 1, 0) * px;
    const blockH = rows * h + Math.max(rows - 1, 0) * py;
    const ha = P(grid, 'HorizontalAlignment', 'Left');
    const va = P(grid, 'VerticalAlignment', 'Top');
    const ox = ha === 'Center' ? (cw - blockW) / 2 : ha === 'Right' ? cw - blockW : 0;
    const oy = va === 'Center' ? (ch - blockH) / 2 : va === 'Bottom' ? ch - blockH : 0;
    const out = items.map((c, i) => {
      const a = i % perLine;
      const b = Math.floor(i / perLine);
      const col_ = horizontal ? a : b;
      const row = horizontal ? b : a;
      return { node: c, x: ox + col_ * (w + px), y: oy + row * (h + py), w, h };
    });
    return { items: out, content: horizontal ? blockH : blockW };
  }
  return {
    items: kids.map((c) => {
      const [w, h] = sizeOf(c, cw, ch);
      const pos = ud2(c, 'Position', [0, 0, 0, 0]);
      const anchor = col(c, 'AnchorPoint', [0, 0]);
      return { node: c, x: cw * pos[0] + pos[1] - anchor[0] * w, y: ch * pos[2] + pos[3] - anchor[1] * h, w, h };
    }),
    content: 0,
  };
}

// ---------- drawing ----------
function gradientCss(n, baseColor, baseAlpha) {
  const g = child(n, 'UIGradient');
  if (!g) return null;
  const colors = g.p.Color ? g.p.Color.v : [[0, 1, 1, 1], [1, 1, 1, 1]];
  const trans = g.p.Transparency ? g.p.Transparency.v : [[0, 0], [1, 0]];
  const times = [...new Set([...colors.map((k) => k[0]), ...trans.map((k) => k[0])])].sort((a, b) => a - b);
  const sample = (keys, t, len) => {
    for (let i = 0; i < keys.length - 1; i++) {
      if (t >= keys[i][0] && t <= keys[i + 1][0]) {
        const f = (t - keys[i][0]) / Math.max(keys[i + 1][0] - keys[i][0], 1e-9);
        return keys[i].slice(1).map((v, j) => v + (keys[i + 1][j + 1] - v) * f);
      }
    }
    return keys[keys.length - 1].slice(1, 1 + len);
  };
  const off = (g.p.Offset ? g.p.Offset.v : [0, 0]);
  const stops = times.map((t) => {
    const c = sample(colors, t, 3);
    const tr = sample(trans, t, 1)[0];
    const mixed = [c[0] * baseColor[0], c[1] * baseColor[1], c[2] * baseColor[2]];
    return `${rgb(mixed, baseAlpha * (1 - tr))} ${((t + off[0]) * 100).toFixed(1)}%`;
  });
  return `linear-gradient(${90 + P(g, 'Rotation', 0)}deg, ${stops.join(', ')})`;
}

function strokeShadow(thickness, color) {
  const steps = 16;
  const parts = [];
  for (let i = 0; i < steps; i++) {
    const a = (i / steps) * Math.PI * 2;
    parts.push(`${(Math.cos(a) * thickness).toFixed(2)}px ${(Math.sin(a) * thickness).toFixed(2)}px 0 ${color}`);
  }
  for (let i = 0; i < steps; i++) {
    const a = (i / steps) * Math.PI * 2;
    parts.push(`${(Math.cos(a) * thickness * 0.5).toFixed(2)}px ${(Math.sin(a) * thickness * 0.5).toFixed(2)}px 0 ${color}`);
  }
  return parts.join(', ');
}

const scaledTexts = [];

function drawNode(n, box, parentEl) {
  const el = document.createElement('div');
  el.dataset.name = n.n;
  el.style.position = 'absolute';
  el.style.left = `${box.x}px`;
  el.style.top = `${box.y}px`;
  el.style.width = `${box.w}px`;
  el.style.height = `${box.h}px`;
  el.style.zIndex = String(P(n, 'ZIndex', 1));
  const anchor = col(n, 'AnchorPoint', [0, 0]);
  const transforms = [];
  const scale = child(n, 'UIScale');
  if (scale && P(scale, 'Scale', 1) !== 1) transforms.push(`scale(${P(scale, 'Scale', 1)})`);
  if (P(n, 'Rotation', 0)) transforms.push(`rotate(${P(n, 'Rotation', 0)}deg)`);
  if (transforms.length) {
    el.style.transform = transforms.join(' ');
    el.style.transformOrigin = `${anchor[0] * 100}% ${anchor[1] * 100}%`;
  }

  const bgT = P(n, 'BackgroundTransparency', 0);
  const bg = col(n, 'BackgroundColor3', [0.64, 0.64, 0.65]);
  const grad = gradientCss(n, bg, 1 - bgT);
  if (bgT < 1) el.style.background = grad || rgb(bg, 1 - bgT);
  const corner = child(n, 'UICorner');
  let radius = 0;
  if (corner) {
    const r = corner.p.CornerRadius ? corner.p.CornerRadius.v : [0, 8];
    radius = Math.min(r[0] * Math.min(box.w, box.h) + r[1], Math.min(box.w, box.h) / 2);
    el.style.borderRadius = `${radius}px`;
  }
  if (P(n, 'BorderSizePixel', 0) > 0 && bgT < 1 && !corner) {
    el.style.boxShadow = `inset 0 0 0 ${P(n, 'BorderSizePixel', 1)}px ${rgb(col(n, 'BorderColor3', [0.1, 0.16, 0.2]), 1 - bgT)}`;
  }
  const stroke = child(n, 'UIStroke');
  const isText = TEXT.has(n.c);
  const textStroke = stroke && isText && P(stroke, 'ApplyStrokeMode', 'Contextual') !== 'Border';
  if (stroke && !textStroke) {
    const t = P(stroke, 'Thickness', 1);
    const sc = rgb(col(stroke, 'Color', [0, 0, 0]), 1 - P(stroke, 'Transparency', 0));
    el.style.boxShadow = `0 0 0 ${t}px ${sc}` + (el.style.boxShadow ? `, ${el.style.boxShadow}` : '');
  }
  if (P(n, 'ClipsDescendants', false) || n.c === 'ScrollingFrame') el.style.overflow = 'hidden';

  if (IMAGE.has(n.c)) {
    const image = String(P(n, 'Image', ''));
    const id = (image.match(/(\d{3,})/) || [])[1];
    const local = image.startsWith('local:') ? window.ASSETS[image] : null;
    const info = local || (id && window.ASSETS[id]);
    const url = info && info.url;
    if (url) {
      const img = document.createElement('div');
      img.style.position = 'absolute';
      img.style.inset = '0';
      img.style.borderRadius = el.style.borderRadius;
      img.style.opacity = String(1 - P(n, 'ImageTransparency', 0));
      const tint = col(n, 'ImageColor3', [1, 1, 1]);
      const type = P(n, 'ScaleType', 'Stretch');
      let size = '100% 100%';
      let repeat = 'no-repeat';
      if (type === 'Fit') size = 'contain';
      if (type === 'Crop') size = 'cover';
      if (type === 'Tile') {
        const ts = ud2(n, 'TileSize', [1, 0, 1, 0]);
        size = `${box.w * ts[0] + ts[1]}px ${box.h * ts[2] + ts[3]}px`;
        repeat = 'repeat';
      }
      const tinted = tint.some((v) => v < 0.999);
      const rs = n.p.ImageRectSize ? n.p.ImageRectSize.v : [0, 0];
      let position = 'center';
      if (rs[0] > 0 && rs[1] > 0) {
        // Sprite sheet: show only the ImageRect, fitted like ScaleType says.
        const ro = n.p.ImageRectOffset ? n.p.ImageRectOffset.v : [0, 0];
        let sx = box.w / rs[0];
        let sy = box.h / rs[1];
        if (type === 'Fit') sx = sy = Math.min(sx, sy);
        if (type === 'Crop') sx = sy = Math.max(sx, sy);
        const dx = (box.w - rs[0] * sx) / 2;
        const dy = (box.h - rs[1] * sy) / 2;
        size = `${info.w * sx}px ${info.h * sy}px`;
        position = `${dx - ro[0] * sx}px ${dy - ro[1] * sy}px`;
        img.style.clipPath = `inset(${dy}px ${dx}px ${dy}px ${dx}px)`;
      }
      if (type === 'Slice') {
        const sc = n.p.SliceCenter ? n.p.SliceCenter.v : [0, 0, 0, 0];
        const ss = P(n, 'SliceScale', 1);
        img.style.borderStyle = 'solid';
        img.style.borderWidth = `${sc[1] * ss}px ${sc[0] * ss}px ${sc[1] * ss}px ${sc[0] * ss}px`;
        img.style.borderImage = `url("${url}") ${sc[1]} ${sc[0]} fill / ${sc[1] * ss}px ${sc[0] * ss}px stretch`;
      } else if (tinted) {
        img.style.background = rgb(tint);
        img.style.webkitMask = `url("${url}") ${position}/${size} ${repeat}`;
      } else {
        img.style.background = `url("${url}") ${position}/${size} ${repeat}`;
        if (type === 'Tile') img.style.backgroundPosition = '0 0';
      }
      const g = child(n, 'UIGradient');
      if (g && bgT >= 1) {
        img.style.background = gradientCss(n, tint, 1);
        img.style.webkitMask = `url("${url}") center/${size} ${repeat}`;
      }
      el.appendChild(img);
    }
  }

  if (n.c === 'ViewportFrame') {
    el.style.background = el.style.background || 'radial-gradient(circle, rgba(255,255,255,0.35), rgba(255,255,255,0) 70%)';
  }

  if (isText && String(P(n, 'Text', '')) !== '') {
    const [pl, pt, pr, pb] = padding(n, box.w, box.h);
    const holder = document.createElement('div');
    holder.style.position = 'absolute';
    holder.style.left = `${pl}px`;
    holder.style.top = `${pt}px`;
    holder.style.width = `${box.w - pl - pr}px`;
    holder.style.height = `${box.h - pt - pb}px`;
    holder.style.display = 'flex';
    holder.style.zIndex = '1';
    const xa = P(n, 'TextXAlignment', 'Center');
    const ya = P(n, 'TextYAlignment', 'Center');
    holder.style.justifyContent = xa === 'Left' ? 'flex-start' : xa === 'Right' ? 'flex-end' : 'center';
    holder.style.alignItems = ya === 'Top' ? 'flex-start' : ya === 'Bottom' ? 'flex-end' : 'center';
    const span = document.createElement('span');
    span.innerHTML = displayText(n);
    const font = P(n, 'Font', 'Legacy');
    span.style.fontFamily = fontFamily(font);
    span.style.fontWeight = String(fontWeight(font));
    span.style.lineHeight = String(P(n, 'LineHeight', 1) * 1.05);
    span.style.textAlign = xa === 'Left' ? 'left' : xa === 'Right' ? 'right' : 'center';
    span.style.whiteSpace = P(n, 'TextWrapped', false) ? 'normal' : 'nowrap';
    span.style.overflowWrap = 'break-word';
    const tc = col(n, 'TextColor3', [0.1, 0.16, 0.2]);
    span.style.color = rgb(tc, 1 - P(n, 'TextTransparency', 0));
    let strokeCss = null;
    if (textStroke) {
      // Roblox fades a text's stroke along with the text.
      const alpha = (1 - P(stroke, 'Transparency', 0)) * (1 - P(n, 'TextTransparency', 0));
      strokeCss = { t: P(stroke, 'Thickness', 1), c: rgb(col(stroke, 'Color', [0, 0, 0]), alpha) };
    } else if (P(n, 'TextStrokeTransparency', 1) < 1) {
      strokeCss = { t: 1, c: rgb(col(n, 'TextStrokeColor3', [0, 0, 0]), 1 - P(n, 'TextStrokeTransparency', 1)) };
    }
    if (strokeCss) span.dataset.stroke = JSON.stringify(strokeCss);
    const g = child(n, 'UIGradient');
    if (g && bgT >= 1) span.dataset.gradient = gradientCss(n, tc, 1 - P(n, 'TextTransparency', 0));
    holder.appendChild(span);
    el.appendChild(holder);
    const tsc = child(n, 'UITextSizeConstraint');
    scaledTexts.push({ span, holder, scaled: P(n, 'TextScaled', false), size: P(n, 'TextSize', 14), max: tsc ? P(tsc, 'MaxTextSize', 100) : 100, min: tsc ? P(tsc, 'MinTextSize', 1) : 1 });
  }

  parentEl.appendChild(el);
  // Children: inside padding; ScrollingFrame uses its canvas size.
  const [pl, pt, pr, pb] = padding(n, box.w, box.h);
  let cw = box.w - pl - pr;
  let ch = box.h - pt - pb;
  if (n.c === 'ScrollingFrame' && n.p.CanvasSize) {
    const c = n.p.CanvasSize.v;
    cw = Math.max(cw, box.w * c[0] + c[1]);
    ch = Math.max(ch, box.h * c[2] + c[3]);
  }
  for (const it of layoutChildren(n, cw, ch).items) {
    drawNode(it.node, { x: it.x + pl, y: it.y + pt, w: it.w, h: it.h }, el);
  }
}

function fitText() {
  for (const t of scaledTexts) {
    const s = t.span;
    const W = t.holder.clientWidth;
    const H = t.holder.clientHeight;
    if (t.scaled) {
      let lo = t.min;
      let hi = Math.min(t.max, 100);
      s.style.fontSize = `${hi}px`;
      while (hi - lo > 0.5) {
        const mid = (lo + hi) / 2;
        s.style.fontSize = `${mid}px`;
        if (s.scrollWidth <= W + 0.5 && s.offsetHeight <= H + 0.5) lo = mid; else hi = mid;
      }
      s.style.fontSize = `${lo}px`;
    } else {
      s.style.fontSize = `${t.size}px`;
    }
    if (s.dataset.stroke) {
      const st = JSON.parse(s.dataset.stroke);
      s.style.textShadow = strokeShadow(st.t, st.c);
    }
    if (s.dataset.gradient) {
      // Stroke copy underneath, gradient-filled copy on top.
      const top = s.cloneNode(true);
      top.style.textShadow = 'none';
      top.style.background = s.dataset.gradient;
      top.style.webkitBackgroundClip = 'text';
      top.style.color = 'transparent';
      top.style.position = 'absolute';
      const holderRect = t.holder.getBoundingClientRect();
      const r = s.getBoundingClientRect();
      top.style.left = `${r.left - holderRect.left}px`;
      top.style.top = `${r.top - holderRect.top}px`;
      top.style.width = `${r.width}px`;
      t.holder.appendChild(top);
    }
  }
}

window.renderTree = function (tree) {
  const root = document.getElementById('root');
  const guis = tree.k.filter((g) => g.c === 'ScreenGui' && P(g, 'Enabled', true));
  guis.sort((a, b) => P(a, 'DisplayOrder', 0) - P(b, 'DisplayOrder', 0));
  for (const g of guis) {
    const inset = P(g, 'IgnoreGuiInset', false) ? 0 : SCREEN.inset;
    const layer = document.createElement('div');
    layer.dataset.name = g.n;
    layer.style.position = 'absolute';
    layer.style.left = '0';
    layer.style.top = `${inset}px`;
    layer.style.width = `${SCREEN.w}px`;
    layer.style.height = `${SCREEN.h - inset}px`;
    root.appendChild(layer);
    for (const it of layoutChildren(g, SCREEN.w, SCREEN.h - inset).items) {
      drawNode(it.node, it, layer);
    }
  }
  fitText();
};
