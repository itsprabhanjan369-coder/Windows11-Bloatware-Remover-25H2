# Debloat-Windows.ps1
# Removes bloatware apps while preserving Store, Terminal, PowerShell, Core Utilities, and Media Codecs.
# Run as Administrator

# 1. List of app names to KEEP
$appsToKeep = @(
    # --- Store, App Installer, & Core Frameworks ---
    "Microsoft.WindowsStore",
    "Microsoft.StorePurchaseApp",
    "Microsoft.Services.Store.Engagement",
    "Microsoft.DesktopAppInstaller",
    "MicrosoftCorporationII.WinAppRuntime.Main.1.8",

    # --- Terminal & PowerShell ---
    "Microsoft.WindowsTerminal",
    "Microsoft.PowerShell",

    # --- Essential Utilities & Security ---
    "Microsoft.WindowsNotepad",
    "Microsoft.ScreenSketch",       # Snipping Tool
    "Microsoft.WindowsCalculator",
    "Microsoft.Windows.Photos",
    "Microsoft.Paint",
    "Microsoft.WindowsCamera",
    "Microsoft.SecHealthUI",         # Windows Security (Defender Dashboard)

    # --- Media Codecs & Image Extensions ---
    "Microsoft.HEIFImageExtension",
    "Microsoft.HEVCVideoExtension",
    "Microsoft.VP9VideoExtensions",
    "Microsoft.AV1VideoExtension",
    "Microsoft.WebpImageExtension",
    "Microsoft.RawImageExtension"
)

Write-Host "`n=== Removing Provisioned Apps (for all future users) ===`n" -ForegroundColor Cyan

# Remove provisioned apps (for new users)
Get-AppxProvisionedPackage -Online | ForEach-Object {
    if ($appsToKeep -notcontains $_.DisplayName) {
        Write-Host "Removing provisioned app: $($_.DisplayName)" -ForegroundColor Yellow
        Remove-AppxProvisionedPackage -Online -PackageName $_.PackageName -ErrorAction SilentlyContinue
    } else {
        Write-Host "Keeping provisioned app: $($_.DisplayName)" -ForegroundColor Green
    }
}

Write-Host "`n=== Removing Apps for Current User ===`n" -ForegroundColor Cyan

# Remove installed apps for current user
Get-AppxPackage | ForEach-Object {
    # Dynamically detect and protect system/framework dependencies (CRITICAL for Store functionality)
    $isFramework = $_.IsFramework
    $isSystem = $_.SignatureKind -eq "System" -or $_.NonRemovable -eq $true

    if ($isFramework -or $isSystem) {
        Write-Host "Keeping System/Framework Dependency: $($_.Name)" -ForegroundColor DarkGray
    }
    elseif ($appsToKeep -notcontains $_.Name) {
        Write-Host "Removing current user app: $($_.Name)" -ForegroundColor Yellow
        Remove-AppxPackage -Package $_.PackageFullName -ErrorAction SilentlyContinue
    } else {
        Write-Host "Keeping user app: $($_.Name)" -ForegroundColor Green
    }
}

Write-Host "`n✅ Debloating Complete!" -ForegroundColor Green
