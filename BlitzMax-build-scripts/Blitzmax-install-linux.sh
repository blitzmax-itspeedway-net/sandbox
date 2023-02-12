#!/bin/sh

# BlitzMaxNG Installer
# Scaremonger, 2023

GITHUB=https://github.com
BLITZMAX=bmx-ng
SCAREMONGER=blitzmax-itspeedway-net
BRUCEYS_MODULES=maxmods

BLITZMAX_LATEST=0.133.3.48

#if [ ! -d ~/BlitzMax ]; then mkdir ~/BlitzMax; fi
if [ ! -d ~/BlitzMax/Downloads ]; then mkdir -p ~/BlitzMax/Downloads; fi
cd ~/BlitzMax/Downloads

BMX_NG=BlitzMax_linux_x64_${BLITZMAX_LATEST}.tar.xz

getarchive() {
    if [ ! -f "$2.zip" ]
    then
        echo curl -k -l "${GITHUB}/$1/$2/archive/refs/heads/master.zip" -o "$2.zip"
    fi
}

#curl -k -l "${GITHUB}/${BLITZMAX}/bmx-ng/releases/download/v${BLITZMAX_LATEST}.linux.x64/${BMX_NG}" -o "${BMX_NG}"

getarchive $BLITZMAX bcc 
#getarchive $BLITZMAX bmk
#getarchive $BLITZMAX maxide

# Get Standard BlitzMax Modules
#getarchive $BLITZMAX audio.mod
#getarchive $BLITZMAX brl.mod
#getarchive $BLITZMAX crypto.mod
#getarchive $BLITZMAX maxgui.mod
#getarchive $BLITZMAX mky.mod
#getarchive $BLITZMAX pub.mod
#getarchive $BLITZMAX random.mod
#getarchive $BLITZMAX sdl.mod
#getarchive $BLITZMAX steam.mod
#getarchive $BLITZMAX text.mod

# Optional Modules
#getarchive $BLITZMAX image.mod
#getarchive $BLITZMAX net.mod
#getarchive $BLITZMAX database.mod
#getarchive $BLITZMAX physics.mod
#getarchive $BLITZMAX boost.mod
#getarchive $BLITZMAX glfw.mod
#getarchive $BLITZMAX gfx.mod
#getarchive $BLITZMAX ray.mod
#getarchive $BLITZMAX odd.mod
#getarchive $BLITZMAX gdb.mod
#getarchive $BLITZMAX iot.mod
#getarchive $BLITZMAX zeke.mod

# Get Bruceys Modules
#getarchive $BRUCEYS_MODULES bah.mod

# Get Scaremongers Modules
#getarchive $SCAREMONGER observer.mod
#getarchive $SCAREMONGER json.mod

#unzip



