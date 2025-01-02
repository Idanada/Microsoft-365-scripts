<#
.SYNOPSIS
  Script to generate a comprehensive report of Azure Active Directory users, including MFA settings, email addresses, and licensing status.
.DESCRIPTION
  This script connects to the MSOnline service, retrieves all non-guest Azure AD users, and generates a report containing detailed information about each user. The report includes MFA settings, primary email addresses, aliases, and licensing status.
.PARAMETER None
  This script does not accept any parameters.
.INPUTS
  None
.OUTPUTS
  A CSV report file containing detailed information about Azure AD users.
.PREREQUISITES
  - Ensure PowerShell is running with administrative privileges.
  - This script will check for the MSOnline module and install it if not present.
.NOTES
  Version:        1.0
  Author:         Idan Nadato
  Creation Date:  20230721
  Purpose/Change: Initial version to generate a comprehensive user report for Azure AD.
.EXAMPLE
  .\Office365-GetUsersFullReport .ps1
#>

# Check if the MSOnline module is installed, and install if not
if (-not (Get-Module -ListAvailable -Name MSOnline)) {
    Write-Host "MSOnline module is not installed. Installing now..." -ForegroundColor Yellow
    try {
        Install-Module -Name MSOnline -Scope CurrentUser -Force -ErrorAction Stop
        Write-Host "MSOnline module installed successfully." -ForegroundColor Green
    } catch {
        Write-Host "Failed to install MSOnline module. Exiting script." -ForegroundColor Red
        return
    }
} else {
    Write-Host "MSOnline module is already installed." -ForegroundColor Green
}

# Import the MSOnline module
Import-Module MSOnline

# Connect to MSOnline service
Connect-MsolService

Write-Host "Finding Azure Active Directory Accounts..."

# Get all non-guest users
$Users = Get-MsolUser -All | Where-Object { $_.UserType -ne "Guest" }

# Create an output list for the report
$Report = [System.Collections.Generic.List[Object]]::new()

Write-Host "Processing $($Users.Count) accounts..."

# Process each user
ForEach ($User in $Users) {
    # Get MFA default method
    $MFADefaultMethod = ($User.StrongAuthenticationMethods | Where-Object { $_.IsDefault -eq $true }).MethodType

    # Get MFA phone number
    $MFAPhoneNumber = $User.StrongAuthenticationUserDetails.PhoneNumber

    # Get primary SMTP address and aliases
    $PrimarySMTP = $User.ProxyAddresses | Where-Object { $_ -clike "SMTP*" } | ForEach-Object { $_ -replace "SMTP:", "" }
    $Aliases = $User.ProxyAddresses | Where-Object { $_ -clike "smtp*" } | ForEach-Object { $_ -replace "smtp:", "" }

    # Determine MFA state
    $MFAState = if ($User.StrongAuthenticationRequirements) { 
        $User.StrongAuthenticationRequirements.State
    } else {
        'Disabled'
    }

    # Determine MFA default method
    if ($MFADefaultMethod) {
        switch ($MFADefaultMethod) {
            "OneWaySMS" { $MFADefaultMethod = "Text code authentication phone" }
            "TwoWayVoiceMobile" { $MFADefaultMethod = "Call authentication phone" }
            "TwoWayVoiceOffice" { $MFADefaultMethod = "Call office phone" }
            "PhoneAppOTP" { $MFADefaultMethod = "Authenticator app or hardware token" }
            "PhoneAppNotification" { $MFADefaultMethod = "Microsoft authenticator app" }
        }
    } else {
        $MFADefaultMethod = "Not enabled"
    }
  
    # Create a report line for each user
    $ReportLine = [PSCustomObject] @{
        BlockCredential   = $User.BlockCredential
        UserPrincipalName = $User.UserPrincipalName
        DisplayName       = $User.DisplayName
        MFAState          = $MFAState
        MFADefaultMethod  = $MFADefaultMethod
        MFAPhoneNumber    = $MFAPhoneNumber
        PrimarySMTP       = ($PrimarySMTP -join ',')
        Aliases           = ($Aliases -join ',')
        Licensed          = $User.isLicensed        
    }
                 
    $Report.Add($ReportLine)
}

# Specify the output file path
$outputFilePath = "C:\temp\AzureADUserReport.csv"

# Create the output directory if it does not exist
$outputDirectory = [System.IO.Path]::GetDirectoryName($outputFilePath)
if (-not (Test-Path -Path $outputDirectory)) {
    New-Item -Path $outputDirectory -ItemType Directory -Force
}

Write-Host "Report is in $outputFilePath"
$Report | Select-Object BlockCredential, UserPrincipalName, DisplayName, MFAState, MFADefaultMethod, MFAPhoneNumber, PrimarySMTP, Aliases , Licensed | Sort-Object UserPrincipalName | Out-GridView
$Report | Sort-Object UserPrincipalName | Export-CSV -Encoding UTF8 -NoTypeInformation $outputFilePath
