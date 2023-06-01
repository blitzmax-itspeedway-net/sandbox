
Type TDatabase 

	Global db:JSON
	
	Field changed:Int = False
	Field updated:Int = True		' USed to flag when an update has occurred (To stop multiple)

	' Create required folders
	Function CreateFolders()
		For Local folder:String = EachIn [ CONFIG.BMX_ROOT, CONFIG.DATAPATH ]
			MakeDirectory( folder )
		Next
	End Function
	
	' Load or Create a database
	Method New()
	
		'DebugStop
		Local dbtext:String
		If FileType( CONFIG.DATAPATH+CONFIG.DATABASE ) = FILETYPE_FILE
			dbtext = LoadString( CONFIG.DATAPATH+CONFIG.DATABASE )
			If Not dbtext 
				Print( "- Database initialised" )
				db = New JSON()
			Else
				db = JSON.parse( dbtext )
				If db.isInvalid()
					Print( "- Invalid database re-initialised" )
					db = New JSON()
				End If
			End If
		Else
			Print( "- Database created" )
			db = New JSON()
			changed = True
		End If
		
		add_default_packages()
		add_default_repositories()
		add_default_modservers()
		
	End Method
	
	' Save database to disk
	Method save()
		'DebugStop
		If Not changed; Return
		CreateFolders()
		If Not FileType( CONFIG.DATAPATH ) = FILETYPE_DIR; Return
		Local dbtext:String = db.prettify()
		'Print CONFIG.DATAPATH+CONFIG.DATABASE
		SaveString( dbtext, CONFIG.DATAPATH+CONFIG.DATABASE )
		changed = False
		Print( "- Database saved." )
	End Method
	
	' Add default modservers to database
	Method add_default_modservers()
		Local updated:Int = False
		Local J:JSON = JSON.parse( DEFAULT_MODSERVERS )
		If Not J die( "Failed to parse DEFAULT MODSERVERS" )
		If J.isInValid() die( "Failed to parse DEFAULT MODSERVERS", J.error() )
	'DebugStop
		
		Local jmodservers:JSON[] = J.toArray()
		For Local jmodserver:JSON = EachIn jmodservers
			' Get details from package
			Local name:String = jmodserver.find("name").toString()
			If Not name; Continue

			' Get details from database
			Local modservers:JSON = db.search( "modservers" )
			'DebugStop
			If Not modservers
				modservers = New JSON( )
				db.set( "modservers", modservers )
			End If
			'Print db.prettify()
			Local record:JSON = modservers.search( name )
			
			' New record?
			If record And record.isValid(); Continue
			modservers.set( name, jmodserver )
			updated = True
		Next
		'Print db.prettify()
		If updated; Print "- Updated default modservers to database."
		
	End Method

	' Add default packages to database
	Method add_default_packages()
		Local updated:Int = False
		Local J:JSON = JSON.parse( DEFAULT_PACKAGES )
		If Not J die( "Failed to parse DEFAULT PACKAGES" )
		If J.isInValid() die( "Failed to parse DEFAULT PACKAGES", J.error() )
	'DebugStop
		
		Local jpackages:JSON[] = J.toArray()
		For Local jpackage:JSON = EachIn jpackages

			' Get details from package
			Local p_name:String = jpackage.find("name").toString()
			If Not p_name; Continue

			' Get details from database
			Local packages:JSON = db.search( "packages" )
			If Not packages
				packages = New JSON()
				db.set( "packages", packages )
			End If
			'Print db.prettify()
			Local record:JSON = packages.search( p_name )
			
			' New record
			If Not record Or record.isInvalid()
				'Print "? Adding package "+p_name+" to database."
				packages.set( p_name, jpackage )
				Continue
			End If
			
			' Update existing record?	
			Local p_revision:Int = jpackage.find("revision").toInt()
			If record.find( "revision" ).toInt() < p_revision
				Print "? Updating package "+p_name+" record"
				record["revision"]   = p_revision
				record["modserver"]  = jpackage.find("modserver").toString()
				record["repository"] = jpackage.find("repository").toString()
				record["zippath"]    = jpackage.find("zippath").toString()
			End If
			updated = True
			
		Next
		'Print db.prettify()
		If updated; Print "- Updated default packages to database."
	End Method

	' Add default repositories to database
	Method add_default_repositories()
		Local updated:Int = False
		Local J:JSON = JSON.parse( DEFAULT_REPOSITORIES )
		If Not J die( "Failed to parse DEFAULT PACKAGES" )
		If J.isInValid() die( "Failed to parse DEFAULT PACKAGES", J.error() )
	'DebugStop
		
		Local JRepositories:JSON[] = J.toArray()
		For Local JRepo:JSON = EachIn JRepositories

			' Get details from package
			Local name:String = JRepo.find("name").toString()
			If Not name; Continue

			' Get details from database
			Local repositories:JSON = db.search( "repositories" )
			If Not repositories
				repositories = New JSON()
				db.set( "repositories", repositories )
			End If
			'Print db.prettify()
			Local record:JSON = repositories.search( name )
			
			' New record
			If Not record Or record.isInvalid()
				'Print "? Adding package "+p_name+" to database."
				'Print JRepo.prettify()
				repositories.set( name, JRepo )
				Continue
			End If
			
			' Update existing record?	
			Local revision:Int = JRepo.find("revision").toInt()
			If record.find( "revision" ).toInt() < revision
				Print "? Updating repository "+name+" record"
				record["revision"] = revision
				record["platform"] = JRepo.find("platform").toString()
				record["path"]     = JRepo.find("path").toString()
				'record["zippath"] = JRepo.find("zippath").toString()
			End If
			updated = True
			
		Next
		'Print db.prettify()
		If updated; Print "- Updated default repositories to database."
	End Method
	
	' Get records
	Method get:JSON( section:String, criteria:String )
		Local JSection:JSON = db.search( section )
		If Not JSection; Return Null
		Return JSection.search( criteria )
	End Method
	
	Method update()
		If updated; Return	' Already updated
		
		' Get array of Repositories
		
		Local JRepositories:JSON = db.search( "repositories" )
		If Not JRepositories; Die( "No repositories defined" )
		
		' Loop through each repository, updating it
		
		For Local name:String = EachIn JRepositories.keys()

			' Get Repository
			Local repository:TRepository = TRepository.get( name )
			If Not repository; Continue
			
			' Download "packages.json"
			Local packages:String = repository.downloadString( "packages.json" )

			DebugStop
			
			'WE ARE HERE
			Print( "IMPLEMENTATION INCOMPLETE" )

		Next
		
	End Method

	Method filecache_add( filename:String, package:String )
		Local filecache:JSON = db.find( "filecache" )
		Local file:JSON = New JSON()
		file["name"]    = filename
		file["package"] = package
		file["date"]    = FileTime( CONFIG.DATAPATH+cachefile )
		filecache[filename] = file
		save()
	End Method
	
	Method filecache_remove( filename:String, package:String )
		Local filecache:JSON = db.find( "filecache" )
	End Method
	
	Method filecache_get:TList( package:String )
		Local filecache:JSON = db.find( "filecache" )
		
		' Loop through each cache entry
		For Local name:String = EachIn JRepositories.keys()
		
		Local files:TList = New TList()
		For Local file:JSON = EachIn filecache.toArray()
			If package="" Or file["package"]=package; files.addlast( file )
		Next
		If files.isEmpty(); Return Null
		Return files
		
	End Method
	
End Type
