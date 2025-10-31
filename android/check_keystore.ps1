# PowerShell script to check keystore fingerprints
# Run this script to identify which keystore has the correct SHA1 fingerprint

Write-Host "Checking keystore fingerprints..." -ForegroundColor Cyan
Write-Host ""

# Find keytool in common locations
$keytoolPaths = @(
    "$env:JAVA_HOME\bin\keytool.exe",
    "$env:ANDROID_HOME\jre\bin\keytool.exe",
    "C:\Program Files\Java\*\bin\keytool.exe",
    "C:\Program Files (x86)\Java\*\bin\keytool.exe"
)

$keytool = $null
foreach ($path in $keytoolPaths) {
    $found = Get-Command keytool -ErrorAction SilentlyContinue
    if ($found) {
        $keytool = "keytool"
        break
    }
}

if (-not $keytool) {
    Write-Host "ERROR: keytool not found in PATH" -ForegroundColor Red
    Write-Host "Please add Java JDK to PATH or specify keytool path manually" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "To find keytool manually:" -ForegroundColor Yellow
    Write-Host "1. Find your JDK installation (usually in Program Files\Java\jdk-XX\bin\)" -ForegroundColor Yellow
    Write-Host "2. Run: `"C:\Path\To\Java\bin\keytool.exe`" -list -v -keystore captain-delivery-keystore.jks -storepass Captain123! -alias captain-release" -ForegroundColor Yellow
    exit 1
}

Write-Host "Checking captain-delivery-keystore.jks..." -ForegroundColor Green
& $keytool -list -v -keystore captain-delivery-keystore.jks -storepass Captain123! -alias captain-release | Select-String -Pattern "SHA1:"

Write-Host ""
Write-Host "Checking Food-shala-keystore.jks..." -ForegroundColor Green
# Try to find alias for Food-shala keystore
& $keytool -list -keystore Food-shala-keystore.jks -storepass Captain123! 2>$null | Out-String
Write-Host ""
Write-Host "To see full details, run:" -ForegroundColor Yellow
Write-Host "keytool -list -v -keystore Food-shala-keystore.jks -storepass Captain123!" -ForegroundColor Yellow

Write-Host ""
Write-Host "Expected SHA1: 7F:BC:B0:C8:55:57:59:38:7F:B1:1B:D9:B5:11:92:AD:F0:DE:4E:96" -ForegroundColor Cyan

