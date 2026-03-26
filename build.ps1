# Videoader Windows Build Script
# Requires: Visual Studio 2026 with C++ toolchain

param(
    [switch]$Clean
)

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Videoader Windows Build Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Set Flutter toolchain path for Visual Studio 2026
$env:FCMK_GCC = "D:\Microsoft Visual Studio\18\Community\VC\Tools\MSVC\14.50.35717\bin\Hostx64\x64"

# Navigate to project root
Set-Location "D:\videoder_demo"

# Clean if requested
if ($Clean) {
    Write-Host "`nCleaning build artifacts..." -ForegroundColor Yellow
    flutter clean
}

# Get dependencies
Write-Host "`nFetching dependencies..." -ForegroundColor Green
flutter pub get

# Build
Write-Host "`nBuilding Windows release..." -ForegroundColor Green
flutter build windows --release

# Check result
if ($LASTEXITCODE -eq 0) {
    Write-Host "`n========================================" -ForegroundColor Green
    Write-Host "  Build Successful!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "`nOutput location:" -ForegroundColor Cyan
    Write-Host "  build\windows\x64\runner\Release\" -ForegroundColor White
    Write-Host "`nFiles generated:" -ForegroundColor Cyan
    Get-ChildItem -Path "build\windows\x64\runner\Release" -File | ForEach-Object {
        Write-Host "  - $($_.Name) ($([math]::Round($_.Length / 1MB, 2)) MB)" -ForegroundColor White
    }
} else {
    Write-Host "`n========================================" -ForegroundColor Red
    Write-Host "  Build Failed!" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    exit 1
}
