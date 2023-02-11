SuperStrict

Function Test( str:String )
	Print str
	Local pos:Int = FindComment( str )
	Print " "[..pos]+"^  "+pos
End Function

DebugStop
Test( "Line without a comment" )
Test( "Line with comment ' at the end" )
Test( "Line with ' comment ~qbefore a String~q" )
Test( "Line with ~qstring~q before 'a comment" )
Test( "Line with ~qstring's with single quote~q but no comment" )
Test( "Line with ~qstring's with single quote~q and ' comment" )

' Searches for a line comment
' Ensures that the comment is not inside a string
Function FindComment:Int( line:String )
	Local comment:Int = line.find( "'" )
	If comment < 0; Return comment
	' Line contains a comment

	Local quote:Int = line.find( Chr(34) )
	If quote < 0 Or comment < quote; Return comment
	' Line contains a quote before a comment
	DebugStop
	' Scan the line until we know what is happening		
	Local dq:Int = True
	For Local pos:Int = quote+1 Until line.length
		Local ch:Int = Asc( line[pos..pos+1] )
		If ch=34		' Found a double quote
			dq = Not dq	
		ElseIf ch=39	' Found a single quote
			If Not dq; Return pos	' Comment outside of string
			comment = -1 ' Turn off the previous comment
		End If
	Next
	Return comment
End Function
