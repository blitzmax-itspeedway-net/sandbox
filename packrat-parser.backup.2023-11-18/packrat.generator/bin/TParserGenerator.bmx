'   TParseGenerator
'   (c) Copyright Si Dunford, MMM 2022, All Rights Reserved. 
'   VERSION: 1.0

'	Creates a Parser from a given grammar

'   CHANGES:
'   DD MMM YYYY  Initial Creation
'

Rem NOTES

Each grammar rule will have its own method called by reflection
	Pass AST as the function and return it as default to allow extension
	
	FUNCTION <- ^"function" ...
	
	would result in a method:
		
		Method visit_{$function$}:ASTNode( ast:ASTNOde ) 
			Return ast
		End Method

	A default visitor will also be provided for anything that is not defined
	(This might be in TParser rather than the generated code)
	
		Method visit_default:ASTNode( ast:ASTNOde ) 
			Return ast
		End Method

How to use the generated parser:
	(The example uses a template that generates "Function MyLanguage_Parser() and Type TMyLanguage_Parser"

	Local parser = MyLanguage_Parser()
ast = parser.parse('text to parse', rule_name='start')
print(ast)
print(json.dumps(ast, indent=2)) # ASTs are JSON-friendy


End Rem

Incbin "../parser_template.txt"

Type TParserGenerator


	Field data:TMap
	Field grammar:TGrammar
	Field name:String
	Field template:String
	Field parseTree:TParseTree

	Method New( name:String, grammar:TGrammar )
	
		data           = New TMap()
		Self.grammar   = grammar
		Self.name      = name
		'Self.parseTree = parseTree

		'
		data["DATE"]      = CurrentDate()
		data["VERSION"]   = VERSION
		data["NAME"]      = Upper(name)
		data["STARTRULE"] = "START"
		data["GENERATOR"] = GENERATOR
		data["WEBLINK"]   = WEBLINK

	End Method


Rem
	Method New( name:String, parseTree:TParseTree )
		data           = New TMap()
		'Self.grammar   = grammar
		Self.name      = name
		Self.parseTree = parseTree

		'
		data["DATE"]      = CurrentDate()
		data["VERSION"]   = "1.0"
		data["NAME"]      = Lower(name)
		data["STARTRULE"] = "START"
		
	End Method
End Rem	

	Method set( key:String, value:String )
		data[Upper(key)] = value
	End Method
	
	Method set( data:String[][] )
		For Local item:String[] = EachIn data
			set( item[0], item[1] )
		Next
	End Method
	
Rem
	Method write( file:String="", properties:String[][] = Null )

		' Validate parse tree
		Local count:Int
		For Local error:TParseNode = EachIn parsetree.ByName( "ERROR" )
			DebugStop
			'Local position:TPosition = parsetree.getPosition( error.start )
			'Print error.captured + " at " + position.format() + " / "+ error.start + ".." + error.finish
			'Print "  LINE:"+position.line+", COLUMN:"+position.col
			'count :+ 1
		Next
		Assert count=0, "Parse tree contains errors. Generator failed"

		' Defaults
		If file = ""; file = "packrat_parser_"+Lower(name)+".bmx" 
		If properties; set( properties )
		
		' Load the blitzmax parser template
		'DebugStop
		
		'Assert FileType( TEMPLATEFILE ) = FILETYPE_FILE, "Template file '"+TEMPLATEFILE+"' missing from "+CurrentDir()
		template = LoadString( "incbin::parser_template.txt" )
		Assert template, "Template file 'parser_template.txt' missing"
		
		' Add PEG definition to template
		'data["PEG"] = grammar.toPEG()
		'Print grammar.toPEG()
		
		'DebugStop
		
		' Generate blitzmax code for each rule
		Print "BLITZMAX RULES:"
		Local declaration:String[] = []
		Local rulenames:String[] = []
		
		For Local rule:TParseNode = EachIn parseTree.ByName( "RULE" )
			DebugStop
			
			' Add to pre-declaration list
			declaration :+ [rule.name]
			
			' Add to rule list
			rulenames :+ [ "{$RULE:"+rule.name+"$}" ]

			' Create rule
			'set( "RULE:"+rule.name, TBC )
			
			DebugStop
			
		Next
		
		' Pre-declare rules
		set( "DECLARATION", ",".join(declaration) )
		set( "RULES", "~n".join(rulenames) )
		
		
		
		' UPDATE TEMPLATE CONTENT
		
		'Local finder:TGrammar = New TGrammar( False )
		'finder.predefine( "OPEN", "CLOSE" )
		'finder["OPEN"] = LITERAL( "{$" )
		'finder["CLOSE"] = LITERAL( "$}" )
		'finder["SEARCH"] = ..
		'	SKIPUNTIL( finder.nonterminal("OPEN") )
		'	SEQUENCE( "TAG", [ ..
		'		finder.nonterminal("OPEN"), ..
		'		CHOICE([ ..
		'			NOTPRED( finder.nonterminal("CLOSE") ), ..
		'			ANY() ..
		'			]), ..
		'		finder.nonterminal("CLOSE") ..
		'		])
		'	UNTILEND()
		'
		'Local search:IPattern = finder[ "SEARCH" ]
		
		Local regex:TRegEx = TRegEx.Create("({\$(.*?)\$})")
		
		Try
			DebugStop
			Local matches:TRegExMatch
			Repeat
				matches = regex.Find(template)
				DebugStop
				While matches
					'DebugStop
					'For Local i:Int = 0 Until matches.SubCount()
					'	Print i + ": " + matches.SubExp(i)
					'Next
					If matches.subcount()=3
						Local key:String = String(matches.subexp(2))
						Local value:String = String( data[key] )
						template = template.Replace( String(matches.subexp(1)), value )
						Print matches.subexp(1) + " := " + value
					End If
					matches = regex.Find()
				Wend
				DebugStop
			Until Not matches

		Catch e:TRegExException
			Print "Error : " + e.toString()
			End
		End Try
			
		'For Local key:String = EachIn data.keys()
		'	Local tag:String = "{$"+Upper(key+"$}"
		'	template.Replace( tag, data[key] ) )
		'Next

		Print template
		DebugStop
		
		' Save file
		SaveString( template, file )
	
	End Method
EndRem

	Method write( filename:String="", properties:String[][] = Null )

		'DebugStop
		If Not grammar; Throw "NO GRAMMAR DEFINED"
		data["STARTRULE"] = grammar.getStart()
		
		' Defaults
		If filename = ""; filename = "TPackratParser_"+Upper(name)+".bmx" 
		If properties; set( properties )

		Local verhi:Int = 1
		Local verlo:Int = 0
		Local build:Int = 0

		' Get the current parser version number
		Local configfile:String = StripExt( filename ) + ".ver"
		If FileType( configfile )
			Local file:TStream = ReadFile( configfile )
			If file
				While Not Eof(file)
					Local line:String = ReadLine( file )
					Local keyvalue:String[] = line.split("=")
					If keyvalue.length=2
						Select Upper(keyvalue[0])
						Case "VERSION"
							Local num:String[] = keyvalue[1].split(".")
							Select num.length
							Case 1
								verhi = Int( num[0] )
								verlo = 0
							Case 2
								verhi = Int( num[0] )
								verlo = Int( num[1] )
							End Select
						Case "BUILD"
							build = Int( keyvalue[1] ) + 1
						End Select
					End If
				Wend
			CloseStream file
			End If
		End If

		set( "VERSION", verhi+"."+verlo )
		set( "BUILD", build )

		' Load the parser template
		template = LoadString( "incbin::../parser_template.txt" )
		Assert template, "Template file 'parser_template.txt' missing"
		
		' Add PEG definition to template
		set( "PEG", grammar.toPEG() )
		
		' Convert grammar to rule definition
		Local declaration:String[] = []
		Local rulenames:String[]   = []
		Local tab:String           = " "[..2].Replace(" ","~t")
		
		For Local key:String = EachIn grammar.keys()
		'	parseTree.ByName( "RULE" )
		'	DebugStop
		
			' Add to pre-declaration list
			declaration :+ ["~q"+key+"~q"]
			
			' Add to rule list
			rulenames :+ [ "{$RULE:"+key+"$}" ]

			' Create rule
			set( "RULE:"+key, ..
				tab+"' "+key+" <- " + grammar[key].PEG() +"~n"+ ..
				tab+"grammar[~q"+key+"~q] = .." + grammar[key].generate(tab+"~t") + "~n" ..
				)
'			
'			DebugStop
'			
		Next
	
		' Pre-declare rules
		set( "DECLARATION", ",".join(declaration) )
		set( "RULES", "~n".join(rulenames) )
		
		' UPDATE TEMPLATE CONTENT
		
		'Local finder:TGrammar = New TGrammar( False )
		'finder.predefine( "OPEN", "CLOSE" )
		'finder["OPEN"] = LITERAL( "{$" )
		'finder["CLOSE"] = LITERAL( "$}" )
		'finder["SEARCH"] = ..
		'	SKIPUNTIL( finder.nonterminal("OPEN") )
		'	SEQUENCE( "TAG", [ ..
		'		finder.nonterminal("OPEN"), ..
		'		CHOICE([ ..
		'			NOTPRED( finder.nonterminal("CLOSE") ), ..
		'			ANY() ..
		'			]), ..
		'		finder.nonterminal("CLOSE") ..
		'		])
		'	UNTILEND()
		'
		'Local search:IPattern = finder[ "SEARCH" ]
		
		Local regex:TRegEx = TRegEx.Create("({\$(.*?)\$})")
		
		Try
			'DebugStop
			Local matches:TRegExMatch
			matches = regex.Find(template)
			While matches
				'DebugStop
				While matches
					'DebugStop
					'For Local i:Int = 0 Until matches.SubCount()
					'	Print i + ": " + matches.SubExp(i)
					'Next
					If matches.subcount()=3
						Local key:String = String(matches.subexp(2))
						Local value:String = String( data[key] )
						template = template.Replace( String(matches.subexp(1)), value )
'						Print matches.subexp(1) + " := " + value
					End If
					matches = regex.Find()
				Wend
				'DebugStop
				matches = regex.Find(template)
			Wend

		Catch e:TRegExException
			Print "## ERROR : " + e.toString()
			End
		End Try
		
		' Add CR to Blitzmax multi-line operators
		template = template.Replace( "..", "..~n" )
		Print template
		'DebugStop
		
		' Save file
		'Local action:Int = ( FileType( filename ) <> FILETYPE_FILE )
		'If Not action
		'	Print "- File already exists"
		'	action = Confirm( "- Overwrite", True )
		'End If
		'DebugStop
		'If Not action
		'	Print "- Aborted"
		'	Return		
		'End If
		
		' Save the generated Parser:
		Print "- Writing Parser to file: '"+filename+"'"
		SaveString( template, filename )

		' Update / Save the parser version information
		Local file:TStream = WriteFile( configfile )
		If file
			WriteLine file,"VERSION="+verhi+"."+verlo
			WriteLine file,"BUILD="+build
			CloseStream file
		End If

	End Method
	
End Type


