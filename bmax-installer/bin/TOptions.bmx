
' COmmand line options

Function getOptions:TMap( args:String[] )
	Local map:TMap = New TMap()
	
	For Local n:Int = 0 Until args.length

		Local arg:String = args[n]
		Local eq:Int = arg.find("=")
		
		' Options without a value
		If eq=-1
			Select arg.toLower()
			Case "-latest"
				map.insert( arg[1..].toLower(), "TRUE" )
			Default
				die( "Unknown option: "+arg )
			EndSelect				
			Continue
		End If
		
		Local key:String = arg[..eq].toLower()
		Local value:String = arg[eq..].Replace( "\","/" )

		If value.StartsWith( "~q" ) And value.EndsWith( "~q" ); value = value[1..-1]
		DebugStop
		' TEST ABOVE FUNCTIONALITY
		
		Select key
		Case "-into"
			map.insert( "into", value )
		Default
			die( "Unknown argument: "+arg )
		End Select
		
	Next
	
End Function
