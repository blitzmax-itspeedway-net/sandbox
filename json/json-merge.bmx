SuperStrict

'	JSON EXAMPLES
'	(c) Copyright Si Dunford, September 2021

'	MERGE JSON INTO JSON

'Import bmx.json

Import bmx.lexer
Import bmx.parser
Import brl.objectlist

Include "../json.mod/src/JSON.bmx"
Include "../json.mod/src/TJSONLexer.bmx"
Include "../json.mod/src/TJSONParser.bmx"

DebugStop

Local list_a:String = "{'name':'jack','july':['beans']}"
Local list_b:String = "{'name':'jill','july':['spaghetti','tomatoes']}"

Local JA:JSON = JSON.parse( list_a.Replace( "'", "~q" ) )
Local JB:JSON = JSON.parse( list_b.Replace( "'", "~q" ) )
Local JC:JSON

Print "LIST A:"
Print JA.prettify()

Print "LIST B:"
Print JB.prettify()

Print "MERGE WITH OVERWRITE:"
JC = JA.merge( JB )
Print JC.prettify()

Print "MERGE WITHOUT OVERWRITE:"
JC = JA.merge( JB, False )
Print JC.prettify()

