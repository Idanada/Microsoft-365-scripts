#!/bin/bash
# Author: Idan Nadato
# Description: This script creates a hidden admin user on macOS with a non-expiring, non-changeable password.
# The user will be part of the admin group and have full privileges. Additionally, their home folder will be hidden and protected.

# Summary of changes:
# Username: Change the value of accountname in Line 14.
# Password: Change the value of password in Line 15.
# Full Name: Change the full name in Line 20.
# Unique ID: Change the UniqueID value in Line 21.
# Password Hint: Change the password hint in Line 25.

# Step 1: Define the variables for the new user
accountname="newuser"  # Change "newuser" to the desired username in this line.
password="YourSecurePassword123!"  # Change "YourSecurePassword123!" to the desired secure password in this line.

# Step 2: Create the user account
sudo dscl . -create /Users/$accountname  # Creates the user in the system with the specified username.
sudo dscl . -create /Users/$accountname UserShell /bin/bash  # Sets the user's shell to bash.
sudo dscl . -create /Users/$accountname RealName "Hidden Admin Account"  # Change "Hidden Admin Account" to the desired full name in this line.
sudo dscl . -create /Users/$accountname UniqueID "2002"  # Change "2002" to a unique ID not used by other users in this line.
sudo dscl . -create /Users/$accountname PrimaryGroupID 20  # Sets the primary group ID.
sudo dscl . -create /Users/$accountname NFSHomeDirectory /Users/$accountname  # Defines the user's home directory.
sudo dscl . -passwd /Users/$accountname $password  # Sets the password defined earlier in the script.
sudo dscl . -create /Users/$accountname hint "Password Hint"  # Change "Password Hint" to a secure hint in this line.
sudo dscl . -append /Groups/admin GroupMembership $accountname  # Adds the user to the admin group.
sudo dscl . -create /Users/$accountname IsHidden 1  # Hides the user from the login screen.

# Step 3: Configure password policies to prevent expiration and changes
sudo pwpolicy -u $accountname -setpolicy "maxFailedLoginAttempts=0 requiresAlpha=1 requiresNumeric=1 minChars=8 usingHistory=0 canModifyPasswordforSelf=0 maxMinutesUntilChangePassword=0"  # Password policies.

# Step 4: Hide and protect the user's home folder
sudo chflags hidden /Users/$accountname  # Hides the user's home folder.
sudo chflags uchg /Users/$accountname  # Locks the home folder so it cannot be modified.

# Final Step: Display a message confirming successful user creation
echo "User $accountname created with a non-expiring, non-changeable password."  # Confirmation message.
