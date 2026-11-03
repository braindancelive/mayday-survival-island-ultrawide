# Mayday Ultrawide 32:9 — standalone 1.0 with clock pointer fix.
# No dependency on v0.8 or old backup markers. Only patches a validated Construct 3 archive.
# Run in Mayday's installation folder: .\Mayday-32x9-Rebase.ps1
# Check: .\Mayday-32x9-Rebase.ps1 -Check
# Restore ONLY this patch: .\Mayday-32x9-Rebase.ps1 -Restore
[CmdletBinding()]
param([switch]$Check,[switch]$Restore)
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
$root=(Get-Location).Path
$game=Join-Path $root 'package.nw'
$stateFile=Join-Path $root 'Mayday-32x9-Rebase-state.json'
if (!(Test-Path -LiteralPath $game -PathType Leaf)) {throw 'package.nw not found. Run from Mayday game installation folder.'}
function Read-EntryText($entry) {
  $reader=[IO.StreamReader]::new($entry.Open(),[Text.Encoding]::UTF8)
  try { return $reader.ReadToEnd() } finally { $reader.Dispose() }
}
function CurrentHash([string]$p) { return (Get-FileHash -LiteralPath $p -Algorithm SHA256).Hash }
if ($Restore) {
  if (!(Test-Path -LiteralPath $stateFile)) {throw 'No rebase state found; no changes made.'}
  $state=Get-Content -LiteralPath $stateFile -Raw | ConvertFrom-Json
  if (!(Test-Path -LiteralPath $state.backup)) {throw 'The recorded pre-patch backup is missing.'}
  if ((CurrentHash $game) -ne $state.patchedHash) {throw 'package.nw has changed since this patch (possibly Steam updated). Refusing to overwrite the newer version.'}
  Copy-Item -LiteralPath $state.backup -Destination $game -Force
  if ((CurrentHash $game) -ne $state.originalHash) {throw 'Restoration checksum mismatch.'}
  Remove-Item -LiteralPath $stateFile -Force
  Write-Host 'Rebase removed. Pre-patch game archive restored. Backup retained.' -ForegroundColor Green
  return
}

# Self-contained menu/hotbar coordinates from the previously validated Mayday export.
# Refuse version mismatches; never apply stale coordinates to unknown updated layouts.
$ruleData=@'
175|45|205|313|232|31|320||hotbar
176|41|205|312|29|32|320||hotbar
177|41|234|312|29|32|320||hotbar
178|41|263|312|29|32|320||hotbar
180|41|321|312|29|32|320||hotbar
181|41|292|312|29|32|320||hotbar
191|41|350|312|29|32|320||hotbar
192|41|379|312|29|32|320||hotbar
193|41|408|312|29|32|320||hotbar
194|45|142|310|355|41|320||hotbar
195|41|176|312|29|32|320||hotbar
196|41|437|312|29|32|320||hotbar
198|773|151|336|109|23|320||hotbar
203|45|263|313|116|25|320||hotbar
204|41|263|312|29|32|320||hotbar
205|41|321|312|29|32|320||hotbar
206|41|292|312|29|32|320||hotbar
207|41|350|312|29|32|320||hotbar
208|45|142|310|355|41|320||hotbar
209|45|140|313|363|31|320||hotbar
217|41|176|312|29|32|320||hotbar
218|41|205|312|29|32|320||hotbar
219|41|234|312|29|32|320||hotbar
220|41|263|312|29|32|320||hotbar
221|41|321|312|29|32|320||hotbar
222|41|292|312|29|32|320||hotbar
223|41|350|312|29|32|320||hotbar
224|41|379|312|29|32|320||hotbar
225|41|408|312|29|32|320||hotbar
226|41|437|312|29|32|320||hotbar
227|298|60|318|50|60|320||hotbar
228|306|51|326|22|22|320||hotbar
229|45|114|310|413|41|320||hotbar
383|416|320|422|170|109|640||menu
496|456|917|514|86|38|640||menu
497|526|795|447|154|38|640||menu
500|83|367|514|110|34|640||menu
512|453|640|360|752|424|640||menu
514|454|696|226|36|38|640||menu
515|454|894|314|36|38|640||menu
516|454|894|226|36|38|640||menu
517|454|696|314|36|38|640||menu
518|454|894|360|36|38|640||menu
519|454|696|360|36|38|640||menu
520|454|894|272|36|38|640||menu
521|454|696|272|36|38|640||menu
522|456|367|514|86|38|640||menu
523|83|917|514|110|34|640||menu
524|83|795|226|143|28|640||menu
526|83|795|314|143|28|640||menu
527|83|795|360|143|28|640||menu
528|83|795|272|143|28|640||menu
529|83|390|-126|162|34|640||menu
530|454|604|336|36|38|640||menu
531|454|364|336|36|38|640||menu
534|454|894|404|36|38|640||menu
535|454|696|404|36|38|640||menu
536|454|895|448|36|38|640||menu
537|454|696|448|36|38|640||menu
538|454|824|-181|36|38|640||menu
539|454|752|-183|36|38|640||menu
540|83|795|404|143|28|640||menu
541|83|784|-155|143|28|640||menu
542|83|795|447|143|28|640||menu
673|486|775|-59|16|16|640||menu
713|487|640|360|1280|720|640|2560|menu_sky
1066|416|526|422|170|109|640||menu
1069|80|135|495|248|53|640||menu
1070|416|950|422|170|109|640||menu
1071|416|733|422|170|109|640||menu
1072|80|135|554|248|53|640||menu
1073|80|320|422|136|109|640||menu
1082|80|135|672|248|53|640||menu
1083|80|640|370|317|53|640||menu
1084|80|733|422|136|109|640||menu
1085|80|526|422|136|109|640||menu
1087|80|640|430|418.899230957|53|640||menu
1088|80|640|490|323|53|640||menu
1089|80|830|430|317|53|640||menu
1090|80|459|430|240|53|640||menu
1091|80|640|647|323|53|640||menu
1202|359|0|0|930|222|640||menu_logo
1821|80|950|422|136|109|640||menu
4290|597|1218|629|46|46|1280||menu_edge
4291|80|1218|657|99|43|1280||menu_edge
4621|582|81|327|26|30|320||hotbar
4622|80|640|647|323|53|640||menu
4626|80|392|410|256|64|640||menu
4628|80|392|480|256|64|640||menu
4629|80|392|340|256|64|640||menu
4630|587|642|340|86|46|640||menu
4631|80|392|550|256|64|640||menu
4632|587|642|410|86|46|640||menu
4633|587|642|480|86|46|640||menu
4634|587|642|550|86|46|640||menu
4635|587|862|340|86|46|640||menu
4636|587|862|410|86|46|640||menu
4637|587|862|480|86|46|640||menu
4638|587|862|550|86|46|640||menu
4639|80|757|340|256|64|640||menu
4640|80|757|410|256|64|640||menu
4641|80|757|480|256|64|640||menu
4642|80|757|550|256|64|640||menu
5314|41|147|312|29|32|320||hotbar
5370|41|467|312|29|32|320||hotbar
8097|755|1220|705|235|60|1280||menu_edge
9424|80|135|613|248|53|640||menu
9876|199|233|981|593|83|640||menu
9877|198|219|829|543|202|640||menu
9878|200|212|915|637|126|640||menu
9882|492|1268|984|544.8260292164674|210.6197604790419|640||menu
11502|80|640|448|512|64|640||menu
11503|80|440|647|323|53|640||menu
11504|80|640|370.5|665|93|640||menu
11505|201|640|553|1000|83|640||menu
11506|80|840|647|323|53|640||menu
11507|771|452|448|86|46|640||menu
11508|771|828|448|86|46|640||menu
11509|80|640|486|288|53|640||menu
11510|772|640|554|773|36|640||menu
11515|45|179|313|284|25|320||hotbar
11516|41|205|312|29|32|320||hotbar
11517|41|234|312|29|32|320||hotbar
11518|41|263|312|29|32|320||hotbar
11519|41|321|312|29|32|320||hotbar
11520|41|292|312|29|32|320||hotbar
11521|41|350|312|29|32|320||hotbar
11522|41|379|312|29|32|320||hotbar
11523|41|408|312|29|32|320||hotbar
11548|45|142|310|355|41|320||hotbar
'@
function N([string]$s) {return [double]::Parse($s,[Globalization.CultureInfo]::InvariantCulture)}
function F([double]$n) {return $n.ToString('G17',[Globalization.CultureInfo]::InvariantCulture).Replace('E+','e+').Replace('E-','e-')}
function Update-Data([string]$raw) {
  $changes=[System.Collections.Generic.List[object]]::new()
  $script:matchedRules=0
  $seen=[System.Collections.Generic.HashSet[string]]::new()
  foreach($line in ($ruleData -split "`r?`n")) {
    if (!$line.Trim()) {continue}
    $a=$line.Split('|')
    if ($a.Count -ne 9) {throw "Bad embedded rule $line"}
    $type=$a[1];$uid=$a[0];$group=$a[8];$marker=','+$type+','+$uid+','
    $dx=if ($group -eq 'hotbar') {320} elseif ($group -eq 'menu_edge') {1280} elseif ($group -eq 'menu' -and ($uid -in @('1069','1072','1082','9424'))) {1145} else {640}
    $newX=F ((N $a[2])+$dx)
    $newW=if ($a[7]) {$a[7]} else {$a[4]}
    $old='[['+$a[2]+','+$a[3]+',0,'+$a[4]+','+$a[5]+',0,0,'
    $new='[['+$newX+','+$a[3]+',0,'+$newW+','+$a[5]+',0,0,'
    $count=0
    $start=0
    while ($true) {
      $at=$raw.IndexOf($marker,$start,[StringComparison]::Ordinal)
      if ($at -lt 0) {break}
      $p=$raw.LastIndexOf($old,$at,[StringComparison]::Ordinal)
      if ($p -ge 0 -and ($at-$p) -le 900 -and $seen.Add([string]$p)) {
        $changes.Add([pscustomobject]@{Start=$p;Length=$old.Length;Text=$new})
        $count++
      } else {
        $p2=$raw.LastIndexOf($new,$at,[StringComparison]::Ordinal)
        if ($p2 -ge 0 -and ($at-$p2) -le 900) {$count++} # Already patched.
      }
      $start=$at+$marker.Length
    }
    if ($count -eq 0) { throw "Game updated the menu/hotbar objects (UID=$uid, type=$type). No game file changed. Export the updated Mayday-UI-Source.zip so the coordinates can be refreshed." }
    $script:matchedRules++
  }
  $script:patchCount=$changes.Count
  $sb=[Text.StringBuilder]::new($raw.Length+4096)
  $cursor=0
  foreach($e in ($changes | Sort-Object Start)) {
    if ($e.Start -lt $cursor) {throw 'Overlapping Construct UI edits; no changes made.'}
    [void]$sb.Append($raw,$cursor,$e.Start-$cursor)
    [void]$sb.Append($e.Text)
    $cursor=$e.Start+$e.Length
  }
  [void]$sb.Append($raw,$cursor,$raw.Length-$cursor)
  return $sb.ToString()
}

$js=@'
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
'@
$source=$null
try {
  $source=[IO.Compression.ZipFile]::OpenRead($game)
  $dataEntry=$source.GetEntry('data.json')
  $mainEntry=$source.GetEntry('scripts/c3main.js')
  $indexEntry=$source.GetEntry('index.html')
  if (!$dataEntry -or !$mainEntry -or !$indexEntry) {throw 'Unrecognized Mayday export: data.json, c3main.js or index.html missing.'}
  $data=Read-EntryText $dataEntry
  $main=Read-EntryText $mainEntry
  $moduleEntry=$source.GetEntry('scripts/mayday-ultrawide-ui.js')
  $hasMod=$moduleEntry -and ((Read-EntryText $moduleEntry).Contains('MAYDAY_REBASE_V1'))
  $isWide=$data.Contains(',false,2560,720,4,false,"nearest"')
  $isNarrow=$data.Contains(',false,1280,720,4,false,"nearest"')
  if ($Check) {
    Write-Host "Current archive: $game"
    Write-Host "Base viewport: $(if ($isWide) {'2560x720 (32:9)'} elseif ($isNarrow) {'1280x720 (16:9)'} else {'Unknown: game changed'})"
    Write-Host "Rebase module present: $([bool]$hasMod)"
    Write-Host "Old v0.8 backup present: $(Test-Path -LiteralPath (Join-Path $root 'package.nw.pre-hud-v08.bak')) (ignored by this script)"
    if (Test-Path -LiteralPath $stateFile) {Write-Host 'Rebase state exists; restore is checksum-protected.'}
    return
  }
  if ($hasMod -and $isWide) {
    if ($moduleEntry -and ((Read-EntryText $moduleEntry).Contains('MAYDAY_CLOCK_ARROW_FIX_V1'))) {
      Write-Host 'Mayday 32:9 with clock-arrow correction is already installed.' -ForegroundColor Green
    } else {throw 'Earlier rebase detected without clock-arrow fix. Verify game files in Steam, then install standalone release.'}
    return
  }
  if ($moduleEntry) { throw 'Existing nonstandard ultrawide runtime detected. Verify game files through Steam before standalone install.' }
  if (!$isWide -and !$isNarrow) {throw 'Unknown viewport configuration after update; no changes made. Export updated Mayday-UI-Source.zip for inspection.'}
  if (!$main.Contains('import "./objRefTable.js";')) {throw 'Construct startup entry changed in this update; no changes made.'}
  if (!$data.Contains('"MAYDAY","TELA_INICIAL"')) {throw 'Game project signature changed; no changes made.'}
  if ($isNarrow) {
    # Modify ONLY the primary export viewport, not every occurrence of 1280,720.
    $old=',false,1280,720,4,false,"nearest"'
    $new=',false,2560,720,4,false,"nearest"'
    $first=$data.IndexOf($old,[StringComparison]::Ordinal)
    if ($first -lt 0 -or $data.IndexOf($old,$first+$old.Length,[StringComparison]::Ordinal) -ge 0) {throw 'Unexpected count of viewport settings. No changes made.'}
    $data=$data.Replace($old,$new)
  }
  $updatedData=Update-Data $data
  $updatedMain=$main
  $import='import "./mayday-ultrawide-ui.js";'
  if (!$updatedMain.Contains($import)) {$updatedMain += "`r`n$import`r`n"}
  $oldHash=CurrentHash $game
  $stamp=(Get-Date).ToString('yyyyMMdd-HHmmss')
  $backup=Join-Path $root ('package.nw.pre-rebase-'+$stamp+'-'+[Guid]::NewGuid().ToString('N').Substring(0,6)+'.bak')
  $temp=Join-Path $root ('package.nw.rebase-'+[Guid]::NewGuid().ToString('N')+'.tmp')
  $writer=$null
  try {
    $writer=[IO.Compression.ZipFile]::Open($temp,[IO.Compression.ZipArchiveMode]::Create)
    foreach($entry in $source.Entries) {
      $dest=$writer.CreateEntry($entry.FullName,[IO.Compression.CompressionLevel]::Fastest)
      $dest.LastWriteTime=$entry.LastWriteTime
      if ($entry.FullName.EndsWith('/')) {continue}
      $stream=$dest.Open()
      try {
        if ($entry.FullName -eq 'data.json') {$s=$updatedData}
        elseif ($entry.FullName -eq 'scripts/c3main.js') {$s=$updatedMain}
        elseif ($entry.FullName -eq 'scripts/mayday-ultrawide-ui.js') {$s=$js}
        else {$s=$null}
        if ($null -ne $s) {
          $b=[Text.UTF8Encoding]::new($false).GetBytes($s)
          $stream.Write($b,0,$b.Length)
        } else {
          $inputStream=$entry.Open()
          try { $inputStream.CopyTo($stream) } finally { $inputStream.Dispose() }
        }
      } finally { $stream.Dispose() }
    }
    if (!$moduleEntry) {
      $newEntry=$writer.CreateEntry('scripts/mayday-ultrawide-ui.js',[IO.Compression.CompressionLevel]::Optimal)
      $stream=$newEntry.Open()
      try {$b=[Text.UTF8Encoding]::new($false).GetBytes($js); $stream.Write($b,0,$b.Length)} finally {$stream.Dispose()}
    }
    $writer.Dispose();$writer=$null
    $source.Dispose();$source=$null
    $checkZip=[IO.Compression.ZipFile]::OpenRead($temp)
    try {
      $checkData=Read-EntryText ($checkZip.GetEntry('data.json'))
      $checkMain=Read-EntryText ($checkZip.GetEntry('scripts/c3main.js'))
      $checkMod=Read-EntryText ($checkZip.GetEntry('scripts/mayday-ultrawide-ui.js'))
      if (!$checkData.Contains(',false,2560,720,4,false,"nearest"') -or !$checkMain.Contains($import) -or (!$checkMod.Contains('MAYDAY_REBASE_V1') -or !$checkMod.Contains('MAYDAY_CLOCK_ARROW_FIX_V1'))) {throw 'Rebuilt archive verification failed.'}
      if ($checkZip.Entries.Count -lt 8) {throw 'Rebuilt archive unexpectedly small.'}
    } finally {$checkZip.Dispose()}
    [IO.File]::Replace($temp,$game,$backup)
  } catch {
    if ($writer) {$writer.Dispose()}
    if (Test-Path -LiteralPath $temp) {Remove-Item -LiteralPath $temp -Force}
    throw
  }
  if (Test-Path -LiteralPath $stateFile) {
    $oldState=Join-Path $root ('Mayday-32x9-Rebase-state.old-'+$stamp+'.json')
    Move-Item -LiteralPath $stateFile -Destination $oldState -Force
  }
  $state=@{backup=$backup;originalHash=$oldHash;patchedHash=(CurrentHash $game);installedAt=(Get-Date).ToString('o');gamePath=$game}
  $state | ConvertTo-Json | Set-Content -LiteralPath $stateFile -Encoding UTF8
  Write-Host 'Mayday 32:9 standalone installed, including clock-arrow fix.' -ForegroundColor Green
  Write-Host "Menu/hotbar matched UI objects: $script:matchedRules (changed layout instances: $script:patchCount)."
  Write-Host 'Survival/Hunger and Clock/Day are independent anchors, not one HUD offset.'
  Write-Host 'Ctrl+Alt+1: survival; Ctrl+Alt+2: clock; Ctrl+Alt+arrows: move selected anchor; add Shift for 1px.'
  Write-Host 'F10 toggles the new HUD positioning. Your old v0.8 backups have NOT been used.'
  Write-Host "Current-version backup: $backup"
  Write-Host 'To restore this rebase safely: .\Mayday-32x9-Rebase.ps1 -Restore'
} finally { if ($source) {$source.Dispose()} }