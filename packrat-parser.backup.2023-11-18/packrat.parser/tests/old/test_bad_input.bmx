'	test_bad_input.bmx
'	(c) Copyright Si Dunford [Scaremonger], 2023-date, All rights reserved.
'	VERSION 1.0
'
'	Test PEG Parser against known bad input!
'
'	NOTE: IT IS A SUCCESS TO CORRECTLY IDENTIFY ALL THESE ERRORS

'Import bmx.packrat
Import "../../bmx.packrat/packrat.bmx"

'Import bmx.pegparser
'Import "../../bmx.peg-parser/peg-parser.bmx"
Import "../../bmx.peg-parser/bin/TPackrat_PEG_Parser_DEV.bmx"

'Import bmx.packrat-fn
Import "../../bmx.packrat-fn/packrat-fn.bmx"

' ############################################################

DebugStop

' Load the (Manual) PEG Parser
'Local PEG:TPackrat_Parser = PEG_Parser()
Global PEG:TPackrat_Parser = New TPackrat_PEG_Parser_DEV()

'Local source:String
'Local tree:TParseTree
'Local count:Int
'Local document:TTextDocument

Global TABSTOP:Int[] = [3,28,10,10]
Global COUNTER:Int = 0 

Function test( title:String, source:String, parser:TPackrat_Parser = Null )
	Local document:TTextDocument = New TTextDocument( source )

	' By default use the PEG parser
	If Not parser; parser = PEG

	' Parse source into a parse tree using parser
	document.parse( parser )

	COUNTER :+ 1
	If document.errors.length=0
		write([ String(COUNTER), title, "FAILED", "No error reported!"])
	Else
		write([ String(COUNTER), title, "SUCCESS", ",".join(document.errors[])])
	End If
	
End Function

Function write( data:String[] )
	Assert data.length = TABSTOP.length, "Data has "+data.length+" fields, expected "+TABSTOP.length	
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

' ############################################################
' PEG PARSER TESTING
' Known issues added here to confirm when they are resolved

write([ "#","TEST","STATE","ERROR" ])
DEBUGGER = False
'DebugStop
test( "Invalid line with EOI",        "// badline" )
'DebugStop
test( "Invalid line",                 "// badline~n" )

DebugStop
test( "Missing Non-Terminal",          "EXAMPLE <- TEST / 'test'~n" )
test( "Missing Non-Terminal and EOL",  "EXAMPLE <- TEST / 'test'" )


' ############################################################
' PEG SYNTAX TESTING

DEBUGGER = False
DebugStop
Local parser:TPackrat_Parser = New TPackrat_Parser( "TEST" )
Local grammar:TGrammar = parser.grammar

grammar["START"] = ZEROORMORE( NOTPRED( ANY() ) )
test( "Infinite Loop (!.)*",           "Example Document", parser )

grammar["START"] = ZEROORMORE( OPTIONAL( LITERAL("a") ) )
test( "Infinite Loop ('a'?)*",          "Example Document", parser )

grammar["START"] = SEQUENCE([ NONTERMINAL( grammar, "START" ), LITERAL( "a" ) ])
test( "Left recursion",                "aaaaaaaaaa", parser )

