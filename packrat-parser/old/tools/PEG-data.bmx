'	PEG-data.bmx
'	(c) Copyright Si Dunford [Scaremonger], 2023-date, All rights reserved.
'	VERSION 1.0
'
'	Convert PEG to Data
'
SuperStrict

'Import bmx.packrat
Import "../../bmx.packrat/packrat.bmx"

' Load the (Manual) PEG Parser
Local PEG:TPackrat_Parser = PEG_Parser()

' Build Defdata
Local text:String = PEG.grammar.toDataDef()
Print text

' Save to disk
SaveString( text, "PEG_Definition_Generated.bmx" )


