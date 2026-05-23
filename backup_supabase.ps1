# Supabase Backup Script - main(production) / dev(development)

$TIMESTAMP = Get-Date -Format "yyyyMMdd_HHmmss"
$ROOT_DIR   = $PSScriptRoot
$BACKUP_DIR = Join-Path $ROOT_DIR "supabase_backups"

function Get-SupabaseRefFromEnv {
    param([string]$EnvFile)

    $path = Join-Path $ROOT_DIR $EnvFile
    if (-not (Test-Path $path)) {
        throw "Env file not found: $path"
    }

    $urlLine = Get-Content $path | Where-Object {
        $_ -match '^\s*SUPABASE_URL\s*=\s*https?://'
    } | Select-Object -First 1

    if (-not $urlLine) {
        throw "SUPABASE_URL not found in $EnvFile"
    }

    if ($urlLine -match 'https?://([^.]+)\.supabase\.co') {
        return $Matches[1]
    }

    throw "Could not parse project ref from SUPABASE_URL in $EnvFile"
}

$MAIN_REF = Get-SupabaseRefFromEnv ".env.production"
$DEV_REF  = Get-SupabaseRefFromEnv ".env.development"

$SecurePass = Read-Host "DB Password" -AsSecureString
$DB_PASS    = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
                  [Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePass)
              )

$ENVS = @(
    [PSCustomObject]@{ Name = "main"; Ref = $MAIN_REF },
    [PSCustomObject]@{ Name = "dev";  Ref = $DEV_REF  }
)

foreach ($e in $ENVS) {
    $d = Join-Path $BACKUP_DIR $e.Name
    if (-not (Test-Path $d)) {
        New-Item -ItemType Directory -Force -Path $d | Out-Null
    }
    Write-Host "[INFO] Folder ready: $d" -ForegroundColor Cyan
}

function Invoke-Dump {
    param(
        [string]$Label,
        [string]$OutFile,
        [string[]]$Extra
    )
    Write-Host "`n[DUMP] $Label" -ForegroundColor Yellow
    Write-Host "       -> $OutFile"
    $argList = @("db","dump","--linked","--password",$DB_PASS,"--file",$OutFile) + $Extra
    & supabase @argList
    if ($LASTEXITCODE -eq 0) {
        if (Test-Path $OutFile) {
            $kb = [math]::Round((Get-Item $OutFile).Length / 1KB, 1)
            Write-Host "[OK]   $Label done ($kb KB)" -ForegroundColor Green
        } else {
            Write-Host "[WARN] File not created." -ForegroundColor Yellow
        }
    } else {
        Write-Host "[ERROR] Dump failed (exit $LASTEXITCODE)" -ForegroundColor Red
    }
}

foreach ($e in $ENVS) {
    $name = $e.Name
    $ref  = $e.Ref
    $dir  = Join-Path $BACKUP_DIR $name

    Write-Host "`n===========================================" -ForegroundColor Magenta
    Write-Host " ENV: $($name.ToUpper())  (ref: $ref)" -ForegroundColor Magenta
    Write-Host " Timestamp: $TIMESTAMP" -ForegroundColor Magenta
    Write-Host "===========================================" -ForegroundColor Magenta

    Write-Host "`n[LINK] Linking $name project..." -ForegroundColor Cyan
    & supabase link --project-ref $ref --password $DB_PASS
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[ERROR] Link failed for $name — skipping." -ForegroundColor Red
        continue
    }

    Invoke-Dump -Label "$name - Schema" `
        -OutFile (Join-Path $dir ($name + "_schema_" + $TIMESTAMP + ".sql")) `
        -Extra @()

    Invoke-Dump -Label "$name - Data" `
        -OutFile (Join-Path $dir ($name + "_data_" + $TIMESTAMP + ".sql")) `
        -Extra @("--data-only")

    Invoke-Dump -Label "$name - Roles" `
        -OutFile (Join-Path $dir ($name + "_roles_" + $TIMESTAMP + ".sql")) `
        -Extra @("--role-only")
}

Write-Host "`n===========================================" -ForegroundColor Cyan
Write-Host " All backups completed!" -ForegroundColor Cyan
Write-Host " Location: $BACKUP_DIR" -ForegroundColor Cyan
Write-Host "===========================================" -ForegroundColor Cyan

Get-ChildItem -Recurse $BACKUP_DIR -Filter "*.sql" |
    Select-Object FullName, @{Name="KB"; Expression={[math]::Round($_.Length/1KB,1)}} |
    Format-Table -AutoSize
