
'	BlitzMax installer
'	(c) Copyright Si Dunford [Scaremonger], FEB 2023, All rights reserved

'SuperStrict

'Import "config.bmx"
'Import "TGitHub.bmx"
'Import "TRepository.bmx"
'Import "TRelease.bmx"

Function cmd_install_blitzmax( options:TMap )
	DebugStop
	Local name:String = "blitzmax"
	'CONFIG.CreateFolders()

	' Get the package from database
	Local package:TPackage = New TPackage.get( name )
	If Not package; die( "Package "+name+" not found in database" )

	' Get the repository for this package
	Local repository:TRepository = New TRepository.get( package.repository )
	If Not repository; die( "Repository not found for "+name )
	
	Print "-Installing Blitzmax"
	
	' Get available releases

	Local releases:TList = repository.getReleases( CONFIG.BLITZMAX_RELEASE )
	If Not releases; Die( "Failed to obtain release information" )
	' Select the latest release
	Local latest:TRelease = TRelease( releases.removeFirst() )
	' Download archive if we don't already have a copy
	If FileType( CONFIG.DATAPATH+latest.name ) = FILETYPE_FILE
		Print( latest.name +" already downloaded" )
	Else
		Print( "Downloading "+latest.name+"..." )	
		Local size:Int = repository.downloadBinary( latest.url, latest.name ) 
		' Check size with release information
		If size <> latest.size
			' Delete failed download
			If FileType( CONFIG.DATAPATH+latest.name ) = FILETYPE_FILE
				DeleteFile( CONFIG.DATAPATH+latest.name )
			End If
			die( "Failed to download release" )
		End If
	End If

	' Decompress the "blitzmax" folder into our working directory
	
	Local source:String = CONFIG.DATAPATH+latest.name
	Local target:String = CONFIG.DATAPATH+package.target
	Local folder:String = package.folder
	
	' Check target is folder or path!
	If Not target.endswith( DIRSLASH )
		target :+ folder
	End If
	
	'	DECOMPRESS
	
	Try
		unzip( source, folder, target, unzipNotifier )
	Catch e:TRuntimeException
		Print e.error
	Catch e:String
		Print e
	End Try
	
	'	OPTIONS
	If Not options.contains( "latest" ); Return
	
	DebugStop
	
	'	INSTALL LATEST PACKAGES
	'cmd_install_package( "bcc" )
	'cmd_install_package( "bmk" )
	
	'	INSTALL LATEST MODULES
	'For Local name:String = EachIn LATEST_MODULES
	'	cmd_install_module( name )
	'Next
	
	' Should we compile some of the modules?
	
End Function

Function cmd_install_package( name:String, options:TMap=Null )
	DebugStop

	' Validation
	If FileType( CONFIG.BMX_BIN+CONFIG.BMX_BCC ) <> FILETYPE_FILE Or..
	   FileType( CONFIG.BMX_BIN+CONFIG.BMX_BMK ) <> FILETYPE_FILE
		die( "Blitzmax is not installed" )
	End If

	' Get the package from database
	Local package:TPackage = New TPackage.get( name )
	If Not package; die( "Package "+name+" not found in database" )
	Print "-Installing Package"

	' Get the repository for this package
	Local repository:TRepository = New TRepository.get( package.repository )
	If Not repository; die( "Repository not found for "+name )

End Function

Function cmd_install_module( name:String, options:TMap=Null )
	DebugStop

	' Validation
	If FileType( CONFIG.BMX_BIN+CONFIG.BMX_BCC ) <> FILETYPE_FILE Or..
	   FileType( CONFIG.BMX_BIN+CONFIG.BMX_BMK ) <> FILETYPE_FILE
		die( "Blitzmax is not installed" )
	End If

	' Get the package from database
	Local package:TPackage = New TPackage.get( name )
	If Not package; die( "Module "+name+" not found in database" )
	Print "-Installing Module"

	' Get the repository for this package
	Local repository:TRepository = New TRepository.get( package.repository )
	If Not repository; die( "Repository not found for "+name )
	
	

End Function



' Callback for unzip
Function unzipNotifier( event:Int, pathname:String, data:Int=0 )
	Global begin:Int

	Select event
	Case EVENT_UNZIP_START
		Print( "Unzipping "+pathname )
		begin = MilliSecs()
	Case EVENT_UNZIP_ENTRY
		Print( "* "+pathname )
	Case EVENT_UNZIP_FINISH
		Print( "Completed in "+(MilliSecs()-begin)+"ms" )
	EndSelect
	
End Function