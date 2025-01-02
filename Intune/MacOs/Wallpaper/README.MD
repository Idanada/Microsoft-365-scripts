---

# 🖥️ **macOS Desktop and Lock Screen Wallpaper Configuration**

## Overview

This solution automates the setup of custom desktop and lock screen wallpapers on **macOS** devices. It combines a **bash script** to download the wallpaper and a **mobileconfig** profile to enforce the wallpaper settings via **Microsoft Intune**. Ideal for organizations looking to implement branding or uniform visuals across devices, this solution ensures consistency for both the desktop and lock screen.

---

## 📖 **Table of Contents**

1. [✨ Features](#features)
2. [🔧 Script Configuration](#script-configuration)
3. [📜 Example Script Usage](#example-script-usage)
4. [📂 MobileConfig Configuration](#mobileconfig-configuration)
5. [🚀 Deploying with Intune](#deploying-with-intune)
6. [💻 System Requirements](#system-requirements)
7. [🧪 Testing the Script](#testing-the-script)
8. [👤 Author](#author)

---

## ✨ **Features**

- 🎨 **Automated Wallpaper Setup**: Downloads and applies the wallpaper to the macOS desktop.
- 📂 **Custom Path**: Saves the downloaded wallpaper in the user's Downloads folder.
- 🛠️ **Automated Process**: Runs in the background, logs all actions, and avoids duplicates.
- 🔐 **Enforced Consistency**: The **mobileconfig** profile ensures the wallpaper is applied across devices, syncing the desktop and lock screen.

---

## 🔧 **Script Configuration**

To use the script, update the following fields before deployment:

- **Wallpaper URL** (`wallpaperurl`): Set this field to the URL where your wallpaper is hosted.
- **Wallpaper Filename** (`wallpaperfile`): Set the name of the wallpaper file that will be downloaded.
- **Wallpaper Directory** (`wallpaperdir`): Defines the folder where the wallpaper will be saved.

---

## 📜 **Example Script Usage**

```bash
#!/bin/bash

# Variables
wallpaperurl="https://yourwallpaper.com/image.png"  # Change this URL
wallpaperdir="/Users/$(whoami)/Downloads"  # Directory for the wallpaper
wallpaperfile="company_wallpaper.png"  # Change this filename
log="/var/log/fetchdesktopwallpaper.log"  # Log file location

# Check if wallpaper exists
if [ -f "$wallpaperdir/$wallpaperfile" ]; then
    echo "$(date): Wallpaper already exists. No action taken." >> "$log"
    exit 0
fi

# Download wallpaper
curl -o "$wallpaperdir/$wallpaperfile" "$wallpaperurl"
if [ $? -eq 0 ]; then
    echo "$(date): Wallpaper downloaded to $wallpaperdir/$wallpaperfile" >> "$log"
else
    echo "$(date): Error downloading wallpaper." >> "$log"
    exit 1
fi

# Set desktop wallpaper
osascript -e "tell application \"System Events\" to set picture of every desktop to \"$wallpaperdir/$wallpaperfile\""
if [ $? -eq 0 ]; then
    echo "$(date): Wallpaper set successfully." >> "$log"
else
    echo "$(date): Error setting wallpaper." >> "$log"
    exit 2
fi
```

---

## 📂 **MobileConfig Configuration**

The **mobileconfig** file ensures the wallpaper is applied consistently across all devices, including the desktop and lock screen.

### Example **MobileConfig** File

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTDs/PropertyList-1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>PayloadContent</key>
    <array>
        <dict>
            <key>PayloadType</key>
            <string>com.apple.desktop</string>
            <key>override-picture-path</key>
            <string>/Users/$(whoami)/Downloads/company_wallpaper.png</string> <!-- Change to match the wallpaper path -->
            <key>PayloadUUID</key>
            <string>84c4927c-b438-4a8b-9a23-7a229f71919f</string> <!-- Replace with a unique UUID -->
            <key>PayloadVersion</key>
            <integer>1</integer>
            <key>PayloadDisplayName</key>
            <string>Set Desktop Wallpaper</string>
        </dict>
    </array>
    <key>PayloadIdentifier</key>
    <string>com.company.wallpaper</string> <!-- Update with your organization’s identifier -->
    <key>PayloadUUID</key>
    <string>84c4927c-b438-4a8b-9a23-7a229f71919f</string> <!-- Replace with a unique UUID -->
    <key>PayloadVersion</key>
    <integer>1</integer>
    <key>PayloadDisplayName</key>
    <string>Wallpaper Configuration Profile</string>
</dict>
</plist>
```

### Key Instructions:
- **UUID**: Replace `YOUR_UUID_HERE` with a unique UUID.
- **Wallpaper Path**: Ensure the path points to the correct file location on the device.

---

## 🚀 **Deploying with Intune**

### Steps:

1. Navigate to **Devices > macOS > Shell Scripts** in the [Microsoft Endpoint Manager Admin Center](https://endpoint.microsoft.com/).
2. **Upload the script** and configure:
   - **Run script as signed-in user**: Set to **Yes**.
   - **Hide script notifications**: Set to **Yes**.
   - **Script frequency**: Set to **Daily** or according to your organization's needs.
3. **Upload the mobileconfig** file to enforce the wallpaper on all devices.
4. **Assign the scripts and profiles** to the appropriate device groups.
5. **Save and deploy** the configurations.

---

## 💻 **System Requirements**

- **macOS**: The solution is compatible with macOS versions that support shell scripts and mobileconfig profiles.
- **Microsoft Intune**: Used to deploy both the bash script and **mobileconfig** profile.

---

## 🧪 **Testing the Script**

To verify that the script and **mobileconfig** file work, run the script locally:

```bash
sudo bash set_wallpaper.sh
```

Confirm that the desktop wallpaper is applied correctly.

---

## 👤 **Author**

This solution was created by **Idan Nadato** to automate and enforce desktop and lock screen wallpapers on macOS devices using Intune.

---
