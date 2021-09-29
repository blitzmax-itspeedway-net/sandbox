
'	ABSTRACT SYNTAX TREE / NODE
'	(c) Copyright Si Dunford, July 2021, All Rights Reserved

'	CHANGE LOG
'	V1.0	07 AUG 21	Initial version
'	V1.1	17 AUG 21	Added consume()

' An Abstract Syntax Tree Leaf Node
Type TASTNode
	Field parent:TASTNode
	'Field class:Int
	Field name:String		' Fallback to metadata "class"
	'Field token:TToken
	Field tokenid:Int		' This is the token id that created the node
	Field value:String		' Used in leaf nodes
	Field line:Int, pos:Int	' Not normally held in an AST, but needed for language server
	'Field definition:String	' Block comment (before) used to describe meaning
	Field descr:String		' Optional Trailing "line" comment
	Field link:TLink		' Used in Compound nodes
	
	Field comment:TToken	' Trailing comment or Null
	Field valid:Int = False	' Is node valid
	Field error:String		' The invalidation message
	
	Method New( name:String )
		Self.name  = name
	End Method

	Method New( token:TToken )
		consume( token )
	End Method

	Method New( name:String, token:TToken, desc:String = "" )
		Self.name  = name
		consume( token )
		Self.descr = descr
	End Method

	Method class:String()
		Local T:TTypeId = TTypeId.ForObject( Self )
		Return T.metadata("class")
	End Method
	
	Method consume( token:TToken )
		Self.tokenid = token.id
		Self.value   = token.value
		Self.line    = token.line
		Self.pos     = token.pos
	End Method
	
	' Walk the tree to find left-most leaf
	Method walkfirst:TASTNode() 
		Return Self
	End Method
	
	' A Leaf has not decendents go automatically passes to parent.
	'Method walknext:TASTNode()
	'	Return parent
	'End Method
	
	' Obtain the preceeding node
	'Method preceeding:TASTNode()
	'	If parent Return parent.previous( Self )
	'	Return Null
	'End Method
	
	' Obtain the child prior to given node
	'Method previous:TASTNode( given:TASTNode )
	'	Return Null
	'End Method
	
	' Used for debugging tree structure
	Method reveal:String( indent:String = "" )
		Local block:String = ["!","."][valid]+" "+indent+getname()
		block :+ " " + Trim(showLeafText()) + "~n"
		If descr<>"" block :+ " >"+indent+"  ("+descr+")~n"
		Return block
	End Method

	' Get string location
	Method loc:String( Prefix:String = " " )
		Return prefix+"["+line+","+pos+"]"
	End Method
	
	' Debugging text (Name of node taken from metadata or name)
	Method getname:String()
		Local this:TTypeId = TTypeId.ForObject( Self )
		Local class:String = this.metadata( "class" )
		If class Return class
		Return name
	End Method
	
	' Debugging text (Leaf value)
	Method showLeafText:String()
		Return Replace(value,"~n","\n")
	End Method
	
	' Confirm validity of a node
	Method isValid:Int()
		Return valid
	End Method
	
	' Validate the node
	' By default it is invalid forcing a validate function to be added to node
	Method validate()
		valid = False
		error = ""
	End Method
	
End Type

Type TASTError Extends TASTNode

	Method New( name:String )
		Self.name  = name
		Self.valid = False	' INVALID BY DEFAULT
	End Method

	Method New( token:TToken )
		consume( token )
		Self.valid = False	' INVALID BY DEFAULT
	End Method

	Method New( name:String, token:TToken, desc:String = "" )
		Self.name  = name
		consume( token )
		Self.descr = descr
		Self.valid = False	' INVALID BY DEFAULT
	End Method
		
	' Used for debugging tree structure
	Method reveal:String( indent:String = "" )
		Local block:String = ["!","."][valid]+" "+indent+name
		If value<>"" block :+ " "+Replace(value,"~n","\n")
		block :+ "~n"
		If descr<>"" block :+ indent+"  ("+descr+")~n"
		Return block
	End Method

End Type
