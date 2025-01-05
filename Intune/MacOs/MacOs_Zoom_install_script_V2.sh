#!/bin/bash
#set -x

#########################################################
##                                                     ##
## Script to install or update the latest Zoom client  ##
##    Supporting both Intel and Apple Silicon Macs     ##
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

##############################################
##            User-Defined Variables        ##
##############################################

## If you prefer a single Universal installer for both Intel & Apple Silicon, 
## just set the same URL in both variables below.
weburlIntel="https://zoom.us/client/latest/ZoomInstallerIT.pkg"       # Intel/Universal package 
weburlAppleSilicon="https://zoom.us/client/latest/Zoom.pkg"          # Apple Silicon package

appname="Zoom"
app="/Applications/zoom.us.app"
logandmetadir="/Library/Logs/Microsoft/IntuneScripts/installZoom"
metafile="$logandmetadir/$appname.meta"

terminateprocess="false"     # not currently used
autoUpdate="false"           # not currently used

##############################################
##           Generated Variables            ##
##############################################
tempdir=$(mktemp -d)
log="$logandmetadir/$appname.log"

##############################################
##         Function: startLog               ##
##############################################
startLog() {
    ################################################################
    ##  Function to start logging - Output to log file and STDOUT ##
    ################################################################

    if [[ ! -d "$logandmetadir" ]]; then
        echo "$(date) | Creating [$logandmetadir] to store logs"
        mkdir -p "$logandmetadir" || {
            echo "Failed to create log directory, exiting"
            exit 1
        }
    fi

    exec &> >(tee -a "$log")
    echo "$(date) | Starting script [$0]"
    echo "$(date) | Running as user: $(whoami)"
}

##############################################
##       Function: checkForRosetta2         ##
##############################################
checkForRosetta2() {
    ######################################################
    ##  Installs Rosetta 2 if needed on Apple Silicon   ##
    ######################################################

    echo "$(date) | Checking if we need Rosetta 2"
    processor=$(/usr/sbin/sysctl -n machdep.cpu.brand_string | grep -o "Intel")

    # If no "Intel" in processor string, we are on Apple Silicon.
    if [[ -z "$processor" ]]; then
        # Check if rosetta is installed by seeing if 'oahd' process exists
        if ! /usr/bin/pgrep oahd >/dev/null 2>&1; then
            echo "$(date) | Installing Rosetta 2"
            /usr/sbin/softwareupdate --install-rosetta --agree-to-license || {
                echo "$(date) | Failed to install Rosetta 2, exiting"
                exit 1
            }
        else
            echo "$(date) | Rosetta 2 already installed"
        fi
    else
        echo "$(date) | Intel processor detected, no need for Rosetta 2"
    fi
}

##############################################
##     Function: selectZoomInstaller        ##
##############################################
selectZoomInstaller() {
    ################################################################
    ##  Selects the correct Zoom installer URL based on CPU type  ##
    ################################################################

    local cpuBrand
    cpuBrand=$(/usr/sbin/sysctl -n machdep.cpu.brand_string)

    if [[ "$cpuBrand" =~ "Intel" ]]; then
        echo "$weburlIntel"
    else
        # Apple Silicon
        echo "$weburlAppleSilicon"
    fi
}

##############################################
##      Function: waitForProcess            ##
##############################################
waitForProcess() {
    ############################################################
    ##  Wait for the specified process to finish              ##
    ##  $1 = process name                                     ##
    ##  $2 = delay time (optional, default 30 seconds)        ##
    ############################################################

    local processName="$1"
    local delay=${2:-30}

    echo "$(date) | Waiting for process [$processName] to end..."

    while pgrep "$processName" >/dev/null; do
        echo "$(date) | Process [$processName] is running, waiting [$delay] seconds"
        sleep "$delay"
    done

    echo "$(date) | Process [$processName] is not running, proceeding"
}

##############################################
##     Function: downloadApp                ##
##############################################
downloadApp() {
    ###################################################################
    ##  Download the Zoom installer from the URL determined by CPU   ##
    ###################################################################

    local zoomURL="$1"
    echo "$(date) | Starting download of [$appname] from [$zoomURL]"

    # Navigate to our temp directory
    pushd "$tempdir" || {
        echo "$(date) | Failed to enter temp directory [$tempdir], exiting."
        exit 1
    }

    # Download the package
    curl -f -s --connect-timeout 30 --retry 5 --retry-delay 60 -L -J -O "$zoomURL" || {
        echo "$(date) | Failed to download [$zoomURL], exiting"
        popd
        exit 1
    }

    local pkgFile
    for f in "$tempdir"/*; do
        pkgFile="$f"
    done

    if [[ -z "$pkgFile" ]]; then
        echo "$(date) | Download failed or file not found in [$tempdir]"
        popd
        exit 1
    else
        echo "$(date) | Successfully downloaded file [$pkgFile]"
    fi

    popd
    echo "$pkgFile"
}

##############################################
##     Function: checkForUpdate             ##
##############################################
checkForUpdate() {
    ##################################################################################################################
    ##  Checks if the app needs an update by comparing the Last-Modified header from the server to what was stored  ##
    ##  locally in $metafile. If it matches, no update is needed; otherwise, we save the new date and proceed.       ##
    ##################################################################################################################

    local zoomURL="$1"
    echo "$(date) | Checking if update is needed from [$zoomURL]"

    local lastModified
    lastModified=$(curl -sIL "$zoomURL" | grep -i "last-modified" | awk '{$1=""; print $0}' | tr -d '\r')

    if [[ -f "$metafile" ]]; then
        local previousLastModified
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

##############################################
##    Function: checkIfInstalled            ##
##############################################
checkIfInstalled() {
    ###################################################################
    ## Checks if the application is already installed. If it exists, ##
    ## we check for updates; if not, we proceed with installation.    ##
    ###################################################################

    local zoomURL="$1"

    if [[ -d "$app" ]]; then
        echo "$(date) | [$appname] is already installed, checking for updates..."
        checkForUpdate "$zoomURL"
    else
        echo "$(date) | [$appname] is not installed, proceeding with installation."
    fi
}

##############################################
##     Function: installApp                 ##
##############################################
installApp() {
    ################################################################
    ##  Installs the pkg file that was downloaded                ##
    ################################################################

    local pkgFile="$1"

    echo "$(date) | Installing [$appname] from package [$pkgFile]"
    /usr/sbin/installer -pkg "$pkgFile" -target / || {
        echo "$(date) | Installation of [$appname] failed"
        exit 1
    }

    echo "$(date) | [$appname] installed successfully"
}

##############################################
##     Function: cleanOldLogs               ##
##############################################
cleanOldLogs() {
    ###########################################################
    ##  Cleans up temp files and old logs (older than 7 days) ##
    ###########################################################
    
    find "$logandmetadir" -type f -mtime +7 -exec rm {} \; 2>/dev/null
    echo "$(date) | Cleaned up old logs in [$logandmetadir]"
}

#########################################################
##                    Main Script                      ##
#########################################################

startLog            # Start logging
checkForRosetta2    # Check if we need Rosetta 2 on Apple Silicon

# Determine correct Zoom URL based on CPU type
zoomURL=$(selectZoomInstaller)
echo "$(date) | Selected Zoom URL: [$zoomURL]"

checkIfInstalled "$zoomURL"           # Check if Zoom is already installed (and if up to date)
waitForProcess "/usr/sbin/softwareupdate"  # Wait if "softwareupdate" is running

pkgPath=$(downloadApp "$zoomURL")     # Download the package, store the path returned
cleanOldLogs                          # Clean logs older than 7 days

installApp "$pkgPath"                 # Install Zoom from the downloaded pkg

# If we reach here, everything should be successful
exit 0
