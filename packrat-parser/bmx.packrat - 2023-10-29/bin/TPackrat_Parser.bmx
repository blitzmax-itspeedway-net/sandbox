' TPackrat_Parser
' (c) Copyright Si Dunford [Scaremonger], 2023-date, All rights reserved.
' VERSION 1.0
'
' A Packrat parser. This will be extended to support a specific language

Type TPackrat_Parser

	Field grammar:TGrammar
	Field source:String
	Field memo:TMemoisation

'	Method New()
'		grammar = New TDictionary()
'	End Method
	
	' Parse PEG definition into a language grammar
	'Method build:TParser( definition:String, name:String )
		'DebugStop
		'If FileType( definition ) = FILETYPE_FILE
		'	definition = LoadString( definition )
		'End If
		
		'Local PEG:TParser = New PEG_Parser()

		' Parse the definition into a parse tree	
		'DebugStop
		'Local tree:TParseNode = PEG.parse( definition, "PEG" )
		'ui.treeviewer.Create( tree )
		'DebugStop
		'viewer.setTree( tree )
		'DebugStop
		
		' Build parser from parse tree
	'	Local text:String
		
		'DebugStop
		
		'SaveString( "parse_"+name+".bmx", definition )
		
	'	Return Self
	'End Method

	Method load:TParser( parser:String )
	'TODO:
		If FileType( parser ) = FILETYPE_FILE
		Else
			Return Null
		End If
	End Method
	
	' Saves a definition to a file (OVERWRITES)
	Method save( filename:String )
		DebugStop
		Local J:JSON = New JSON()
		For Local key:String = EachIn grammar.keys()
			Print "KEY="+key
			Local rule:TPattern = TPattern( grammar[key] )
			J[key] = rule.save() 
		Next
		Print J.Prettify()
		DebugStop
		SaveString( J.Prettify(), filename )
	End Method
	
	' Parse source using grammar into a Parse Tree
	Method parse:TParseTree( source:String )
		Self.source = source
		
		'# Get initial rule and start processing
		Local start:TPattern = grammar.StartRule()	'TPattern( grammar[ StartRule ] )
		' If we don't have a starting rule generate an Error Matcher
		If Not start; start = New TError( zeroOrmore( any() ), "Start rule '"+grammar.getStart()+"' is not defined in '"+grammar.name+"'" )

		' Parse the source starting with the starting rule
		DebugStop
		Local parsetree:TParseTree = New TParseTree( start.match( source ) )
		
		'CONSOLE.Tree = parsetree
		If parsetree
			Print( "TEXT" )
			Print( "----------" )
			Print parsetree.AsString()
		
			'Print( "PEG TREE" )
			'Print( "----------" )
			'Print( parsetree.AsString() )
		Else
			Print( "** Failed to PARSE source" )
		End If
		' Check for errors in syntax
		'TODO:
		'
		
		' Walk the tree
		
		'Local visitor:TVisitor = New TSearchByName("ERROR")
		'parsetree.Accept( visitor )
		
		'Local results:String[] = visitor.get()
		'Console.WriteLine("Sum: " + visitor.Sum);
		'For Local result:String = EachIn results
		'	Print result
		'Next
		
'		Print( "PRINT ERRORS" )
'		For Local error:TParseNode = EachIn parsetree.ByName( "ERROR" )
'			Local position:TPosition = parsetree.getPosition( error.start )
'			Print error.captured + " at " + position.format() + " / "+ error.start + ".." + error.finish
'			'Print "  LINE:"+position.line+", COLUMN:"+position.col
'		Next
'		Print( "-----" )
		
		'DebugStop
		
		' Create parser for syntax
		'CONSOLE.wait()
		
		'DebugStop
		
		Return parsetree
		
	End Method
	

	Private

	' Shortcut method to get WHITESPACE
	'Method _:TPattern( name:String )
	'	Return __("WSP")
	'End Method
	
	' Shortcut method to get a grammar object
	Method __:TPattern( name:String )
	'DebugStop
		Assert grammar.contains( name ), "Undefined Pattern '"+name+"' in definition"
	'	Local pattern:TPattern = New TNonTerminal( name, grammar )
	'	Return pattern
		Return grammar.nonTerminal( name )
	End Method

	' Pre-define some patterns
	' 10/10/23, Moved into TGrammar
	'Method predefine( patterns:String[] )
	'	For Local pattern:String = EachIn patterns
	'		grammar[pattern] = Any()
	'	Next
	'End Method

	Public
	
	Method rules:TMapEnumerator()
		Return grammar.keys()
	End Method
	
	' Validate the rules
	Method validate()
		Assert grammar, "Grammar is not defined"
		'Print "DEFINTION: "+grammar.name
		'DebugStop
		For Local rule:String = EachIn grammar.keys()
			Local pattern:TPattern = TPattern( grammar[rule] )
			Assert pattern, "Rule '"+rule+"' is declared but not defined in '"+grammar.name+"'"
			'Print rule + " -> " + pattern.peg()
		Next
	End Method
	
	'Method toPEG:String( hidden:Int = False )
	'		Print "PEG DEFINTION:"
	'	DebugStop
	'	For Local rule:String = EachIn grammar.keys()
	'	Local dd:Object = grammar[rule]
	'		Local pattern:TPattern = TPattern( grammar[rule] )
	'		if not pattern.hidden; Print rule + " -> " + pattern.peg()
	'	Next
	'End Method

	' Convert a start position into a line/column
	
	' There are a number of ways this can be done:
	' 1. Loop thorough source counting CRLF and calculate line length
	' 2. Extract all CRLF's in the latest parsetree and work out position of last
	' 3. Loop through parsetree summing lines
	Public Method getPosition:TPosition( pos:Int )
		'DebugStop
		'Local position:TPosition = New TPosition()
		Local line:Int = 1, last:Int
		For Local n:Int = 0 Until Min( pos, Len(source) )
			'Local x:Int = source[n]
			If source[n]=$0A
				line :+ 1
				last = n
			End If
		Next
		Return New TPosition( line, pos-last )
	End Method
	
End Type