---

# 🖥️ **MacOS Hidden Admin User Script**

## Overview

This script securely creates a hidden admin user on macOS with a non-expiring, non-changeable password, mimicking the functionality of **Local Administrator Password Solution (LAPS)** in Windows. It is ideal for managed environments where admin credentials need remote control. The hidden account will have full admin privileges, and its home folder will be hidden and protected from unauthorized access or modification.

---

## 📖 **Table of Contents**

1. [✨ Features](#features)
2. [⚙️ Configuration](#configuration)
3. [🔍 Example Usage](#example-usage)
4. [🚀 Deploying with Intune](#deploying-with-intune)
5. [💻 System Requirements](#system-requirements)
6. [💡 FAQs](#faqs)
7. [🔍 Troubleshooting](#troubleshooting)
8. [🛠️ Best Practices](#best-practices)
9. [📚 Additional Resources](#additional-resources)
10. [🧪 Testing the Script](#testing-the-script)
11. [👤 Author](#author)

---

## ✨ **Features**

- 🛡️ **Hidden Admin Account**: The user won’t appear on the macOS login screen.
- 🔒 **Non-Expiring Password**: The password will never expire and cannot be changed by the user.
- 🔐 **Home Folder Protection**: The user’s home folder will be hidden and locked to prevent unauthorized access.

---

## ⚙️ **Configuration**

Before deploying, customize the following fields in the script:

- **Username** (`accountname`): Set the username for the hidden account.
- **Password** (`password`): Assign a secure, non-expiring password.
- **Full Name** (`RealName`): Customize the full name of the admin user.
- **Unique ID** (`UniqueID`): Ensure the `UniqueID` is unique and doesn’t conflict with existing users.
- **Password Hint** (`hint`): Set a password hint (optional but recommended).

---

## 🔍 **Example Usage**

Here’s an example of how to configure the script for your environment:

```bash
# Define the new user's details
accountname="adminuser"  # Replace "adminuser" with the desired username
password="StrongPassword123!"  # Replace with a secure password

# Create the new admin user and configure
sudo dscl . -create /Users/$accountname
sudo dscl . -create /Users/$accountname UserShell /bin/bash
sudo dscl . -create /Users/$accountname RealName "Admin User"
sudo dscl . -create /Users/$accountname UniqueID "2002"
sudo dscl . -create /Users/$accountname PrimaryGroupID 20
sudo dscl . -create /Users/$accountname NFSHomeDirectory /Users/$accountname
sudo dscl . -passwd /Users/$accountname $password
sudo dscl . -create /Users/$accountname hint "Use a secure password"
sudo dscl . -append /Groups/admin GroupMembership $accountname
sudo dscl . -create /Users/$accountname IsHidden 1

# Set password policies and secure the home directory
sudo pwpolicy -u $accountname -setpolicy "maxFailedLoginAttempts=0 requiresAlpha=1 requiresNumeric=1 minChars=8 usingHistory=0 canModifyPasswordforSelf=0 maxMinutesUntilChangePassword=0"
sudo chflags hidden /Users/$accountname  # Hide the home folder
sudo chflags uchg /Users/$accountname  # Lock the home folder

echo "User $accountname created with a non-expiring, non-changeable password."
```

---

## 🚀 **Deploying with Intune**

### Steps:

1. Navigate to **Devices > macOS > Shell Scripts** in the [Microsoft Endpoint Manager Admin Center](https://endpoint.microsoft.com/).
2. Add a new shell script and configure:
   - **Run script as signed-in user**: Set to **Yes**.
   - **Hide script notifications**: Set to **Yes**.
   - **Script frequency**: Set to **Daily** (or customize the frequency based on your needs).
   - **Max retries**: Set to **3 retries** (recommended for fault tolerance).
3. Assign the script to the appropriate **device or user groups**.
4. **Save and deploy** the script.

This script provides a macOS equivalent to **LAPS**, ensuring secure, hidden administrative accounts are created and managed remotely.

---

## 💻 **System Requirements**

- **macOS**: The script is compatible with macOS versions that support the `dscl` and `pwpolicy` commands.
- **Administrator Privileges**: Required to create and manage the hidden user.

---

## 💡 **FAQs**

### **Q1: Can I customize the home directory location for the hidden user?**
**A1**: Yes, modify the `NFSHomeDirectory` field in the script to the desired path. By default, it is set to `/Users/$accountname`.

---

### **Q2: Will the hidden admin account appear in System Preferences?**
**A2**: No, the `IsHidden` flag ensures the account doesn’t appear in the macOS login screen or System Preferences.

---

### **Q3: Can the password be changed after the account is created?**
**A3**: No, the script sets policies that prevent the user from changing the password (`canModifyPasswordforSelf=0`).

---

### **Q4: How do I verify that the hidden user was created successfully?**
**A4**: Use the following command to verify:
```bash
dscl . list /Users | grep 'adminuser'
```
Replace `adminuser` with the username defined in the script.

---

## 🔍 **Troubleshooting**

### **Issue**: The script fails to create the hidden user.
- **Solution**: Ensure the script is being run with administrator privileges. Verify that the `dscl` and `pwpolicy` commands are available on the system.

---

### **Issue**: Password policies were not applied correctly.
- **Solution**: Use the following command to check the effective policy for the user:
```bash
sudo pwpolicy get-effective-policy -u $accountname
```
Replace `$accountname` with the username defined in the script.

---

## 🛠️ **Best Practices**

- **Test locally**: Run the script on a test device before deploying it across your organization to ensure it behaves as expected.
- **Use strong passwords**: Ensure the admin account password is strong, with a combination of letters, numbers, and special characters.
- **Monitor deployments**: Utilize Intune’s reporting feature to monitor script deployment and confirm successful user creation.

---

## 📚 **Additional Resources**

- [Managing macOS Devices with Intune](https://learn.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts)
- [macOS `dscl` Command Documentation](https://ss64.com/osx/dscl.html)
- [macOS `pwpolicy` Command Documentation](https://ss64.com/osx/pwpolicy.html)
- [Microsoft Intune Overview](https://learn.microsoft.com/en-us/mem/intune/)
- [Deploying Scripts to macOS Using Intune](https://learn.microsoft.com/en-us/mem/intune/apps/intune-macos-shell-scripts)

---

## 🧪 **Testing the Script**

To verify that the script works correctly, run the following command locally:

```bash
sudo bash hidden_admin_user.sh
```

Ensure that the user account is created, the password policies are applied, and the home directory is hidden.

---

## 👤 **Author**

This script was created by **Idan Nadato** to automate and enhance the management of hidden administrative accounts on macOS systems, ensuring security and compliance in managed environments.

---
