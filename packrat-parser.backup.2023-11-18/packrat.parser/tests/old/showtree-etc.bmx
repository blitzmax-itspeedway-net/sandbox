'	test_peg_parser.bmx
'	(c) Copyright Si Dunford [Scaremonger], 2023-date, All rights reserved.
'	VERSION 1.0
'
'	Test PEG Parser against example syntax!
'

'Import packrat.parser
Import "../../packrat.parser/parser.bmx"

'Import peg.parser
'Import "../../peg.parser/parser.bmx"
Import "../../peg.parser/bin/TPackratParser_PEG_DEV.bmx"

Include "bin/testlib.bmx"
Global TABSTOP:Int[] = [3,28,10,10]		' Column widths

' ############################################################

DEBUGGER = True

DebugStop

' Load the (Manual) PEG Parser
'Local PEG:TPackratParser = PEG_Parser()
Local PEG:TPackratParser = New TPackratParser_PEG_DEV()
Local source:String
Local tree:TParseTree
Local count:Int
Local document:TTextDocument


' ############################################################

test( "Line Comment", "#Test", PEG, "COMMENT" )

' ------------------------------
Print "~n== TREE ==============="
'DebugStop
Print document.getTextTree()


' ------------------------------
Print "~n== REVEAL ============="
'DebugStop
If tree
	Print tree.reveal()
Else
	Print "Failed To parse"
End If

'For Local error:TParseNode = EachIn tree.ByName( "ERROR" )
'	'DebugStop
'	Local position:TPosition = PEG.getPosition( error.start )
'	Print error.captured + " at " + position.format() + " / "+ error.start + ".." + error.finish
'	'Print "  LINE:"+position.line+", COLUMN:"+position.col
'	count :+ 1
'Next
'If count>0
'	Print "RESULT: Failed - Parse tree contains "+count+ " errors."
'	End
'End If
'Print "RESULT: Success"

' ############################################################

' RANGES
'testrange( "DIGIT <- [0-9]", "0123456789" )
'testrange( "ALPHANUMERIC <- [a-zA-Z_]", "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_" )
'testrange( "SYMBOL <- [+-/*]", ["+",",","-",".","/","*"] )	' This is a common issue
'testrange( "SYMBOL <- [-+/*]", ["+","-","/","*"] )
'testrange( "SYMBOL <- [+/*-]", ["+","-","/","*"] )
DebugStop
' Result


' ############################################################

Print "~n##"
Print "## TEST 2 / 'EXPECT' errors"
Print "##"
source = showsource( "123" )
document = New TTextDocument( source )
document.parse( PEG, "ALPHA" )
If document.errors.length=0
	Print "SUCCESS :)"
Else
	Print "* "+"~n* ".join(document.errors[])
End If

Print "~n##"
source = showsource( "TESTRULE => ALPHA~n" )
document = New TTextDocument( source )
document.parse( PEG, "RULE" )
If document.errors.length=0
	Print "SUCCESS :)"
Else
	Print "* "+"~n* ".join(document.errors[])
End If
DebugStop


' ############################################################

Print "~n##"
Print "## SELF TEST 1"
Print "## There should be no Parse Errors!"
Print "##~n"

'For Local error:TParseNode = EachIn CSV.ByName( "ERROR" )
'	'DebugStop
'	Local position:TPosition = PEG.getPosition( error.start )
'	Print error.captured + " at " + position.format() + " / "+ error.start + ".." + error.finish
'	'Print "  LINE:"+position.line+", COLUMN:"+position.col
'	count :+ 1
'Next

'If count>0
'	Print "RESULT: Failed - Parse tree contains "+count+ " errors."
'	End
'End If
'Print "RESULT: Success"

' ############################################################

'Print "~n##"
'Print "## Use the parser to parse a CSV file"
'Pint "##~n"

DebugStop

Local CSVfile:TParseNode 

' ############################################################

Print "~n##"
Print "## SHOW MEMO TABLE"
Print "##~n"

DebugStop


Function showsource:String( source:String )
	Local str:String = source
	'str = str.Replace( "~n", "\n~n" )
	str = str.Replace( "~t", "\t" )
	Print str
	Return source
End Function