' GENERATE BLITZMAX PARSER
' (c) Copyright Si Dunford [Scaremonger], 2023-date, All rights reserved.
' VERSION 1.0
'
' Uses the packrat module to generate a parser for Blitzmax from a peg definition
'

'Import bmx.packrat
Import "../bmx.packrat/packrat.bmx"

DebugStop

' Load the (Manual) PEG Parser
Local parser:TPackrat_Parser = New TPackrat_PEG_Parser()

' Load the Blitzmax PEG Definition
Local BlitzMaxPEG:String = LoadString( "BlitzMaxNG.peg" )

' Use the PEG Parser to parse the BlitzMax definition
Local parseTree:TParseTree = parser.Parse( BlitzMaxPEG )

' Display a list of rules
Print "BLITZMAX RULES:"
For Local rule:TParseNode = EachIn parseTree.ByName( "RULE" )
	DebugStop
	Print rule.tostring()
Next

' Generate a Blitzmax Parser
Local generator:TParserGenerator = New TParserGenerator( "Blitzmax", parsetree )
generator.set( "VERSION", "0.00" )

DebugStop
generator.write()



