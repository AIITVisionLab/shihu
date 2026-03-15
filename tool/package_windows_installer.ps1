param(
  [Parameter(Mandatory = $true)]
  [string]$BuildDir,

  [Parameter(Mandatory = $true)]
  [string]$OutputFile,

  [Parameter(Mandatory = $true)]
  [string]$Version,

  [Parameter(Mandatory = $true)]
  [ValidateSet("x64", "arm64")]
  [string]$Architecture
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $BuildDir)) {
  throw "BuildDir not found: $BuildDir"
}

$buildDirPath = (Resolve-Path -LiteralPath $BuildDir).ProviderPath
$outputFilePath = [System.IO.Path]::GetFullPath($OutputFile)

$isccPath = $null
$candidates = @(
  "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe",
  "${env:ProgramFiles}\Inno Setup 6\ISCC.exe"
)

foreach ($candidate in $candidates) {
  if (Test-Path -LiteralPath $candidate) {
    $isccPath = $candidate
    break
  }
}

if (-not $isccPath) {
  $command = Get-Command ISCC.exe -ErrorAction SilentlyContinue
  if ($command) {
    $isccPath = $command.Source
  }
}

if (-not $isccPath) {
  throw "ISCC.exe not found."
}

$workDir = Join-Path ([System.IO.Path]::GetTempPath()) ("husheng-installer-" + [System.Guid]::NewGuid().ToString("N"))
$stageDir = Join-Path $workDir "app"
$scriptPath = Join-Path $workDir "installer.iss"

New-Item -ItemType Directory -Force -Path $stageDir | Out-Null
Copy-Item -Recurse -Force (Join-Path $buildDirPath '*') $stageDir

$outputDir = Split-Path -Parent $outputFilePath
$outputBase = [System.IO.Path]::GetFileNameWithoutExtension($outputFilePath)
New-Item -ItemType Directory -Force -Path $outputDir | Out-Null

$appId = if ($Architecture -eq "arm64") {
  "{{9F05A93F-76F5-47AA-BB7E-8F0E27A6B862}"
} else {
  "{{5D33FFB0-0318-4A71-8A5D-53F6D1D99B9E}"
}

$allowedArch = if ($Architecture -eq "arm64") { "arm64" } else { "x64compatible" }
$installArch = if ($Architecture -eq "arm64") { "arm64" } else { "x64compatible" }

$iss = @"
[Setup]
AppId=$appId
AppName=斛生
AppVersion=$Version
AppPublisher=AIITVisionLab
DefaultDirName={autopf}\斛生
DefaultGroupName=斛生
DisableProgramGroupPage=yes
OutputDir=$outputDir
OutputBaseFilename=$outputBase
Compression=lzma
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=$allowedArch
ArchitecturesInstallIn64BitMode=$installArch
UninstallDisplayIcon={app}\sickandflutter.exe

[Languages]
Name: "chinesesimp"; MessagesFile: "compiler:Languages\ChineseSimplified.isl"

[Tasks]
Name: "desktopicon"; Description: "创建桌面快捷方式"; GroupDescription: "附加任务:"

[Files]
Source: "$stageDir\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\斛生"; Filename: "{app}\sickandflutter.exe"
Name: "{autodesktop}\斛生"; Filename: "{app}\sickandflutter.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\sickandflutter.exe"; Description: "启动斛生"; Flags: nowait postinstall skipifsilent
"@

Set-Content -LiteralPath $scriptPath -Value $iss -Encoding utf8BOM
& $isccPath $scriptPath | Out-Host

if ($LASTEXITCODE -ne 0) {
  throw "Inno Setup compile failed with exit code $LASTEXITCODE"
}

if (-not (Test-Path -LiteralPath $outputFilePath)) {
  throw "Installer not generated: $outputFilePath"
}
