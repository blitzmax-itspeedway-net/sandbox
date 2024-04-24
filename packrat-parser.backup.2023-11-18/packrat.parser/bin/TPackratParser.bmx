' TPackrat_Parser
' (c) Copyright Si Dunford [Scaremonger], 2023-date, All rights reserved.
' VERSION 1.0
'
' A Packrat parser. This will be extended to support a specific language

Type TPackratParser

	Field grammar:TGrammar
	Field document:TTextDocument	
	Field memo:TMemoisation
	
'	Field this:TTypeId			' This is a Reflection of self

'	Method New()
'		grammar = New TDictionary()
'	End Method

	Method New( name:String, start:String = "START" )
		grammar = New TGrammar( name, start )
	End Method

	' Parse definition into a language grammar
Rem
	Method build:TPackrat_Parser()

		DebugStop
		Try
			Local name:String, start:String, rulename:String
			ReadData name, start, rulename
			grammar = New TGrammar( name, start, False )
		
			While rulename<>"#END#"
				Local pattern:TPattern = buildtree()
				
				grammar[rulename] = pattern	'buildtree()
				ReadData rulename
			Wend
		
		Catch e:String
			Print "Error: "+e
		EndTry
		
		Return Self

	End Method
	
	Method buildtree:TPattern()
		Local pattern:TPattern
		Local name:String, typeid:String, kind:Int, core:Int, sensitive:Int, patterns:Int, expect:String, pat:String, init:String
		
		ReadData name
		If name = "#END#"; Return pattern
		ReadData typeid, kind, core, sensitive, patterns, expect, pat, init
	
		Select Upper(typeid)
		Case "ANY", "TANY"
			pattern = New TAny()
		Default
			Print "## Unknown Type-ID: '"+typeid
			DebugStop
		End Select
		
		If patterns>0
			For Local n:Int = 0 Until patterns
				pattern.patterns :+ [buildtree()]
			Next
		End If
	End Method
EndRem

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
	
	' Saves grammar definition as JSON to a file (OVERWRITES)
'	Method save( filename:String )
'		Assert grammar And Not grammar.Empty, "Grammar is not defined"
'		Local text:String = toJSON()
'		SaveString( text, filename )
'	End Method

Rem	
	Method toJSON:String()
		'DebugStop
		
		' Create Rules
		Local Jrules:JSON = New JSON()
		For Local key:String = EachIn grammar.keys()
			Print "KEY="+key
			Local pattern:TPattern = TPattern( grammar[key] )
			Jrules[key] = pattern.save() 
		Next
		
		' Create JSON
		Local J:JSON = New JSON()
		J["name"]  = grammar.name
		J["start"] = grammar.start		
		J["rules"] = Jrules
		
'		Print J.Prettify()
		Return J.Prettify()
	End Method

	Method toData:String()
		Return grammar.todata()
	End Method	
EndRem

Rem
	Method fromJSON:TPackrat_Parser( text:String )
		'DebugStop
		Local J:JSON = JSON.Parse( text )
		Assert J, "JSON definition is invalid"
		Local name:String      = J["name"].toString()
		Local startrule:String = J["start"].toString()
		Local core:Int         = J["core"].toInt()
		Local rules:JSON       = J.search("rules")
		
		If Not name;      name = Hex( Rand( $0000, $ffff ) )
		If Not startrule; startrule="start"
		
		grammar = New TGrammar( name, startrule, core )
	
		If Not rules; Return Self

		DebugStop
		For Local rulename:String = EachIn rules.keys()
			'DebugStop
			'Print rulename
			Local rule:JSON = rules.find( rulename )
			'Local typeid:String = rule["typeid"]
			
			Local pattern:TPattern = transpose( rule, rulename, grammar )
			
			'Local pattern:TPattern = TPattern( rule.transpose( typeid ) )
			Local identifier:String = pattern.identifier()
			If identifier; identifier = " '"+identifier+"'"
			Local quiet:String = ["","#quiet "][pattern.quiet]
			Print rulename + identifier + " -> "+quiet+pattern.PEG()
			
			'DebugStop
			grammar[rulename] = pattern
			
		Next
		
		Print grammar.toPEG()
		
		If validate(); Return Self
		DebugStop	
		Return Null
	End Method
EndRem

Rem
	Method transpose:TPattern( rule:JSON, name:String, grammar:TGrammar )
		Local typeid:String = rule["typeid"]
		'DebugStop
		Local pattern:TPattern
		Select Upper(typeid)
		Case "TANDPREDICATE", "AND", "ANDPRED", "ANDPREDICATE"
			pattern = New TAndPredicate()
		Case "TANY", "ANY"
			pattern = New TAny()
		Case "TCHOICE", "CHOICE"
			pattern = New TChoice()
		Case "TGROUP", "GROUP"
			pattern = New TGroup()
		Case "TNOTPREDICATE", "NOT", "NOTPRED", "NOTPREDICATE"
			pattern = New TNotPredicate()
		Case "TONEORMORE", "ONEORMORE"
			pattern = New TOneOrMore()
		Case "TOPTIONAL", "OPTIONAL", "ZEROORONE"
			pattern = New TOptional()
		Case "TRANGE", "RANGE"
			pattern = New TRange()
			TRange(pattern).allowed = rule["pattern"].toString()
		Case "TSEQUENCE", "SEQUENCE"
			pattern = New TSequence()
		Case "TZEROORMORE", "ZEROORMORE"
			pattern = New TZeroOrMore()
			'DebugStop
		Case "TCHARSET", "CHARSET"
			pattern = New TCharset()
			TCharset(pattern).allowed = rule["pattern"].toString()
		Case "TLITERAL", "LITERAL"
			pattern = New TLiteral()
			TLiteral(pattern).casesensitive = rule["casesensitive"].toInt()
			TLiteral(pattern).pattern = rule["pattern"].toString()
		Case "TNONTERMINAL", "NONTERMINAL"
			pattern = New TNonTerminal()
			TNonTerminal(pattern).grammar = grammar
		Case "TSYMBOL", "SYMBOL"
			pattern = New TSymbol()
			TSymbol(pattern).set( rule["pattern"].toString() )
		Case "TERROR", "ERROR"
			pattern = New TError()
			TError(pattern).errortext = rule["errortext"]
		Default
			Assert False, "Invalid typeid '"+typeid+"' in rule '"+name+"' definition."
		End Select
		'
		Assert pattern, "Failed to transpose rule '"+name+"'"
		
		'
		pattern.kind     = rule["kind"].toInt()
		pattern.name     = rule["name"].toString()
		pattern.hidden   = rule["core"].toInt()
		pattern.expected = rule["expected"].tostring()
		pattern.quiet    = rule["quiet"].toInt()
		
		Local patterns:JSON = rule.search("patterns")
		If Not patterns; Return pattern
		'DebugStop
		For Local child:JSON = EachIn patterns
			'DebugStop
			pattern.patterns :+ [ transpose( child, name, grammar ) ]
		Next
		Return pattern
	End Method
EndRem

	Method errorcount:Int()
		If Not document; Return -1
		Return document.errors.length
	End Method

	' Get the grammar name tied to this parser
	Method name:String()
		Return grammar.name
	End Method

	' Parse source using grammar into a Parse Tree
	Method parse:TParseTree( source:String, startrule:String="" )
		Return parse( New TTextDocument( source ), startrule )
	End Method
	
	' Parse document using grammar into a Parse Tree
	Private Method parse:TParseTree( document:TTextDocument, startrule:String="" )
		Self.document = document

		' Ensure source code ends with a "\n"
		' If this is not appended; you have to check for EOI as well as EOL in each statement
'TODO: Should this be corrected; or is it simply a coding fault?
		If Not Self.document.content.endswith("~n"); Self.document.content :+ "~n"

'		DebugStop
'		Local rule:TMethod
'		Try
'			rule = findrule( "START" )
'		
'			DebugStop
'			If rule
'				rule.invoke( Self, ["TEST"] )
'			End If
'				'Invoke:Object( obj:Object,args:Object[] = Null)
'			
'		Catch E:TException
'			Print E.message()
'			DebugStop
'		EndTry
		
		'# Get initial rule and start processing
		Local start:TPattern 
		If startrule
			start = grammar.getrule( startrule )
		Else
			start = grammar.StartRule()
		End If

		' If we don't have a valid starting rule generate an Error Matcher
		If Not start
			'start = New TError( zeroOrmore( any() ), "Start rule '"+grammar.getStart()+"' is not defined in '"+grammar.name+"'" )
			Local pattern:TPattern = New TZeroOrMore( New TAny() )
			start = New TError( pattern, "Start rule '"+startrule+"' is not defined in '"+grammar.name+"'" )
		End If

		' Parse the source starting with the starting rule
		'DebugStop
		Try
			Return New TParseTree( start.match( document ) )
		Catch e:String
			Print e
			DebugStop
		End Try
	End Method
	

'	Method findrule:TMethod( name:String )
'		
'		Local methd:String = "__"+Upper(name)
'		
'		If Not this; this = TTypeId.forobject( Self )
'		Local rule:TMethod
'		
'		rule = this.findmethod( "__"+name )
'		If rule; Return rule
'		rule = this.findmethod( "RULE_"+name )
'		If rule; Return rule
'		
'		error( name, New TFailedRef() )
'	
'	End Method

'	Method error( msg:String, exception:IException = Null )
'		If Not exception; exception = New TFailedParse()
'       Throw exception.set( msg )
'	End Method

'	Method fail()
'		error( "FAIL" )
'	End Method

	public Method setGrammar( grammar:TGrammar, Replace:Int=True )
		
		DebugStop
		
		If Replace
			Self.grammar = grammar
			Return
		End If
		
		For Local key:String = EachIn grammar.keys()
			Local pattern:TPattern = grammar[key]
			Self.grammar[key] = pattern
		Next
	
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
		Return document.getPosition( pos )
		'DebugStop
		Rem
		Local line:Int = 1, last:Int
		For Local n:Int = 0 Until Min( pos, Len(source) )
			'Local x:Int = source[n]
			If source[n]=$0A
				line :+ 1
				last = n
			End If
		Next
		Return New TPosition( line, pos-last )
		EndRem
	End Method
	
End Type
