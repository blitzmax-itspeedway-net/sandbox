
'	BlitzMax installer
'	(c) Copyright Si Dunford [Scaremonger], FEB 2023, All rights reserved

SuperStrict

?windows
	Const DIRSLASH:String = "\"
?Not windows
	Const DIRSLASH:String = "/"
?

'	Type used as namespace
'	I know a lot of people hate this, but it is better than in the global namespace right?
'
Type CONFIG
	
	Global BLITZMAX_RELEASE:String
	Global BMX_ROOT:String
	Global BMX_BIN:String
	Global BMX_CFG:String
	Global BMX_MOD:String
	Global BMX_SRC:String
	Global CERTPATH:String
	Global CERTIFICATE:String  = "cacert.pem"
	Global DOWNLOAD:String
	'Global SHAREDDATA:String
	'Global USERDATA:String
	'Global USERDESKTOP:String
	'Global USERDOCS:String
	Global USERHOME:String
	
	Function initialise()

		' Get the BlitzMax release platform
?linux
		BLITZMAX_RELEASE = "linux_x64"
?Win32x86
		BLITZMAX_RELEASE = "win32_x86"
?Win32x64
		BLITZMAX_RELEASE = "win32_x64"
?MacOSX64
		BLITZMAX_RELEASE = "macos_x64"
?raspberrypiARM
		BLITZMAX_RELEASE = "rpi_arm"
?
		' Get User folders
		'USERDATA    = GetUserDesktopDir()
		'USERDESKTOP = GetUserDesktopDir()
		'USERDOCS    = GetUserDocumentsDir()
		USERHOME    = GetUserHomeDir()
		'SHAREDDATA  = GetCustomDir( DT_SHAREDUSERDATA )

		' Set the Blitzmax root to existing or default
		Try
			' Attempt to set root to existing BlitzMax path
			BMX_ROOT = BlitzMaxPath()
		Catch Exception:String
			Print Exception
			SetRoot()		' Sets root to default
		EndTry

		ResetFolderNames()
	End Function

	' Reset folder variables
	Function ResetFolderNames()
		Print BMX_ROOT
		BMX_BIN  = BMX_ROOT+DIRSLASH+"bin"
		BMX_CFG  = BMX_ROOT+DIRSLASH+"cfg"
		BMX_MOD  = BMX_ROOT+DIRSLASH+"mod"
		BMX_SRC  = BMX_ROOT+DIRSLASH+"src"

		CERTPATH = BMX_ROOT+DIRSLASH+"cfg"
		DOWNLOAD = BMX_ROOT+DIRSLASH+"download"
	End Function

	' Change the installation folder
	Function SetRoot( root:String = "" )
		If root = ""	' Set to default
			BMX_ROOT = USERHOME+DIRSLASH+"BlitzMax"
		Else			' Specific path
			BMX_ROOT = root
		End If
		ResetFolderNames()
	End Function
	
	' Check all folders exist
	Function CreateFolders()
		For Local folder:String = EachIn [ BMX_ROOT, BMX_BIN, BMX_CFG, BMX_MOD, BMX_SRC, CERTPATH, DOWNLOAD ]
			MakeDirectory( folder )
		Next
		DebugStop
		' We will also copy our certificate
		Local src:String = AppDir+DIRSLASH+"certificate"+DIRSLASH+CERTIFICATE
		Local dst:String = CERTPATH+DIRSLASH+CERTIFICATE
		If Not CopyFile( src, dst ); Throw( "Failed to copy certificate" )
	End Function
	
	' Creates a folder if it doesn't exist
	Function MakeDirectory( folder:String )
		Select FileType( folder )
		Case FILETYPE_DIR	' Already exists
			Return
		Case 0				' Does not exist
			If CreateDir( folder ); Return
			Throw( "Unable to create '"+folder+"', please check your permissions" )
		Default				' A File of eror condition
			Throw( "Unable to create '"+folder+"'." )
		End Select
	End Function
	
	Private Method New(); End Method	' Prevent Create
	
End Type
