
Type TConfig Extends TMap
	Field filename:String

	Method Load( filename:String )
		' Load configuration
		Self.filename = filename
		Local file:TStream = OpenFile( filename )
		If file 
			Self.clear()
			While Not Eof(file)
				Local line:String = ReadLine(file)
				Local pair:String[] = line.split("=")
				If pair.length>1
					Local value:String = "=".join( pair[1..] )
					Self.insert( Lower(pair[0]),value )
				End If
			Wend
			CloseStream file
		EndIf
	End Method
	
	Method Save( filename:String="" )
		' Save configuration
		If filename = ""; filename = Self.filename
		Local file:TStream = OpenFile( filename, False, True )
		If file 
			For Local key:String = EachIn Self.keys()
				WriteLine( file, key+"="+String( Self.valueforkey( key )) )
			Next
			CloseStream file
		EndIf		
	End Method

	Method getint:Int( key:String )
		Return Int(String(Self.valueforkey( key )))
	End Method

End Type