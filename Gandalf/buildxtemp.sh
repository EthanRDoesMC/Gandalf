#!/bin/bash
# 
# Packages "Gandalf" into a deb
#
# Follow https://google.github.io/styleguide/shell.xml
# for the most part (You can ignore some, like error checking for mv)

# This file is so that I can have a nice restful saturday
# In other words, it's a temporary solution.
# Can we start working towards an all-in-one build.sh that you choose the version in the terminal?
# Config
PKG_VERSION="1.0.1" #Bump this everytime you update something.
CONFLICTS_FILE="conflictsportal.txt"

#DO NOT TOUCH! (Unless you have a good reason...)
#Variable format is "PKG_FIELDNAME"
PKG_PACKAGE="io.github.ethanrdoesmc.gandalfx"
PKG_NAME="Gandalf for YaluX (Mach_Portal)"
PKG_DESCRIPTION="Some tweaks may break jailbreaks. Let this tweak say
  \"You Shall Not Pass!\" to incompatible tweaks and you can sit back and have
  fun with your jailbreak."
PKG_DEPICTION="https://ethanrdoesmc.github.io/gandalf/depictions/?p=io.github.ethanrdoesmc.gandalf102"
PKG_MAINTAINER="EthanRDoesMC <ethanrdoesmc@gmail.com>"
PKG_AUTHOR="EthanRDoesMC <ethanrdoesmc@gmail.com>"
PKG_SECTION="Gandalf_For_YaluX_AKA_Mach_Portal"
PKG_DEPENDS="firmware (>=10.1), sudo, com.officialscheduler.mterminal"
PKG_REPLACES="com.enduniverse.cydiaextenderplus, com.github.ethanrdoesmc.gandalf, com.github.ethanrdoesmc.gandalf102"
PKG_ARCHITECTURE='iphoneos-arm'
PKG_BREAKS=$(cat ${CONFLICTS_FILE} | sed ':a;N;$!ba;s/\n/,\ /g')

#Script specific variables.
GANDALF_COMMAND_NAME="gandalf102"

#Main script

#Start message
echo "Started packaging ${PKG_NAME}"

#Prepare the package structure
echo "Creating package structure..."

mkdir "${PKG_PACKAGE}"
mkdir "${PKG_PACKAGE}/DEBIAN"
mkdir -p "${PKG_PACKAGE}/usr/bin"
mkdir -p "${PKG_PACKAGE}/var/mobile/Downloads/Gandalf102"


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

tar -czf "Gandalf.app.tar.gz" "gandalf.app"
mv "Gandalf.app.tar.gz" "${PKG_PACKAGE}/var/mobile/Downloads/Gandalf102"


#Copy over the executable
echo "Bundling ${GANDALF_COMMAND_NAME}..."

cat "gandalf102" \
  | sed "s/iDenT1FIEr/${PKG_PACKAGE}/" \
  | sed "s/vErs10Nname/${PKG_NAME}/" \
  > "${PKG_PACKAGE}/usr/bin/${GANDALF_COMMAND_NAME}"

#OKAYEY PLZE WORK
#DOIN ME A SIGNIFICATE FRUSTRATE

chmod 0775 "${PKG_PACKAGE}/usr/bin/${GANDALF_COMMAND_NAME}"

#Copy the DEBIAN scripts
echo "Copying the DEBIAN scripts"

cp "prerm" "${PKG_PACKAGE}/DEBIAN"
cp "postinst" "${PKG_PACKAGE}/DEBIAN"


#Create the package
echo "Creating the package..."

dpkg-deb -Zgzip -b "${PKG_PACKAGE}"


#Clean up
echo "Cleaning up temporary files and folders..."
rm -rf "${PKG_PACKAGE}"

echo "Packaging done."
echo "Filename: ${PKG_PACKAGE}.deb"
