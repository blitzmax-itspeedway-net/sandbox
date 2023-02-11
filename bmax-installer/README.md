# BlitzMax Installer

EXPERIMENTAL

# Command Line

```
bmax --version      Application version
bmax list           List all modules
bmax show <module>  Show module detail

bmax --debug        Produced a CSV containing all module data

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

UPDATE FROM GITHUB
https://www.advancedinstaller.com/github-integration-for-updater.html

This uses the "Release" API

https://api.github.com/repos/<username>/<repository_name>/releases

Because it is HTTPS; we have to use Bruceys CURL module
    https://github.com/maxmods/bah.mod

    You will need 
        libcurl.mod
        libssh2.mod
        mbedtls.mod

    Copy them into mods/bah.mod (You may need to create the folder)
    
	ON LINUX:
	* You also need libidn
		sudo apt-get install libidn11-dev

INSTALLER LOGIC

	Some modules have Blitzmax dependencies
	Some modules have operating system dependencies
		For example, libcurl needs libidn11-dev
	
THINGS TO DO
* Document how to re-generate the certificate (Before it expires)


