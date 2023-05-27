
'	Github Modserver API test
'	(c) Copyright Si Dunford [Scaremonger], FEB 2023, All rights reserved

'	Github only allows 60/hour anonymous and 5000/hour authenticated

'	This example gets the last commit date for a file
'	GITTOKEN needs to be taken from the environment variable

SuperStrict

'Import brl.base64
Import net.libcurl
Import "../bin/datetime.bmx"		'TODO: Move to Blitzmax own version

Import bmx.json
'Import bah.libcurl


Include "../default-data.bmx"

Include "../bin/utils.bmx"
Include "../bin/config.bmx"
Include "../bin/TGitHub.bmx"
Include "../bin/TDatabase.bmx"
Include "../bin/TModserver.bmx"
Include "../bin/TRelease.bmx"
Include "../bin/TRepository.bmx"
Include "../bin/TPackage.bmx"

'CONFIG.initialise()
Print CONFIG.CERTPATH+"/"+CONFIG.CERTIFICATE

Global DATABASE:TDatabase = New TDatabase()
DATABASE.update()
DATABASE.save()

' Set platform specific filters
Global BLITZMAX_FILTER:String
?linux
		BLITZMAX_FILTER = "linux_x64"
?Win32x86
		BLITZMAX_FILTER = "win32_x86"
?Win32x64
		BLITZMAX_FILTER = "win32_x64"
?MacOSX64
		BLITZMAX_FILTER = "macos_x64"
?raspberrypiARM
		BLITZMAX_FILTER = "rpi_arm"
?


' We need to get a "modules" file from the modserver for a given username
' so we know what modules are available
' This means that an organisation or username must have a repo called "modserver"
' Or the name of the modserver repo is provided 



DebugStop

'Global API:String = "http://api.github.com/repos/${USERNAME}/${REPO}/contents/${FILEPATH}"

'Const USERNAME:String = "blitzmaxmods"
'Const REPO:String = "bmx.timestamp"

Global package:TPackage = New TPackage().get( "bmx.timestamp" )

'If "File" specified in package, Then use that, otherwise get package.json commit.
'We could Then use package.json To get version, dependency And title information during update.

Try

	DebugStop
	Local jtext:String = package.getLastCommit()
	
	Local response:JSON = JSON.parse( jtext )
	
	DebugStop
	Rem
	' Validate response from modserver
	If modules.isInvalid() Or Lower(modules["message"])="not found"
		Print "** FAILED TO GET MODSERVER FILE **"
	Else
		Print modules.prettify()

		Local content:String
		Local sha:String = modules["sha"]
		Local encoded:String = modules["content"]
		Local encoding:String = modules["encoding"]
		If encoding = "base64"
			Local data:Byte[] = TBase64.Decode(encoded)
			content = String.FromUTF8String(data)
		End If

		Local m:JSON = JSON.parse( content )
		If m And m.isValid()
			Print m.prettify()
		End If
	End If
	DebugStop
	EndRem
	
	' Compare SHA to see if the file has changed.
	
	
	
Catch e:String
	Print e
End Try

