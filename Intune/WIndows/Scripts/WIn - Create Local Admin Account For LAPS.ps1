<#
.SYNOPSIS
    This script checks if a local user exists, verifies if they are a member of the Administrators group,
    and if not, it creates the user and adds them to the Administrators group.

.DESCRIPTION
    The script first checks if a local user exists. If the user exists, it checks if the user is part of the 
    Administrators group. If the user does not exist, the script creates the user with no password (to be managed by LAPS)
    and adds them to the Administrators group. If the user is created, they are also removed from the Users group if they
    were added there by default.

.PREPARATION
    # Instructions on where to change values:

    1. **UserName**:
       - Line 41: Change the value of the `$UserName` variable to your desired username.

    2. **Description**:
       - Line 42: Change the value of the `$Description` variable to the desired description for the user account.

    3. **Groups**:
       - Line 43-44: Change the values of the `$UsersGroup` and `$AdminsGroup` variables to the appropriate group names if needed.

    # If you do not specify new parameters when running the script, the default values set in the variables will be used.

.INTUNE DEPLOYMENT    
    # This script is designed to be fully compatible with Intune and should work smoothly when deployed as described above.
    **Deployment via Microsoft Intune**:

    - Ensure the script is saved as a `.ps1` file before uploading it to Intune.
    - Upload this script to Intune as part of a device configuration profile under (Device Configuration > Scripts).
    
    **Configuration Options:**
    - Set "Run this script using the logged on credentials" to "No" to ensure the script runs with system-level privileges.
    - Set "Run script in 64-bit PowerShell" to "Yes" if the target devices are 64-bit.
    - Set "Enforce Script Signature Check" to "No" if you are not signing the script.

    **Monitoring and Operation:**
    - After deploying, monitor the Intune portal to verify that the users are created and added to the correct groups as expected.


.PARAMETER Verbose
    Provides detailed information about the process.


.NOTES
    Author: Idan Nadato
    Version: 1.0
    Last Updated: [2/9/2024]
#>

param (
    [switch]$Verbose
)

# Variables for user and groups
$UserName = "YourUserName"
$Description = "Your Local Admin account"
$UsersGroup = "Users"
$AdminsGroup = "Administrators"

# Check if the user exists
$userExists = Get-LocalUser -Name $UserName -ErrorAction SilentlyContinue

if ($userExists) {
    # Check if the user is a member of the Administrators group
    $isAdmin = Get-LocalGroupMember -Group $AdminsGroup -Member $UserName -ErrorAction SilentlyContinue

    if ($isAdmin) {
        Write-Host "All is good, account exists and is in Administrators group" -Verbose:$Verbose
        exit 0
    } else {
        Write-Host "Account exists but is not in Administrators group" -Verbose:$Verbose
        exit 1
    }
} else {
    Write-Host "Account is missing. Creating the account..." -Verbose:$Verbose

    try {
        # Create the user with minimal parameters to avoid errors
        New-LocalUser -Name $UserName -Description $Description -NoPassword
        Write-Host "Account created successfully" -Verbose:$Verbose
    } catch {
        Write-Host "Failed to create account: $_" -Verbose:$Verbose
        exit 1
    }

    try {
        # Remove the user from the Users group if they are added by default
        Remove-LocalGroupMember -Group $UsersGroup -Member $UserName -ErrorAction SilentlyContinue
        Write-Host "Account removed from Users group if existed" -Verbose:$Verbose
    } catch {
        Write-Host "Failed to remove account from Users group: $_" -Verbose:$Verbose
        exit 1
    }

    try {
        # Add the user to the Administrators group
        Add-LocalGroupMember -Group $AdminsGroup -Member $UserName
        Write-Host "Account added to Administrators group successfully" -Verbose:$Verbose
    } catch {
        Write-Host "Failed to add account to Administrators group: $_" -Verbose:$Verbose
        exit 1
    }

    Write-Host "Local admin user has been created and added to the Administrators group." -Verbose:$Verbose
    exit 0
}
