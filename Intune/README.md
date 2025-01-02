---

# 🌐 **Intune Scripts**

## 📝 **Overview**

This repository contains scripts designed to manage **Windows**, **macOS**, and **Linux** devices through **Microsoft Intune**. The scripts automate various tasks, such as device configuration, application deployment, and compliance policy enforcement. These solutions simplify IT management, offering scalability and efficiency across the entire device fleet.

---

## 📖 **Table of Contents**

1. [📂 Managing Windows Devices](#managing-windows-devices)
2. [💻 Managing macOS Devices](#managing-macos-devices)
3. [🐧 Managing Linux Devices](#managing-linux-devices)
4. [⚙️ Essential PowerShell Modules for Intune](#essential-powershell-modules-for-intune)
5. [💡 FAQs](#faqs)
6. [🔍 Troubleshooting](#troubleshooting)
7. [🛠️ Best Practices](#best-practices)
8. [📚 Additional Resources](#additional-resources)
9. [🚀 How to Use These Scripts](#how-to-use-these-scripts)
10. [🔧 Contributions and Issues](#contributions-and-issues)

---

## 📂 **Managing Windows Devices**

These scripts enable key automation tasks for **Windows** devices via Intune:

1. **Device Configuration**:
   - 📁 Apply configuration profiles and security policies.
   - ⚙️ Manage device settings and configurations.

2. **App Management**:
   - 📦 Deploy, update, or remove applications.
   - 🛠️ Monitor app installation and status.

3. **Compliance Policies**:
   - ✅ Create and enforce compliance policies.
   - 🔧 Remediate non-compliant devices automatically.

4. **Device Actions**:
   - 🔒 Remotely wipe, lock, or reset passcodes.
   - 🛰️ Locate lost or stolen devices.

---

## 💻 **Managing macOS Devices**

The scripts provided also help automate key tasks for **macOS** device management:

1. **Device Enrollment**:
   - 🔄 Automate macOS device enrollment into Intune.
   - 🛠️ Apply enrollment policies and configurations.

2. **Configuration Profiles**:
   - 🔐 Manage security policies and settings.
   - ⚙️ Apply organization-wide settings using profiles.

3. **App Deployment**:
   - 🚀 Deploy and monitor applications across devices.
   - 🔄 Automate app updates and management.

4. **Compliance Policies**:
   - 📊 Enforce compliance policies.
   - 📈 Track and report compliance status.

---

## 🐧 **Managing Linux Devices**

Intune's support for **Linux** devices enables automation with these scripts:

1. **Device Enrollment**:
   - 📥 Enroll Linux devices into Intune.
   - ⚙️ Apply device-specific enrollment policies.

2. **Configuration Management**:
   - 🔐 Enforce security policies and system settings.
   - 🛠️ Manage configuration profiles for Linux systems.

3. **App Management**:
   - 📦 Deploy applications to Linux devices.
   - 🔄 Monitor and update app installations.

4. **Compliance and Reporting**:
   - ✅ Enforce compliance policies for Linux systems.
   - 📊 Generate detailed compliance reports.

---

## ⚙️ **Essential PowerShell Modules for Intune**

Before deploying the scripts, ensure these PowerShell modules are installed for effective management:

- **Microsoft Graph Intune Module**:  
  [Learn more about Microsoft Graph Intune PowerShell](https://learn.microsoft.com/en-us/powershell/intune/intune-ps-module?view=intune-ps)
  ```powershell
  Install-Module -Name Microsoft.Graph.Intune -Scope CurrentUser
  ```

- **Microsoft Graph Module**:  
  [Learn more about Microsoft Graph PowerShell](https://learn.microsoft.com/en-us/graph/powershell/get-started)
  ```powershell
  Install-Module -Name Microsoft.Graph -Scope CurrentUser
  ```

- **Azure AD Module**:  
  [Learn more about Azure AD Module](https://learn.microsoft.com/en-us/powershell/azure/active-directory/install-adv2?view=azureadps-2.0)
  ```powershell
  Install-Module -Name AzureAD -Scope CurrentUser
  ```

---

## 💡 **FAQs**

### **Q1: How do I deploy scripts to devices via Intune?**
**A1**: Go to **Microsoft Endpoint Manager Admin Center** → **Devices** → **Scripts**. Upload your PowerShell or bash script, set the correct options (e.g., "Run as signed-in user"), and assign the script to the appropriate device group. [Read more here](https://learn.microsoft.com/en-us/mem/intune/apps/intune-macos-shell-scripts).

---

### **Q2: How can I check if a script successfully ran on a device?**
**A2**: After deploying a script, go to **Devices > Scripts** in the Intune Admin Center. You can track deployment success through **Reports** to see if the script was applied correctly.

---

### **Q3: Why is my compliance policy failing on macOS devices?**
**A3**: Ensure that the correct **configuration profiles** and **compliance policies** are applied. Check if the policies are up to date and if any conflicts exist between the profile settings.

---

### **Q4: Can I remotely update apps on enrolled devices?**
**A4**: Yes, Intune allows remote app management, including deployment, updates, and removal. Monitor these tasks through **Devices > Apps** in the Admin Center.

---

## 🔍 **Troubleshooting**

### **Issue**: Script failed to run on a macOS device.
- **Solution**: Ensure the script has executable permissions. Run `chmod +x script.sh` to make it executable. Additionally, verify that the device is properly enrolled in Intune.

---

### **Issue**: Compliance policy isn't applying correctly to Windows devices.
- **Solution**: Verify that the compliance policy is correctly assigned to the device group. Also, check for conflicts between applied policies or configuration profiles.

---

### **Issue**: Linux devices aren't reporting compliance status.
- **Solution**: Ensure the Linux devices are properly enrolled and assigned the correct compliance policies. Check that the Intune connector is working correctly.

---

## 🛠️ **Best Practices**

- **Test scripts** on a few devices before deploying them organization-wide.
- Regularly **monitor script reports** in Intune to ensure successful deployment.
- Keep PowerShell modules up to date to ensure compatibility with Intune and Microsoft Graph API.
- Always **back up device configurations** before applying significant changes, especially when pushing configuration profiles or security policies.

---

## 📚 **Additional Resources**

- [Microsoft Intune Overview](https://learn.microsoft.com/en-us/mem/intune/)
- [Microsoft Graph API Documentation](https://learn.microsoft.com/en-us/graph/api/overview)
- [Intune PowerShell SDK](https://learn.microsoft.com/en-us/powershell/intune/intune-ps-module?view=intune-ps)
- [Microsoft Endpoint Manager Documentation](https://learn.microsoft.com/en-us/mem/endpoint-manager-overview)
- [Managing Compliance Policies](https://learn.microsoft.com/en-us/mem/intune/protect/protect-devices-with-compliance-policies)
- [Deploying Apps in Intune](https://learn.microsoft.com/en-us/mem/intune/apps/apps-deploy)

---

## 🚀 **How to Use These Scripts**

1. **Modify the Scripts**: Each script comes with detailed instructions on how to modify them to suit your organization's needs. Update variables such as **usernames**, **passwords**, and **URLs** before deployment.

2. **Deploy via Intune**: Upload scripts in **Microsoft Endpoint Manager Admin Center** → **Devices** → **Scripts**. Select whether to run the script as the **signed-in user** or **system** and assign it to device/user groups.

---

## 🔧 **Contributions and Issues**

We welcome contributions! Please feel free to submit a **pull request** or open an **issue** if you encounter any problems. If you have suggestions for new scripts, don't hesitate to share them.

---

**Author**: Idan Nadato

---
