
Global COUNTER:Int = 0  ' Test counter

Function test( title:String, source:String, parser:TPackratParser, startrule:String = "START" )
	Local document:TTextDocument = New TTextDocument( source )
	COUNTER :+ 1

	' Parse source into a parse tree using parser
	document.parse( parser, startrule )

	If document.errors.length=0
		write([ String(COUNTER), title, "SUCCESS", "No errors reported!" ])
	Else
		write([ String(COUNTER), title, "FAILED", ",".join(document.errors[]) ])
	End If
	
End Function

Function test( title:String, original:String, match:String )
	COUNTER :+ 1
	If original = match
		write([ String(COUNTER), title, "SUCCESS", "Strings match" ])
	Else
		write([ String(COUNTER), title, "FAILED", "Strings do not match" ])
	End If
End Function

Function write( data:String[] )
	Local line:String, error:String
	For Local n:Int = 0 Until TABSTOP.length
		If n+1 >= TABSTOP.length
			' Last column
			line  :+ data[n]
		Else
			' Middle column
			line  :+ data[n][..TABSTOP[n]] + "|"
			If data[n].length > TABSTOP[n]
				If error; error :+ "~n"
				error :+ "* Cannot fit "+data[n].length+" chars in Column "+(n+1)
			End If
		End If
	Next
	Print line
	If error; Print error
End Function
