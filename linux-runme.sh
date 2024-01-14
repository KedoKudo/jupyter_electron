#!/bin/bash

# Install helper script for jupyter-electron-app
#
# 11-Jan-2024: Rev. 1      -  John L   -  Initial build
# 12-Jan-2024: Rev. 1.1    -  John L   -  Tab fixes
# 13-Jan-2024: Rev. 2      -  John L   -  Rewrite for clarity and:
#                                            - Create main function
#                                            - Update function calls
#                                            - Add default install value
# 14-Jan-2024: Rev. 2.1    -  John L   -  Update choices for non-root alt loc
#                                            - Rename functions
#                                            - moved default VARs to top
#                                            - Update menu items
#
#
# TODO: Add line item to update thru git
#






############  Set DEFAULT INSTALL value in User's home dir  ###################
HOMEDIR=$( getent passwd "$USER" |cut -d: -f6 )
INST_DIR=$HOMEDIR/.local/share/jupyter-electron-app

clear

###########################  Welcome info   ###################################
menu_func () {
   echo "
   ####################################################
   ##          Linux installation helper for         ##
   ##              jupyter-electron-app              ##
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
   echo ""
   echo "> Q or q. QUIT / CANCEL / EXIT"
}

####### Create timer_func function to allow reading and time to cancel ########
timer_func () {
   secs=$((5 * 1))
   while [ $secs -gt 0 ]; do
      echo -ne ">>> $secs \033 \r"
      sleep 1
      : $((secs--))
   done
}

############# Install the req'd npm files and run packager  ###################
npm_func () {
   echo "building electron packages"
   npm install electron electron-packager
   npm run package-linux
}

#################   Give User INSTALL DIR choice  #############################
install_chooser_func () {
   echo -e "\n\n\nDefault deployment location is $INST_DIR"
   while IFS= read -p "Install to alternative location, (y/n/q) > " \
   && [[ $REPLY != [Qq] ]]; do
      case $REPLY in
      [Yy]) while IFS= read -p \
      "Will alternative location require elevated privileges, (y/n) > "; do
               case $REPLY in
               [Yy]) echo "Deploying as root."
                     read -p "Full path to alternative location: > " INST_DIR
                     install_func_root
                     break ;;
               [Nn]) echo "Deploying as local user."
                     read -p "Full path to alternative location: > " INST_DIR
                     install_func_local
                     break ;;
               *   ) echo "Please enter y/Y or n/N" ;;
               esac
            done
         exit ;;
      [Nn]) echo "install_func_local"
         exit ;;
      *   ) echo -e "Please enter y/Y, n/N, or q/Q to QUIT." ;;
      esac
   done
}

#######################  Package Installer  ###################################
install_func_local () {
   echo "Moving files to $INST_DIR"
   timer_func
   mv ./release-builds/jupyter-electron-app-linux-x64 $INST_DIR
   ##chmod -R 755 $INST_DIR
}
install_func_root () {
   echo "Moving files to $INST_DIR"
   timer_func
   mv ./release-builds/jupyter-electron-app-linux-x64 /tmp/
   sudo mv /tmp/jupyter-electron-app-linux-x64 $INST_DIR
   sudo chown -R root:root $INST_DIR
   sudo chmod -R 755 $INST_DIR
}

################## Clean up any residual files in /tmp/ #######################
cleanup_func () {
   timer_func
   echo "cleaning up any /tmp/ files"
   rm -rfv /tmp/electron-packager
   # rm -fv /tmp/jupyter-electron-app-*.rpm
}

###############################################################################
###############################################################################
###############################################################################
main () {
   menu_func
   read -p "> " USER_OPTION

   ## Start the chosen option
   case "$USER_OPTION" in
   1  )  echo "Building packages..."
         timer_func
         npm_func
         install_chooser_func
         echo "$(date +%F--%H:%M:%S) > Installed to $INST_DIR" >> activity_log.txt
         echo "Cleaning up..."
         cleanup_func
         # clear
         ## list current npm-installed packages before exiting
         npm list
         exit ;;

   2  )  echo "Cleaning up npm packages in..."
         cleanup_func
         npm remove electron electron-packager
         rm -rfv ./release-builds
         echo "./release-builds cleaned."
         echo "$(date +%F--%H:%M:%S) > Activated cleanup_func." >> activity_log.txt
         # clear
         ## list empty npm-installed packages before exiting, for verification
         npm list
         exit ;;

   [Qq]) echo "Quiting."
         clear
         exit ;;

   *   ) echo "Unknown option.  Please choose properly."
         sleep 1
         clear ;;
   esac

}

###########################   run it   ########################################
while true
do
   main
done
