#!/bin/bash

# Install helper script for jupyter-electron-app
#
# 11-Jan-2024: Rev. 1      -  John L   -  Initial build
# 12-Jan-2024: Rev. 1.1    -  John L   -  Tab fixes
# 13-Jan-2024: Rev. 2      -  John L   -  Rewrite for clarity and:
#                                            - Create main function
#                                            - Update function calls
#                                            - Add default install value
#
#


clear

###########################  Welcome info   ###################################
WELCOME_MESG () {
   echo "
   ####################################################
   ##            LINUX install helper for            ##
   ##         ***  jupyter-electron-app  ***         ##
   ##                                                ##
   ##      Please choose from the options below.     ##
   ##         Depending on chosen location,          ##
   ##          the process may require               ##
   ##            elevated privileges.                ##
   ####################################################
   "
   echo "Available options are:"
   echo "> 1. INSTALL npm-based electron, then package for linux execution"
   echo "> 2. REMOVE / CLEAN npm-installed packages & build area"
   echo "> 3. QUIT / CANCEL / EXIT"
}

####### Create TIMER function to allow reading and time to cancel #############
TIMER () {
   secs=$((5 * 1))
   while [ $secs -gt 0 ]; do
      echo -ne ">>> $secs \033 \r"
      sleep 1
      : $((secs--))
   done
}

#########  Set DEFAULT INSTALL value in User's home dir  ######################
HOMEDIR=$( getent passwd "$USER" |cut -d: -f6 )
INST_DIR=$HOMEDIR/.local/share/jupyter-electron-app

############# Install the req'd npm files and run packager  ###################
NPM_BUILD () {
   echo "building electron packages"
   npm install electron electron-packager
   npm run package-linux
}

#################   Give User INSTALL DIR choice  #############################
INST_CHOICE () {
   echo "Default installation: $INST_DIR"
   read -p "Install to alternative location (y/n)? > " yn
   case $yn in
   [Yy]) read -p "Full path to alternative location: > " INST_DIR
         INST_ROOT ;;
   
   [Nn]) INST_LOCAL ;;
   
   *   ) echo "Please enter y/Y or n/N." ;;
   esac
}

#######################  Package Installer  ###################################
INST_LOCAL () {
   echo "Moving files to $INST_DIR"
   TIMER
   mv ./release-builds/jupyter-electron-app-linux-x64 $INST_DIR
   ##chmod -R 755 $INST_DIR
}
INST_ROOT () {
   echo "Moving files to $INST_DIR"
   TIMER
   mv ./release-builds/jupyter-electron-app-linux-x64 /tmp/
   sudo mv /tmp/jupyter-electron-app-linux-x64 $INST_DIR
   sudo chown -R root:root $INST_DIR
   sudo chmod -R 755 $INST_DIR
}

################## Clean up any residual files in /tmp/ #######################
CLEANUP () {
   TIMER
   echo "cleaning up any /tmp/ files"
   rm -rfv /tmp/electron-packager
   # rm -fv /tmp/jupyter-electron-app-*.rpm
}

###############################################################################
###############################################################################
###############################################################################
MAIN () {
   WELCOME_MESG
   read -p "> " USER_OPTION

   ## Start the chosen option
   case "$USER_OPTION" in
   1) echo "Building packages..."
      TIMER
      NPM_BUILD
      INST_CHOICE
      echo "$(date +%F--%H:%M:%S) > Installed to $INST_DIR" >> activity_log.txt
      echo "Cleaning up..."
      CLEANUP
      clear
      ## list current npm-installed packages before exiting
      npm list
      exit ;;
   
   2) echo "Cleaning up npm packages in..."
      CLEANUP
      npm remove electron electron-packager
      rm -rfv ./release-builds
      echo "./release-builds cleaned."
      echo "$(date +%F--%H:%M:%S) > Activated Cleanup." >> activity_log.txt
      # clear
      ## list empty npm-installed packages before exiting, for verification
      npm list
      exit ;;

   3) echo "Quiting."
      exit ;;

   *) echo "Unknown option.  Please choose properly."
      sleep 1
      clear ;;
   esac

}

###########################   run it   ########################################
while true
do
   MAIN
done
