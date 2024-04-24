'   VISITORS
'   (c) Copyright Si Dunford, MMM 2022, All Rights Reserved. 
'   VERSION: 1.0

'	Look up "Visitor pattern" for an explaination of how these are used

'   CHANGES:
'   DD MMM YYYY  Initial Creation
'

Type TSearchByName Implements IVisitor

	Field name:String
	Field results:TList
		
	Method New( name:String )
		Self.results = New TList()
		Self.name = name
	End Method

	Method visit:Int( node:TParsenode )
		Local match:TParseNode = TParseNode( node )
		'DebugStop
		If Not match Or match.name <> name; Return
		DebugStop
		results.addlast( match )
	End Method


	Method get:String[]()
		DebugStop
	End Method
End Type	




