'

Type TPosition
	Field line:Int = 0
	Field col:Int = 0
	
	Method New( line:Int, col:Int )
		Self.line = line
		Self.col = col
	End Method
	
	Method format:String()
		Return "("+line+":"+col+")"
	End Method
	
	Method toString:String()
		Return line+":"+col
	End Method
	
End Type

' INTERNAL USE ONLY!

Type TTextDocument

	' Cache of line numbers
	Field lines:Int[]
	Field content:String
	
	Field tree:TParseTree
	
	Field errors:String[]

	Method New( content:String )
		Self.content = content
	End Method

	Method error( text:String )
		errors:+ [text]
	End Method

	Method error( template:String, node:TPattern, pos:Int )
		Local position:TPosition = getposition(pos)
		Local text:String = template.Replace( "{pos}", position.tostring() )
		text = text.Replace( "{identifier}", node.identifier() )
		'DebugStop
		If Instr( text, "{show}" )
			Local start:Int = lines[position.line-1]
			Local eol:Int = lines[position.line]
			Local line:String = content[start..eol].Replace("~t"," ").Replace("~n","").Replace("~r","")
			'position.line
			'DebugStop
			text = text.Replace( "{show}", "~n "+line+"~n"+ (" "[..position.col])+"^~n" )
		End If
		errors:+ [text]
	End Method

	Method getPosition:TPosition( pos:Int )
		'DebugStop
		'Print "FINDING POS '"+pos+"'"
		'Assert pos<=content.length, "Invalid position "+pos+" is not within document!"
		Local line:Int
		If lines.length = 0
'Print "- Creating cache"
			' Create cache
			lines :+ [0]
			For Local n:Int = 0 Until content.length
				'Print( content[n] )
				If content[n] = 10; lines :+ [n+1]
				If pos = n; line = lines.length
			Next
			'For Local n:Int = 0 Until lines.length
			'	Print "LINE "+n+" @"+lines[n]
			'Next
			'DebugStop
			lines :+ [content.length]
			Return New TPosition( line, pos-lines[line-1]+1 )
		Else
'Print "- Using cache"
			' Use cache
			For Local line:Int = 1 Until lines.length
				If pos< lines[line]; Return New TPosition( line, pos-lines[line-1]+1 )
			Next
			'DebugStop
			Return New Tposition(1,pos)
		End If
	End Method

	Method parse( parser:TPackratParser, startrule:String = "" )
		tree = parser.parse( Self, startrule )
	End Method
	
	Method getTextTree:String()
		If tree; Return tree.getTextTree( Self )
	End Method

End Type