<#
.SYNOPSIS
  Script to configure Fortinet FortiClient SSL VPN settings.
.DESCRIPTION
  This script checks if the required registry keys and properties for Fortinet FortiClient SSL VPN settings are correctly set. If they are not set, it configures them accordingly.
.PARAMETER None
  This script does not accept any parameters.
.INPUTS
  None
.OUTPUTS
  Output to console.
.PREREQUISITES
  - Ensure PowerShell is running with administrative privileges.
  - Modify the script to include your specific VPN settings:
    1. Change <VPNName> to the desired VPN site name at line 29, 39, 60, 62.
    2. Change <Description> to the desired description for the VPN site at line 32.
    3. Change <IP:PORT> to the server IP address and port for the VPN at line 35.
.NOTES
  Version:        1.0
  Author:         Idan Nadato
  Creation Date:  20230721
  Purpose/Change: Initial version to set Fortinet FortiClient SSL VPN settings.
.EXAMPLE
  .\Win - FortiClient SiteVPN.ps1
#>

# Define the registry path and key
# Change <VPNName> to the desired VPN site name
$registryPath = "HKLM:\SOFTWARE\Fortinet\FortiClient\Sslvpn\Tunnels\<VPNName>"

# Change <Description> to the desired description for the VPN site
$descriptionValue = "<Description>"

# Change <IP:PORT> to the server IP address and port for the VPN
$serverValue = "<IP:PORT>"

# Check if the registry key exists and create it if it does not
if (-not (Test-Path -LiteralPath $registryPath)) {
    Write-Output "VPN site '<VPNName>' is not configured correctly. Creating registry key and setting values..."
    New-Item -Path $registryPath -Force -ErrorAction SilentlyContinue
}

# Set the registry properties
try {
    Write-Output "Setting Description to '$descriptionValue'..."
    New-ItemProperty -Path $registryPath -Name 'Description' -Value $descriptionValue -PropertyType String -Force -ErrorAction SilentlyContinue
    Write-Output "Setting Server to '$serverValue'..."
    New-ItemProperty -Path $registryPath -Name 'Server' -Value $serverValue -PropertyType String -Force -ErrorAction SilentlyContinue
    Write-Output "Setting promptusername to '0'..."
    New-ItemProperty -Path $registryPath -Name 'promptusername' -Value 0 -PropertyType DWord -Force -ErrorAction SilentlyContinue
    Write-Output "Setting promptcertificate to '0'..."
    New-ItemProperty -Path $registryPath -Name 'promptcertificate' -Value 0 -PropertyType DWord -Force -ErrorAction SilentlyContinue
    Write-Output "Setting ServerCert to '0'..."
    New-ItemProperty -Path $registryPath -Name 'ServerCert' -Value "0" -PropertyType String -Force -ErrorAction SilentlyContinue
    Write-Output "Setting sso_enabled to '1'..."
    New-ItemProperty -Path $registryPath -Name 'sso_enabled' -Value 1 -PropertyType DWord -Force -ErrorAction SilentlyContinue
    Write-Output "Setting use_external_browser to '0'..."
    New-ItemProperty -Path $registryPath -Name 'use_external_browser' -Value 0 -PropertyType DWord -Force -ErrorAction SilentlyContinue

    Write-Output "VPN site '<VPNName>' is configured correctly."
} catch {
    Write-Output "Failed to configure VPN site '<VPNName>': $_"
}
