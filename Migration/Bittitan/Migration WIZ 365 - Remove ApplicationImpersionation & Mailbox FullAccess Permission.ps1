<#
.SYNOPSIS
This script connects to Exchange Online, removes the ApplicationImpersonation role from a specified user, and removes full access permissions from multiple mailboxes based on CSV input.

.DESCRIPTION
The script initiates by connecting to Exchange Online using modern authentication. It then prompts for a user from whom the ApplicationImpersonation role will be removed. Following this, it allows the selection of a CSV file containing mailbox addresses for removing full access permissions. The script uses a graphical interface for both file selection and user input, making it user-friendly. It handles errors gracefully and provides a summary table of actions taken, including any errors encountered.

.PREREQUISITES
- PowerShell 5.1 or higher.
- Exchange Online Management Shell or appropriate permissions for on-premises Exchange Management Shell if running against an on-premises Exchange server.
- A CSV file with a header named 'Mailbox' that lists the email addresses of the mailboxes to modify.
- The executing user must have permissions to modify mailbox permissions in Exchange.

.NOTES
File Name: RemoveMailboxPermissions.ps1
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

# Function to remove ApplicationImpersonation role
function Remove-ApplicationImpersonation {
    param (
        [string]$userUPN
    )
    try {
        Write-Host "Removing ApplicationImpersonation role from $userUPN..."
        Get-ManagementRoleAssignment -Role "ApplicationImpersonation" -GetEffectiveUsers | Where-Object {$_.RoleAssigneeName -eq $userUPN} | Remove-ManagementRoleAssignment -ErrorAction Stop
        Write-Host "Successfully removed ApplicationImpersonation role from $userUPN."
    } catch {
        Write-Host "Failed to remove ApplicationImpersonation role: $_" -ForegroundColor Red
    }
}

# Main script logic
Connect-ExchangeOnlineModernAuth

# Prompt for the admin user UPN for removing the ApplicationImpersonation role and full access permissions
$adminUserUPN = Show-InputBoxDialog -message "Enter the admin UPN to remove ApplicationImpersonation role and Full Access permissions:" -WindowTitle "Admin UPN"
if (-not [string]::IsNullOrWhiteSpace($adminUserUPN)) {
    Remove-ApplicationImpersonation -userUPN $adminUserUPN
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
            # Attempt to remove full access permissions
            Remove-MailboxPermission -Identity $mailbox -User $adminUserUPN -AccessRights FullAccess -InheritanceType All -ErrorAction Stop
            $operationResult = "FullAccess removed from $adminUserUPN"
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


