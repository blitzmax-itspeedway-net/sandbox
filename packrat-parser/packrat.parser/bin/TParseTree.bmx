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

	Method getTree:String()
		If root; Return root.getTree()
	End Method
	
	' Override TParsenode to use specific root instead.
	Method ByName:TSearchEnumerator( name:String )
		If root; Return root.byname( name )
	End Method
	
	' Override TParsenode to use specific root instead.
	Method ByKind:TSearchEnumerator( kind:Int )
		If root; Return root.byKind( Kind )
	End Method
	
	Method hasErrors:Int()
		For Local error:TParseNode = EachIn byname("ERROR")
			Return True
		Next
		Return False
	End Method
	
	' Only use this if you need the error count without errors
	' It is more efficient to get the errors and count them
	Method errorcount:Int()
		Local count:Int = 0
		For Local error:TParseNode = EachIn byname("ERROR")
			count :+ 1
		Next
		Return count
	End Method

	Method getErrors:TParseError[]()
		Local list:TParseError[] = []
		For Local error:TParseNode = EachIn byname("ERROR")
			list :+ [New TParseError( error.value(), error.start, error.finish )]
		Next
		Return list
	End Method
	
	
	' IVisitable
	'Public Method accept:Int( visitor:IVisitor )
	'	Return visitor.visit( Self )
	'End Method
	
	' Debug tool - Builds a textual tree
	Method reveal:String()
		If Not root; Return "NO ROOT"
		Return root.reveal()
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

Type TGift
	Field node:PNode
	Field data:Object
	Field prefix:String
	Method New( node:PNode, data:Object, prefix:String )
		Self.node = node
		Self.data = data
		Self.prefix = prefix
	End Method
EndType