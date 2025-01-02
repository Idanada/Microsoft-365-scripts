#!/bin/bash
#set -x

#########################################################
##                                                     ##
## Script to install or update the latest Zoom client  ##
##                                                     ##
#########################################################

## Copyright (c) 2024 Idan Nada. All rights reserved.
## This script is provided AS IS without warranty of any kind.
## Idan disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a
## particular purpose. The entire risk arising out of the use or performance of the script and documentation remains with you. In no event shall
## Idan, its authors, or anyone else involved in the creation, production, or delivery of the script be liable for any damages whatsoever
## (including, without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary
## loss) arising out of the use of or inability to use the sample script or documentation, even if Idan has been advised of the possibility
## of such damages.


# User Defined variables
weburl="https://zoom.us/client/latest/ZoomInstallerIT.pkg"
appname="Zoom"
app="/Applications/zoom.us.app"
logandmetadir="/Library/Logs/Microsoft/IntuneScripts/installZoom"
processpath="/Applications/zoom.us.app/Contents/MacOS/zoom.us"
metafile="$logandmetadir/$appname.meta"
terminateprocess="false"
autoUpdate="false"

# Generated variables
tempdir=$(mktemp -d)
log="$logandmetadir/$appname.log"

# Function to initiate logging
startLog() {

    ################################################################
    ##                                                            ##				
    ##  Function to start logging - Output to log file and STDOUT ##
    ##                                                            ##
    ################################################################
    
    if [[ ! -d "$logandmetadir" ]]; then
        echo "$(date) | Creating [$logandmetadir] to store logs"
        mkdir -p "$logandmetadir" || { echo "Failed to create log directory, exiting"; exit 1; }
    fi

    exec &> >(tee -a "$log")
}

# Function to check for and install Rosetta 2 if necessary
checkForRosetta2() {

    ######################################################
    ##                                                  ##
    ##  Simple function to install Rosetta 2 if needed. ##
    ##                                                  ##
    ######################################################
    
    echo "$(date) | Checking if we need Rosetta 2"
    processor=$(/usr/sbin/sysctl -n machdep.cpu.brand_string | grep -o "Intel")
    
    if [[ -z "$processor" ]]; then
        if ! /usr/bin/pgrep oahd >/dev/null 2>&1; then
            echo "$(date) | Installing Rosetta 2"
            /usr/sbin/softwareupdate --install-rosetta --agree-to-license || { echo "Failed to install Rosetta 2, exiting"; exit 1; }
        else
            echo "$(date) | Rosetta 2 already installed"
        fi
    else
        echo "$(date) | Intel processor detected, no need for Rosetta 2"
    fi
}

# Function to wait for a process to finish
waitForProcess() {

    ############################################################
    ##                                                        ##
    ##  Function to wait for the specified process to finish  ##
    ##                                                        ##
    ##  Arguments:                                            ##
    ##      $1 = process name to check                        ##
    ##      $2 = delay time (optional, default is 30 seconds) ##
    ##                                                        ##
    ############################################################

    local processName="$1"
    local delay=${2:-30}

    echo "$(date) | Waiting for process [$processName] to end"

    while pgrep "$processName" >/dev/null; do
        echo "$(date) | Process [$processName] is running, waiting [$delay] seconds"
        sleep "$delay"
    done

    echo "$(date) | Process [$processName] is not running, proceeding"
}

# Function to download the app
downloadApp() {

    ############################################################
    ##                                                        ##
    ##  Function to download the Zoom installer from the web  ##
    ##                                                        ##
    ############################################################
    
    echo "$(date) | Starting download of [$appname]"
    
    curl -f -s --connect-timeout 30 --retry 5 --retry-delay 60 -L -J -O "$weburl" || {
        echo "$(date) | Failed to download [$weburl], exiting"
        exit 1
    }
    
    tempSearchPath="$tempdir/*"
    for f in $tempSearchPath; do
        tempfile=$f
    done

    if [[ -z "$tempfile" ]]; then
        echo "$(date) | Download failed or file not found"
        exit 1
    else
        echo "$(date) | Successfully downloaded file [$tempfile]"
    fi
}

# Function to check if update is needed based on Last-Modified header
checkForUpdate() {

    ##################################################################################################################
    ##                                                                                                              ##
    ##  Function to check if the app needs an update by comparing the Last-Modified header from the web to the last ##
    ##  saved date.                                                                                                 ##
    ##                                                                                                              ##
    ##################################################################################################################
    
    echo "$(date) | Checking if update is needed"

    lastModified=$(curl -sIL "$weburl" | grep -i "last-modified" | awk '{$1=""; print $0}' | tr -d '\r')

    if [[ -f "$metafile" ]]; then
        previousLastModified=$(cat "$metafile")
        if [[ "$previousLastModified" == "$lastModified" ]]; then
            echo "$(date) | No update needed. Zoom is up to date."
            exit 0
        else
            echo "$(date) | Update found. Previous: [$previousLastModified], Current: [$lastModified]"
            echo "$lastModified" > "$metafile"
        fi
    else
        echo "$(date) | No meta file found, creating a new one with the current modified date."
        echo "$lastModified" > "$metafile"
    fi
}

# Function to check if the app is already installed
checkIfInstalled() {

    ###################################################################
    ##                                                               ##
    ##  This function checks if the application is already installed ##
    ##                                                               ##					
    ###################################################################
    
    if [[ -d "$app" ]]; then
        echo "$(date) | [$appname] is already installed, checking for updates..."
        checkForUpdate
    else
        echo "$(date) | [$appname] is not installed, proceeding with installation"
    fi
}

# Clean up temp files and logs older than 7 days
cleanOldLogs() {

    ###########################################################
    ##                                                       ##
    ##  Function to clean up temp files and old log entries  ##
    ##                                                       ##
    ###########################################################
    
    find "$logandmetadir" -type f -mtime +7 -exec rm {} \;
    echo "$(date) | Cleaned up old logs"
}

# Main script
startLog
checkForRosetta2
checkIfInstalled
waitForProcess "/usr/sbin/softwareupdate"
downloadApp
cleanOldLogs

# End with a success code for Intune
exit 0
