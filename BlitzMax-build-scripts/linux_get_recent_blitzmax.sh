#!/bin/bash
# By GWRon, FEB 2023

# ensure curl is installed
# the -k param is used to allow certificate errors
# the -L param is used to follow redirections

VERSION=0.133.3.48
BMAX_FILE="BlitzMax_linux_x64_$VERSION.tar.xz"
BMAX_URL="https://github.com/bmx-ng/bmx-ng/releases/download/v$VERSION.linux.x64/$BMAX_FILE"

# create folders if needed
mkdir -p "BlitzMaxNG.downloads"
mkdir -p "BlitzMaxNG.downloads/mod"
mkdir -p "BlitzMaxNG.downloads/toolchain"


if [[ -e "BlitzMaxNG.downloads/$BMAX_FILE" ]]; then
	echo "downloads exist ... skipping"
else
	curl -k -L "$BMAX_URL" -o "BlitzMaxNG.downloads/$BMAX_FILE"
 
	curl -k -L "https://github.com/bmx-ng/bcc/archive/refs/heads/master.zip" -o "BlitzMaxNG.downloads/bcc.zip"
	curl -k -L "https://github.com/bmx-ng/bmk/archive/refs/heads/master.zip" -o "BlitzMaxNG.downloads/bmk.zip"
	curl -k -L "https://github.com/bmx-ng/brl.mod/archive/refs/heads/master.zip" -o "BlitzMaxNG.downloads/brl.mod.zip"
	curl -k -L "https://github.com/bmx-ng/pub.mod/archive/refs/heads/master.zip" -o "BlitzMaxNG.downloads/pub.mod.zip"
	curl -k -L "https://github.com/bmx-ng/audio.mod/archive/refs/heads/master.zip" -o "BlitzMaxNG.downloads/audio.mod.zip"
	curl -k -L "https://github.com/bmx-ng/text.mod/archive/refs/heads/master.zip" -o "BlitzMaxNG.downloads/text.mod.zip"
	curl -k -L "https://github.com/bmx-ng/random.mod/archive/refs/heads/master.zip" -o "BlitzMaxNG.downloads/random.mod.zip"
	curl -k -L "https://github.com/bmx-ng/sdl.mod/archive/refs/heads/master.zip" -o "BlitzMaxNG.downloads/sdl.mod.zip"
	curl -k -L "https://github.com/bmx-ng/net.mod/archive/refs/heads/master.zip" -o "BlitzMaxNG.downloads/net.mod.zip"
	curl -k -L "https://github.com/bmx-ng/image.mod/archive/refs/heads/master.zip" -o "BlitzMaxNG.downloads/image.mod.zip"
	curl -k -L "https://github.com/bmx-ng/maxgui.mod/archive/refs/heads/master.zip" -o "BlitzMaxNG.downloads/maxgui.mod.zip"
	curl -k -L "https://github.com/bmx-ng/database.mod/archive/refs/heads/master.zip" -o "BlitzMaxNG.downloads/database.mod.zip"
	curl -k -L "https://github.com/bmx-ng/archive.mod/archive/refs/heads/master.zip" -o "BlitzMaxNG.downloads/archive.mod.zip"
fi


echo "Preparing latest stable NG"
cd "BlitzMaxNG.downloads"
if [[ -e "BlitzMax" ]]; then
	echo "blitzmax unzipped... skipping"
else
	tar -xf "$BMAX_FILE"
fi

 
 
echo "Preparing module updates"
if [[ -e "mod/brl.mod" ]]; then
	echo "mods prepared ... skipping"
else
	unzip -o "brl.mod.zip" -d "mod"
	unzip -o "pub.mod.zip" -d "mod"
	unzip -o "audio.mod.zip" -d "mod"
	unzip -o "text.mod.zip" -d "mod"
	unzip -o "random.mod.zip" -d "mod"
	unzip -o "sdl.mod.zip" -d "mod"
	unzip -o "net.mod.zip" -d "mod"
	unzip -o "image.mod.zip" -d "mod"
	unzip -o "maxgui.mod.zip" -d "mod"
	unzip -o "database.mod.zip" -d "mod"
	unzip -o "archive.mod.zip" -d "mod"
	
	mv "mod/brl.mod-master" "mod/brl.mod"
	mv "mod/pub.mod-master" "mod/pub.mod"
	mv "mod/audio.mod-master" "mod/audio.mod"
	mv "mod/text.mod-master" "mod/text.mod"
	mv "mod/random.mod-master" "mod/random.mod"
	mv "mod/sdl.mod-master" "mod/sdl.mod"
	mv "mod/net.mod-master" "mod/net.mod"
	mv "mod/image.mod-master" "mod/image.mod"
	mv "mod/maxgui.mod-master" "mod/maxgui.mod"
	mv "mod/database.mod-master" "mod/database.mod"
	mv "mod/archive.mod-master" "mod/archive.mod"
fi
 
#unzip tools
echo "Preparing toolchain"
if [[ -e "toolchain/bcc" ]]; then
	echo "toolchain prepared ... skipping"
else
	unzip -o "bcc" -d "toolchain"
	unzip -o "bmk" -d "toolchain"
	mv "toolchain/bcc-master" "toolchain/bcc"
	mv "toolchain/bmk-master" "toolchain/bmk"
fi 
 
#compile bcc
echo "Compiling bcc"
cd "BlitzMax/bin"
./bmk makeapp -r -t console "../../toolchain/bcc/bcc.bmx"
cd ../..
echo "Updating bcc"
mv -f "BlitzMax/bin/bcc" "BlitzMax/bin/bcc.bak"
cp -rf "toolchain/bcc/bcc" "BlitzMax/bin/bcc"

 
#update modules - so we can update bmk
rm -r "BlitzMax/mod"
mv "mod" "BlitzMax"
 
 
#compile bmk
echo "Compiling bmk"
cd "BlitzMax/bin"
./bmk makeapp -r -t console "../../toolchain/bmk/bmk.bmx"
cd ../..
echo "Updating bmk"
cd "toolchain/bmk"
cp -rf "bmk" "../../BlitzMax/bin/"
cp -rf "core.bmk" "../../BlitzMax/bin/"
cp -rf "custom.bmk" "../../BlitzMax/bin/"
cp -rf "make.bmk" "../../BlitzMax/bin/"
cd ../..

#cleanup toolchain build dir
rm -r "toolchain"
 
 
cd ..
echo "=========="
echo "Setup is complete. You can close now.."
