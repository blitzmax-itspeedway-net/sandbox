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
Local text:String

' ############################################################

test( "Line Comment", "#Test", PEG, "COMMENT" )

' RANGES
Local pattern:TPattern = RANGE("0-9")
Print pattern.tostring()
debugstop
test( "Number using RANGE", text, "0123456789" )

test( "Number", "23", PEG, "NUMBER" )

'testrange( "ALPHANUMERIC <- [a-zA-Z_]", "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_" )
'testrange( "SYMBOL <- [+-/*]", ["+",",","-",".","/","*"] )	' This is a common issue
'testrange( "SYMBOL <- [-+/*]", ["+","-","/","*"] )
'testrange( "SYMBOL <- [+/*-]", ["+","-","/","*"] )
DebugStop
' Result

