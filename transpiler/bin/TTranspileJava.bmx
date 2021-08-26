
'	JAVA TRANSPILER
'	(c) Copyright Si Dunford, July 2021, All Rights Reserved

Type TTranspileJava Extends TTranspiler

	Method header:String()
		Return "~n//~n//"+TAB+"Transpiled from BlitzMaxNG by Scaremongers Transpiler~n//~n~n"
	End Method

	Method visit_comment:String( arg:TVisitorArg ) 'node:TASTNode, indent:String="" )
		Return "// "+arg.node.value+"~n"
	End Method

	Method visit_framework:String( arg:TVisitorArg ) 'node:TASTNode, indent:String="" )
		Local text:String = "// Framework "+arg.node.value
		If arg.node.descr text :+ " ' "+arg.node.descr
		Return text + "~n"
	End Method
	
	Method visit_function:String( arg:TVisitorArg ) 'node:TAST_Function, indent:String="" )
'DebugStop
		If Not arg.node ThrowException( "Invalid node in visit_function" ) 
		Local text:String = "static "
		Local compound:TAST_Function = TAST_Function( arg.node )
		If compound.returntype
			text :+ compound.returntype.value + " "
		Else
			text = "void "
		EndIf
		text :+ arg.node.value+"() {~n"
		If arg.node.descr text :+ TAB+"// "+arg.node.descr +"~n"
		text :+ arg.indent+"}~n"
		Return text
	End Method

	Method visit_import:String( arg:TVisitorArg ) 'node:TASTNode, indent:String="" )
		Local text:String = "// Import "+arg.node.value
		If arg.node.descr text :+ " ' "+arg.node.descr
		Return text + "~n"
	End Method
	
	Method visit_imports:String( arg:TVisitorArg ) 'node:TASTCompound, indent:String="" )
		Return visitChildren( arg.node, "visit", arg.indent+TAB  )
	End Method

	Method visit_include:String( arg:TVisitorArg ) 'node:TASTNode, indent:String="" )
		Local text:String = "// Include "+arg.node.value
		If arg.node.descr text :+ " ' "+arg.node.descr
		Return text + "~n"
	End Method

	Method visit_method:String( arg:TVisitorArg ) 'node:TAST_Function, indent:String="" )
'DebugStop
		If Not arg.node ThrowException( "Invalid node in visit_function" ) 
		Local text:String = arg.indent
		Local compound:TAST_Method = TAST_Method( arg.node )
		If compound.returntype
			text :+ compound.returntype.value + " "
		Else
			text :+ "void "
		EndIf
		text :+ arg.node.value+"() {~n"
		If arg.node.descr text :+ TAB+"// "+arg.node.descr +"~n"
		text :+ arg.indent+"}~n"
		Return text
	End Method
		
	Method visit_remark:String( arg:TVisitorArg ) 'node:TASTNode, indent:String="" )
		Return "/*"+arg.node.value+"*/~n"
	End Method

	Method visit_strictmode:String( arg:TVisitorArg ) 'node:TASTNode, indent:String="" )
		Return ""
	End Method

	Method visit_type:String( arg:TVisitorArg ) 'node:TAST_Type, indent:String="" )
		Local text:String = "class "+arg.node.value 
		Local compound:TAST_Type = TAST_Type( arg.node )
		If compound.supertype
			text :+ " extends "+compound.supertype.value
		EndIf
		text :+ " {~n"
		If arg.node.descr text :+ TAB+"// "+arg.node.descr +"~n"
		text :+ visitChildren( arg.node, "visit", arg.indent+TAB )
		text :+ "}~n"
		Return text
	End Method
		
End Type
