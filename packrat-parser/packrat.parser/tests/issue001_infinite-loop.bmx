'	Issue #1 - Infinite Loop
'	(c) Copyright Si Dunford [Scaremonger], 2023-date, All rights reserved.
'	VERSION 1.0
'
'	Test PEG Parser against known Infinite loops!
'
'	12 NOV 2023 - Example of issue
'	13 NOV 2023 - Mitigation applied

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

DEBUGGER = False

DebugStop
Local parser:TPackratParser = New TPackratParser( "TEST" )
Local grammar:TGrammar = parser.grammar

'	START <- (!.)*

grammar["START"] = ZEROORMORE( NOTPRED( ANY() ) )
test( "Infinite Loop (!.)*",   "Example Document", parser )

'	START <- ('a'?)*

grammar["START"] = ZEROORMORE( OPTIONAL( LITERAL("a") ) )
test( "Infinite Loop ('a'?)*", "Example Document", parser )

'	START <- (&'a')*

grammar["START"] = ZEROORMORE( ANDPRED( LITERAL("a") ) )
test( "Infinite Loop (&'a')*", "abcdefghijklmnop", parser )
