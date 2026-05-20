$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot
$envFile = Join-Path $PSScriptRoot '.env.development'
if (-not (Test-Path -LiteralPath $envFile)) {
  throw "Missing $envFile — run_dev.ps1 must live next to .env.development"
}
flutter run --dart-define-from-file="$envFile" @args
