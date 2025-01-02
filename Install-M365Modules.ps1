<#
.SYNOPSIS
    Installs or updates Microsoft 365 related PowerShell modules with enhanced UI.

.DESCRIPTION
    This script checks for the installation of various Microsoft 365 related PowerShell modules. If a module is not installed,
    the script will automatically install it. If the module is already installed, it checks if an update is available and asks 
    the user whether to update it. The script includes a colorful and structured interface.

.PARAMETER ModuleName
    The name of the PowerShell module to be checked, installed, or updated.

.EXAMPLE
    .\Install-M365Modules.ps1
    This example will run the script, check the status of all listed modules, and then proceed with installation or update based on user input.

.NOTES
    Author: Idan Nadato
    Date: [05/08/2024]
    Version: 1.5

.REQUIREMENTS
    - PowerShell 5.1 or higher
    - Internet access to download and update modules from the PowerShell Gallery

.PERMISSIONS
    Ensure you have permission to install and update modules in the current user's scope.

#>

# Function to display a colorful header
function Show-Header {
    Write-Host "╔════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║                        Microsoft 365 Module Installer              ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
}

# Function to display the menu options in a box
function Show-Menu {
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════════════╗" -ForegroundColor Yellow
    Write-Host "║ Please select which module to install or update:                   ║" -ForegroundColor Yellow
    Write-Host "║ 0. Check for updates for all modules                               ║" -ForegroundColor Yellow
    for ($i = 0; $i -lt $modules.Length; $i++) {
        Write-Host ("║ " + ($i + 1) + ". $($modules[$i])").PadRight(66) + "║" -ForegroundColor Yellow
    }
    Write-Host ("║ " + ($modules.Length + 1) + ". Install all modules").PadRight(66) + "║" -ForegroundColor Yellow
    Write-Host "╚════════════════════════════════════════════════════════════════════╝" -ForegroundColor Yellow
}

# Function to install or update a module
function Install-OrUpdateModule {
    param(
        [string]$ModuleName
    )

    $moduleInstalled = Get-Module -ListAvailable -Name $ModuleName

    if ($moduleInstalled) {
        Write-Host "The module $ModuleName is already installed." -ForegroundColor Cyan
        $updateAvailable = Find-Module -Name $ModuleName | Select-Object -ExpandProperty Version

        if ($updateAvailable -gt $moduleInstalled.Version) {
            $confirmUpdate = Read-Host "An update is available for $ModuleName (Current version: $($moduleInstalled.Version), Available version: $updateAvailable). Would you like to update? (Y/N)"
            if ($confirmUpdate -eq 'Y') {
                Update-Module -Name $ModuleName -Force
                Write-Host "$ModuleName updated successfully!" -ForegroundColor Green
            } else {
                Write-Host "Skipping update for $ModuleName." -ForegroundColor Yellow
            }
        } else {
            Write-Host "$ModuleName is up to date." -ForegroundColor Green
        }
    } else {
        Write-Host "Installing module $ModuleName..." -ForegroundColor Yellow
        Install-Module -Name $ModuleName -Scope CurrentUser -Force -AllowClobber
        Write-Host "$ModuleName installed successfully!" -ForegroundColor Green
    }
}

# Function to check for updates for all modules
function Check-AllUpdates {
    foreach ($module in $modules) {
        Write-Host "Checking for updates for $module..." -ForegroundColor Cyan
        Install-OrUpdateModule -ModuleName $module
    }
}

# List of Microsoft 365 related modules
$modules = @(
    "ExchangeOnlineManagement",    # Exchange Online
    "Microsoft.Graph",             # Microsoft Graph
    "MicrosoftTeams",              # Microsoft Teams
    "SharePointPnPPowerShellOnline", # SharePoint Online (PnP)
    "AzureAD",                     # Azure Active Directory
    "MSOnline",                    # MSOnline module (Legacy Azure AD)
    "Azure",                       # Azure (general)
    "Az",                          # Azure Az module (newer)
    "Microsoft.Online.SharePoint.PowerShell" # SharePoint Online (SPO)
)

# Show header and menu
Show-Header
Show-Menu

$selection = Read-Host "Enter the number of the module you want to install/update or choose the last option to install all"

# Handle user selection
if ($selection -eq 0) {
    # Check for updates for all modules
    Check-AllUpdates
} elseif ($selection -eq ($modules.Length + 1)) {
    # Install or update all modules
    foreach ($module in $modules) {
        Install-OrUpdateModule -ModuleName $module
    }
} elseif ($selection -match '^\d+$' -and $selection -le $modules.Length) {
    # Install or update selected module
    Install-OrUpdateModule -ModuleName $modules[$selection - 1]
} else {
    Write-Host "Invalid selection. Exiting." -ForegroundColor Red
}

Write-Host "Operation completed." -ForegroundColor Cyan
