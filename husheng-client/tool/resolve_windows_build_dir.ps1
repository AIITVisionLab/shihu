param(
  [Parameter(Mandatory = $true)]
  [ValidateSet("x64", "arm64")]
  [string]$PreferredArchitecture
)

$ErrorActionPreference = "Stop"

function Get-PeBinaryArchitecture {
  param(
    [Parameter(Mandatory = $true)]
    [string]$BinaryPath
  )

  $stream = [System.IO.File]::Open($BinaryPath, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
  try {
    $reader = New-Object System.IO.BinaryReader($stream)
    $stream.Seek(0x3C, [System.IO.SeekOrigin]::Begin) | Out-Null
    $peHeaderOffset = $reader.ReadInt32()
    $stream.Seek($peHeaderOffset + 4, [System.IO.SeekOrigin]::Begin) | Out-Null
    $machine = $reader.ReadUInt16()
  } finally {
    $stream.Dispose()
  }

  switch ($machine) {
    0x8664 { return "x64" }
    0xAA64 { return "arm64" }
    default { return ("unknown-0x{0:X4}" -f $machine) }
  }
}

$workspaceRoot = (Get-Location).ProviderPath
$windowsBuildRoot = Join-Path $workspaceRoot "build/windows"
$candidateDirs = [System.Collections.Generic.List[string]]::new()

$candidateDirs.Add((Join-Path $windowsBuildRoot "$PreferredArchitecture/runner/Release"))
$candidateDirs.Add((Join-Path $windowsBuildRoot "runner/Release"))

if (Test-Path -LiteralPath $windowsBuildRoot) {
  Get-ChildItem -LiteralPath $windowsBuildRoot -Directory | ForEach-Object {
    $candidateDirs.Add((Join-Path $_.FullName "runner/Release"))
  }
}

$resolvedBuildDir = $null
$resolvedBinaryArch = $null

foreach ($candidateDir in ($candidateDirs | Select-Object -Unique)) {
  $exePath = Join-Path $candidateDir "husheng.exe"
  if (-not (Test-Path -LiteralPath $exePath)) {
    continue
  }

  $resolvedBuildDir = (Resolve-Path -LiteralPath $candidateDir).ProviderPath
  $resolvedBinaryArch = Get-PeBinaryArchitecture -BinaryPath $exePath
  break
}

if (-not $resolvedBuildDir) {
  throw "未找到可用的 Windows Release 目录。已检查: $($candidateDirs -join ', ')"
}

$archMatches = $resolvedBinaryArch -eq $PreferredArchitecture

Write-Host "Resolved Windows build dir: $resolvedBuildDir"
Write-Host "Resolved binary arch: $resolvedBinaryArch"

if (-not $archMatches) {
  Write-Warning "当前产物架构与预期不一致。预期: $PreferredArchitecture，实际: $resolvedBinaryArch"
}

if ($env:GITHUB_OUTPUT) {
  "build_dir=$resolvedBuildDir" | Out-File -FilePath $env:GITHUB_OUTPUT -Encoding utf8 -Append
  "binary_arch=$resolvedBinaryArch" | Out-File -FilePath $env:GITHUB_OUTPUT -Encoding utf8 -Append
  "arch_matches=$($archMatches.ToString().ToLowerInvariant())" | Out-File -FilePath $env:GITHUB_OUTPUT -Encoding utf8 -Append
}
