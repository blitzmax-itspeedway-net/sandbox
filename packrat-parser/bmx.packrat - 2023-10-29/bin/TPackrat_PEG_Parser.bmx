'	PEG PARSER
'	(c) Copyright Si Dunford [Scaremonger], 2023-date, All rights reserved.
'	VERSION 1.0
'
'	A Manually created PEG parser that is used by the Parser generator

' Generate PEG grammar
' NOTE: This is a manually created parser
Type TPackrat_PEG_Parser Extends TPackrat_Parser

	Method New()
		grammar = New TGrammar( "PEG", "PEG", True )

		' Pre-define PEG rule names
		'DebugStop
		grammar.declare([..
			"ALPHANUMUNDER", "ANDPREDICATE",..
			"BLOCKCOMMENT",..
			"CHOICE", ..
			'"EOL",..
			"EXPRESSION",..
			"GROUP",..
			"LINE",..
			"LINECOMMENT",..
			"NONTERMINAL", "NOTPREDICATE",..
			"ONEORMORE", "OPTIONAL",..
			"PEG", "PEXPR",..
			"RULE", ..
			"SEQUENCE", ..
			"TERMINAL", ..
			"ZEROORMORE", "ZEROONEOPT" ])
			
		' Some shortcuts that we can use elsewhere
		'Local SP:TPattern  = __("SP")			' Whitespace
		'Local SP0:TPattern = zeroOrMore(WSP)	' Zero or more whitespace
		'Local SP1:TPattern = oneOrMore(WSP)		' One or more whitespace
		Local EOL:TPattern = __("EOL")
		Local ENDOFFILE:TPattern = __("EOF")
		'Local _:TPattern = zeroOrMore(WSP)		' Optional whitespace
		Local _:TPattern = ZEROORMORE( __("SP") )
		
		'Local READ_TO_EOL:TPattern = sequence([ zeroOrMore( sequence([ negate(EOL), any() ]) ), EOL ])	' Reads to end of line
		
		' ALPHA                  -> [A-Za-z]
		'grammar["ALPHA"]         = CHARSET([ "AZ", "az" ])
		' ALPHANUMUNDER          -> [A-Za-z0-9_]
		grammar["ALPHANUMUNDER"] = RANGE([ "AZ", "az", "09", "_" ])
		' ANDPREDICATE           -> "&" EXPRESSION
		grammar["ANDPREDICATE"]  = SEQUENCE( "ANDPREDICATE", [ literal("&"), __("EXPRESSION") ])
		' CHOICE                 -> EXPRESSION ( "/" EXPRESSION )+
		grammar["CHOICE"]        = SEQUENCE( "CHOICE", [ __("EXPRESSION"), ONEORMORE( sequence([ LITERAL("/"), __("EXPRESSION") ]) ) ])
		' CHAR					 -> "%" ( ( "d" DIGIT+ ) / ("x" HEXDIGIT+ ) / ("b" ["0","1"]+) )
		grammar["CHAR"]          = ..
			SEQUENCE( "CHAR", [ ..
				LITERAL("%"), ..
				CHOICE([ ..
					SEQUENCE([ LITERAL("d"),ONEORMORE(__("DIGIT"))]),..
					SEQUENCE([ LITERAL("h"),ONEORMORE(__("HEXDIGIT"))]),..
					SEQUENCE([ LITERAL("b"),ONEORMORE(CHARSET("01"))]) ..
					]).. 
				])
		' DQUOTE                 -> &034;
		'grammar["DQUOTE"]        = CHARSET( Chr(34) )
		' EOL                    -> SP* "/r"? "/n"
		'grammar["EOL"]           = SEQUENCE( "EOL", [ _, optional( LITERAL("~r") ), LITERAL( "~n" ) ] )
		' EXPRESSION             -> NONTERMINAL / QUOTEDSTRING
		grammar["EXPRESSION"]    = CHOICE( "EXPRESSION", [ __("NONTERMINAL"), __("QSTRING"), ERROR( READUNTIL(EOL), "Invalid expression" ) ])
		' GROUP                  -> "(" EXPRESSION ")"  
		grammar["GROUP"]         = SEQUENCE( "GROUP", [ LITERAL("("), __("EXPRESSION"), LITERAL(")") ])
		' LINE                   -> LINECOMMENT | BLOCKCOMMENT | RULE | EOL
		grammar["LINE"]          = SEQUENCE( "LINE", [ ..
										_, ..
										CHOICE([ ..
											__("EOL"), ..
											__("LINECOMMENT"), ..
											__("BLOCKCOMMENT"), ..
											__("RULE"), ..
											ANDPRED(__("EOF")), ..
											ERROR( READUNTIL(EOL), "Line contains invalid definition" ) ..
											]) ..
										])
		' NONTERMINAL            -> UPPERCASE+ 
		grammar["NONTERMINAL"]   = ONEORMORE( __("ALPHA") )    
		' NOTPREDICATE           -> "!" EXPRESSION
		grammar["NOTPREDICATE"]  = SEQUENCE( "NOTPREDICATE", [ literal("!"), __("EXPRESSION") ])
		' ONEORMORE              -> EXPRESSION "+"
		grammar["ONEORMORE"]     = SEQUENCE( "ONEORMORE", [ __("EXPRESSION"), literal("+") ])
		' OPTIONAL               -> EXPRESSION "?"
		grammar["OPTIONAL"]      = SEQUENCE( "OPTIONAL", [ __("EXPRESSION"), literal("?") ])
		' PEG                    -> LINE+
		grammar["PEG"]           = CHOICE( "PEG", [..
										SEQUENCE( "LINES",[ ..
											ONEORMORE( __("LINE") ), ..
											__("EOF") ..
											]), ..
										ERROR( READUNTIL(EOL), "Invalid file" )..
										])
		' PEXPRESSION            -> CHOICE / SEQUENCE / ZEROONEOOPT / ANDNOT / GROUPED
		grammar["PEXPR"]         = CHOICE( "PEXPR", [ __("CHOICE"), __("SEQUENCE"), __("ZEROONEOPT"), __("NOTPREDICATE"), __("GROUP"), ERROR( READUNTIL(__("EOL")), "Invalid Expression") ])
		' QUOTEDSTRING           -> DQUOTE (!DQUOTE, .)* DQUOTE
		'grammar["QUOTEDSTRING"]  = SEQUENCE( "QUOTEDSTRING", [ __("DQUOTE"), zeroOrMore( sequence([ NEG(__("DQUOTE")), any() ])), __("DQUOTE") ])
		' RULE                   -> NONTERMINAL SP+ "->" SP+ PEXPR EOL
		'grammar["RULE"]          = sequence([ choice([ __("NONTERMINAL"), error( "Rule name expected!" )]), SP_, literal("->"), SP_, __("PEXPR"), EOL ])

		' RULE                   -> NONTERMINAL _ "->" _ PEXPR EOL
		grammar["RULE"]  = SEQUENCE( "RULE", [ ..
			CHOICE([ ..
				__("NONTERMINAL"), ..
				ERROR( READUNTIL(__("EOL")), "Invalid rulename" ) ..
				]), ..
			_, ..
			CHOICE([ ..
				LITERAL( "->" ), ..
				ERROR( READUNTIL(__("EOL")), "'->' was expected" ) ..
				]), ..
			_, ..
			CHOICE([ ..
				__("PEXPR"), ..
				ERROR( READUNTIL(__("EOL")), "Expression expected" ) ..
				]), ..
			EOL ..					
			])

		' SEQUENCE               -> EXPRESSION EXPRESSION+
		grammar["SEQUENCE"]      = SEQUENCE( "SEQUENCE", [ __("EXPRESSION"), ONEORMORE( __("EXPRESSION") ) ])
		' SP                     -> (" " / "/t")
		grammar["SP"]            = CHARSET([ " ", "~t" ])
		' TERMINAL               -> ALPHA ALPHANUMUNDER*
		grammar["TERMINAL"]      = SEQUENCE( "TERMINAL", [ __("ALPHA"), ZEROORMORE( __("ALPHANUMUNDER") ) ])
		' UPPERCASE              -> [A-Z]
		'grammar["UPPERCASE"]     = RANGE( "AZ" )
		' ZEROORMORE             -> EXPRESSION "*"
		grammar["ZEROORMORE"]    = SEQUENCE( "ZEROORMORE", [ __("EXPRESSION"), CHARSET("*") ])
		' ZEROONEOOPT            -> ZEROORMORE / ONEORMORE / OPTIONAL
		grammar["ZEROONEOPT"]    = SEQUENCE( "ZEROONEOPT", [ __("EXPRESSION"), __("ONEORMORE"), __("OPTIONAL") ])



		' BLOCK COMMENT          -> SP* "#" (!EOL, .)* EOL
		'grammar["COMMENT"]       = named( "COMMENT", sequence([ zeroorMore(SP), literal("#"), readUntil(EOL) ]))
		grammar["BLOCKCOMMENT"]  = SEQUENCE( "BLOCKCOMMENT", ..
			[ ..
			LITERAL("/*"),..
			ZEROORMORE(..
				SEQUENCE([..
					NOTPRED( LITERAL("*/") ),..
					CHOICE([..
						__("BLOCKCOMMENT"),..
						ANY()..
						])..
					])..
				),..
			LITERAL("*/")..
			])

		' LINE COMMENT           -> SP* "//" (!EOL, .)* EOL
		'grammar["COMMENT"]       = named( "COMMENT", sequence([ zeroorMore(SP), literal("#"), readUntil(EOL) ]))
		grammar["LINECOMMENT"]   = SEQUENCE( "LINECOMMENT", [ LITERAL("//"), READUNTIL(EOL) ])


		
		Rem FIRST TEST
		grammar["_"]          = zeroOrMore( choice([ __("WHITESPACE"), __("EOL") ]) )

		grammar["ALPHA"]      = charmatch( AZaz, KIND_ALPHA )
		grammar["ASSIGN"]     = named( "ASSIGN", literal( "->" ))
		grammar["SQUOTE"]     = charmatch( "'", KIND_SQUOTE )

		grammar["FAIL"]       = named( "FAIL", zeroOrMore( Any() ) )
		grammar["EOL"]        = named( "EOL", zeroOrMore( charMatch( "~n~r" ) ))
		grammar["WHITESPACE"] = zeroOrMore( charmatch( " ~t" ) )


		grammar["LITERAL"]    = named( "LITERAL", sequence([ __("SQUOTE"), zeroOrMore( sequence([ negate(__("SQUOTE")), any() ])), __("SQUOTE") ]) )
		grammar["GROUP"]      = sequence([ literal("("), oneOrMore( sequence([ negate(literal(")")), __("EXPRESSION") ])), literal(")") ]) 

		grammar["NAME"]       = named( "NAME", sequence([ __("ALPHA"), OneOrMore( charmatch( AZaz09_ ) ) ]) )
		grammar["RULE"]       = named( "RULE", sequence([ named( "RULENAME", __("NAME")), _, __("ASSIGN"), _, __("EXPRESSION"), _ ] ) )
				
		grammar["PEG"]        = choice([ OneOrMore( __("RULE") ), __("FAIL") ])

		grammar["EXPRESSION"] = choice([ __("LITERAL"), __("NAME"), __("GROUP") ] )
				

		grammar["SEQUENCE"]   = sequence([ __("EXPRESSION"), _, zeroOrMore( sequence([ charmatch( "/" ), _, __("EXPRESSION")]))])
		  
		EndRem

		'Local _Assign:TPattern = named( "ASSIGN", literal( "->" ))
		'DebugStop
		'Local _Alpha:TPattern = charmatch( Str_Alpha, KIND_ALPHA )
		'Local __:TPattern = ZeroOrMore( charmatch( " ~t\n\r" ), KIND_WHITESPACE )


		'Local _SQuote:TPattern = literal("'")
		'Local _fail:TPattern = Any()
		
		'Local _Expression:TPattern
		' Cannto declare expression and use ut afterwards, cannot declare and update object!
		'Local _literal:TPattern = named( "LITERAL", sequence([ literal("'"), zeroOrMore( sequence([ negate(literal("'")), any() ])), literal("'") ]) )
		'Local _group:TPattern = sequence([ literal("("), oneOrMore( sequence([ negate(literal(")")),_Expression ])), literal(")") ]) 

		'Local _Name:TPattern = named( "NAME", sequence([ _Alpha, OneOrMore( charmatch( Str_AlphaNum_ ) ) ]) )
		'Local _rule:TPattern = named( "RULE", sequence([ named( "RULENAME", _Name), __, _Assign, __, _Expression, __ ] ) )
		'Local peg:TPattern = choice([ OneOrMore( _rule ), _fail ])

		'_Expression = choice([ _literal, _name, _group ] )
		
		'save( "PEG.peg.json" )

		' Validate the rules
		validate()

	End Method
	
End Type
