' PACKRAT PARSER
' Based on various research papers and other documents

Rem IMPROVEMENTS

number, aplha and alphanumeric can be improved by making a specific type
instead of a character comparison.

Pattern name should be an ID similar or instead of KIND. We dont need a string in here it was only for debugging.

LINE and COLUMN numbers getPosition() need some work as it mis-reports node column

' Packrat Parsing
'Local result:TParseTree = blitzmax.parse( program )

' Packrat incremental parsing
' If TParseTree.memoisation is null, then it acts as a parser
' Otherwise it uses the memo table to perform incremental parsing
' 3.3
' Memoisation tables need to have some UNDO/REDO capability
' For example, starting a multiline string will render the entire documen a string!
' Same with a mutli-line remark
'Local memoization:Object 	' New memoization table
'Local result:TParseTree = blitzmax.parse( program, memoization )



End Rem


'NEED A VISITOR To GET ALL ERROR NODES For BUILDING DEBUG MESSAGES

' https://blog.bruce-hill.com/packrat-parsing-from-scratch
' https://en.wikipedia.org/wiki/Parsing_expression_grammar

' https://janet-lang.org/docs/peg.html
' https://peps.python.org/pep-0617/

' PARSE TREE to AST:
' https://medium.com/basecs/leveling-up-ones-parsing-game-with-asts-d7a6fc2400ff


'SuperStrict

'Import "gui/gui.bmx"
'Import "../gui/IViewable.bmx"


Interface IVisitable
	Method accept( visitor:TVisitor )
End Interface

Type TVisitor
	Method visit( node:Object ) Abstract
	Method get:String[]() Abstract
End Type

Type TSearchByName Extends TVisitor

	Field name:String
	Field results:TList
		
	Method New( name:String )
		Self.results = New TList()
		Self.name = name
	End Method

	Method visit( node:Object )
		Local match:TParseNode = TParseNode( node )
		'DebugStop
		If Not match Or match.name <> name; Return
		DebugStop
		results.addlast( match )
	End Method


	Method get:String[]()
		DebugStop
	End Method
End Type	



Function title( text:String )
	Print( "+----------------------------------------" )
	Print( "| "+Upper(text) )
	Print( "+----------------------------------------" )
End Function











'######################################################




Rem Memoization
Key-Value list
	The key is (id,pos)
	The value contains the length of the match (or null if no match)
		and the resulting ParseTree (if any) [optional]

End Rem

Rem
Type TPEGgenerator

	Field def:String
	Field rules:TMap
		
	' Takes filename or text definition of the parser to generate
	Function build:TPEGParser( def:String )
		Local generator:TPEGgenerator

		If FileType( def ) = FILETYPE_FILE
			generator = New TPEGgenerator( LoadString( def ) )
		Else
			generator = New TPEGgenerator( def )
		End If
		
		' Initialise the PEG parser
		generator.initialise()
		
		Return generator.parse()
	End Function
	
	Method New( def:String )
		Self.def = def
		Self.rules = New TMap()
	End Method
	
	Method initialise()
		' Set up PEG rules
		
		'rules["PEG"] = 
	End Method
	
	Method parse:TPEGParser()
	
		'Local parser:TPattern = rules["peg"].match( def )
		Return Null
	End Method
	
End Type
End Rem

Rem # BUILD BLITZMAX GRAMMAR PARSER USING PEG
module:
program: _strictmode frame
 
EndRem

Rem
Type TParseTree
	Field memoisation:Object
End Type
End Rem

'Local blitzmax:TPEGParser = TPEGgenerator.build( EXAMPLE )

'Local program:String = LoadString( "tests/program1.bmx" ) 

' Packrat Parsing
'Local result:TParseTree = blitzmax.parse( program )

' Packrat incremental parsing
' If TParseTree.memoisation is null, then it acts as a parser
' Otherwise it uses the memo table to perform incremental parsing
' 3.3
' Memoisation tables need to have some UNDO/REDO capability
' For example, starting a multiline string will render the entire documen a string!
' Same with a mutli-line remark
'Local memoization:Object 	' New memoization table
'Local result:TParseTree = blitzmax.parse( program, memoization )


