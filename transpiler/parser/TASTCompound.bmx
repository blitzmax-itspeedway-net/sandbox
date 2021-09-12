
'	ABSTRACT SYNTAX TREE / COMPOUND NODE
'	(c) Copyright Si Dunford, July 2021, All Rights Reserved

'	CHANGE LOG
'	V1.0	07 AUG 21	Initial version

' A Compound AST Node with multiple children
Type TASTCompound Extends TASTNode
	Field children:TList = New TList()
	
	' Walk the tree to find left-most leaf
	Method walkfirst:TASTNode()
		If children.isempty() Return Self
		Return TASTNode(children.first()).walkFirst()
	End Method
	
	' Obtain the child prior to given node
	'Method previous:TASTNode( given:TASTNode )
	'	If given And given.link Return TASTNode(given.link.prevlink.value())
	'	Return Null
	'End Method

	' Add a child
	Method add( child:TASTNode )
		child.link = children.addlast( child )
	End Method
	
	' Insert a child at top
'	Method insert( child:TASTNode )
'		child.link = children.addfirst( child )
'	End Method

	' Used for debugging tree structure
	Method reveal:String( indent:String = "" )
		Local block:String = ["!","."][valid]+" "+indent+name
		If value<>"" block :+ " "+Replace(value,"~n","\n")
		block :+ "~n"
		If descr<>"" block :+ indent+"  ("+descr+")~n"
		For Local child:TASTNode = EachIn children
			block :+ child.reveal( indent+"  " )
		Next
		Return block
	End Method
	
	' Validate the node and it's children
	' Passes the child state back
	Method validate:Int()
		If Not children Return True
'		valid = True
		Local status:Int = True
		For Local child:TASTNode = EachIn children
			status = Min( status, child.validate() )
		Next
		Return status
	End Method
	
End Type