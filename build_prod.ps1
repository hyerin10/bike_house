# pubspec.yaml이 있는 폴더에서 실행해야 하고, .env.production 경로도 그 기준이어야 합니다.
$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot
$envFile = Join-Path $PSScriptRoot '.env.production'
if (-not (Test-Path -LiteralPath $envFile)) {
  throw "Missing $envFile — build_prod.ps1 must live next to .env.production"
}
flutter build appbundle --release --dart-define-from-file="$envFile" @args

# dart-define가 실제로 넣어졌는지 AAB 안의 libapp.so로 검증 (없으면 Play에 올려도 스플래시에서 동일 증상)
$aab = Join-Path $PSScriptRoot 'build\app\outputs\bundle\release\app-release.aab'
if (-not (Test-Path -LiteralPath $aab)) {
  throw "Expected AAB not found: $aab"
}
$urlLine = Get-Content -LiteralPath $envFile | Where-Object { $_ -match '^\s*SUPABASE_URL\s*=' } | Select-Object -First 1
if (-not ($urlLine -match 'https://([a-z0-9-]+)\.supabase\.co')) {
  throw "SUPABASE_URL must look like https://xxxx.supabase.co — check: $urlLine"
}
$projectRef = $Matches[1]
$py = Get-Command python -ErrorAction SilentlyContinue
if (-not $py) {
  Write-Warning 'python이 PATH에 없어 AAB 검증을 건너뜁니다. 업로드 전 `python`으로 동일 검증을 권장합니다.'
} else {
  & python -c @"
import zipfile, sys
mark = sys.argv[2].encode()
z = zipfile.ZipFile(sys.argv[1])
name = next(x for x in z.namelist() if x.endswith('base/lib/arm64-v8a/libapp.so'))
data = z.read(name)
sys.exit(0 if mark in data else 1)
"@ $aab $projectRef
  if ($LASTEXITCODE -ne 0) {
    throw "AAB verify failed: libapp.so missing Supabase project ref '$projectRef'. Run flutter clean, then re-run this script."
  }
  Write-Host ('OK: AAB contains dart-define host substring: ' + $projectRef)
}
