---

# 📊 **Azure AD User Report Script**

## Overview

This PowerShell script generates a comprehensive report of **Azure Active Directory (AD)** users, including their **MFA settings**, **email addresses**, and **licensing status**. The script is ideal for administrators who need a detailed view of their Azure AD environment. It saves the report as a CSV file for further analysis.

---

## 📖 **Table of Contents**

1. [✨ Features](#features)
2. [⚠️ Prerequisites](#prerequisites)
3. [⚙️ Script Configuration](#script-configuration)
4. [📜 Example Script Usage](#example-script-usage)
5. [🚀 Automating with Task Scheduler](#automating-with-task-scheduler)
6. [🧪 Testing the Script](#testing-the-script)
7. [📁 Output File and Location](#output-file-and-location)
8. [🔍 Troubleshooting](#troubleshooting)

---

## ✨ **Features**

- **MFA Reporting**: Retrieves MFA state, default method, and associated phone numbers.
- **Email Details**: Collects primary SMTP addresses and aliases for users.
- **Licensing Status**: Identifies if users are licensed within Azure AD.
- **CSV Report**: Exports the gathered data into a **CSV** file for easy reference and analysis.
- **Automatic Module Installation**: Checks for the **MSOnline** module and installs it if not already present.

---

## ⚠️ **Prerequisites**

1. **MSOnline Module**:
   The script checks and installs the **MSOnline** module automatically if it's not installed. However, you can install it manually using:
   ```powershell
   Install-Module -Name MSOnline -Scope CurrentUser -Force
   ```

2. **Run with Administrator Privileges**:
   Ensure you run the script with elevated privileges.

---

## ⚙️ **Script Configuration**

This script doesn't require any complex configuration. It automatically connects to your **Azure AD** tenant and gathers user data.

- **MSOnline Authentication**:
  You will be prompted to authenticate to the **MSOnline** service using your admin credentials.
  
- **Output File**:
  The generated report is saved as a **CSV** file in `C:\temp\AzureADUserReport.csv`. You can modify the path in the script.

---

## 📜 **Example Script Usage**

```bash
# Open PowerShell as Administrator and run the script
.\Office365-GetUsersFullReport.ps1
```

After running the script, it will connect to Azure AD, retrieve user information, and generate a report. You'll find the CSV file in the output folder, which can be opened in Excel for further analysis.

---

## 🚀 **Automating with Task Scheduler**

To automate this script using **Task Scheduler**:
1. Open **Task Scheduler** and create a new task.
2. Set the task to run with **highest privileges**.
3. In the **Actions** tab, add the script path.
4. Set a schedule in the **Triggers** tab for the report to run daily, weekly, or as needed.

---

## 🧪 **Testing the Script**

Before automating the script, you can run it manually to verify it works as expected:

```bash
# Run the script
.\Office365-GetUsersFullReport.ps1
```

Ensure that:
1. **MSOnline** module is installed and the connection is successful.
2. The CSV report is created with the expected user data in the `C:\temp\` directory.

---

## 📁 **Output File and Location**

- The report is saved in the following location: `C:\temp\AzureADUserReport.csv`.
- Fields in the report include:
  - **BlockCredential**: Whether the user is blocked.
  - **UserPrincipalName**: The UPN of the user.
  - **DisplayName**: The user's display name.
  - **MFAState**: Whether MFA is enabled or disabled.
  - **MFADefaultMethod**: The default MFA method.
  - **MFAPhoneNumber**: The phone number used for MFA (if applicable).
  - **PrimarySMTP**: The primary email address.
  - **Aliases**: Email aliases of the user.
  - **Licensed**: Whether the user is licensed.

---

## 🔍 **Troubleshooting**

1. **Failed Connection to Azure AD**: Ensure you're logged in as a Global Admin or have sufficient permissions in Azure AD.
   
2. **MSOnline Module Not Found**: Run the following command to install the module:
   ```powershell
   Install-Module -Name MSOnline -Scope CurrentUser -Force
   ```

3. **No Report Generated**: Ensure that the output directory exists, or the script has permission to create one.

---
