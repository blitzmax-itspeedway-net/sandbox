' Unit Test the Packrat Parser
' (c) Copyright Si Dunford [Scaremonger], 2023, All rights reserved

SuperStrict

Import "../bmx.packrat/packrat-parser.bmx"

Function Title( message:String )
	Print "~n+"+(" "[..79].Replace(" ","-"))
	Print "| "+message
	Print "+"+(" "[..79].Replace(" ","-"))
End Function

Function dotpad:String( text:String, length:Int )
	Local pad:String = " "[..(length-Len(text)-2)].Replace(" ",".")
	Return (text+" "+pad)[..length]
End Function

' Report a unittest state
Function Report( caption:String, result:Int, state:Int, addendum:String="" )
	Local str:String = dotpad( caption, 50 )	' + " " + ( " "[..50].Replace(" ",".") )
	If addendum; addendum = " '"+addendum+"'"
	Print str + dotpad(["NOTFOUND","FOUND","n/a"][result],10) + dotpad(["FAILED","SUCCESS"][state],9) + addendum
End Function

' Perform a simple state test
Function Test( caption:String, state:Int, result:Int=2 )
	Report( caption, result, state )
End Function

' Perform a string-based Equality test
Function EQ( caption:String, larg:String, rarg:String, result:Int=2 )
	Report( caption, result, larg=rarg )
End Function

' Perform an object NULL test
Function FOUND( caption:String, node:TParseNode, show:Int=False )
	Local found:Int = node.found
	If show
		Report( caption, found, found, node.text[ node.start..node.finish ] )
	Else
		Report( caption, found, found )
	End If
End Function

Function NOTFOUND( caption:String, node:TParseNode, show:Int=False )
	Local found:Int = node.found
	If show
		Report( caption, found, Not found, node.text[ node.start..node.finish ] )
	Else
		Report( caption, found, Not found )
	End If
End Function

'------------------------------------------------------------

Local code:String
Local pattern:TPattern
'Local DQUOTE:TPattern = CHARSET( Chr(34) )
Local grammar:TGrammar

'------------------------------------------------------------
Title( "AND PREDICATE: &e" )

pattern = SEQUENCE([ LITERAL("hello",CASE_INSENSITIVE), SP, ANDPRED( LITERAL("world", CASE_INSENSITIVE) ) ])
FOUND( "Hello [World] matched", pattern.match( "Hello world" ) )
NOTFOUND( "Hello [World] mismatch", pattern.match( "Hello universe" ) )

'------------------------------------------------------------
Title( "CHOICE OPERATOR: ( e1 / e2 / e3 ..) " )

pattern = CHOICE([ CHARSET("A"), CHARSET("B"), CHARSET("C") ])
FOUND( "A in ABC matched", pattern.match( "A" ) )
FOUND( "B in ABC matched", pattern.match( "B" ) )
FOUND( "C in ABC matched", pattern.match( "C" ) )
NOTFOUND( "D in ABC mismatch", pattern.match( "D" ) )

'------------------------------------------------------------
Title( "GROUP OPERATOR: ( e ) " )

pattern = SEQUENCE([ CHARSET("A"), GROUP([ CHARSET("B"), CHARSET("C") ])

'------------------------------------------------------------
Title( "NOT PREDICATE: !e " )

pattern = SEQUENCE([ LITERAL("hello",CASE_INSENSITIVE), SP, NOTPRED( LITERAL("world", CASE_INSENSITIVE) ) ])
NOTFOUND( "Match for Hello world", pattern.match( "Hello world" ) )
FOUND( "Match for Hello universe", pattern.match( "Hello universe" ) )

'------------------------------------------------------------
Title( "ONE OR MORE OPERATOR: e+ " )

pattern = ONEORMORE( DIGIT )
FOUND( "Match digit on 1234", pattern.match( "1234" ), True )
FOUND( "Match digit on 1234A", pattern.match( "1234A" ), True )
NOTFOUND( "Match digit on ABCD", pattern.match( "ABCD" ), True )

'------------------------------------------------------------
Title( "OPTIONAL OPERATOR: e?   - Also known as ZERO OR ONE" )

pattern = SEQUENCE([ ..
	LITERAL("john",CASE_INSENSITIVE), ..
	SP, ..
	LITERAL("has", CASE_INSENSITIVE), ..
	SP, ..
	OPTIONAL( SEQUENCE([ LITERAL("some",CASE_INSENSITIVE), SP]) ), ..
	LITERAL("beans", CASE_INSENSITIVE) ..
	])
FOUND( "John has some beans", pattern.match( "john has some beans" ), True )
NOTFOUND( "John has no beans", pattern.match( "john has no beans" ), True )
FOUND( "John has beans", pattern.match( "john has beans" ), True )

'------------------------------------------------------------
Title( "SEQUENCE OPERATOR: ( e1 e2 e3 )" )

pattern = SEQUENCE([ ..
	LITERAL( "Function", CASE_INSENSITIVE ), ..
	SP,
	SEQUENCE( "FuncName",[ RANGE([ "AZ","AF","_" ]), ZEROORMORE( RANGE([ "AZ", "az", "09", "_" ]) ) ]), ..
	CHARSET( "(" ), ..
	CHARSET( ")" ) ..
	])
FOUND( "Function example()", pattern.match( "Function Example()" ), True )
NOTFOUND( "Method example()", pattern.match( "Method Example()" ), True )
NOTFOUND( "Function 2example()", pattern.match( "Function 2Example()" ), True )

pattern = sequence([ ..
	Literal( "Lord", CASE_INSENSITIVE ), ..
	WSP,
	Literal( "Of", CASE_INSENSITIVE ), ..
	WSP,
	Literal( "The", CASE_INSENSITIVE ), ..
	WSP,
	Literal( "Rings", CASE_INSENSITIVE ) ..
	])
'DebugStop
FOUND( "Sequence match", pattern.match( "Lord of the Rings", 0 ) )
NOTFOUND( "Sequence mismatch", pattern.match( "Lord of the Flies", 0 ) )

'------------------------------------------------------------
Title( "ZERO OR MORE OPERATOR: e*" )

pattern = ZEROORMORE( CHARSET( "Aa" ) )
FOUND( "A", pattern.match( "A" ), True )
FOUND( "ABC", pattern.match( "ABC" ), True )
FOUND( "AAAAAB", pattern.match( "AAAAB" ), True )
FOUND( "DEF", pattern.match( "DEF" ), True )

'------------------------------------------------------------
Title( "CHARSET" )

pattern = CHARSET("A")
FOUND( "Match A with A", pattern.match( "A" ) )
NOTFOUND( "Match A with B", pattern.match( "B" ) )

'------------------------------------------------------------
Title( "RANGE()" )

Const NUMBERS:String = "0123456789"
Const UPPERCASE:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
Const LOWERCASE:String = "abcdefghijklmnopqrstuvwxyz"
EQ( "RANGE( '09' )", TRange(RANGE( "09" )).pattern, NUMBERS )
EQ( "RANGE( '0-9' )", TRange(RANGE( "0-9" )).pattern, NUMBERS )
EQ( "RANGE([ 'AZ', 'a-z', '0..9' ])", TRange(RANGE([ "AZ", "a-z", "0..9" ])).pattern, UPPERCASE+LOWERCASE+NUMBERS )

pattern = sequence([ CHARSET("$"), ONEORMORE( RANGE([ "AF", "af", "09" ]) ) ])
FOUND( "Hexadecimal match", pattern.match( "$22AB88cf" ) )
NOTFOUND( "Hexadecimal mismatch", pattern.match( "$MONEY$" ) )

pattern = RANGE( "09" )
FOUND( "Number match", pattern.match( "366" ) )
NOTFOUND( "Number mismatch", pattern.match( "Hello World" ) )

'------------------------------------------------------------
Title( "LITERAL" )

pattern = Literal( "world", CASE_SENSITIVE )
NOTFOUND( "Literal mismatch", pattern.match( "hello world", 0 ) )
FOUND( "Literal match (Case Sensitive)", pattern.match( "hello world", 6 ) )
NOTFOUND( "Literal mismatch (Case Sensitive)", pattern.match( "hello WORLD", 6 ) )

pattern = Literal( "world", CASE_INSENSITIVE )
FOUND( "Literal match (Case Insensitive)", pattern.match( "hello WORLD", 6 ) )
'DebugStop

'------------------------------------------------------------
Title( "NUMBER" )
'TDebug.enable()
'DebugStop
pattern = NUMBER
FOUND( "Number match", pattern.match( "1267" ) )
NOTFOUND( "Number mimatch", pattern.match( "ABCD" ) )

'------------------------------------------------------------
Title( "STRING" )
'TDebug.enable()
'DebugStop
' A String is allowed to contain any character except CHR(34)
'Local allow:String = Chr($20)+Chr($21)+MakeRange( Chr($23)+Chr($7E) )


pattern = QSTRING
FOUND( "String match", pattern.match( Chr(34) + "This is a string" + Chr(34) ) )

'------------------------------------------------------------
Title( "EXAMPLES" )

Local DOT:TPattern = CHARSET(".")

pattern = sequence([ NUMBER, DOT, NUMBER, DOT, NUMBER, DOT, NUMBER ])
FOUND( "IP Address", pattern.match( "192.168.10.11" ))

'------------------------------------------------------------
Title( "CSV" )

DebugStop

grammar = New TGrammar()
grammar.predefine([ "ITEM", "LINE", "FILE" ])


' FILE -> LINE ( "\n" LINE )*
grammar["FILE"] = ..
	SEQUENCE( "FILE", [..
		grammar.nonTerminal( "LINE" ), ..
		ZEROORMORE( ..
			SEQUENCE([ ..
				LITERAL("~n"), ..
				grammar.nonTerminal( "LINE" ) ..
			])..
		)..
	])

' LINE -> ( ITEM ( "," ITEM )* )
grammar["LINE"] = ..
	SEQUENCE( "LINE", [ ..
		grammar.nonTerminal( "ITEM" ), ..
		ZEROORMORE( ..
			SEQUENCE([ ..
				LITERAL(","), ..
				grammar.nonTerminal( "ITEM" ) ..
			]) ..
		) ..
	])

' ITEM -> ( !"," !"\n" . )*
' Equivalent To the regex: [^,\n]*
grammar["ITEM"] = ..
	ZEROORMORE( "ITEM", ..
		SEQUENCE([ ..
			NOTPRED( LITERAL(",") ), ..
			NOTPRED( LITERAL("~n") ), ..
			any() ..
		]) ..
	)

' It works (but only For validation)
Local my_file:String = "1,2,3~n4,5,6"

DebugStop
pattern = grammar["FILE"]

Print "PEG DEFINTION:"
For Local rule:String = EachIn grammar.keys()
	Local pattern:TPattern = TPattern( grammar[rule] )
	Print rule + " -> " + pattern.peg()
Next

Local result:TParsenode = pattern.match( my_file )
If result; Print result.AsString() Else Print( "NULL" )
If result; Print "VALIDATED"

'view.show( result )

DebugStop

' Sum values in each row of CSV file:
'For Local row:TMatch = EachIn result.children
'	Local total:Int = 0
'	DebugStop
'	For Local item_text:String = EachIn row.captures()	'get_captures( row )
'		DebugStop
'		' total :+ int( item_text )
'	Next
'	Print "TOTAL:"+total	' Should be 6 and 15
'Next




