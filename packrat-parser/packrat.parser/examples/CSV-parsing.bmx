' TEST CSV Parsing....

' REMEMBER - MATCH START POSITION ARE ZERO-BASED

Rem

This example uses the following CSV definition:

* A CSV contains one or line lines. Each line is a record.
* A Line contains one or more values seperated by commas

End Rem

'Import packrat.parser
Import "../../packrat.parser/parser.bmx"
Import "../../packrat.functions/functions.bmx"

Import "../../peg.parser/parser.bmx"

'Import peg.parser

Function showdata( result:TParseNode )
	Print "Result:"
	Print "+---+---+---+-----+"
	Print "| A | B | C | SUM |"
	Print "+---+---+---+-----+"
	For Local row:TParseNode = EachIn result.byName( "LINE" )
		Local line:String, sum:Int = 0
		'Print line.tostring()
		For Local col:TParsenode = EachIn row.byName( "ITEM" )
			line :+ "| " + col.value() + " "
			sum :+ Int(col.value())
		Next
		Print line + "| " + RSet(sum,3) + " |"
		Print "+---+---+---+-----+"
	Next
End Function

'	EXAMPLE DATA

Local CSV_DATA:String = "1,2,3~n4,5,6~n7,8,9~n"

'	USE PACKRAT MATCHING

Print "########################################"
Print "# PACKRAT MATCHING"
Print

'	Define the Packrat matcher

'DebugStop
' Equivalent To the regex: [^,\n]*
Local CSVItem:TPattern = ..
	CAPTURE( "ITEM", ..
		ONEORMORE( ..
			SEQUENCE([ ..
				NOTPRED( SYMBOL(",") ), ..
				NOTPRED( SYMBOL("~n" ) ), ..
				ANY() ..
			]) ..
		)..
	)
' Sort of like: CSVItem ("," CSVItem)*
Local CSVLine:TPattern = ..
	CAPTURE( "LINE",..
		SEQUENCE( [CSVItem, ONEORMORE( SEQUENCE([SYMBOL(","), CSVItem]))] )..
	)
' Sort of like: CSVLine ("\n" CSVLine)*
Local CSVFile:TPattern = ..
	CAPTURE( "FILE",..
		SEQUENCE( [CSVLine, ONEORMORE( SEQUENCE([SYMBOL("~n"), CSVLine]))] )..
	)

'	Match the data using the defined parser

Local result:TParseNode = CSVFile.match( CSV_DATA )

'	Debugging

Print result.AsString()

Print result.getTree()

Print result.reveal()

Print CSVFile.peg()
Print CSVLine.peg()
Print CSVItem.peg()

'	Show the result

showdata( result )


'	USE A PEG PARSER

Print
Print "########################################"
Print "# PEG PARSER"
Print

'TPackratParser.debug()
'DebugStop

'	Load the PEG definition from a file

Local csv_peg:String = LoadString( "csv.peg" )
Local csv_doc:TTextDocument = New TTextDocument( csv_peg )

'	Parse the CSV definition using the PEG parser
'DebugStop
Local PEG:TPackratParser     = PEG_Parser_DEV()
Local csv_tree:TParseTree
'Try
	DebugStop
	csv_tree = PEG.parse( csv_doc )
'Catch e:TParserException
'	Print "## EXCEPTION: "+e.message()
'	Print "## TRACEBACK: "+e.traceback()
'	End
'EndTry

If Not csv_tree
	Print "## csv_tree IS NULL"
	End
End If

' Check parse
'NEED To FIGURE OUT BEST WAY To GET PARSE ERRORS
DebugStop

Print "-----ASSTRING---------------------------"
'Print csv_tree.root.AsString()

Print "-----TREE-------------------------------"
'Print csv_tree.root.getTree()

'Print "-----TEXTTREE---------------------------"
'Print csv_tree.root.getTextTree()

Print "-----REVEAL-----------------------------"
DebugStop
Print csv_tree.reveal()

Print "-----PARSE ERRORS-----------------------"

' Manually extract errors
'Print "---> ERRORS BY NAME"
'For Local error:TParseNode = EachIn csv_tree.byName( "ERROR" )
'	Print "## "+error.value()
'Next

'Print "---> ERRORS BY NAME"
'For Local error:TParseNode = EachIn csv_tree.byKind( KIND_ERROR )
'	Print "## "+error.value()
'Next

Print "---> ERROR METHODS"
If csv_tree.hasErrors(); Print "## CSV HAS ERRORS"
Print "CSV ERRORS: "+ csv_tree.errorCount()
Local csv_errors:TParseError[] = csv_tree.getErrors()
Print "CSV ERRORCOUNT : "+ csv_errors.length
For Local error:TParseError = EachIn csv_errors
	Local position:TPosition = csv_doc.getPosition( error )

	Print "## "+position.format()+", "+error.message
Next

' ERRORS SHOULD BE IMPROVED, ESPECIALLY AS I NEED THESE FOR THE
' LANGUAGE SERVER
End
DebugStop

Print "########################################"
Print "# GRAMMAR GENERATOR"

'	Generate a CSV parser using the result
DebugStop

Print "-----PARSE CSV TREE TO GRAMMAR----------"
' 	COMPILE CSV PARSE TREE INTO GRAMMAR
Local Compile:TTreeToGrammar = New TTreeToGrammar()
Local csv_grammar:TGrammar
Try
	csv_grammar = Compile.grammar( csv_tree )
Catch e:TParserException
	Print "## EXCEPTION: "+e.message()
	Print "## TRACEBACK: "+e.traceback()
	End
EndTry
'Local CSV:TPackratParser     = New TPackratParser().from( PEG_result )
'Local CSV_result:TParseTree  = CSV.parse( CSV_DATA )

If Not csv_grammar
	Print "## grammar IS NULL"
	End
End If

Print csv_grammar.toPEG()

'	Show the result
DebugStop


'TODO:
' Now we need to create a parser using CSV_PEG
' And parse the CSV

Print "----------------------------------------"
Print "-----RESULT-----------------------------"
showdata( result )

Type TTreeToGrammar 

	Field tree:TParseTree
	Field result:TGrammar


	Field exception_on_missing_method:Int = True
	Field filter:String[]	' Filters the nodes that are allowed
	
	Method New( tree:TParseTree )
		Self.tree = tree
	End Method

	Method grammar:TGrammar( tree:TParseTree = Null )
		If tree; Self.tree = tree
		If Not Self.tree Or Not Self.tree.root; Return Null
		'
		' Wrap visitor to catch reflection exceptions that simply report "ERROR"
		Try
			visit( tree.root, Self )', "visit" )
		Catch e:String
			If e="ERROR"
				Throw New TReflectionException()
			Else
				Throw New TStringException( e )
			EndIf
		Catch e:Object
			Throw e
		End Try
		
	End Method



Rem	Method visit:String( node:TASTNode, prefix:String="visit", indent:String="" )
'DebugStop
		If Not node ThrowException( "Cannot visit null node" ) 
		'If node.name = "" invalid()	' Leave this to use "visit_" method
		
		' Use Reflection to call the visitor method (or an error)
'DebugStop
		Local this:TTypeId = TTypeId.ForObject( Self )
		' The visitor function is defined in metadata 
		Local class:String = this.metadata( "class" )
		If class = "" 
			If node.classname = "" ; Return ""
			class = node.classname
		End If
		Local methd:TMethod = this.FindMethod( prefix+"_"+class )
		If methd
			Local Text:String = String( methd.invoke( Self, [New TVisitorArg(node,indent)] ))
			Return Text
		EndIf
		If exception_on_missing_method ; exception( prefix+"_"+class )
		Return ""
	End Method
End Rem

	Method in:Int( needle:String, haystack:String[] )
		For Local i:Int = 0 Until haystack.length
			If haystack[i]=needle ; Return True
		Next
		Return False
	End Method

	Method visit( node:TParseNode, mother:Object, prefix:String = "visitor" )
		If Not node ; Return
		
		' We cannot visit a node unless it is named
		Local name:String = node.name()
		If Not name; Return
		
		' Use Reflection to call the visitor method (or an error)
		Local nodeid:TTypeId = TTypeId.ForObject( node )
		
		' The visitor function is defined in metadata or name
		Local class:String '= nodeid.metadata( "class" )
		If class = ""; class=name

DebugStop	
		' Filter nodes
		If filter.length>0 And Not in( Lower(class), filter ) 
DebugLog( "Filtered '"+class+"'")
			Return
		End If

		' Use Reflection to call the visitor method (or an error)
		Local this:TTypeId = TTypeId.ForObject( Self )
		Local methd:TMethod = this.FindMethod( prefix+"_"+class )
		If methd
			DebugStop
			DebugLog( "Visiting "+prefix+"_"+class+"()" )
			methd.invoke( Self, [node,mother] )
		ElseIf exception_on_missing_method
			Throw New TMissingVisitor( prefix+"_"+class )
		Else
			DebugLog( "Visitor "+prefix+"_"+class+"() is not defined" )
		EndIf

		' Visit children
		For Local child:TParseNode = EachIn node.children
			visit( child, node, prefix )
		Next
		
	End Method

	'Method visitChildren:String( node:TASTNode, prefix:String, indent:String="" )
	'	Local Text:String
	'	Local compound:TASTCompound = TASTCompound( node )
'DebugStop
	'	For Local child:TASTNode = EachIn compound.children
	'		Text :+ visit( child, prefix, indent )
	'	Next
	'	Return Text
	'End Method
	
	Method visitChildren( node:TParseNode, mother:Object, prefix:String )
		Local family:TParseNode = TParseNode( node )
		If Not family ; Return
		If Not family.children Or family.children.length=0; Return

		For Local child:TParseNode = EachIn family.children
			visit( child, mother, prefix )
		Next
	End Method
	
	' This is called when node doesn't have metadata or a name...
'	Method visit_:String( node:TParseNode, indent:String="" )
'		DebugStop
'		Throw( "Node '"+node.name()+"' has no name!" )
'	End Method
	
'	Method _:String( node:TParseNode, indent:String="" )
'		DebugStop
'		Throw( "Node '"+node.name()+"' has no name!" )
'	End Method
	
	Method visitor_PEG:String( node:TParseNode, mother:Object )
		DebugStop
		Print "PEG:"
	End Method

	Method visitor_comment:String( node:TParseNode, mother:Object )
		DebugStop
		Print "COMMENT:"
	End Method
	
End Type

