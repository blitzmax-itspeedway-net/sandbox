'   TParseGenerator
'   (c) Copyright Si Dunford, MMM 2022, All Rights Reserved. 
'   VERSION: 1.0

'	Creates a Parser from a given grammar

'   CHANGES:
'   DD MMM YYYY  Initial Creation
'

Incbin "parser_template.txt"

Type TParserGenerator


	Field data:TMap
	'Field grammar:TGrammar
	Field name:String
	Field template:String
	Field parseTree:TParseTree

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
	
	Method set( key:String, value:String )
		data[Upper(key)] = value
	End Method
	
	Method set( data:String[][] )
		For Local item:String[] = EachIn data
			set( item[0], item[1] )
		Next
	End Method
	
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

	Private
	
	Method gen_choice()
	End Method

End Type


