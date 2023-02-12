
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
	If Not releases; Throw "Failed to download release information"
	' Select the latest release
	Local latest:TRelease = TRelease( releases.removeFirst() )
	' Check if we have already downloaded it
	DebugStop
	If FileType( CONFIG.DOWNLOAD+DIRSLASH+latest.name+".zip" ) = FILETYPE_FILE
		Print( latest.name +" already downloaded" )
	Else
		Print( "Downloading "+latest.name+"..." )	
		modserver.downloadBinary( latest.url, latest.name+".zip" ) 
	End If
	
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