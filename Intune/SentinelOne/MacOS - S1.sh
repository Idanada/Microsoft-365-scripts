#!/bin/bash

################################################################################
# SentinelOne Installation Script for macOS
#
# .DESCRIPTION
#   This script downloads and installs the SentinelOne agent on a macOS machine.
#   The script is designed to be used with a specific SITE_TOKEN, which must be 
#   provided.
#
# .PARAMETERS
#   SITE_TOKEN
#       The site token for SentinelOne. Replace the placeholder in line 29 with 
#       your actual site token.
#
#   MSI_URL
#       The URL for the SentinelOne installer package. Replace the placeholder 
#       in line 30 with the actual URL.
#
# .EXAMPLE
#   sudo ./install-sentinelone-macos.sh
#
# .NOTES
#   Author: Idan Nadato
#   This script is intended to be run on macOS machines with appropriate admin 
#   privileges.
################################################################################

SITE_TOKEN="Enter_Your_Site_token_Here"  # Replace "Enter_Your_Site_token_Here" in this line (line 8) with your actual site token.
MSI_URL="https://elpc.cloud/Public/Sentinel-macos.pkg"  # The actual URL of the SentinelOne installer.

echo "Downloading SentinelOne installer..." 
curl -o /tmp/Sentinelmacos.pkg "$MSI_URL"

echo "Writing site token to registration file..." 
echo $SITE_TOKEN > /tmp/com.sentinelone.registration-token

echo "Installing SentinelOne agent..." 
sudo /usr/sbin/installer -pkg /tmp/Sentinelmacos.pkg -target /Library/

echo "SentinelOne installation completed."
