'	TParseTree
'	(c) Copyright Si Dunford [Scaremonger], 2023-date, All rights reserved.
'	VERSION 1.0
'
'	A ParseTree is the result of parsing a source file with a given grammar.

'   CHANGES:
'   DD MMM YYYY  V1.0  First version
'

Type TParseTree ' Extends TParseNode

	'Field startrule:String = "BEGIN"
	Field root:TParseNode
	
	'Method New( startrule:String, root:TParseNode = Null )
	Method New( root:TParseNode = Null )
		'Self.startrule: String = startrule
		Self.root = root
	End Method

	Method getRoot:TParseNode()
		Return root
	End Method
	
	Method setRoot( root:TParseNode )
		Self.root = root
	End Method
	
	Method AsString:String()
		If root; Return root.AsString()
	End Method
	
	' Override TParsenode to use specific root instead.
	Method ByName:TSearchEnumerator( name:String )
		If root; Return root.byname( name )
	End Method
	
	' IVisitable
	'Public Method accept:Int( visitor:IVisitor )
	'	Return visitor.visit( Self )
	'End Method

End Type

