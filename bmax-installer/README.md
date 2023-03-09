# BlitzMax Installer

EXPERIMENTAL

CURRENT STATE:
Will download latest official release but does not unzip it etc (yet)


NEED COMMUNITY INPUT BUT THIS MIGHT CHANGE

* Instructions to install should be:

    Create folder in home directory called BlitzMax
    Copy the downloaded file to that folder
    Unzip it.
    Run the executeable for your platform

* This applicaton MUST install into the current folder
    so the use of -in and -default are not available
   THE CHOICE OF FOLDER IS MADE BY THE CREATION OF FOLDER
   NT BY --default or --in xxx

* Community input into this change is necessary 


# Command Line

NOTE: This should be based on something like "apt"

```
bmax --version      Application version
bmax list           List all modules
bmax show <module>  Show module detail

bmax --debug        Produced a CSV containing all module data

THESE ARE IN PROGESS AND ARE EXPERIMENTAL
bmax install [--default|--in <folder>]	Installs latest release of Blitzmax
	--default							Install in default location
	--in <folder>						Specify the installation directory

bmax install <package|module>			Installs latest package or module

FROM HERE ARE NOT IMPLEMENTED:
bmax upgrade

bmax update <package|module>
bmax install <package|module>
bmax uninstall <package|module>			

# NOTES

The application currently collects info from ModuleInfo statements in modules and follows include and import statements for dependencies

Before INSTALL/UNINSTALL is possible, we need a way to identify some additonal data:

    One or more "modserver" definitions where module details can be downloaded
    modserver definitions should contain module version numbers that can be used to
        identify modules that need to be updated
    the definitions also need to provide dependency information and this is the tricky bit
        How to document the module versions that everything works with.

    The module version number and details really needs to be in an external file. Parsing the modules to get
    this information is not the correct way to do it, but for now thats all that can be done

    Maybe Brucey will see this and add some type of dependency system in the modules.

    @bmk version - (see some of my other modules) can write version details to a file
        Basically it should write to some type of JSON file.

	Need a way to flag depreciated modules to the user
	
UPDATE FROM GITHUB
https://api.github.com/
https://www.advancedinstaller.com/github-integration-for-updater.html
https://docs.github.com/en/rest/releases/releases?apiVersion=2022-11-28

This uses the "Release" API

To get a list of releases; you call this:
https://api.github.com/repos/<username>/<repository_name>/releases

Because it is HTTPS; we have to use Bruceys CURL module
    https://github.com/maxmods/bah.mod

    You will need 
        libcurl.mod
        libssh2.mod
        mbedtls.mod
	
		volumes.mod		<- Now part of BlitzMaxNG brl.volumes

    Copy them into mods/bah.mod (You may need to create the folder)
    
	ON LINUX:
	* You also need libidn
		sudo apt-get install libidn11-dev

INSTALLER LOGIC

	Some modules have Blitzmax dependencies
	Some modules have operating system dependencies
		For example, libcurl needs libidn11-dev
	Find list of documented libraries for "sudo apt-get install"

MODSERVER INFORMATION

PACKAGE			REPO					MODSERVER		INSTALL
BlitzMaxNG		bmx-ng					bmx-ng					
BlitzMax		bmx-ng					bmx-ng

bcc				bmx-bg					bcc				. to ${BLITZMAX}/src/bcc
		After compile: the exe needs copying to ${BLITZMAX}/bin/
bmk				bmx-bg					bmk				. to ${BLITZMAX}/src/bmk
		After compile: the exe needs copying to ${BLITZMAX}/bin/
maxide			bmx-bg					maxide			. to ${BLITZMAX}/src/maxide
		After compile: the exe needs copying to ${BLITZMAX}/
bmax			blitzmax-itspeedway-net	bmax			. to ${BLITZMAX}/src/bmax
		After compile:
			the exe needs copying to ${BLITZMAX}/
			Copy package database into ${BLITZMAX}/cfg/
bls				blitzmax-itspeedway-net	bls				tbc

audio.*			bmx-bg
brl.*			bmx-bg
crypto.mod		bmx-bg
maxgui.mod		bmx-bg
mky.mod			bmx-bg
pub.mod			bmx-bg
random.mod		bmx-bg
sdl.mod			bmx-bg
steam.mod		bmx-bg
text.mod		bmx-bg

bah.libcurl		maxmods 				bah.mod			Modules inside parent zip
bah.mbedtls		maxmods 				bah.mod			Modules inside parent zip
bah.libssh2		maxmods 				bah.mod			Modules inside parent zip

bmx.observer	blitzmax-itspeedway-net	observer.mod	. to /mod/bmx/observer.mod
bmx.json		blitzmax-itspeedway-net	json.mod		. to /mod/bmx/json.mod

Need to document other users modules; i'm sure there are a lot of them

THINGS TO DO
* Document how to re-generate the certificate (Before it expires)
* Do we need setProgressCallback() in TModserver.downloadString()?
* setProgressCallback() needs to be in MB instead of bytes... and only show increases.
* Improve TModserver.sanitise()
* We dont need to download releases EVERY time. Once per day is enough.


