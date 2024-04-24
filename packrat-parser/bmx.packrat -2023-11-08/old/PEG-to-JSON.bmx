'	test_peg_parser.bmx
'	(c) Copyright Si Dunford [Scaremonger], 2023-date, All rights reserved.
'	VERSION 1.0
'
'	Test PEG Parser against example syntax!
'

'Import bmx.packrat
Import "../packrat.bmx"
Import bmx.json

' ############################################################

'DebugStop

' Load the (Manual) PEG Parser
'Local PEG:TPackrat_Parser = PEG_Parser()
Local PEG:TPackrat_Parser = New TPackrat_PEG_Parser()

' Save JSON
Local Jtext:String = PEG.toJSON()
SaveString( Jtext, "PEG.json" )

