'	Issue #2 - Left Recusion Issue
'	(c) Copyright Si Dunford [Scaremonger], 2023-date, All rights reserved.
'	VERSION 1.0
'
'	Test PEG Parser against known Left Recusion issue!
'
'	14 NOV 2023 - Example of issue

' ####                                     ####
' #### WARNING - THIS CAUSES A STACK CRASH #### 
' ####                                     ####

'Import packrat.parser
Import "../../packrat.parser/parser.bmx"

'Import peg.parser
'Import "../../peg.parser/parser.bmx"
Import "../../peg.parser/bin/TPackratParser_PEG_DEV.bmx"

'Import bmx.packrat-fn
Import "../../packrat.functions/functions.bmx"

Include "bin/testlib.bmx"
Global TABSTOP:Int[] = [3,28,10,10]		' Column widths

' ############################################################

DEBUGGER = True

DebugStop
Local parser:TPackratParser = New TPackratParser( "TEST" )
Local grammar:TGrammar = parser.grammar

'	START   <- EXAMPLE
'	EXAMPLE <- EXAMPLE / 'a'

grammar["START"]   = NONTERMINAL( grammar, "EXAMPLE" )
grammar["EXAMPLE"] = SEQUENCE([ NONTERMINAL( grammar, "EXAMPLE" ), LITERAL( "a" ) ])

Print "WARNING - THIS CAUSES A STACK CRASH"
DebugStop

test( "Left recursion", "aaaaaaaaaa", parser )

' ############################################################

