<#
.SYNOPSIS
    Install SentinelOne agent on Windows.

.DESCRIPTION
    This script downloads and installs the SentinelOne agent on a Windows machine.
    The script is designed to be used with a specific SITE_TOKEN, which must be provided.

.PARAMETERS
    SITE_TOKEN
    The site token for SentinelOne. Replace the placeholder in line 21 with your actual site token.

.EXAMPLE
    .\Install-SentinelOne-Windows.ps1 -SiteToken "your_site_token"

.NOTES
    Author: Idan Nadato
    This script is intended to be run on Windows machines.
#>

param (
    [Parameter(Mandatory=$true)]
    [string]$SiteToken = "Enter_Your_Site_Token"  # Replace "Enter_Your_Site_Token" in this line (line 21) with your actual site token.
)

# Define the URL for the MSI file
$msiUrl = "https://elpc.cloud/Public/SentinelAgentWin.msi"  # Replace <URL_MSI> with the actual URL of the SentinelOne MSI installer (line 28).

# Download the SentinelOne MSI installer
Write-Host "Downloading SentinelOne MSI installer..." -Verbose
curl -o SentinelOne.msi $msiUrl

# Install SentinelOne using the provided site token
Write-Host "Installing SentinelOne agent..." -Verbose
Start-Process msiexec.exe -ArgumentList "/i SentinelOne.msi /q /NORESTART SITE_TOKEN=$SiteToken" -Wait -NoNewWindow

Write-Host "SentinelOne installation completed." -Verbose
