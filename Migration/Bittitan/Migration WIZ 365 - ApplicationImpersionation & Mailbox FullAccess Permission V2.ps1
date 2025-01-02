<#
.SYNOPSIS
This script connects to Exchange Online, assigns the ApplicationImpersonation role to a specified user, and adds full access permissions to multiple mailboxes based on CSV input.

.DESCRIPTION
This script is designed to assist with migrations using BitTitan MigrationWiz when performing migrations to and from Office 365. The script connects to Exchange Online using modern authentication, assigns the ApplicationImpersonation role to a specified user, and adds full access permissions to multiple mailboxes based on a CSV input. It uses a graphical interface for both file selection and user input, making it user-friendly. The script handles errors gracefully and provides a summary table of actions taken, including any errors encountered.

.PREREQUISITES
- PowerShell 5.1 or higher.
- Exchange Online Management Shell or appropriate permissions for on-premises Exchange Management Shell if running against an on-premises Exchange server.
  - Install using: `Install-Module -Name ExchangeOnlineManagement -Scope CurrentUser`
- A CSV file with a header named 'Mailbox' that lists the email addresses of the mailboxes to modify.
- The executing user must have permissions to modify mailbox permissions in Exchange.
  - Global Administrator role in Microsoft 365.
  - Exchange Administrator role.

.NOTES
File Name: Migration WIZ 365 - ApplicationImpersionation & Mailbox FullAccess Permission V2.ps1
Author: Idan Nadato
Copyright 2024: Idan Nadato
This script is designed for educational purposes and should be tested in a non-production environment before use.

.LINK
For more information on PowerShell scripting and Exchange management:
- https://docs.microsoft.com/powershell/
- https://docs.microsoft.com/exchange/powershell/exchange-powershell
#>

# Load necessary assemblies for GUI
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Function to connect to Exchange Online using modern authentication
function Connect-ExchangeOnlineModernAuth {
    try {
        Write-Host "Connecting to Exchange Online with modern authentication..."
        Connect-ExchangeOnline -ShowBanner:$false
        Write-Host "Successfully connected to Exchange Online."
    } catch {
        Write-Host "Failed to connect to Exchange Online: $_" -ForegroundColor Red
        exit
    }
}

# Function to show input dialog
function Show-InputBoxDialog {
    param (
        [string]$message,
        [string]$WindowTitle
    )
    $InputBox = New-Object System.Windows.Forms.Form
    $InputBox.StartPosition = "CenterScreen"
    $InputBox.Size = New-Object System.Drawing.Size(300,140)
    $InputBox.Text = $WindowTitle

    $Label = New-Object System.Windows.Forms.Label
    $Label.Location = New-Object System.Drawing.Point(10,10)
    $Label.Size = New-Object System.Drawing.Size(280,20)
    $Label.Text = $message
    $InputBox.Controls.Add($Label)

    $TextBox = New-Object System.Windows.Forms.TextBox
    $TextBox.Location = New-Object System.Drawing.Point(10,40)
    $TextBox.Size = New-Object System.Drawing.Size(260,20)
    $InputBox.Controls.Add($TextBox)

    $Button = New-Object System.Windows.Forms.Button
    $Button.Location = New-Object System.Drawing.Point(10,70)
    $Button.Size = New-Object System.Drawing.Size(260,20)
    $Button.Text = "OK"
    $Button.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $InputBox.Controls.Add($Button)
    $InputBox.AcceptButton = $Button

    $result = $InputBox.ShowDialog()

    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        return $TextBox.Text
    } else {
        return $null
    }
}

# Function to enable organization customization if not already enabled
function Enable-OrganizationCustomizationIfNeeded {
    try {
        $customizationStatus = Get-OrganizationConfig
        if ($customizationStatus.IsDehydrated -eq $false) {
            Write-Host "Organization customization is already enabled."
        } else {
            Write-Host "Enabling organization customization..."
            Enable-OrganizationCustomization
            Write-Host "Organization customization enabled successfully."
        }
    } catch {
        Write-Host "Error checking/enabling organization customization: $_" -ForegroundColor Red
    }
}

# Function to assign ApplicationImpersonation role
function Assign-ApplicationImpersonation {
    param (
        [string]$userUPN
    )
    try {
        Write-Host "Assigning ApplicationImpersonation role to $userUPN..."

        # Check if the role assignment already exists
        $roleAssignmentExists = Get-ManagementRoleAssignment -Role "ApplicationImpersonation" -RoleAssignee $userUPN -ErrorAction SilentlyContinue
        if ($roleAssignmentExists) {
            Write-Host "ApplicationImpersonation role is already assigned to $userUPN."
        } else {
            New-ManagementRoleAssignment -Role "ApplicationImpersonation" -User $userUPN -ErrorAction Stop
            Write-Host "Successfully assigned ApplicationImpersonation role to $userUPN."
        }
    } catch {
        Write-Host "Failed to assign ApplicationImpersonation role: $_" -ForegroundColor Red
        exit
    }
}

# Main script logic
Connect-ExchangeOnlineModernAuth

# Enable organization customization if needed
Enable-OrganizationCustomizationIfNeeded

# Prompt for the admin user UPN for assigning the ApplicationImpersonation role and for full access permissions
$adminUserUPN = Show-InputBoxDialog -message "Enter the admin UPN for Impersonation and Full Access permissions:" -WindowTitle "Admin UPN"
if (-not [string]::IsNullOrWhiteSpace($adminUserUPN)) {
    Assign-ApplicationImpersonation -userUPN $adminUserUPN
} else {
    Write-Host "No admin user UPN provided. Exiting script." -ForegroundColor Red
    exit
}

# Create an OpenFileDialog for selecting the CSV file
$openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
$openFileDialog.initialDirectory = [Environment]::GetFolderPath("Desktop")
$openFileDialog.filter = "CSV files (*.csv)|*.csv|All files (*.*)|*.*"
$openFileDialog.ShowDialog() | Out-Null
$csvPath = $openFileDialog.FileName

# Check if a file was selected
if ([string]::IsNullOrWhiteSpace($csvPath)) {
    [System.Windows.Forms.MessageBox]::Show("No file was selected.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    exit
}

# Initialize an array to hold the results
$results = @()

# Import the CSV and loop through each row
if (Test-Path $csvPath) {
    Import-Csv $csvPath | ForEach-Object {
        $mailbox = $_.Mailbox
        $operationResult = $null
        try {
            # Attempt to add full access permissions
            Add-MailboxPermission -Identity $mailbox -User $adminUserUPN -AccessRights FullAccess -InheritanceType All -ErrorAction Stop
            $operationResult = "FullAccess granted to $adminUserUPN"
        } catch {
            $operationResult = "Failed: " + $_.Exception.Message
        }

        # Log the result
        $results += New-Object PSObject -Property @{
            Mailbox = $mailbox
            Result = $operationResult
        }
    }
} else {
    Write-Host "File not found: $csvPath" -ForegroundColor Red
}

# Display the results in a table
$results | Format-Table -Property Mailbox, Result -AutoSize
