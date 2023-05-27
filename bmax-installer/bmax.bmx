
'	BlitzMax installer
'	(c) Copyright Si Dunford [Scaremonger], FEB 2023, All rights reserved

' DEBUG COMMAND LINE:	install -in BlitzMaxNG

Rem TODO
* Finish ShowHelp()
* Add default modservers
End Rem

Rem

blitzmaxng, Offical Blitzmax, https://github.com/bmx-ng

	bmx-ng						APP		RELEASE
	maxide						APP		ZIP
	bcc							APP 	ZIP
	bmx							APP 	ZIP
	brl.mod						MODULE	ZIP

maxmods, Bruceys Modules, https://github.com/maxmods

	bah.mod						ZIP
		bah.volumes				MODULE	maxmods/bah.mod/volumes.mod
		etc...
	ifsogui.mod					MODULE	ZIP
		ifsogui.mod						maxmods/ifsogui.mod
		
blitzmaxmods, Scaremongers Modules, https://github.com/blitzmaxmods

	timestamp.mod				MODULE	ZIP
		bmx.timestamp
	modserver					MODSERVER	FILE
		packages.json

itspeedway, ITSpeedway modules, https://github.com/blitzmax-itspeedway-net

	Blitzmax-Language-Server	APP	ZIP
		bls
	json.mod					ZIP
		bmx.json
	observer.mod				ZIP
		bmx.observer
	behavior.mod				ZIP
		bmx.behavior

End Rem

Rem ARGUMENTS

' MODSERVER SUPPORT

bmax modserver [show]
bmax modserver add type>:<path>
bmax modserver remove type>:<path>

	<type>	Currently only GITHUB is supported
	<path>	For GITHUB, the path consists of <username>[/<repository>]

			<username>		The User or Organisation where the repository is located
			<repository>	The repository that contains the modserver.json descriptor
							(This defaults to "modserver" if not specified)

' REPOSITORY SUPPORT

bmax repo add type>:<path>
bmax repo [list]
bmax repo show <path>
bmax repo remove type>:<path>

bmax install bmx.libcurl
- Lookup repo for "bmx.libcurl"
	Username:"maxmods", Repository:"bah.mod", Type:Github, path="libcurl.mod"
	If it does not exist, Repository should ask modserver to update
		Modserver downloads modserver.json and updates repository list
		repeats find and if fail then exits
- Ask repo for "libcurl.mod/installer.json"
- File not found

bmax install bmx.timestamp
- Lookup repo for "bmx.timestamp"
	Username:"blitzmaxmods", Repository:"bmx.timestamp", Type:Github, path=""
	If it does not exist, Repository should ask modserver to update
	
- archive exists in "installer" folder?
	YES:
	- Ask repo for "installer.json"
		File found:
		- Get sha version and compare against downloaded sha
		  MATCH: You already have the latest version
		  NO MATCH: Begin Download
		File not found:
		  Begin download
	NO:
	 Begin download
- Download
  - Are we downloading release or latest! (--latest)

		

bmax update
- 

A MODSERVER ONCE ADDED IS CHECKED FOR UPDATES AND THIS POPULATES
AND MAINTAINS THE LIST OF REPOSITORIES.

So if we add a github repository, that github modserver is responsible.
If it has a modserver configured, it will take prescedence
- This is where we ned to request the modserver.json file
If not, the user can manage it.

A repo can contain multiple modules or packages!
- We download them as a ZIP, the module/package is in a path within that ZIP

End Rem

SuperStrict

'Import bah.libcurl
Import net.libcurl
Import bmx.json

'Import "bin/adler32.bmx"		' Also part of zlib but not exposed!
Import "bin/datetime.bmx"		'TODO: Move to Blitzmax own version
Import "bin/unzip.bmx"

Include "bin/utils.bmx"
Include "bin/config.bmx"
Include "bin/TOptions.bmx"

'Import "bin/TGitHub.bmx"

Include "bin/TDatabase.bmx"

Include "bin/TRepository.bmx"
Include "bin/TPackage.bmx"

Include "bin/TModserver.bmx"
Include "bin/TGitHub.bmx"

Include "bin/TRelease.bmx"

Include "bin/cmd_install.bmx"
'Include "bin/cmd_modserver.bmx"
'Import "bin/unzip.bmx"

Include "default-data.bmx"

'	INITIAISE CONFIG AND CREATE FOLDERS

'DebugStop

AppTitle = "bmax"
Local AppVersion:String = "0.0.0"
	
'DebugStop

'	DEBUGGING VERSION
CONFIG.setRoot( "BlitzMaxTest" )

'	LOAD OR CREATE DATABASE
Global DATABASE:TDatabase = New TDatabase()
DATABASE.update()
DATABASE.save()

'	ADD MODSERVERS TO LIST

'Local modservers:JSON = config.settings.find("modservers")
'Print modservers.prettify()
'debugStop

'For Local name:String = EachIn modservers.keys()
	'DebugStop
'	Local modserver:JSON = modservers.find(name)
	'Print modserver.prettify()
'	Select modserver.find("type").toInt()
'	Case MODSERVER_GITHUB
'		TModserver.register( name, New TGithub( modserver["repository"], modserver["desc"] ) )
'	EndSelect
'Next

'	PARSE ARGUMENTS
DebugStop
'Local args:String[] = AppArgs[1..]
'DebugLog( "## ARG COUNT: "+args.length )
'For Local n:Int = 0 Until args.length
'	DebugLog n+") "+args[n]
'Next

DebugLog( "## ARG COUNT: "+AppArgs.length )
If AppArgs.length < 2
	RestoreData help_syntax
	showdata()
EndIf

'ParseOption( AppArgs[2..] )

'	PARSE ARGUMENTS
Select AppArgs[1].tolower()
Case "repo", "modserver"
'	cmd_modserver( AppArgs[1..] )
Case "help"
	If AppArgs.length < 2
		RestoreData help_syntax
		showdata()
	End If
	
	Select AppArgs[2].toLower()
	Case "UNTESTED"
	Default
		die( "Sorry, help is not available for "+AppArgs[2] )
	End Select
	
Case "list"
'		cmd_list()
Case "show"
'		Assert args.length=2 Else "?" 'AppTitle+": expected 1 argument, found "+args.length
'		cmd_show( AppArgs[2] )
'Case "--debug"
'		DebugStop
'		cmd_debug( "all-modules.csv" )
Case "install"
	DebugStop
	If AppArgs.length < 3; Die( "No package specified" )
	Select True
	' No arguments is install blitzmax
	Case AppArgs[2].toLower() = "blitzmax"
		cmd_install_blitzmax( getOptions( AppArgs[3..] ) )
	Case Instr( AppArgs[2], "." ) > 0
		cmd_install_module( AppArgs[2], getOptions( AppArgs[3..] ) )
	Case AppArgs[2].startswith("-")
		Die( "No package specified" )
	Default
		cmd_install_package( AppArgs[2], getOptions( AppArgs[3..] ) )
	EndSelect
'Case "search"
'Case "download"		
'Case "remove", "uninstall"
Case "update"
	' Update packages from online repositories
Case "upgrade"
	' With no arguments we upgrade to the latest offical release
Case "version", "--version"
	Print AppTitle+" "+AppVersion+" ("+AppDir+")"
Default
	die( "Unknown command: " +AppArgs[1] )
End Select


