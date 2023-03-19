
'	GitHub modserver for BlitzMax installer
'	(c) Copyright Si Dunford [Scaremonger], FEB 2023, All rights reserved

'	GITHUB API:
'	https://docs.github.com/en/rest/repos/contents?apiVersion=2022-11-28



SuperStrict

Import bmx.json

Import "TModserver.bmx"
Import "TRelease.bmx"
Import "TRepository.bmx"
Import "datetime.bmx"

Type TGithub Extends TModserver

	Private
	
	Const ONE_DAY:Int = 60*60*24	
	Const GITHUB_API:String = "http://api.github.com/repos/"

	Method _TRelease:TRelease( J:JSON )
		Local author:String    = J.find("author")["login"]
		Local published:String = J.find("published_at").toString()
		Local version:String   = J.find("tag_name").toString()
		
		Local assets:JSON[]    = J.find("assets").toArray()
		
		Local name:String      = assets[0].find("name").toString()
		Local size:Long        = assets[0].find("size").toLong()
		Local url:String       = assets[0].find("browser_download_url").toString()

		Return New TRelease( name, version, author, size, url )
	End Method

	Public
	
'	Method New()
'	End Method
	
	Method getReleases:TList( filter:String = "" )
		Local data:JSON
		DebugStop
		
		' Check if we have a recent copy of Repository Releases in cache
		Local filename:String = CONFIG.DOWNLOAD+DIRSLASH+repository.filename()
		If FileType( filename ) = FILETYPE_FILE And FileTime(filename ) < DateTime.time() - ONE_DAY
			' Load from cache
			Local jtext:String = LoadString( filename )
			data = JSON.parse( jtext ) 
		Else
			Print "Updating release information"
			DebugStop
			If Not filter; Return Null
			data = JDownload( GITHUB_API + repository.repo + "/releases" )
			' Cache release information
			If Not data Or data.isInvalid(); Return Null
			SaveString( data.prettify(), filename )
		End If
		
		' Extract release information	
		Local releases:TList = New TList()
		For Local asset:JSON = EachIn data.toArray()
			Local rel:TRelease = _TRelease( asset )
			If filter And Instr( rel.name, filter ) = 0; Continue
			releases.addlast( rel )
		Next
		If releases.isEmpty(); Return Null
		Return releases
	End Method
	
	Method getLatest:TRelease()
		Print "READING LATEST:"
		Local asset:JSON = JDownload( GITHUB_API + repository.repo + "/releases/latest" )
'		Print asset.prettify()
'		DebugStop
		Return _TRelease( asset )
	End Method
	
End Type