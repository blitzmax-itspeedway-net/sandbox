
'	BlitzMax installer
'	(c) Copyright Si Dunford [Scaremonger], FEB 2023, All rights reserved

'	A repository is a source of data located on a modserver.

'SuperStrict


'Global API:String = "http://api.github.com/repos/{USERNAME}/{REPO}/contents/{FILEPATH}"

Type TRepository

	'Global initialised:Int
	'Global repositories:TMap = New TMap()
	'Field JRepository:JSON

	                      ' GITHUB               WEBAPI  SOURCEFORGE
	Field name:String
	Field path:String     ' username/repository  n/a     n/a
	'Field revision:int
	Field platform:String ' GITHUB/WEBAPI/SOURCEFORGE etc

	Field modserver:TModserver
	
	'Function Initialise()
'DebugStop

	'	Local name:String, repo:String
	'	RestoreData repositories
	'	ReadData( name )
	'	ReadData( repo )
		
	'	While Name
	'		New TRepository( name, repo )
	'		ReadData( name )
	'		If name
	'			ReadData( repo )
	'		End If
	'	Wend

	'End Function

	' Retrieve a Repository
	Function get:TRepository( name:String )		
		' Get repository from database
		'DebugStop
		Local JRepository:JSON = DATABASE.get( "repositories", name )
		If Not JRepository; Return Null
		
		' Create repository object
		'Local repository:TRepository = New TRepository( JRepository )
		

		'TRepository( repositories.valueForKey( name.toLower() ) )
		'If repository; Return repository
		'repository = New TRepository()
		'repository.name = name
		'repository.path = path
		'repositories.insert( name.toLower(), repository )
		Local repository:TRepository = TRepository( JRepository.Transpose( "TRepository" ) )
		If repository; repository.initialise()
		Return repository
	End Function

	'Method New( JRepository:JSON )
	'	Self.JRepository = JRepository
	'End Method

	'Method find:TRepository( name:String )
	'	Return TRepository( repositories.valueForKey( name.toLower() ) )
	'End Method
	
	'Method workspace:String()
	'	Return username + "/" + repo
	'End Method
	
	' Format a temporary cache filename for this repository
	Method filename:String()
		Return name+"_releases.cache"
	End Method

	' Initialise the modserver for this repository
	Method initialise()
		Select platform
		Case "GITHUB"
			modserver = New TGithub( path )
		Default
			Die( "Unknown modserver '"+platform+"' defined for repository "+name )
		End Select
	End Method
	
	' Get releases for a package
	Method getReleases:TList( filter:String = "" )
		Return modserver.getReleases( Self, filter )
	End Method

	' Download a binary from the repository
	Method downloadBinary:Int( url:String, filename:String="" )
		Return modserver.downloadBinary( url, filename )
	End Method
	
	' Download a string from a file in the repository
	Method downloadString:String( url:String, headers:String[] = [] )
		Return modserver.downloadString( url, headers )
	End Method
	
	Method getLastCommit:String( filepath:String )
		Return modserver.getLastCommit( Self, filepath:String )
	End Method
	
End Type
'TRepository.initialise()

'#repositories
'DefData "BlitzMax", "bmx-ng/bmx-ng"	'	,TRepository.GITHUB
'DefData ""


