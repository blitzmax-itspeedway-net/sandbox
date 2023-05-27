'# CONFIGURATION
'# V1.0

Global config:TConfig = New TConfig.Load( ExtractDir(AppFile)+"/"+StripAll(AppFile)+".cfg" )
OnEnd TConfig.OnExit

'############################################################
Type TConfig
Field filename$
Field values:TMap = CreateMap()
'#	
 	'------------------------------------------------------------
	Method Load:TConfig( filename$ = "config.cfg" )
	Local file:TStream 
	Local line$, key$, value$, item$[], pos%
DebugLog "Config.Load("+filename+")"
		'#
		'# Default the configuration
		ClearMap( values )
DebugLog "Setting defaults..."
		setDefault()
		Self.filename = filename
		'#
DebugLog "Opening configuration..."
		If FileType( filename )<>1 Then Return Self
'DebugStop
Print FileType( filename )
		file = ReadFile( filename )
		If Not file Then Return Self	'# File missing or locked, either way ignore it.
		'#
DebugLog "Loading config..."
		While Not Eof( file )
			line = Trim( ReadLine( file ) )
			If line.startsWith("'") Or line.length=0 Then Continue
			pos = Instr( line, "=" )
			If pos=0 Then Continue		'# Ignore invalid lines
			set( line[..pos-1], line[pos..])
		Wend
		file.close()
	Return Self
	End Method

 	'------------------------------------------------------------
	Method save( name$="" )
	Local file:TStream
		If name<>"" Then filename = name
'DebugLog "Config.Save("+filename+")"
'DebugStop
		file = WriteStream( filename )
		If Not file Then Return		'Failed to save configuration
		For Local key:String = EachIn MapKeys( values )
			WriteLine file, key+"="+String(MapValueForKey( values, key ))
		Next
		CloseStream file
	End Method
	
 	'------------------------------------------------------------
	Method Get$( key$ )
	Return String( MapValueForKey( values, Upper( key ) ) )
	End Method

 	'------------------------------------------------------------
	Method Getint:Int( key$ )
	Return String( MapValueForKey( values, Upper( key ) ) ).toint()
	End Method

 	'------------------------------------------------------------
	Method Set( key$, value$ )
DebugLog "  CONFIG.set: "+key+"="+value
		MapInsert( values, Trim(Upper( key )), Trim( value ))
	End Method

	'------------------------------------------------------------
	Method SetDefault()
		set( "MAIN.X", "0" )
		set( "MAIN.Y", "0" )
		set( "MAIN.W", GadgetWidth( Desktop() ))
		set( "MAIN.H", 100 )
	End Method

	'============================================================
	Function onExit()
		config.save()
	End Function

End Type

