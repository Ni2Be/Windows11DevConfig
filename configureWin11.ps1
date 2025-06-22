# Windows 11 Development Configuration Wizard
# This script helps configure Windows 11 for development with an interactive wizard

# Exit if not running as administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Start the script with administrator privileges." -ForegroundColor Red
    exit 1
}

# Function to get Yes/No choice with Y as default
function Get-YesNoChoice {
    param(
        [string]$Question
    )
    
    do {
        $response = Read-Host "$Question (Y/n - defaults to Y)"
        if ([string]::IsNullOrWhiteSpace($response)) {
            $response = "Y"
        }
        $response = $response.ToUpper()
    } while ($response -ne "Y" -and $response -ne "N")
    
    return $response -eq "Y"
}

# Function to show file extensions
function Set-ShowFileExtensions {
    try {
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0
        Write-Host "✓ File extensions will now be shown" -ForegroundColor Green
    }
    catch {
        Write-Host "✗ Failed to configure file extensions: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Function to show hidden files
function Set-ShowHiddenFiles {
    try {
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Value 1
        Write-Host "✓ Hidden files and folders will now be shown" -ForegroundColor Green
    }
    catch {
        Write-Host "✗ Failed to configure hidden files: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Function to show full path in title bar
function Set-ShowFullPath {
    try {
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState" -Name "FullPath" -Value 1 -Force
        Write-Host "✓ Full file paths will be shown in title bar" -ForegroundColor Green
    }
    catch {
        Write-Host "✗ Failed to configure full path display: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Function to enable expanded context menu
function Set-ExpandedContextMenu {
    try {
        New-Item -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" -Force | Out-Null
        New-Item -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" -Force | Out-Null
        Set-ItemProperty -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" -Name "(Default)" -Value ""
        Write-Host "✓ Expanded context menu enabled (restart Explorer to take effect)" -ForegroundColor Green
    }
    catch {
        Write-Host "✗ Failed to configure expanded context menu: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Function to add PowerShell to context menu
function Add-PowerShellContextMenu {
    try {
        # Add "Open PowerShell here" to folder context menu
        New-Item -Path "HKCU:\Software\Classes\Directory\shell\OpenPowerShellHere" -Force | Out-Null
        Set-ItemProperty -Path "HKCU:\Software\Classes\Directory\shell\OpenPowerShellHere" -Name "(Default)" -Value "Open PowerShell here"
        Set-ItemProperty -Path "HKCU:\Software\Classes\Directory\shell\OpenPowerShellHere" -Name "Icon" -Value "powershell.exe"
        New-Item -Path "HKCU:\Software\Classes\Directory\shell\OpenPowerShellHere\command" -Force | Out-Null
        Set-ItemProperty -Path "HKCU:\Software\Classes\Directory\shell\OpenPowerShellHere\command" -Name "(Default)" -Value 'powershell.exe -NoExit -Command "Set-Location -Path \"%V\""'
        
        # Add "Open PowerShell here (Admin)" to folder context menu
        New-Item -Path "HKCU:\Software\Classes\Directory\shell\OpenPowerShellAsAdmin" -Force | Out-Null
        Set-ItemProperty -Path "HKCU:\Software\Classes\Directory\shell\OpenPowerShellAsAdmin" -Name "(Default)" -Value "Open PowerShell here (Admin)"
        Set-ItemProperty -Path "HKCU:\Software\Classes\Directory\shell\OpenPowerShellAsAdmin" -Name "Icon" -Value "powershell.exe"
        Set-ItemProperty -Path "HKCU:\Software\Classes\Directory\shell\OpenPowerShellAsAdmin" -Name "HasLUAShield" -Value ""
        New-Item -Path "HKCU:\Software\Classes\Directory\shell\OpenPowerShellAsAdmin\command" -Force | Out-Null
        Set-ItemProperty -Path "HKCU:\Software\Classes\Directory\shell\OpenPowerShellAsAdmin\command" -Name "(Default)" -Value 'powershell.exe -Command "Start-Process powershell.exe -ArgumentList ''-NoExit'', ''-Command'', ''Set-Location -Path \"\"%V\"\"'' -Verb RunAs"'
        
        # Add "Open PowerShell here" to background context menu
        New-Item -Path "HKCU:\Software\Classes\Directory\Background\shell\OpenPowerShellHere" -Force | Out-Null
        Set-ItemProperty -Path "HKCU:\Software\Classes\Directory\Background\shell\OpenPowerShellHere" -Name "(Default)" -Value "Open PowerShell here"
        Set-ItemProperty -Path "HKCU:\Software\Classes\Directory\Background\shell\OpenPowerShellHere" -Name "Icon" -Value "powershell.exe"
        New-Item -Path "HKCU:\Software\Classes\Directory\Background\shell\OpenPowerShellHere\command" -Force | Out-Null
        Set-ItemProperty -Path "HKCU:\Software\Classes\Directory\Background\shell\OpenPowerShellHere\command" -Name "(Default)" -Value 'powershell.exe -NoExit -Command "Set-Location -Path \"%V\""'
        
        # Add "Open PowerShell here (Admin)" to background context menu
        New-Item -Path "HKCU:\Software\Classes\Directory\Background\shell\OpenPowerShellAsAdmin" -Force | Out-Null
        Set-ItemProperty -Path "HKCU:\Software\Classes\Directory\Background\shell\OpenPowerShellAsAdmin" -Name "(Default)" -Value "Open PowerShell here (Admin)"
        Set-ItemProperty -Path "HKCU:\Software\Classes\Directory\Background\shell\OpenPowerShellAsAdmin" -Name "Icon" -Value "powershell.exe"
        Set-ItemProperty -Path "HKCU:\Software\Classes\Directory\Background\shell\OpenPowerShellAsAdmin" -Name "HasLUAShield" -Value ""
        New-Item -Path "HKCU:\Software\Classes\Directory\Background\shell\OpenPowerShellAsAdmin\command" -Force | Out-Null
        Set-ItemProperty -Path "HKCU:\Software\Classes\Directory\Background\shell\OpenPowerShellAsAdmin\command" -Name "(Default)" -Value 'powershell.exe -Command "Start-Process powershell.exe -ArgumentList ''-NoExit'', ''-Command'', ''Set-Location -Path \"\"%V\"\"'' -Verb RunAs"'
        
        Write-Host "✓ PowerShell context menu options added (regular and admin)" -ForegroundColor Green
    }
    catch {
        Write-Host "✗ Failed to add PowerShell context menu: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Function to configure taskbar
function Set-TaskbarConfiguration {
    try {
        # Left-align taskbar
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAl" -Value 0
        
        Write-Host "✓ Taskbar configured (left-aligned)" -ForegroundColor Green
        Write-Host "  Note: You may need to restart Explorer or sign out/in for changes to take effect" -ForegroundColor Gray
    }
    catch {
        Write-Host "✗ Failed to configure taskbar: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Function to disable Bing search in Start menu
function Disable-BingSearch {
    try {
        # Disable Bing search in Start menu
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Value 0 -Force
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "CortanaConsent" -Value 0 -Force
        
        # Additional registry keys for comprehensive Bing search disable
        if (!(Test-Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer")) {
            New-Item -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Force | Out-Null
        }
        Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Name "DisableSearchBoxSuggestions" -Value 1 -Force
        
        Write-Host "✓ Bing web search disabled in Start menu" -ForegroundColor Green
    }
    catch {
        Write-Host "✗ Failed to disable Bing search: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Function to restart Explorer
function Restart-Explorer {
    try {
        Write-Host "Restarting Windows Explorer to apply changes..." -ForegroundColor Yellow
        Stop-Process -Name "explorer" -Force
        Start-Sleep -Seconds 2
        Start-Process "explorer.exe"
        Write-Host "✓ Explorer restarted" -ForegroundColor Green
    }
    catch {
        Write-Host "✗ Failed to restart Explorer: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Please manually restart Explorer or sign out/in to see all changes" -ForegroundColor Yellow
    }
}

# Function to install PowerToys
function Install-PowerToys {
    try {
        Write-Host "Checking for PowerToys installation..." -ForegroundColor Yellow
        
        # Check if winget is available
        if (Get-Command winget -ErrorAction SilentlyContinue) {
            Write-Host "Installing PowerToys via winget..." -ForegroundColor Yellow
            winget install --id Microsoft.PowerToys --source winget --accept-package-agreements --accept-source-agreements
            Write-Host "✓ PowerToys installation completed" -ForegroundColor Green
        } else {
            Write-Host "Winget not found. Opening PowerToys download page..." -ForegroundColor Yellow
            Start-Process "https://github.com/microsoft/PowerToys/releases"
            Write-Host "✓ PowerToys download page opened in browser" -ForegroundColor Green
        }
    }
    catch {
        Write-Host "✗ Failed to install PowerToys: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "You can manually download PowerToys from: https://github.com/microsoft/PowerToys/releases" -ForegroundColor Yellow
    }
}

# Main script execution
Clear-Host
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "    Windows 11 Development Configuration Wizard" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "This wizard will help you configure Windows 11 for development." -ForegroundColor Green
Write-Host "Please answer the following questions:" -ForegroundColor Green
Write-Host ""

# Initialize configuration object
$config = @{}

# Ask configuration questions
$config.ShowFileExtensions = Get-YesNoChoice "1. Show file extensions in File Explorer?"
$config.ShowHiddenFiles = Get-YesNoChoice "2. Show hidden files and folders?"
$config.ShowFullPath = Get-YesNoChoice "3. Show full file paths in File Explorer title bar?"
$config.EnableExpandedContextMenu = Get-YesNoChoice "4. Always show expanded right-click context menu (disable 'Show more options')?"
$config.AddPowerShellContextMenu = Get-YesNoChoice "5. Add 'Open with PowerShell' options to right-click context menu?"
$config.ConfigureTaskbar = Get-YesNoChoice "6. Configure taskbar (left-align)?"
$config.DisableBingSearch = Get-YesNoChoice "7. Disable Bing web results in Start menu search (local results only)?"
$config.InstallPowerToys = Get-YesNoChoice "8. Install Microsoft PowerToys (essential productivity utilities)?"

Write-Host ""
Write-Host "Configuration Summary:" -ForegroundColor Yellow
Write-Host "- File extensions: $(if($config.ShowFileExtensions){'Show'}else{'Keep current'})"
Write-Host "- Hidden files: $(if($config.ShowHiddenFiles){'Show'}else{'Keep current'})"
Write-Host "- Full path: $(if($config.ShowFullPath){'Show'}else{'Keep current'})"
Write-Host "- Expanded context menu: $(if($config.EnableExpandedContextMenu){'Enable'}else{'Keep current'})"
Write-Host "- PowerShell context menu: $(if($config.AddPowerShellContextMenu){'Add'}else{'Keep current'})"
Write-Host "- Taskbar configuration: $(if($config.ConfigureTaskbar){'Configure'}else{'Keep current'})"
Write-Host "- Disable Bing search: $(if($config.DisableBingSearch){'Yes'}else{'Keep current'})"
Write-Host "- Install PowerToys: $(if($config.InstallPowerToys){'Yes'}else{'No'})"
Write-Host ""

$proceed = Get-YesNoChoice "Do you want to proceed with these changes?"

if ($proceed) {
    Write-Host ""
    Write-Host "Applying configuration changes..." -ForegroundColor Green
    Write-Host ""
    
    # Apply configurations based on user choices
    if ($config.ShowFileExtensions) { Set-ShowFileExtensions }
    if ($config.ShowHiddenFiles) { Set-ShowHiddenFiles }
    if ($config.ShowFullPath) { Set-ShowFullPath }
    if ($config.EnableExpandedContextMenu) { Set-ExpandedContextMenu }
    if ($config.AddPowerShellContextMenu) { Add-PowerShellContextMenu }
    if ($config.ConfigureTaskbar) { Set-TaskbarConfiguration }
    if ($config.DisableBingSearch) { Disable-BingSearch }
    if ($config.InstallPowerToys) { Install-PowerToys }
    
    Write-Host ""
    Write-Host "Configuration completed!" -ForegroundColor Green
    
    # Ask if user wants to restart Explorer
    if ($config.ShowFileExtensions -or $config.ShowHiddenFiles -or $config.ShowFullPath -or $config.ConfigureTaskbar) {
        Write-Host ""
        $restartExplorer = Get-YesNoChoice "Some changes require Explorer restart. Restart now?"
        if ($restartExplorer) {
            Restart-Explorer
        }
    }
    
    Write-Host ""
    Write-Host "All done! Your Windows 11 system has been configured for development." -ForegroundColor Green
    Write-Host "You may need to sign out and sign back in to see all changes take effect." -ForegroundColor Yellow
}
else {
    Write-Host ""
    Write-Host "Configuration cancelled. No changes were made." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')