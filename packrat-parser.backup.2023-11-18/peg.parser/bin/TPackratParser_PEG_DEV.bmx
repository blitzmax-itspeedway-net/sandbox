'	PEG PARSER
'	(c) Copyright Si Dunford [Scaremonger], 2023-date, All rights reserved.
'	VERSION 1.0
'
'	A Manually created PEG parser that is used by the Parser generator

' Get the Development Packrat Parser
' THE MANUAL PARSER IS CONSIDERED A DEVELOPMENT VERSION ONLY

Function PEG_Parser_DEV:TPackratParser()
	Return New TPackratParser_PEG_DEV()
End Function

' Generate PEG grammar
' NOTE: This is a manually created parser
Type TPackratParser_PEG_DEV Extends TPackratParser

	Method New()
		grammar = New TGrammar( "PEG", "PEG", True )

		' define core rules

		'DebugStop
		grammar["ALPHA"]    = RANGE("ALPHA", "A-Za-z" )                 ' Case insensitive A-Z
		grammar["CHAR"]     = RANGE( Chr($34)+"-"+Chr($7F) )            ' 7 BIt ASCII except CTRL
		grammar["CR"]       = SYMBOL( $0D )                             ' %d13 = Carriage Return \r
		grammar["CRLF"]     = CHARSET( Chr($0D)+Chr($0A) )              ' Newline \r\n
		grammar["DIGIT"]    = RANGE( "DIGIT", "0-9" )                   ' Digit 0 to 9
		grammar["DQUOTE"]   = SYMBOL( $22 )                             ' %d34 = Double Quote 
		grammar["HEXDIGIT"] = RANGE( "0-9A-Fa-f" )                      ' Hexadecimal digits
		grammar["HTAB"]     = SYMBOL( $09 )                             ' %d09 = Horizontal Tab
		grammar["LF"]       = SYMBOL( $0A )                             ' %d10 = Line Feed \n
		'Self["OCTET"]    = RANGE( Chr($00)+Chr($FF) )                   ' Any 8 bit character
		'Self["VCHAR"]    = RANGE( Chr($21)+Chr($7E) )                   ' visible (printing) characters
		grammar["SP"]       = SYMBOL( $20 )                             ' %d32 = Space
		grammar["WSP"]      = CHOICE([ SP, HTAB ])                      ' Whitespace
		'
		
		' WHITESPACE SHORTCUT
		Local _:TPattern = ZEROORMORE( __("WSP") )

		' EXTENDED CORE DEFINTIONS
		grammar["NUMBER"]  = ONEORMORE( "NUMBER", DIGIT )               	' Number
		grammar["QSTRING"] = SEQUENCE([ DQUOTE, ZEROORMORE( SEQUENCE([ NOTPRED(DQUOTE), RANGE( Chr($20)+Chr($21)+Chr($23)+"-"+Chr($7E) ) ]) ), DQUOTE ])
		' EOI <- !.
		grammar["EOI"]     = NOTPRED( ANY() )				' End of Input / End of File
		' EOL <- ( _ CR? LF ) 
		grammar["EOL"]     = SEQUENCE("EOL",[ _, OPTIONAL( __("CR") ), __("LF") ])

		'Self["UNTILEOL"] = SEQUENCE( [ ZEROORMORE( SEQUENCE([ NOTPRED( __("EOL") ), ANY() ]) ), __("EOL") ])

		' Flag all core rules to prevent them being shown in output
		For Local rule:String = EachIn grammar.keys()
			Local pattern:TPattern = TPattern( grammar[rule] )
			pattern.hidden = True
		Next
	
		' Pre-define PEG rule names
		'DebugStop
		grammar.declare([..
			"ALPHANUMUNDER", "ANDPREDICATE",..
			"CHOICE", "COMMENT", ..
			"EXPRESSION",..
			"GROUP",..
			"LINE",..
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
		'DebugStop
		Local EOL:TPattern = __("EOL")
		Local EOI:TPattern = __("EOI")
		'Local _:TPattern = zeroOrMore(WSP)		' Optional whitespace
		'Local _:TPattern = ZEROORMORE( __("SP") )
		
		'Local READ_TO_EOL:TPattern = sequence([ zeroOrMore( sequence([ negate(EOL), any() ]) ), EOL ])	' Reads to end of line
		
		' ALPHA                  <- [A-Za-z]
		'grammar["ALPHA"]         = CHARSET([ "AZ", "az" ])
		' ALPHANUMUNDER          <- [A-Za-z0-9_]
		grammar["ALPHANUMUNDER"] = RANGE( "A-Za-z0-9_" )
		' ANDPREDICATE           <- "&" EXPRESSION
		grammar["ANDPREDICATE"]  = SEQUENCE( "ANDPREDICATE", [ literal("&"), __("EXPRESSION") ])
		' CHOICE                 <- EXPRESSION ( "/" EXPRESSION )+
		grammar["CHOICE"]        = SEQUENCE( "CHOICE", [ __("EXPRESSION"), ONEORMORE( sequence([ LITERAL("/"), __("EXPRESSION") ]) ) ])
		' CHAR					 <- "%" ( ( "d" DIGIT+ ) / ("x" HEXDIGIT+ ) / ("b" ["0","1"]+) )
		grammar["CHAR"]          = ..
			SEQUENCE( "CHAR", [ ..
				LITERAL("%"), ..
				CHOICE([ ..
					SEQUENCE([ LITERAL("d"),ONEORMORE(__("DIGIT"))]),..
					SEQUENCE([ LITERAL("h"),ONEORMORE(__("HEXDIGIT"))]),..
					SEQUENCE([ LITERAL("b"),ONEORMORE(CHARSET("01"))]) ..
					]).. 
				])
		' COMMENT           	 <- SP* "//" (!EOL, .)* EOL
		grammar["COMMENT"]       = SEQUENCE( "COMMENT", [ ZEROORMORE(SP), LITERAL("#"), READUNTIL(EOL) ])
		' DQUOTE                 <- &034;
		'grammar["DQUOTE"]        = CHARSET( Chr(34) )
		' EOL                    <- SP* "/r"? "/n"
		'grammar["EOL"]           = SEQUENCE( "EOL", [ _, optional( LITERAL("~r") ), LITERAL( "~n" ) ] )
		' EXPRESSION             <- NONTERMINAL / QUOTEDSTRING
		grammar["EXPRESSION"]    = CHOICE( "EXPRESSION", [ __("NONTERMINAL"), __("QSTRING"), ERROR( READUNTIL(EOL), "Invalid expression" ) ])
		' GROUP                  <- "(" EXPRESSION ")"  
		grammar["GROUP"]         = SEQUENCE( "GROUP", [ LITERAL("("), __("EXPRESSION"), LITERAL(")") ])
		' LINE                   <- LINECOMMENT | BLOCKCOMMENT | RULE | EOL
		grammar["LINE"]          = SEQUENCE( "LINE", [ ..
										_, ..
										CHOICE([ ..
											__("RULE"), ..											
											__("EOL"), ..
											__("COMMENT"), ..
											SEQUENCE([ ..
												__("NONTERMINAL"), ..
												NOTPRED( LITERAL("<-") ),..
												ERROR( RECOVERLINE(), "'<-' expected at {pos}" )..
												]),
											ERROR( READUNTIL(CHOICE([EOL,EOI])), "Invalid definition" ) ..
											]) ..
										])
		' NONTERMINAL            <- UPPERCASE+ 
		grammar["NONTERMINAL"]   = ONEORMORE( __("ALPHA") )    
		' NOTPREDICATE           <- "!" EXPRESSION
		grammar["NOTPREDICATE"]  = SEQUENCE( "NOTPREDICATE", [ LITERAL("!"), __("EXPRESSION") ])
		' ONEORMORE              <- EXPRESSION "+"
		grammar["ONEORMORE"]     = SEQUENCE( "ONEORMORE", [ __("EXPRESSION"), LITERAL("+") ])
		' OPTIONAL               <- EXPRESSION "?"
		grammar["OPTIONAL"]      = SEQUENCE( "OPTIONAL", [ __("EXPRESSION"), LITERAL("?") ])
		' PEG                    <- LINE+

		grammar["PEG"]           = CHOICE( "PEG", [ ..
										ZEROORMORE( ..
											CHOICE("LINES",[ ..
												EOI,..
												__("LINE") ..
												]) ..
											) ..
										])
		' PEXPRESSION            <- CHOICE / SEQUENCE / ZEROONEOOPT / ANDNOT / GROUPED
		grammar["PEXPR"]         = CHOICE( "PEXPR", [ __("CHOICE"), __("SEQUENCE"), __("ZEROONEOPT"), __("NOTPREDICATE"), __("GROUP"), ERROR( READUNTIL(__("EOL")), "Invalid Expression") ])
		' QUOTEDSTRING           <- DQUOTE (!DQUOTE, .)* DQUOTE
		'grammar["QUOTEDSTRING"]  = SEQUENCE( "QUOTEDSTRING", [ __("DQUOTE"), zeroOrMore( sequence([ NEG(__("DQUOTE")), any() ])), __("DQUOTE") ])
		' RULE                   <- NONTERMINAL SP+ "<-" SP+ PEXPR EOL
		'grammar["RULE"]          = sequence([ choice([ __("NONTERMINAL"), error( "Rule name expected!" )]), SP_, literal("<-"), SP_, __("PEXPR"), EOL ])

		' RULE                   <- NONTERMINAL _ "<-" _ PEXPR EOL
		grammar["RULE"]  = SEQUENCE( "RULE", [ ..
			__("NONTERMINAL"), ..
			_, ..
			LITERAL( "<-" ), ..
			_, ..
			__("PEXPR"), ..
			EOL ..					
			])

		' SEARCH                 <- "@" EXPRESSION
		grammar["SEARCH"]        = SEQUENCE( "SEARCH", [ SYMBOL("@"), __("EXPRESSION") ])
		' SEQUENCE               <- EXPRESSION EXPRESSION+
		grammar["SEQUENCE"]      = SEQUENCE( "SEQUENCE", [ __("EXPRESSION"), ONEORMORE( __("EXPRESSION") ) ])
		' SP                     <- (" " / "/t")
		grammar["SP"]            = CHARSET([ " ", "~t" ])
		' TERMINAL               <- ALPHA ALPHANUMUNDER*
		grammar["TERMINAL"]      = SEQUENCE( "TERMINAL", [ __("ALPHA"), ZEROORMORE( __("ALPHANUMUNDER") ) ])
		' UPPERCASE              <- [A-Z]
		'grammar["UPPERCASE"]     = RANGE( "AZ" )
		' ZEROORMORE             <- EXPRESSION "*"
		grammar["ZEROORMORE"]    = SEQUENCE( "ZEROORMORE", [ __("EXPRESSION"), CHARSET("*") ])
		' ZEROONEOOPT            <- ZEROORMORE / ONEORMORE / OPTIONAL
		grammar["ZEROONEOPT"]    = SEQUENCE( "ZEROONEOPT", [ __("EXPRESSION"), __("ONEORMORE"), __("OPTIONAL") ])


		
		Rem FIRST TEST
		grammar["_"]          = zeroOrMore( choice([ __("WHITESPACE"), __("EOL") ]) )

		grammar["ALPHA"]      = charmatch( AZaz, KIND_ALPHA )
		grammar["ASSIGN"]     = named( "ASSIGN", literal( "<-" ))
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

		'Local _Assign:TPattern = named( "ASSIGN", literal( "<-" ))
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

	' Shortcut to NonTerminal
	Method __:TPattern( name:String )
		Assert grammar.contains( name ), "Undefined Pattern '"+name+"' in definition"
		Return New TNonTerminal( name, grammar )
	End Method
		
	'Method RULE_PEG:TASTNode( ast:TASTNode )
	'	Return ast
	'End Method
	
	'Method _LINECOMMENT:Object( state:Object )
	'	' SEQUENCE
	'	If Not _LITERAL( state, "//" ); Return Null
	'	Local comment:String = state.readuntil( [EOL,EOI] )
	'	' CREATE NODE
	'	Return New TASTNode( TOKEN_LINE_COMMENT, comment, state )
	'End Method
	
	'	RULE DEFINITION
	
	'Method __START:Object( ast:String )
	'	DebugStop
	'End Method
	
	'Method __PEG:Object( ast:String )
	'End Method
	
End Type
