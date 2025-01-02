#!/bin/bash

# This script downloads a wallpaper to the logged-in user's Downloads folder
# and sets it as the desktop wallpaper. The script also logs the action.

# Variables
usebingwallpaper=false
wallpaperurl="URL_OF_THE_WALLPAPER"  # Change this to the desired wallpaper URL
wallpaperdir="/Users/$(whoami)/Downloads"  # Location where wallpaper will be saved
wallpaperfile="WALLPAPER_FILENAME"  # Change this to match the wallpaper filename
log="/var/log/fetchdesktopwallpaper.log"  # Log file location

# Check if wallpaper is already downloaded
if [ -f "$wallpaperdir/$wallpaperfile" ]; then
    echo "$(date): Wallpaper already exists. No action taken." >> "$log"
    exit 0
fi

# Step 1: Download the wallpaper
echo "$(date): Starting wallpaper download..." >> "$log"
curl -o "$wallpaperdir/$wallpaperfile" "$wallpaperurl"
if [ $? -eq 0 ]; then
    echo "$(date): Wallpaper downloaded successfully to $wallpaperdir/$wallpaperfile" >> "$log"
else
    echo "$(date): Error downloading wallpaper from $wallpaperurl" >> "$log"
    exit 1  # Return error code 1 if download fails
fi

# Step 2: Set the downloaded image as the desktop wallpaper
echo "$(date): Setting wallpaper..." >> "$log"
osascript -e "tell application \"System Events\" to set picture of every desktop to \"$wallpaperdir/$wallpaperfile\""
if [ $? -eq 0 ]; then
    echo "$(date): Wallpaper set successfully." >> "$log"
    exit 0  # Return 0 for success
else
    echo "$(date): Error setting wallpaper." >> "$log"
    exit 2  # Return error code 2 if setting wallpaper fails
fi
