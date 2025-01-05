<#
.SYNOPSIS
This script creates a dynamic device security group in Microsoft 365 with a specified membership rule using the Microsoft Graph PowerShell SDK.

.DESCRIPTION
The script connects to Microsoft Graph, defines properties for a new dynamic device security group, and then creates the group with a specified membership rule.
This group will dynamically include devices based on the defined rule, such as devices not part of a specific order ID and having certain properties.

.PREREQUISITES
- Microsoft Graph PowerShell SDK installed.
- Appropriate admin permissions (Groups Administrator or Privileged Role Administrator).
- Microsoft Entra ID P1 or Intune for Education license.

.NOTES
File Name: CreateDynamicDeviceGroup.ps1
Author: Idan Nadato
Copyright 2024: Idan Nadato
This script is designed for creating dynamic device groups in Microsoft 365 and should be tested in a non-production environment before use.

.LINK
For more information on PowerShell scripting and Microsoft Graph:
- https://learn.microsoft.com/en-us/powershell/microsoftgraph/overview
- https://learn.microsoft.com/en-us/azure/active-directory/enterprise-users/groups-dynamic-membership-rules
#>

#region Check and Import Microsoft Graph module

if (-not (Get-Module -ListAvailable -Name Microsoft.Graph)) {
    try {
        Install-Module -Name Microsoft.Graph -Scope CurrentUser -Force -AllowClobber
        Write-Output "Microsoft Graph module installed successfully."
    }
    catch {
        Write-Error "Failed to install Microsoft Graph module. Please check your internet connection or permissions."
        exit
    }
}
else {
    Write-Output "Microsoft Graph module is already installed."
}

Import-Module Microsoft.Graph

#endregion

#region Connect to Microsoft Graph

try {
    # Interactive login
    Connect-MgGraph -Scopes "Group.ReadWrite.All"
    Write-Output "Connected to Microsoft Graph successfully."
}
catch {
    Write-Error "Failed to connect to Microsoft Graph: $($_.Exception.Message)"
    exit
}

#endregion

#region Define group properties

$groupName = "AAD - Autopilot Devices - User Driven"

$description = @"
| What does this do? | Creates a dynamic device group that is used to assign the "Baseline - User Driven Profile" Autopilot profile to devices. This group includes all devices that are not in the Azure AD group "Baseline - Autopilot Devices - Self Deploying." | 
| Why should you use this? | When a device is going to be used by a single user, this approach is ideal because the device shows as assigned in all relevant Intune pages and reports. It is also the most stable and consistent Autopilot mode. | 
| What is the end-user impact? | Devices with this profile can be Autopiloted by users themselves. The device will be registered to the user and the user will be able to use the company portal application. | 
| Learn more | [Windows Autopilot User-Driven mode](https://docs.microsoft.com/en-us/mem/autopilot/user-driven) |
"@

# Define the dynamic membership rule
# Explanation: 
# (device.devicePhysicalIDs -all (_ -ne "[OrderID]:Autopilot-SelfDeploying"))
#    → devices that do NOT have an OrderID of Autopilot-SelfDeploying
# and
# ((device.devicePhysicalIDs -any (_ -contains "[ZTDId]")) -or (device.deviceOwnership -eq "Company"))
#    → devices that have a ZTDId or are owned by the company

$rule = '(device.devicePhysicalIDs -all (_ -ne "[OrderID]:Autopilot-SelfDeploying")) -and ((device.devicePhysicalIDs -any (_ -contains "[ZTDId]")) -or (device.deviceOwnership -eq "Company"))'

$params = @{
    displayName                   = $groupName
    description                   = $description
    mailEnabled                   = $false
    mailNickname                  = "AADAutopilotDevicesUserDriven"
    securityEnabled               = $true
    groupTypes                    = @("DynamicMembership")
    membershipRule                = $rule
    membershipRuleProcessingState = "On"
}

#endregion

#region Create the group and validate

Write-Output "Creating dynamic device security group: $groupName"

try {
    $newGroup = New-MgGroup -BodyParameter $params
    if ($newGroup.Id) {
        Write-Output "Dynamic device security group created successfully."
        Write-Output "Group Display Name: $($newGroup.DisplayName)"
        Write-Output "Group ID: $($newGroup.Id)"

        # Optional: Check group membership (may be empty initially, membership can take time to update)
        try {
            Write-Output "Retrieving current members (may take time for dynamic rule to process)..."
            $members = Get-MgGroupMember -GroupId $newGroup.Id -All:$true
            if ($members) {
                Write-Output "Found $($members.Count) members in the new group."
            }
            else {
                Write-Output "No members found yet. Dynamic membership might take a few minutes to update."
            }
        }
        catch {
            Write-Error "Failed to retrieve group members: $($_.Exception.Message)"
        }
    }
    else {
        Write-Error "Failed to create the dynamic device security group: No Group ID returned."
    }
}
catch {
    Write-Error "Failed to create the dynamic device security group: $($_.Exception.Message)"
    exit
}

#endregion
