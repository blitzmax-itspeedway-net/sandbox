
'	BlitzMax installer
'	(c) Copyright Si Dunford [Scaremonger], FEB 2023, All rights reserved

SuperStrict

Import "config.bmx"
Import "TGitHub.bmx"
Import "TRepository.bmx"
Import "TRelease.bmx"

Function cmd_install_blitzmax()
	Print "Installing Blitzmax"
	DebugStop
	CONFIG.CreateFolders()
	' Get the repository for this package
	Local repository:TRepository = New TRepository.find( "BlitzMax" )
	' Create a modserver ready fro download
	Local modserver:TGitHub = New TGithub( repository )
	' Get available releases
	Local releases:TList = modserver.getReleases( CONFIG.BLITZMAX_RELEASE )
	If Not releases; Throw "Failed to obtain release information"
	' Select the latest release
	Local latest:TRelease = TRelease( releases.removeFirst() )
	' Download archive if we don't already have a copy
	If FileType( CONFIG.DOWNLOAD+DIRSLASH+latest.name ) = FILETYPE_FILE
		Print( latest.name +" already downloaded" )
	Else
		Print( "Downloading "+latest.name+"..." )	
		modserver.downloadBinary( latest.url, latest.name ) 
	End If
	
	' Decompress the library if we haven't already
	' FOR THIS WE NEED TO KNOW THE UNZIPPED NAME
	
	Local package:TPackege = New TPackage( "Blitzmax" )
	package.install()
	
	' 

	
End Function

Function cmd_install_package()
	Print "Installing Package"
	DebugStop
	CONFIG.CreateFolders()
End Function

Function cmd_install_module()
	Print "Installing Module"
	DebugStop
	CONFIG.CreateFolders()
End Function