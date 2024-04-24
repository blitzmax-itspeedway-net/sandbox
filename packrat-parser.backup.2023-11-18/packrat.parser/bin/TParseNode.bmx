'	TParseNode
'	(c) Copyright Si Dunford [Scaremonger], 2023-date, All rights reserved.
'	VERSION 1.0
'
'	A ParseNode is a node in the Parse Tree

Type TParseNode Extends PNode Implements IViewable, IVisitable

	'Field found:Int = True		' Match Found
	'Field Empty:Int = True		' Empty result

	Field kind:Int
	'Field text:String		' Original text		' DEPRECIATED
	
	Field start:Int			' First character in match
	Field finish:Int		' Last character in match
	Field name:String		' Named capture
	Field captured:String	' Text captured by a pattern
	Field patid:String		' Pattern ID that matched this
	Field children:TParseNode[]

	'Method New( kind:Int, text:String, start:Int, finish:Int, children:TParseNode[]=[] )
	'	Self.kind = kind
	'	Self.text = text
	'	Self.start = start
	'	Self.finish = finish
	'	Self.children = children
	'	Debug asString()
	'	CONSOLE.Log( reveal() )
	'End Method
	
	Method New() ' found:Int = False )
		'Self.found = found
	End Method
	
	Method New( pattern:TPattern, kind:Int, text:TTextDocument, start:Int, finish:Int, children:TParseNode[]=[] )
		'Self.found = True
		Self.kind = kind
		'Self.text = text
		Self.start = start
		Self.finish = finish
		Self.children = children
		'
		'DebugStop
		'Debug AsString()
		'DebugStop
		'CONSOLE.Log( reveal() )
		'DebugStop
		' Save Pattern type
		'Local typ:TTypeId = TTypeId.forObject( pattern )
		'Self.pattern = typ.name()
'DebugStop
		Self.patid = pattern.GetID()
		'
		'Self.Empty = (start=finish)
	End Method
	
	
	'Method getCapture:String()
	'	Return captured
	'End Method
	
	'Method New( text:String, start:Int, finish:Int, children:TParseNode[]=[] )
	'	DebugLog( "** Depreciated TParseNode.new( -4- ) called **" )
	'	DebugStop
	'	Self.text = text
	'	Self.start = start
	'	Self.finish = finish
	'	Self.children = children
	'End Method

'	Method captures:TParseNodeEnumerator()
'		'Local nodeenum:TParseNodeEnumerator
'		'If children
'		Return New TParseNodeEnumerator( Self )
'		'End If
'		'Return New TParseNodeEmptyEnumerator( Self )
'	End Method

	Method AsString:String( padding:Int=0 )
'		DebugStop
		Local pad:String = " "[..padding]
		Local str:String = pad+KINDSTR[ kind ]+": "+start+".."+finish
		If name; str :+ ", Name='"+name+"'"
		If captured; str :+ ", Captured='"+captured+"'"
		'str :+ ",value='"+text[start..finish]+"'"
		If children
			str :+ ", Children: "+ children.length
			str :+ "~n"
			For Local child:TParseNode = EachIn children
				str :+ child.AsString( padding+1 ) + "~n"
			Next
		End If
		Return str
	End Method

Rem
	ONE
	+-TWO
	| +-THREE
	| +-FOUR
	| | +-FIVE
	| | +-SIX
	| +-SEVEN
	+-EIGHT
	  +-NINE
End Rem

	' Return a formatted text tree 
	Method getTextTree:String( doc:TTextDocument, depth:Int=0 ) ', lastchild:Int=False )
		'DebugStop
		Local str:String = " "[..depth*2]
		str :+ doc.getPosition( start ).format() + ".." + doc.getPosition( finish ).format()
		str :+ KINDSTR[ kind ]+": "+start+".."+finish
		If name; str :+ ", Name='"+name+"'"
		If captured; str :+ ", Captured='"+captured+"'"
		'str :+ ",value='"+text[start..finish]+"'"
		If children
			str :+ ", Children: "+ children.length
			str :+ "~n"
			For Local child:TParseNode = EachIn children
				str :+ child.getTextTree( doc, depth+1 ) + "~n"
			Next
		End If
		Return str
	End Method

	Method reveal:String()
'If kind=KIND_ERROR; DebugStop
		Local str:String = KINDSTR[ kind ]+": ["+start+".."+finish+"]"
		If patid; str :+ ", Pattern='"+patid+"'"
		If name; str :+ ", Name='"+name+"'"
		'str :+ ", Name='"+name+"'"
		If captured; str :+ ", Captured='"+captured+"'"
		'str :+ ", Captured='"+captured+"'"
		'str :+ ", value='"+text[start..finish]+"'"
		Return str
	End Method
	
Rem
	Method Keys:TMapEnumerator()
		Local nodeenum:TNodeEnumerator=New TKeyEnumerator
		nodeenum._node=_FirstNode()
		Local mapenum:TMapEnumerator=New TMapEnumerator
		mapenum._enumerator=nodeenum
		Return mapenum
	End Method
	
	Method Values:TMapEnumerator()
		Local nodeenum:TNodeEnumerator=New TValueEnumerator
		nodeenum._node=_FirstNode()
		Local mapenum:TMapEnumerator=New TMapEnumerator
		mapenum._enumerator=nodeenum
		Return mapenum
	End Method
End Rem		



	' IVisitable
	'Method accept( visitor:TVisitor )
	'	For Local child:TParseNode = EachIn children
	'		child.accept( visitor )
	'	Next
	'	visitor.visit( Self )
	'End Method

	' IViewable
	Method getCaption:String()
		Return patid+"["+start+".."+finish+"] "+name+":"+KINDSTR[kind]
	End Method
	
	' IViewable
	Method getText:String[]()
		Local data:String '= doc.content[start..finish]
		data = data.Replace("~n","\n")
		data = data.Replace("~r","\r")
		data = data.Replace("~t","\t")
		data = data.Replace(" ","\s")
	
		Local str:String[]
		str :+ ["NAME:     "+name]
		str :+ ["POSITION: "+start+".."+finish]
		str :+ ["KIND:     "+kind+ " "+KINDSTR[kind]]
		str :+ ["CAPTURE:  "+captured]
		str :+ ["PATTERN:  "+patid]
		str :+ ["VALUE:    "+data]
		Return str
	End Method
	
	' IViewable
	Method getChildren:IViewable[]()
		Local list:IViewable[] = []
		If children
			For Local item:IViewable = EachIn children
				list :+ [ item ]
			Next
		End If
		Return list
	End Method

	' IVisitable
	Method accept:Int( visitor:IVisitor )
		Return visitor.visit( Self )
	End Method

	' SEARCH

	Method ByName:TSearchEnumerator( name:String )
		'DebugStop
		Return New TSearchEnumerator( Self, name:String )
	End Method
		
	'Method searchByName:TSearchEnumerator( name:String )
	'	Print( "** WARNING: TParseNode.searchbyname() is depreciated; please use .byName()" )
	'	Return New TSearchEnumerator( Self, name:String )
	'End Method

	'	TREE-WALKING METHODS
	'	https://en.wikipedia.org/wiki/Tree_traversal
	
	Method inOrder:TInOrderEnumerator()
		Return New TInOrderEnumerator( Self )
	End Method

	Method preorder:TPreOrderEnumerator()
		Return New TPreOrderEnumerator( Self )
	End Method

	Method postorder:TPostOrderEnumerator()
		Return New TPostOrderEnumerator( Self )
	End Method

	
End Type

Rem
Type TObjectEnumerator

	Field node:TParseNode
	Field criteria:String

	Method New( node:TParseNode, criteria:String )
		'DebugStop
		Self.node = node
		Self.criteria = criteria
	End Method

	Method ObjectEnumerator:TIteratorInOrderStack()
		'DebugStop
		Return New TIteratorInOrderStack( node, criteria )
	End Method


End Type

Type TIteratorInOrderStack
	'Field node:TParseNode
	'Field criteria:String
	
	Field stack:TList
	'Field current:TParseNode
	'Field child:Int
	
	Method New( node:TParseNode, criteria:String )
		'DebugStop
		'Self.node = node
		'Self.criteria = criteria
		stack = New TList()
		' Push all nodes onto stack
		stacknodes( node, criteria )
	End Method
	
	Method stacknodes( node:TParseNode, criteria:String )
		'DebugStop
		For Local child:TParseNode = EachIn node.children
			stacknodes( child, criteria )
		Next
		'Debug( node.reveal() )
		If node.name = criteria; stack.addlast( node )
	End Method
	
	Method hasnext:Int()
		Return Not stack.isEmpty()
	End Method
	
	Method nextObject:Object()
		Return stack.removelast()
	End Method
End Type
End Rem

Type TSearchEnumerator

	Field list:TList
	
	Method New( node:TParseNode, criteria:String )
		list = New TList()
		walk( node, criteria )
	End Method
	
	Method walk( node:TParseNode, criteria:String )
		'DebugStop
		For Local child:TParseNode = EachIn node.children
			walk( child, criteria )
		Next
		If node.name = criteria; list.addlast( node )
	End Method
	
	Method ObjectEnumerator:TListIterator()
		'DebugStop
		Return New TListIterator( list )
	End Method
	
End Type

' Visit all the children execpt the last, then to parent
' then the last child.
' Primarily this should be used on Binary trees!
Type TInOrderEnumerator

	Field list:TList
	
	Method New( node:TParseNode )
		list = New TList()
		walk( node )
	End Method
	
	Method walk( node:TParseNode )
		Local lastchild:Int = node.children.length
		' ADD LEFT CHILDREN SUBTREES
		For Local i:Int = 0 Until lastchild-1
			walk( node.children[i] )
		Next
		' ADD SELF
		list.addlast( node )
		' ADD RIGHT CHILD SUBTREE
		If lastchild>1; walk( node.children[lastchild-1] )
	End Method

	Method ObjectEnumerator:TListIterator()
		Return New TListIterator( list )
	End Method

End Type

Type TPreOrderEnumerator 'Implements IEnumerator

	Field list:TList

	Method New( node:TParseNode )
		list = New TList()
		' Build stack from tree
		Local todo:TList = New TList()
		todo.addlast( node )
		While Not todo.isEmpty()
			node = TParseNode( todo.removeFirst() )
			list.addlast( node )
			For Local i:Int = 0 Until node.children.length
				todo.addlast( node.children[i] )
			Next
		Wend
	End Method

	Method ObjectEnumerator:TListIterator()
		Return New TListIterator( list )
	End Method

End Type

Type TPostOrderEnumerator

	Field list:TList

	Method New( node:TParseNode )
		list = New TList()
		walk( node )
	End Method

	Method walk( node:TParseNode )
		For Local i:Int = 0 Until node.children.length
			walk( node.children[i] )
		Next	
		list.addlast( node )
	End Method

	Method ObjectEnumerator:TListIterator()
		Return New TListIterator( list )
	End Method

End Type

Type TListIterator
	Field list:TList

	Method New( list:TList )
		Self.list = list
	End Method
	
	Method hasnext:Int()
		Return Not list.isEmpty()
	End Method
	
	Method nextObject:Object()
		Return list.removefirst()
	End Method
End Type	
