---

# 🔐 **EntraID Scripts Repository**

Welcome to the **EntraID Scripts** repository! This collection of PowerShell scripts helps automate and manage various tasks within **Azure Active Directory (EntraID)**. Use these scripts to streamline administrative tasks such as user and group management, device management, application management, and reporting.

---

## 📖 **Table of Contents**

1. [Possible Actions with EntraID Scripts](#possible-actions)
2. [📦 Important PowerShell Modules](#important-powershell-modules)
3. [⚙️ Usage Instructions](#usage-instructions)
4. [💡 FAQs](#faqs)
5. [🔍 Troubleshooting](#troubleshooting)
6. [🛠️ Best Practices](#best-practices)
7. [🤝 Contributions](#contributions)

---

## 💼 **Possible Actions with EntraID Scripts**

Using **EntraID** scripts, you can manage a variety of tasks within **Azure Active Directory**:

### 👥 **User Management**
- Create, update, or delete users.
- Assign or remove licenses.
- Reset user passwords.
- Add or remove users from groups.

### 👥 **Group Management**
- Create, update, or delete groups.
- Add or remove members from groups.
- Manage group settings and policies.

### 💻 **Device Management**
- Register or remove devices.
- Manage device settings and policies.
- Monitor device compliance and status.

### 🛠️ **Application Management**
- Register or update applications.
- Manage application permissions and roles.
- Assign or remove users from applications.

### 🔄 **Directory Synchronization**
- Configure and manage directory sync settings.
- Monitor sync status and logs.
- Perform manual sync cycles.

### 📊 **Reporting and Auditing**
- Generate reports on user and group activity.
- Monitor audit logs for changes and activities.
- Create custom reports for compliance and monitoring.

---

## 📦 **Important PowerShell Modules for EntraID**

To use these scripts, ensure the following PowerShell modules are installed:

### 🔐 **Azure AD Module**
- ***[Learn More](https://docs.microsoft.com/powershell/azure/active-directory/install-adv2?view=azureadps-2.0)***
```powershell
Install-Module -Name AzureAD -Scope CurrentUser
```

### 📧 **MSOnline Module**
- ***[Learn More](https://docs.microsoft.com/powershell/azure/active-directory/overview?view=azureadps-1.0)***
```powershell
Install-Module -Name MSOnline -Scope CurrentUser
```

### 📊 **Microsoft Graph Module**
- ***[Learn More](https://docs.microsoft.com/graph/powershell/get-started)***
```powershell
Install-Module -Name Microsoft.Graph -Scope CurrentUser
```

### 💬 **Microsoft Teams PowerShell**
- ***[Learn More](https://docs.microsoft.com/powershell/teams/teams-powershell-module)***
```powershell
Install-Module -Name MicrosoftTeams -Scope CurrentUser
```

### 🗂️ **SharePoint Online Management Shell**
- ***[Learn More](https://docs.microsoft.com/powershell/sharepoint/sharepoint-online/connect-sharepoint-online)***
```powershell
Install-Module -Name Microsoft.Online.SharePoint.PowerShell -Scope CurrentUser
```

### 🌐 **OneDrive PowerShell Module**
- ***[Learn More](https://docs.microsoft.com/powershell/sharepoint/sharepoint-online/connect-sharepoint-online)***
```powershell
Install-Module -Name Microsoft.Online.SharePoint.PowerShell -Scope CurrentUser
```

### 📝 **Planner PowerShell Module (via Graph)**
- ***[Learn More](https://docs.microsoft.com/graph/api/resources/planner-overview?view=graph-rest-1.0)***
```powershell
Install-Module -Name Microsoft.Graph.Planner -Scope CurrentUser
```

### 🗂️ **Office 365 PowerShell Module**
- ***[Learn More](https://docs.microsoft.com/powershell/msonline/)***
```powershell
Install-Module -Name MSOnline -Scope CurrentUser
```

---

## ⚙️ **Usage Instructions**

Each script includes detailed comments and instructions for usage, including prerequisites and examples. Ensure that the required PowerShell modules are installed before running the scripts. Execute them in PowerShell with administrator privileges, following the script-specific guidelines.

---

## 💡 **FAQs**

### **Q1: What should I do if I encounter authentication issues?**
**A1**: Ensure you are using the correct credentials and permissions. If Multi-Factor Authentication (MFA) is enabled, you may need to use device code authentication.

---

### **Q2: How can I automate bulk user management tasks?**
**A2**: Use the provided scripts with CSV files to handle bulk user creation, updates, and group management efficiently.

---

### **Q3: What modules are essential for user management and directory sync tasks?**
**A3**: For most user and sync-related tasks, you will need the **AzureAD**, **MSOnline**, and **Microsoft.Graph** modules.

---

## 🔍 **Troubleshooting**

### **Issue**: "Module Not Found" error when running scripts.
- **Solution**: Verify that the required modules are installed using the commands in the **Important Modules** section.

---

### **Issue**: Permissions errors when running EntraID scripts.
- **Solution**: Ensure the user running the script has sufficient **Azure AD admin permissions** and that all necessary modules are authenticated.

---

## 🛠️ **Best Practices**

- **Test scripts** on a **limited number of users or devices** before large-scale deployment.
- **Use secure authentication**: Enable **MFA** to secure your Azure AD environment.
- **Monitor logs**: Use audit logs and reports to track changes and identify potential issues.
- **Schedule regular sync cycles**: Ensure your Azure AD and on-premises directories remain in sync by scheduling regular syncs.

---

## 🤝 **Contributions**

We welcome contributions from the community! If you have new scripts, improvements, or suggestions, feel free to submit a pull request. Review the guidelines in the **CONTRIBUTING.md** file before making contributions.

---
