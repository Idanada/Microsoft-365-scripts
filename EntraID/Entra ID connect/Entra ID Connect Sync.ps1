<#
.SYNOPSIS
  This script automates the process of initiating different types of Active Directory synchronization tasks and stores the output in a dated folder on C:.

.DESCRIPTION
  The script prompts the user to select between **Full**, **Delta**, and **Initial** synchronization types. It initiates the selected sync task, fetches the results, and stores both a summary and detailed report in a timestamped folder on the C: drive.

.PREPARATION
  Before running the script, ensure the necessary modules are installed and the script is run as an administrator. Refer to the **README.md** for preparation steps.

.PARAMETER None
  This script does not accept any parameters.

.INPUTS
  None.

.OUTPUTS
  Console output, log files, and detailed synchronization reports stored in a folder on the C: drive.

.NOTES
  Version:        1.3
  Author:         Idan Nadato
  Creation Date:  2023-07-21
  Last Modified:  2023-10-07
  Purpose/Change: Added folder creation and report generation functionality.

.EXAMPLE
  .\ADSyncScript.ps1
  This will prompt the user to select a synchronization method and execute it based on the selection.
#>

# Create output folder with script name and date
$scriptName = "ADSyncScript"
$dateStamp = Get-Date -Format "yyyy-MM-dd"
$outputDir = "C:\$scriptName-$dateStamp"
if (-not (Test-Path -Path $outputDir)) {
    New-Item -Path $outputDir -ItemType Directory | Out-Null
}

# Log file location inside the output folder
$logFile = "$outputDir\ADSyncLog_$dateStamp.log"

# Function to write logs
function Write-Log {
    param (
        [string]$message,
        [string]$type = "INFO"
    )
    $logEntry = "$(Get-Date -Format yyyy-MM-dd HH:mm:ss) [$type] : $message"
    Write-Host $logEntry
    Add-Content -Path $logFile -Value $logEntry
}

# Pre-Script Validation: Check if the ADSync module is installed and if the script is running with admin privileges
function Check-PreReqs {
    Write-Log "Checking prerequisites..."
    
    if (-not (Get-Module -ListAvailable -Name ADSync)) {
        Write-Log "The ADSync module is not installed. Install it using: Install-Module -Name ADSync -Scope CurrentUser" "ERROR"
        exit 1
    }

    if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Log "This script must be run as an administrator." "ERROR"
        exit 1
    }

    Write-Log "Prerequisites check passed."
}

# Function to perform synchronization based on user selection
function Perform-Synchronization {
    param (
        [string]$policyType
    )

    Write-Log "Starting synchronization: $policyType"
    Start-ADSyncSyncCycle -PolicyType $policyType -Verbose

    # Fetch and display results
    Get-SyncResults
}

# Function to get synchronization results
function Get-SyncResults {
    try {
        Write-Log "Fetching synchronization results..."
        $syncResults = Get-ADSyncConnectorRunStatus
        $syncSummary = $syncResults | Select-Object -Property RunProfileName, ObjectType, Direction, Status, Errors

        # Save synchronization summary to a file
        $summaryFile = "$outputDir\SyncSummary_$dateStamp.txt"
        $syncSummary | Format-Table -AutoSize | Out-File $summaryFile
        Write-Log "Synchronization summary saved to $summaryFile"

        # Display synchronization summary
        Write-Host "`n==== Synchronization Summary ====" -ForegroundColor Green
        $syncSummary | Format-Table -AutoSize
        $syncSummary | ForEach-Object { Write-Log "Summary: $_" }

        # Save detailed synchronization information to a file
        $detailedFile = "$outputDir\SyncDetails_$dateStamp.txt"
        $syncResults | ForEach-Object {
            $syncRun = $_
            Add-Content $detailedFile "--------------------------------------------"
            Add-Content $detailedFile "Run Profile: $($syncRun.RunProfileName)"
            Add-Content $detailedFile "Object Type: $($syncRun.ObjectType)"
            Add-Content $detailedFile "Direction: $($syncRun.Direction)"
            Add-Content $detailedFile "Status: $($syncRun.Status)"
            Add-Content $detailedFile "Start Time: $($syncRun.StartTime)"
            Add-Content $detailedFile "End Time: $($syncRun.EndTime)"
        }
        Write-Log "Detailed synchronization information saved to $detailedFile"

    } catch {
        Write-Log "Error fetching synchronization results: $_" "ERROR"
    }
}

# Main Script Execution
function Main {
    # Check prerequisites
    Check-PreReqs

    # User prompt for synchronization method
    Write-Host "`n==== Active Directory Synchronization Options ====" -ForegroundColor Cyan
    Write-Host "1. Full Synchronization (Complete resync)"
    Write-Host "2. Delta Synchronization (Only changes)"
    Write-Host "3. Initial Synchronization (First-time setups)"
    Write-Host "`nPlease select a synchronization method (1-3): " -ForegroundColor Green
    $syncMethod = Read-Host

    switch ($syncMethod) {
        1 {
            Write-Log "User selected Full Synchronization."
            Perform-Synchronization -policyType "Initial"
        }
        2 {
            Write-Log "User selected Delta Synchronization."
            Perform-Synchronization -policyType "Delta"
        }
        3 {
            Write-Log "User selected Initial Synchronization."
            Perform-Synchronization -policyType "Initial"
        }
        default {
            Write-Log "Invalid input. Please select a valid synchronization option (1-3)." "ERROR"
            exit 1
        }
    }
}

# Execute main function
Main
