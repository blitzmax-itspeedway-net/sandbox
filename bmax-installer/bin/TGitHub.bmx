
'	GitHub modserver for BlitzMax installer
'	(c) Copyright Si Dunford [Scaremonger], FEB 2023, All rights reserved

'	GITHUB API:
'	https://docs.github.com/en/rest/repos/contents?apiVersion=2022-11-28

'SuperStrict

'Import bmx.json

'Import "TModserver.bmx"
'Import "TRelease.bmx"
'Import "TRepository.bmx"

'TModServer.register( "GiTHUB", New TGithub() )

Type TGithub Extends TModserver

	Private
	
	Field path:String
	
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
	
	Method New( path:String )
		Self.path = path
	End Method
	
	Method getReleases:TList( repository:TRepository, filter:String = "" )
		Local data:JSON
		DebugStop
		
		' Check if we have a recent copy of Repository Releases in cache
		Local cachefile:String = CONFIG.DATAPATH + repository.filename()	
		If FileType( cachefile ) = FILETYPE_FILE And FileTime( cachefile ) > DateTime.time() - ONE_DAY
			' Load from cache
			Local jtext:String = LoadString( cachefile )
			data = JSON.parse( jtext ) 
		Else
			Print "Updating release information"
			'DebugStop
			If Not filter; Return Null
			data = JDownload( GITHUB_API + repository.path + "/releases" )
			' Cache release information
			If Not data Or data.isInvalid(); Return Null
			SaveString( data.prettify(), cachefile )
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
	
	Method getLatest:TRelease( repository:TRepository )
		Print "READING LATEST:"
		Local asset:JSON = JDownload( GITHUB_API + repository.path + "/releases/latest" )
'		Print asset.prettify()
'		DebugStop
		Return _TRelease( asset )
	End Method
	
	' Retrieve modserver.json from the modserver repository
	Method getRemoteConfig:JSON( repo:TRepository )
	
		Local url:String = GITHUB_API+repo.path+"/contents/modserver.json"
		DebugStop
		
		' Optionally add users github token
		Local headers:String[] 
		Local githubEnvironment:String = CONFIG["github|environment"]
		If Not githubEnvironment; githubEnvironment = "GITHUB_TOKEN"
		Local token:String = getenv_( "GITHUB_TOKEN" )
		If token = ""
			Print "WARNING: GITHUB token not found in '"+githubEnvironment+"'"
		Else
			Print "Using GITHUB token in environment variable '"+githubEnvironment+"'"
			headers = [ "Authorisation: "+token ]
		End If
		Local response:String = downloadString( url, headers )
		DebugStop
		
	End Method

	Method getLastCommit:String( repository:TRepository, filepath:String )
	'Method getLastCommit:String( username:String, modrepo:String, filepath:String, token:String="" )
'Global API:String = "http://api.github.com/repos/${USERNAME}/${REPO}/commits?path=${FILEPATH}&page=1&per_page=1"
		DebugStop
		Local curl:TCurlEasy = New TCurlEasy.Create()
		Local encoded:String = curl.escape( filepath )
		Local url:String = GITHUB_API+repository.path+"/commits?path="+encoded+"&page=1&per_page=1"
		
		'url = Replace( url, "${USERNAME}", username )
		'url = Replace( url, "${REPO}", modrepo )
		'url = Replace( url, "${FILEPATH}", encoded )
		
		
		DebugStop
		' Optionally add users github token
		Local headers:String[] 
		Local githubEnvironment:String = CONFIG["github|environment"]
		If Not githubEnvironment; githubEnvironment = "GITHUB_TOKEN"
		Local token:String = getenv_( "GITHUB_TOKEN" )
		If token = ""
			Print "WARNING: GITHUB token not found in '"+githubEnvironment+"'"
		Else
			Print "Using GITHUB token in environment variable '"+githubEnvironment+"'"
			headers = [ "Authorisation: "+token ]
		End If
		headers :+ [ "Content-Type:application/json" ]
		
		Local response:String = downloadString( url, headers )
		
		Return response
		

	End Method
	
End Type