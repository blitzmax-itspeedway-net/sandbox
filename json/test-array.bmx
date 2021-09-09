SuperStrict

'Import bmx.json


Import bmx.lexer
Import bmx.parser

Include "../json.mod/src/JSON.bmx"
Include "../json.mod/src/TJSONLexer.bmx"
Include "../json.mod/src/TJSONParser.bmx"

Local JText:String = "{~qtest~q:true,~qitems~q:[{~qsection~q:~qtest~q},{~qsection~q:~qbls~q},{~qsection~q:~qlsp~q},{~qsection~q:~qblitzmax~q}]}"
Local J:JSON = JSON.Parse( Jtext )

Local response:JSON = New JSON()
response.set( "jsonrpc", "2.0")
response.set( "params", J )

response.set( "example", [] )

'response.set( "example", [] )

Print response.prettyprint()
DebugStop



Local items:JSON = response.find( "params|items" )
Print "CLASS: "+items.class

Local items2:JSON2 = JSON2( items)
Print "SIZE:  "+items2.size()

DebugStop
Local aitems:JSON[] = JSON[]( items.value )

aitems :+ [ New JSON( "string", "SJD" ) ]

items.value = aitems


Print response.prettyprint()
		'If class = "array"
		'	Local items:JSON[] = JSON[]( value )
		'	If items
		'		Local J:JSON = items[key]
		'		If J Return J
		'	End If
		'End If

Type JSON2 Extends JSON

	' Set value of a JSON array
	Method operator []( key:Int, value:JSON )
		If class = "array"
'			Local items:JSON[] = JSON[]( value )
'			If items
'				Local J:JSON = items[key]
'				If J Return J
'			End If
		End If
		'Return Null
	End Method

	' Get SIZE of an ARRAY
	Method size:Int()
		If class = "array" Return JSON[](value).length
		Return 0
	End Method

End Type


