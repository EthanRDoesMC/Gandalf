#!/bin/bash
#
# Packages "Gandalf" into a deb
#
# Follow https://google.github.io/styleguide/shell.xml
# for the most part (You can ignore some, like error checking for mv)
# Specify version

PKG_VERSION="2.5.5" #Bump this everytime you update something.

# Define script styling (tput)

BOLD=$(tput bold)
NORMAL=$(tput sgr0)
RED=$(tput setaf 1)

# Check if started without parameters
if [ "$1" = "" ]; then
   echo "${BOLD}USAGE:${NORMAL} './build.sh <versionfolder>'"
   exit 0
fi

# Check if folder exists

if [ ! -d $1 ]; then
   echo "${BOLD}${RED}FATAL:${NORMAL} There's no folder called '$1'. You have either misstiped something ${BOLD}(Linux is case-sensitive)${NORMAL} or the folder '$1' simply doesn't exist."
   echo "ABORT."
   exit 1
fi

# Check filestructure
if [ ! -f $1/conflicts.txt ] || [ ! -f $1/firmware.txt ] || [ ! -f $1/name.txt ] || [ ! -f $1/section.txt ]; then
   echo "${BOLD}${RED}FATAL:${NORMAL} Please check folder '$1'. There's either something missing or misstiped. Be sure you have the files"
   echo
   echo "  - conflicts.txt"
   echo "  - firmware.txt"
   echo "  - name.txt"
   echo "  - section.txt"
   echo
   echo "in folder '$1'."

    # Test if folder is empty
    if test "$(ls -A "$1")"; then
       echo "Currently there are the following files in folder '$1':"
       echo "---"
       ls -la $1
       echo "---"
       echo "${BOLD}Linux is case-sensitive!${NORMAL}"
     else
       echo "${BOLD}ERROR:${NORMAL} The folder '$1' is empty!"
   fi

   echo "${BOLD}ABORT.${NORMAL}"
   exit 1
fi

# Config
CONFLICTS_FILE="$1/conflicts.txt"
GDN_NAME=$(cat $1/name.txt)
GDN_FIRM=$(cat $1/firmware.txt)
#DO NOT TOUCH! (Unless you have a good reason...)
#Variable format is "PKG_FIELDNAME"
PKG_PACKAGE="io.github.ethanrdoesmc.gandalf$1"
PKG_NAME="Gandalf for ${GDN_NAME}"
PKG_DESCRIPTION="Some tweaks may break jailbreaks. Let this tweak say
  \"You Shall Not Pass!\" to incompatible tweaks and you can sit back and have
  fun with your jailbreak."
PKG_DEPICTION="https://ethanrdoesmc.github.io/gandalf/depictions/?p=io.github.ethanrdoesmc.gandalf102"
PKG_MAINTAINER="EthanRDoesMC <ethanrdoesmc@gmail.com>"
PKG_AUTHOR="EthanRDoesMC <ethanrdoesmc@gmail.com>"
PKG_SECTION=$(cat $1/section.txt)
PKG_DEPENDS="firmware ${GDN_FIRM}, sudo, com.officialscheduler.mterminal, mobilesubstrate"
PKG_REPLACES="com.enduniverse.cydiaextenderplus, com.github.ethanrdoesmc.gandalf, com.github.ethanrdoesmc.gandalf102"
PKG_ARCHITECTURE='iphoneos-arm'
PKG_BREAKS=$(cat ${CONFLICTS_FILE} | sed ':a;N;$!ba;s/\n/,\ /g')


# --- --- --- --- --- --- --- --- --- --- 
#Main script

#Start message
echo "Started packaging ${PKG_NAME}"

#Prepare the package structure
echo "Creating package structure..."

mkdir "${PKG_PACKAGE}"
mkdir "${PKG_PACKAGE}/DEBIAN"
mkdir -p "${PKG_PACKAGE}/usr/bin"
mkdir -p "${PKG_PACKAGE}/var/mobile/Downloads/Gandalf"


#Create the control file
echo "Creating the control file..."

cat <<EOF > "${PKG_PACKAGE}/DEBIAN/control";
Package: ${PKG_PACKAGE}
Name: ${PKG_NAME}
Version: ${PKG_VERSION}
Architecture: ${PKG_ARCHITECTURE}
Replaces: ${PKG_REPLACES}
Description: ${PKG_DESCRIPTION}
Depiction: ${PKG_DEPICTION}
Maintainer: ${PKG_MAINTAINER}
Author: ${PKG_AUTHOR}
Depends: ${PKG_DEPENDS}
Section: ${PKG_SECTION}
Breaks: ${PKG_BREAKS}
EOF


#Compress the application
echo "Compressing and moving Gandalf.app..."

tar -czf "Gandalf.app.tar.gz" "Gandalf.app"
mv "Gandalf.app.tar.gz" "${PKG_PACKAGE}/var/mobile/Downloads/Gandalf"


#Copy over the executable
echo "Bundling ${GANDALF_COMMAND_NAME}..."

cp "gandalf" "${PKG_PACKAGE}/usr/bin"

#Make it executable 
chmod +x "${PKG_PACKAGE}/usr/bin/gandalf"

#Copy the DEBIAN scripts
echo "Copying the DEBIAN scripts"

cp "prerm" "${PKG_PACKAGE}/DEBIAN"
cp "postinst" "${PKG_PACKAGE}/DEBIAN"
echo
read -p  "${BOLD}${RED}--- If you have anything else you need to put into Gandalf, now's the time. If you're finished or you don't want to add something press any key to continue. ---${NORMAL}"
echo

# Remove .DS_Store created by macOS (experimental)

find . -name '.DS_Store' -type f -delete

#Create the package
echo "Creating the package..."

dpkg-deb -Zgzip -b "${PKG_PACKAGE}"


#Clean up
echo "Cleaning up temporary files and folders..."
rm -rf "${PKG_PACKAGE}"

echo "Packaging done."
echo "Filename: ${BOLD}${PKG_PACKAGE}.deb${NORMAL}"
