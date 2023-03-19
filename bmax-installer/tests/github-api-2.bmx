
'	Github Modserver API test
'	(c) Copyright Si Dunford [Scaremonger], FEB 2023, All rights reserved

'	Github only allows 60/hour anonymous and 5000/hour authenticated

'	This example downloads a single file from a repo
'	GITTOKEN needs to be taken from the environment variable


' TODO:
' After this is working, it needs to be merged into TModserver/TGithub/TRepository

SuperStrict

Import brl.base64

'Import bmx.json
'Import bah.libcurl

Import "../bin/config.bmx"
Import "../bin/TGitHub.bmx"
Import "../bin/TRepository.bmx"

CONFIG.initialise()
Print CONFIG.CERTPATH+"/"+CONFIG.CERTIFICATE

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

Global API:String = "http://api.github.com/repos/${USERNAME}/${REPO}/contents/${FILEPATH}"

Global repo:String = "BlitzMax"
If AppArgs.length = 2; repo = AppArgs[1]
DebugStop

Local repository:TRepository = New TRepository().find( repo )
Global modserver:TGithub = New TGithub( repository )

' We need to get a "modules" file from the modserver for a given username
' so we know what modules are available
' This means that an organisation or username must have a repo called "modserver"
' Or the name of the modserver repo is provided 

Function github_getfile:String( username:String, modrepo:String, filepath:String, token:String="" )
	
	Local url:String = API
	url = Replace( url, "${USERNAME}", username )
	url = Replace( url, "${REPO}", modrepo )
	url = Replace( url, "${FILEPATH}", filepath )
	DebugStop
	
	Local headers:String[] 
	If token <> "" Then headers = [ "Authorisation: "+token ]
	Local response:String = modserver.downloadString( url, headers )
	
	Return response
	

End Function

Try
	Local username:String = "blitzmax-itspeedway-net"
	Local modrepo:String = "sandbox" 			'default is modserver
	Local filepath:String = "modserver.json"
	Local token:String ' = GetEnv( "GITTOKEN" )
	
	' Get file "modserver.json" from root
	' (Content doesn't matter for this test as long as it is readable)

	Local jtext:String = github_getfile( username, modrepo, filepath, token )
	Local modules:JSON = JSON.parse( jtext )
	
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
	
	' Compare SHA to see if the file has changed.
	
	
	
Catch e:String
	Print e
End Try

