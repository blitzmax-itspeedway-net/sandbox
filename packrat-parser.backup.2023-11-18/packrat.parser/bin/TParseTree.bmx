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
	
	'Method AsString:String()
	'	If root; Return root.AsString()
	'End Method
	
	Method getTextTree:String( doc:TTextDocument )
		If root; Return root.getTextTree( doc )
	End Method
	
	' Override TParsenode to use specific root instead.
	Method ByName:TSearchEnumerator( name:String )
		If root; Return root.byname( name )
	End Method
	
	' IVisitable
	'Public Method accept:Int( visitor:IVisitor )
	'	Return visitor.visit( Self )
	'End Method
	
	' Debug tool - Builds a textual tree
	Method reveal:String()
		If Not root; Return "NO ROOT"
		Return root.AsString()
		'_buildtree( root )
	End Method
	
	'Method _buildtree:String( node:TParsenode, depth:Int = 0 )
	'	Local tab:String = " "[..depth*2]
	'	Local tree:String = node.name + ":" + node.typeof()
	'	Local children:TParsenode[] = node.getChildren()
	'	For Local child:TParseNode = EachIn children
	'		tree :+ _buildtree( child, depth + 1 )
	'	Next
	'	Return tree
	'End Method

End Type

