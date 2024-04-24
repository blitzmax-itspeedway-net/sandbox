
'	TRANSPILER
'	(c) Copyright Si Dunford, July 2021, All Rights Reserved

'	9 NOV 2023  V2.00  Tree is now an object and not an TASTNode

Type TTranspiler Extends TVisitor

	Field tree:PNode
	Field TAB:String = "~t"
	
	Method New( tree:PNode, tab:String="~t" )
		Self.tree = tree
		Self.TAB  = tab
	End Method
	
	' Create code from the tree
	Method run:String()
'DebugStop
		Return visit( tree, "visit" )
		'Local text:String = visit( tree, "visit" )
		'Return text
	End Method

	' ABSTRACT METHODS

'	Method visit_program:String( arg:TVisitorArg ) 'node:TASTCompound, indent:String="" )
'DebugStop
'		Local text:String = header()
'		text :+ visitChildren( arg.node, "visit", "" )
'		Return text
'	End Method

'	Method visit_EOL:String( arg:TVisitorArg ) 'node:TASTNode, indent:String="" )
'		Return "~n"
'	End Method
	
End Type
