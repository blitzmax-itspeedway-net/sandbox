'	1. Memo table
'	(c) Copyright Si Dunford [Scaremonger], 2023-date, All rights reserved.
'	VERSION 1.0
'
'	Test the memo table which is also the parse table!
'

'Import bmx.packrat
Import "../../bmx.packrat/packrat.bmx"

' ############################################################

DebugStop

' Load the (Manual) PEG Parser
Local PEG:TPackrat_Parser = New TPackrat_PEG_Parser()

' Load the CSV parser definition
Local csv_definition:String = LoadString( "csv.peg" )

' Parse CSV defintion into a parse tree
Local CSV:TParseTree = PEG.Parse( csv_definition )

' Debug the Parse tree
'Print CSV.reveal()
Print CSV.AsString()
DebugStop

' ############################################################

Print "~n##"
Print "## SELF TEST 1"
Print "## There should be no Parse Errors!"
Print "##~n"

Local count:Int
For Local error:TParseNode = EachIn CSV.ByName( "ERROR" )
	'DebugStop
	Local position:TPosition = PEG.getPosition( error.start )
	Print error.captured + " at " + position.format() + " / "+ error.start + ".." + error.finish
	'Print "  LINE:"+position.line+", COLUMN:"+position.col
	count :+ 1
Next

If count>0
	Print "RESULT: Failed - Parse tree contains "+count+ " errors."
	End
End If
Print "RESULT: Success"

' ############################################################

Print "~n##"
Print "## Use the parser to parse a CSV file"
Print "##~n"

DebugStop

Local CSVfile:TParseNode 

' ############################################################

Print "~n##"
Print "## SHOW MEMO TABLE"
Print "##~n"

DebugStop


