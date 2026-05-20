$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot
$envFile = Join-Path $PSScriptRoot '.env.production'
if (-not (Test-Path -LiteralPath $envFile)) {
  throw "Missing $envFile — run_prod.ps1 must live next to .env.production"
}
flutter run --dart-define-from-file="$envFile" @args
