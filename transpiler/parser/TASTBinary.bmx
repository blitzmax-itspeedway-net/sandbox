
'	ABSTRACT SYNTAX TREE / BINARY NODE
'	(c) Copyright Si Dunford, July 2021, All Rights Reserved

'	CHANGE LOG
'	V1.0	07 AUG 21	Initial version

' A binary AST Node (TRUE/FALSE, LEFT/RIGHT etc)
Type TASTBinary Extends TASTNode
	Field lnode:TASTNode, rnode:TASTNode
	
	' Walk the tree to find left-most leaf
	Method walkfirst:TASTNode()
		If lnode Return lnode.walkfirst()
		Return lnode
	End Method

	' Obtain the child prior to given node
	'Method previous:TASTNode( given:TASTNode )
	'	If given=rnode Return lnode
	'	Return Null
	'End Method

	' Used for debugging tree structure
	Method reveal:String( indent:String = "" )
		Local block:String = indent+name
		If value<>"" block :+ " "+Replace(value,"~n","\n")
		block :+ "~n"
		If lnode
			block :+ lnode.reveal( indent+"  " )
		Else
			block :+ "NULL~n"
		End If
		If rnode
			block :+ rnode.reveal( indent+"  " )
		Else
			block :+ "NULL~n"
		End If
		If descr<>"" block :+ indent+"  ("+descr+")~n"
		Return block
	End Method

End Type