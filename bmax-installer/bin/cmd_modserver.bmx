
'SuperStrict

'Import "config.bmx"

'Import "TRelease.bmx"

Function cmd_modserver( args:String[] )
	Print "MODSERVER SUPPORT"
	If args.length < 2 die( "Missing argument:", AppTitle+" "+" ".join(args)+" <action>" )

	DebugStop
	Select args[1].toLower()
	Case "add"
		cmd_modserver_add( args )
	Case "list"
		cmd_modserver_list( args )
	Case "remove"
		cmd_modserver_remove( args )
	Case "show"
		cmd_modserver_show( args )
	Default
		die( "Unexpected argument:", AppTitle+" "+" ".join(args) )
	End Select
End Function

' Add a modserver to local configuration
Function cmd_modserver_add( args:String[] )
	Local name:String = args[2]
	Local modsv:String = args[2]
	Local colon:Int = Instr( modsv, ":" )
	Local modservertype:String = modsv[..(colon-1)].toUpper()
	Local path:String = modsv[colon..]
	
	DebugStop
	
	' Validate modserver by getting modserver.json
	Local modserver:TModserver

	Select modservertype
	Case "GITHUB"
		modserver = New TGithub( path )
		TModserver.register( name, modserver )
		'modserver = TModserver.find( "GITHUB" )
		'Local repository:TRepository = modserver.get
		'Local repository:TRepository = TRepository.get( modsv, path )
		'Local Jmodserver:JSON = modserver.getRemoteConfig( repository )
		
		'TODO:
		' Get the modserver default repository and download available packages		
		'Local repository:TRepository = modserver.repository()
		
		' Get the packages.json file from the repository
		'Local packages:String = repository.getfile( "packages.json" )
		
		' Parse the packages into the database
		
		'DebugStop
	Default
		Throw( "Invalid modserver type '"+modservertype+"'" )
	End Select

	'
	Local key:String = "modservers|"+modsv
	config[ key+"|type" ] = modservertype
	'config[ key+"|username" ] = username
	config[ key+"|repository" ] = path
	config.save()
End Function

' List all configured modservers
Function cmd_modserver_list( args:String[] )
End Function

' Remove a modserver from local configuration
Function cmd_modserver_remove( args:String[] )
End Function

' Show a modserver
Function cmd_modserver_show( args:String[] )
End Function

