# Windows game-folder detection and launcher
[CmdletBinding()]
param([ValidateSet('Install','Check','Uninstall')][string]$Action='Install')
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Windows.Forms
$scriptFile=Join-Path $PSScriptRoot 'src\Mayday-Ultrawide.ps1'
if (!(Test-Path -LiteralPath $scriptFile)) {throw 'Missing src\Mayday-Ultrawide.ps1. Extract the entire ZIP.'}
$path=$null
$common=@()
foreach($drive in [IO.DriveInfo]::GetDrives() | Where-Object {$_.IsReady -and $_.DriveType -eq 'Fixed'}) {
  $common+=Join-Path $drive.RootDirectory.FullName 'SteamLibrary\steamapps\common\Mayday The Survival Island'
  $common+=Join-Path $drive.RootDirectory.FullName 'Program Files (x86)\Steam\steamapps\common\Mayday The Survival Island'
}
foreach($dir in $common) {if(Test-Path (Join-Path $dir 'package.nw')) {$path=$dir;break}}
if (!$path) {
  $dialog=New-Object System.Windows.Forms.FolderBrowserDialog
  $dialog.Description='Select Mayday The Survival Island game folder (contains package.nw)'
  $dialog.ShowNewFolderButton=$false
  if($dialog.ShowDialog() -ne [System.Windows.Forms.DialogResult]::OK) {Write-Host 'Cancelled.'; return}
  $path=$dialog.SelectedPath
}
if (!(Test-Path -LiteralPath (Join-Path $path 'package.nw'))) {throw "No package.nw found in: $path"}
Write-Host "Game folder: $path" -ForegroundColor Cyan
Push-Location $path
try {
  if ($Action -eq 'Check') {& $scriptFile -Check}
  elseif ($Action -eq 'Uninstall') {& $scriptFile -Restore}
  else {& $scriptFile}
} finally {Pop-Location}
