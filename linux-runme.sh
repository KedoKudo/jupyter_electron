#!/bin/bash

# Initial install script created by ORNL Username JVL
# 11-Jan-2024: version 1

clear

# Welcome info
echo "
####################################################
##      Please choose from the options below.     ##
##      Depending on chosen location,             ##
##      the process may require                   ##
##      elevated privileges.                      ##
####################################################
"

# Create timer function to allow reading and time to cancel
timer_func () {
   secs=$((5 * 1))
   while [ $secs -gt 0 ]; do
      echo -ne ">>> $secs \033 \r"
      sleep 1
      : $((secs--))
   done
}
# Install the req'd files and run packager
npm_install_func() {
   npm install electron electron-packager
   npm run package-linux
}

# Clean up any residual files in /tmp/
cleanup_func () {
   echo "cleaning up any /tmp/ files"
   timer_func
   rm -rfv /tmp/electron-packager
   rm -fv /tmp/jupyter-electron-app-*.rpm
}

while true
do
   echo "Available options:"
   echo "> 1. INSTALL npm-based electron, then package for linux execution"
   echo "> 2. CLEAN old npm-installed packages / remove build area"
   echo "> 3. CANCEL"
   read -p "> " USER_IN

   # Start the chosen option
   case "$USER_IN" in
   1) read -p "Please give the installation directory: > " INSTALL_DIR
      read -p "Does this location require sudo privileges (y/n)? > " yn
      case $yn in
         [Yy]) echo "OK, will request password later."
               timer_func
               npm_install_func
               cp -r ./release-builds/jupyter-electron-app-linux-x64 /tmp/
               echo "Moving to $INSTALL_DIR"
               timer_func
               # sudo mkdir $INSTALL_DIR
               sudo mv /tmp/jupyter-electron-app-linux-x64 $INSTALL_DIR
               sudo chown -R root:root $INSTALL_DIR
               sudo chmod -R 755 $INSTALL_DIR
               echo "$(date +%F---%H:%M:%S) : installed to $INSTALL_DIR" >> install_log;;
         [Nn]) echo "Installing as local user."
               timer_func
               npm_install_func
               echo "Moving to $INSTALL_DIR"
               timer_func
               # mkdir $INSTALL_DIR
               mv ./release-builds/jupyter-electron-app-linux-x64 $INSTALL_DIR
               chmod -R 755 $INSTALL_DIR
               echo "$(date +%F---%H:%M:%S) : installed to $INSTALL_DIR" >> install_log;;
         *   ) echo "Invalid response.
                     Need y or n, please." ;;
      esac
      echo "Cleaning up..."
      cleanup_func
      clear
      # list out the current npm-installed packages before exiting
      npm list
      break ;;

   2) echo "Cleaning up npm packages now"
      npm remove electron electron-packager
      rm -rfv ./release-builds
      echo "./release-builds cleaned."
      cleanup_func
      clear
      npm list
      break ;;

   3) echo "Package compile cancelled."
      clear
      exit ;;
   *) echo "Unknown.  Please choose one of the options."
      sleep 1 ;;
   esac
done