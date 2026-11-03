// MAYDAY_REBASE_V1 — two independent HUD groups, not a shared offset.
"use strict";
const defaults = {
  survival: { centerX: 1090, topY: 30 },
  clock:    { centerX: 1430, topY: 30 }
};
const groups = [
  {id: "survival", types: ["HP_SPRITE_HUD", "HP_TILE_HUD", "CORACAO_FANTASMA_HUD", "ENERGIA_SPRITE_HUD", "ENERGIA_TILE_HUD"]},
  {id: "clock", types: ["RELOGIO_HUD", "HUD_CONTADOR_DE_DIAS", "HUD_PALAVRA_DIAS_TXT_FONTE", "HUD_QUANTIDADE_DE_DIAS_FONTE"]}
];
let target = JSON.parse(JSON.stringify(defaults));
let enabled = true, selection = "survival", pending = [], ticks = 0;
function report(name, value) {
  try { globalThis.__mayday32Probe?.(name, value); } catch (_) {}
}
try {
  const saved = JSON.parse(globalThis.localStorage?.getItem("mayday32x9.hud.anchors.v1") || "null");
  if (saved?.survival && saved?.clock &&
      [saved.survival.centerX,saved.survival.topY,saved.clock.centerX,saved.clock.topY].every(Number.isFinite)) {
    target = saved;
  }
} catch (_) {}
function save() {
  try { globalThis.localStorage?.setItem("mayday32x9.hud.anchors.v1", JSON.stringify(target)); } catch (_) {}
}
function undo() {
  for (const r of pending) {
    try {
      if (Math.abs(r.obj.x - (r.x+r.dx)) < 0.2 && Math.abs(r.obj.y - (r.y+r.dy)) < 0.2) {
        r.obj.setPosition(r.x, r.y);
      }
    } catch (_) {}
  }
  pending = [];
}
function collect(runtime, group) {
  const found = [];
  let left=Infinity, right=-Infinity, top=Infinity, bottom=-Infinity;
  for (const name of group.types) {
    const cls = runtime.objects[name];
    if (!cls) continue;
    for (const obj of cls.getAllInstances()) {
      if (obj.layer?.name !== "HUD" || !obj.isVisible || obj.opacity <= 0) continue;
      if (!Number.isFinite(obj.x) || !Number.isFinite(obj.y)) continue;
      let b;
      try { b = obj.getBoundingBox(); } catch (_) { continue; }
      if (![b.left,b.top,b.right,b.bottom].every(Number.isFinite)) continue;
      // Exclude parked/inactive objects, which Construct leaves beyond viewport.
      if (b.right < 400 || b.left > 2200 || b.bottom < -80 || b.top > 210) continue;
      found.push(obj);
      left=Math.min(left,b.left); right=Math.max(right,b.right);
      top=Math.min(top,b.top); bottom=Math.max(bottom,b.bottom);
    }
  }
  return found.length ? {found, left, right, top, bottom} : null;
}
function frame(runtime) {
  undo();
  if (runtime.layout?.name !== "MUNDO" || !runtime.layout.getLayer("HUD")?.isVisible) return;
  ticks++;
  const status = [];
  for (const group of groups) {
    const g = collect(runtime, group);
    if (!g) { status.push(group.id + "=none"); continue; }
    const dX = enabled ? target[group.id].centerX - (g.left+g.right)/2 : 0;
    const dY = enabled ? target[group.id].topY - g.top : 0;
    if (enabled) {
      for (const obj of g.found) {
        const x=obj.x, y=obj.y;
        obj.setPosition(x+dX,y+dY);
        pending.push({obj,x,y,dx:dX,dy:dY});
      }
    }
    status.push(group.id + "=" + g.found.length + " dx="+Math.round(dX)+" dy="+Math.round(dY));
  }
  // MAYDAY_CLOCK_ARROW_FIX_V1: reattach only the clock pointer to the
  // face's original PONTEIRO image point *after* moving the clock HUD.
  // Never include the pointer in HUD bounding-box measurements: its live
  // angle/position is controlled by the game's event sheet.
  if (enabled) {
    try {
      const faces = runtime.objects.RELOGIO_HUD?.getAllInstances() || [];
      const arrows = runtime.objects.PONTEIRO_DO_RELOGIO?.getAllInstances() || [];
      let face = null, best = Infinity;
      for (const item of faces) {
        if (item.layer?.name !== "HUD" || !item.isVisible || item.opacity <= 0) continue;
        if (typeof item.getImagePoint !== "function") continue;
        const dist = Math.abs(item.x - target.clock.centerX);
        if (dist < best) { best = dist; face = item; }
      }
      if (face) {
        const p = face.getImagePoint("PONTEIRO");
        if (Array.isArray(p) && Number.isFinite(p[0]) && Number.isFinite(p[1])) {
          let aligned = 0;
          for (const arrow of arrows) {
            if (arrow.layer?.name !== "HUD" || !arrow.isVisible || arrow.opacity <= 0) continue;
            if (!Number.isFinite(arrow.x) || !Number.isFinite(arrow.y)) continue;
            const x = arrow.x, y = arrow.y;
            const dx = p[0] - x, dy = p[1] - y;
            arrow.setPosition(p[0], p[1]);
            pending.push({obj: arrow, x, y, dx, dy});
            aligned++;
          }
          if (ticks % 120 === 0) report("CLOCK ARROW", "aligned=" + aligned);
        }
      }
    } catch (e) { report("CLOCK ARROW ERROR", String(e)); }
  }


  if (ticks%30===0) report("SEPARATE HUD", status.join(" | ") + " / " + (enabled ? "ON" : "OFF"));
}
function key(ev) {
  const k=ev.key;
  if (k==="F10") {enabled=!enabled; report("SEPARATE HUD", enabled ? "ON":"OFF"); return;}
  // Ctrl+Alt+1 = survival; Ctrl+Alt+2 = clock.
  if (!ev.ctrlKey || !ev.altKey) return;
  if (k==="1") selection="survival";
  else if (k==="2") selection="clock";
  else if (["ArrowLeft","ArrowRight","ArrowUp","ArrowDown"].includes(k)) {
    const step=ev.shiftKey ? 1 : 10;
    if (k==="ArrowLeft") target[selection].centerX-=step;
    if (k==="ArrowRight") target[selection].centerX+=step;
    if (k==="ArrowUp") target[selection].topY-=step;
    if (k==="ArrowDown") target[selection].topY+=step;
    save();
  } else if (k==="0") {target[selection]={...defaults[selection]}; save();}
  else return;
  report("HUD CONTROL", selection+" centerX="+target[selection].centerX+" topY="+target[selection].topY);
}
report("MODULE","Mayday 32:9 rebase v1, independent survival/clock HUD");
if (typeof globalThis.runOnStartup === "function") {
  globalThis.runOnStartup(runtime => {
    runtime.addEventListener("beforeprojectstart", () => {
      runtime.addEventListener("pretick", undo);
      runtime.addEventListener("tick2", () => {try { frame(runtime); } catch(e) {report("ERROR",String(e));}});
      runtime.addEventListener("beforeanylayoutend", undo);
      runtime.addEventListener("keydown", key);
      report("HUD CONTROL", "Ctrl+Alt+1/2 select HUD; Ctrl+Alt+arrows move; Shift=1px; F10 toggle");
    });
  });
} else {
  report("ERROR", "Construct runOnStartup unavailable; no HUD change");
}
