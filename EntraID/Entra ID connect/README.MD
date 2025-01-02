---

# 🔄 **Active Directory Sync Script with Logging, Folder Creation, and Reports**

## Overview

This PowerShell script automates **Active Directory Synchronization** tasks, including **Full**, **Delta**, and **Initial Synchronization**. It creates a log file, generates synchronization summary and detailed reports, and stores these files in a timestamped folder on the **C:** drive for easy access.

---

## 📖 **Table of Contents**

1. [✨ Features](#features)
2. [⚠️ Prerequisites](#prerequisites)
3. [⚙️ Script Configuration](#script-configuration)
4. [📜 Example Script Usage](#example-script-usage)
5. [🚀 Automating with Task Scheduler](#automating-with-task-scheduler)
6. [🧪 Testing the Script](#testing-the-script)
7. [📁 Log and Report File Management](#log-and-report-file-management)
8. [🔍 Troubleshooting](#troubleshooting)
9. [🤝 Contributions](#contributions)

---

## ✨ **Features**

- **Pre-Execution Checks**: Ensures the **ADSync** module is installed and that the script is run as an administrator.
- **Modular Design**: Structured into functions, improving maintainability.
- **Detailed Logging**: Logs all actions, errors, and statuses to a log file stored in a timestamped folder.
- **Synchronization Types**: Supports **Full**, **Delta**, and **Initial Synchronization** methods.
- **Folder and Report Creation**: Automatically creates a folder named after the script and the current date, storing synchronization logs and reports for each run.

---

## ⚠️ **Prerequisites**

1. **ADSync Module**:
   Ensure the **ADSync** module is installed before running the script. Use the following command to install it:
   ```powershell
   Install-Module -Name ADSync -Scope CurrentUser
   ```

2. **Run with Administrator Privileges**:
   The script must be run with admin rights. Open PowerShell as an administrator to execute the script.

---

## ⚙️ **Script Configuration**

The script doesn’t require any complex configuration. It automatically prompts the user to select a synchronization method and handles the rest. 

- **Synchronization Options**:
  - **Full Synchronization**: Complete resynchronization of all directory objects.
  - **Delta Synchronization**: Syncs only the changes since the last synchronization.
  - **Initial Synchronization**: Used for first-time synchronization setups.

- **Folder and Report Generation**:
  - The script creates a folder in `C:\ADSyncScript-[date]` where:
    - `ADSyncLog_[date].log`: Logs all actions and errors.
    - `SyncSummary_[date].txt`: Summary of the synchronization.
    - `SyncDetails_[date].txt`: Detailed synchronization run results.

---

## 📜 **Example Script Usage**

```bash
# Open PowerShell as Administrator and run the script
.\ADSyncScript.ps1

# Select the synchronization type when prompted:
# 1. Full Synchronization
# 2. Delta Synchronization
# 3. Initial Synchronization
```

---

## 🚀 **Automating with Task Scheduler**

### Steps to automate this script using **Windows Task Scheduler**:

1. Open **Task Scheduler**.
2. Create a new task and configure it to run the script at regular intervals.
3. Ensure the task is set to **Run with highest privileges**.
4. Set the script path in the **Actions** section.

---

## 🧪 **Testing the Script**

Test the script locally before deploying it in production:

```bash
# Run a Delta Sync
.\ADSyncScript.ps1
```

Verify that:
1. Logs and reports are generated in the folder `C:\ADSyncScript-[date]`.
2. The console outputs the synchronization summary and detailed results.

---

## 📁 **Log and Report File Management**

- The script automatically creates a folder with the name `ADSyncScript-[date]` under **C:**
- Files included:
  - **ADSyncLog_[date].log**: Captures all actions, statuses, and errors during execution.
  - **SyncSummary_[date].txt**: Contains the summary of the synchronization run.
  - **SyncDetails_[date].txt**: Provides detailed information about each synchronization process.

---

## 🔍 **Troubleshooting**

1. **Missing ADSync Module**: Ensure the **ADSync** module is installed using:
   ```powershell
   Install-Module -Name ADSync
   ```

2. **Insufficient Privileges**: The script must be run as an administrator. Right-click on PowerShell and choose **Run as administrator**.

3. **Missing Folder or Files**: Ensure the `C:` drive has write permissions for the script to create folders and files.

---

## 🤝 **Contributions**

We welcome contributions! If you have improvements or new features to add, feel free to submit a pull request. Ensure that you follow the [CONTRIBUTING.md](CONTRIBUTING.md) guidelines.

---
