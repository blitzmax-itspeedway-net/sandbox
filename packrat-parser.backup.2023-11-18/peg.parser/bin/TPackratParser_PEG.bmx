'  Packrat Parser for PEG
'
'  DATE:     17 Nov 2023
'  VERSION:  1.0 build 16
'
'  Generated by 'Packrat Parser Generator for BlitzMax'
'    Version: 1.0
'
'  Template:
'    Version: 1.0
'
'  ###
'  ##### WARNING
'  #####
'  ##### This file is generated and all manual changes will be overwritten
'  #####
'  ##### DO NOT UPDATE MANUALLY
'  ###

Rem
# PEG Definition for PEG
#
# Starting rule: PEG

ALPHANUMUNDER <- [A-Za-z0-9_]
ANDPREDICATE <- ( "&" EXPRESSION )
CHAR <- ( "%" ( ( "d" DIGIT+ ) / ( "h" HEXDIGIT+ ) / ( "b" [01]+ ) ) )
CHOICE <- ( EXPRESSION ( "/" EXPRESSION )+ )
COMMENT <- ( [\x20]* "#" ( ( !EOL . )* EOL ) )
EXPRESSION <- ( NONTERMINAL / QSTRING / #error{'Invalid expression',( ( !EOL . )* EOL )} )
GROUP <- ( "(" EXPRESSION ")" )
LINE <- ( WSP* ( RULE / EOL / COMMENT / ( NONTERMINAL !"<-" #error{''<-' expected at {pos}',( ( !( ( ( \x20 / \t )* \r? \n ) / !. ) . )* ( ( ( \x20 / \t )* \r? \n ) / !. ) )} ) / #error{'Invalid definition',( ( !( EOL / EOI ) . )* ( EOL / EOI ) )} ) )
NONTERMINAL <- ALPHA+
NOTPREDICATE <- ( "!" EXPRESSION )
ONEORMORE <- ( EXPRESSION "+" )
OPTIONAL <- ( EXPRESSION "?" )
PEG <- ( ( EOI / LINE )* )
PEXPR <- ( CHOICE / SEQUENCE / ZEROONEOPT / NOTPREDICATE / GROUP / #error{'Invalid Expression',( ( !EOL . )* EOL )} )
RULE <- ( NONTERMINAL WSP* "<-" WSP* PEXPR EOL )
SEARCH <- ( @ EXPRESSION )
SEQUENCE <- ( EXPRESSION EXPRESSION+ )
SP <- [\x20\t]
TERMINAL <- ( ALPHA ALPHANUMUNDER* )
ZEROONEOPT <- ( EXPRESSION ONEORMORE OPTIONAL )
ZEROORMORE <- ( EXPRESSION * )

EndRem

' Create a Packrat Parser for PEG
Function PEG_Parser:TPackratParser()
    Return New TPackratParser_PEG()
End Function

' A Packrat Parser for PEG
Type TPackratParser_PEG Extends TPackratParser

	Method New()

		grammar = New TGrammar( "PEG", "PEG" )

		' DECLARE RULES
		
		grammar.declare([ "ALPHA","ALPHANUMUNDER","ANDPREDICATE","CHAR","CHOICE","COMMENT","CR","CRLF","DIGIT","DQUOTE","EOI","EOL","EXPRESSION","GROUP","HEXDIGIT","HTAB","LF","LINE","NONTERMINAL","NOTPREDICATE","NUMBER","ONEORMORE","OPTIONAL","PEG","PEXPR","QSTRING","RULE","SEARCH","SEQUENCE","SP","TERMINAL","WSP","ZEROONEOPT","ZEROORMORE" ])
					
		' DEFINE RULES
		
		' ALPHA <- [A-Za-z]
		grammar["ALPHA"] = ..
			RANGE( "A-Za-z" )

		' ALPHANUMUNDER <- [A-Za-z0-9_]
		grammar["ALPHANUMUNDER"] = ..
			RANGE( "A-Za-z0-9_" )

		' ANDPREDICATE <- ( "&" EXPRESSION )
		grammar["ANDPREDICATE"] = ..
			SEQUENCE("ANDPREDICATE", [..
				LITERAL( "&", True ), ..
				__( "EXPRESSION" ) ..
			])

		' CHAR <- ( "%" ( ( "d" DIGIT+ ) / ( "h" HEXDIGIT+ ) / ( "b" [01]+ ) ) )
		grammar["CHAR"] = ..
			SEQUENCE("CHAR", [..
				LITERAL( "%", True ), ..
				CHOICE([..
					SEQUENCE([..
						LITERAL( "d", True ), ..
						ONEORMORE( ..
							__( "DIGIT" )..
						) ..
					]), ..
					SEQUENCE([..
						LITERAL( "h", True ), ..
						ONEORMORE( ..
							__( "HEXDIGIT" )..
						) ..
					]), ..
					SEQUENCE([..
						LITERAL( "b", True ), ..
						ONEORMORE( ..
							CHARSET( "01" )..
						) ..
					]) ..
				]) ..
			])

		' CHOICE <- ( EXPRESSION ( "/" EXPRESSION )+ )
		grammar["CHOICE"] = ..
			SEQUENCE("CHOICE", [..
				__( "EXPRESSION" ), ..
				ONEORMORE( ..
					SEQUENCE([..
						LITERAL( "/", True ), ..
						__( "EXPRESSION" ) ..
					])..
				) ..
			])

		' COMMENT <- ( [\x20]* "#" ( ( !EOL . )* EOL ) )
		grammar["COMMENT"] = ..
			SEQUENCE("COMMENT", [..
				ZEROORMORE( ..
					CHARSET( "\x20" )..
				), ..
				LITERAL( "#", True ), ..
				SEQUENCE([..
					ZEROORMORE( ..
						SEQUENCE([..
							NOTPRED( ..
								__( "EOL" )..
							), ..
							ANY() ..
						])..
					), ..
					__( "EOL" ) ..
				]) ..
			])

		' CR <- \r
		grammar["CR"] = ..
			SYMBOL( "\r" )

		' CRLF <- [\r\n]
		grammar["CRLF"] = ..
			CHARSET( "\r\n" )

		' DIGIT <- [0-9]
		grammar["DIGIT"] = ..
			RANGE( "0-9" )

		' DQUOTE <- \q
		grammar["DQUOTE"] = ..
			SYMBOL( "\q" )

		' EOI <- !.
		grammar["EOI"] = ..
			NOTPRED( "EOI", ..
				ANY()..
			)

		' EOL <- ( WSP* CR? LF )
		grammar["EOL"] = ..
			SEQUENCE("EOL", [..
				ZEROORMORE( ..
					__( "WSP" )..
				), ..
				OPTIONAL( ..
					__( "CR" )				), ..
				__( "LF" ) ..
			])

		' EXPRESSION <- ( NONTERMINAL / QSTRING / #error{'Invalid expression',( ( !EOL . )* EOL )} )
		grammar["EXPRESSION"] = ..
			CHOICE("EXPRESSION", [..
				__( "NONTERMINAL" ), ..
				__( "QSTRING" ), ..
				ERROR( ..
					SEQUENCE([..
						ZEROORMORE( ..
							SEQUENCE([..
								NOTPRED( ..
									__( "EOL" )..
								), ..
								ANY() ..
							])..
						), ..
						__( "EOL" ) ..
					]), ..
					"Invalid expression" ..
				) ..
			])

		' GROUP <- ( "(" EXPRESSION ")" )
		grammar["GROUP"] = ..
			SEQUENCE("GROUP", [..
				LITERAL( "(", True ), ..
				__( "EXPRESSION" ), ..
				LITERAL( ")", True ) ..
			])

		' HEXDIGIT <- [0-9A-Fa-f]
		grammar["HEXDIGIT"] = ..
			RANGE( "0-9A-Fa-f" )

		' HTAB <- \t
		grammar["HTAB"] = ..
			SYMBOL( "\t" )

		' LF <- \n
		grammar["LF"] = ..
			SYMBOL( "\n" )

		' LINE <- ( WSP* ( RULE / EOL / COMMENT / ( NONTERMINAL !"<-" #error{''<-' expected at {pos}',( ( !( ( ( \x20 / \t )* \r? \n ) / !. ) . )* ( ( ( \x20 / \t )* \r? \n ) / !. ) )} ) / #error{'Invalid definition',( ( !( EOL / EOI ) . )* ( EOL / EOI ) )} ) )
		grammar["LINE"] = ..
			SEQUENCE("LINE", [..
				ZEROORMORE( ..
					__( "WSP" )..
				), ..
				CHOICE([..
					__( "RULE" ), ..
					__( "EOL" ), ..
					__( "COMMENT" ), ..
					SEQUENCE([..
						__( "NONTERMINAL" ), ..
						NOTPRED( ..
							LITERAL( "<-", True )..
						), ..
						ERROR( ..
							SEQUENCE([..
								ZEROORMORE( ..
									SEQUENCE([..
										NOTPRED( ..
											CHOICE([..
												SEQUENCE([..
													ZEROORMORE( ..
														CHOICE([..
															SYMBOL( "\x20" ), ..
															SYMBOL( "\t" ) ..
														])..
													), ..
													OPTIONAL( ..
														SYMBOL( "\r" )													), ..
													SYMBOL( "\n" ) ..
												]), ..
												NOTPRED( ..
													ANY()..
												) ..
											])..
										), ..
										ANY() ..
									])..
								), ..
								CHOICE([..
									SEQUENCE([..
										ZEROORMORE( ..
											CHOICE([..
												SYMBOL( "\x20" ), ..
												SYMBOL( "\t" ) ..
											])..
										), ..
										OPTIONAL( ..
											SYMBOL( "\r" )										), ..
										SYMBOL( "\n" ) ..
									]), ..
									NOTPRED( ..
										ANY()..
									) ..
								]) ..
							]), ..
							"'<-' expected at {pos}" ..
						) ..
					]), ..
					ERROR( ..
						SEQUENCE([..
							ZEROORMORE( ..
								SEQUENCE([..
									NOTPRED( ..
										CHOICE([..
											__( "EOL" ), ..
											__( "EOI" ) ..
										])..
									), ..
									ANY() ..
								])..
							), ..
							CHOICE([..
								__( "EOL" ), ..
								__( "EOI" ) ..
							]) ..
						]), ..
						"Invalid definition" ..
					) ..
				]) ..
			])

		' NONTERMINAL <- ALPHA+
		grammar["NONTERMINAL"] = ..
			ONEORMORE( "NONTERMINAL", ..
				__( "ALPHA" )..
			)

		' NOTPREDICATE <- ( "!" EXPRESSION )
		grammar["NOTPREDICATE"] = ..
			SEQUENCE("NOTPREDICATE", [..
				LITERAL( "!", True ), ..
				__( "EXPRESSION" ) ..
			])

		' NUMBER <- [0-9]+
		grammar["NUMBER"] = ..
			ONEORMORE( "NUMBER", ..
				RANGE( "0-9" )..
			)

		' ONEORMORE <- ( EXPRESSION "+" )
		grammar["ONEORMORE"] = ..
			SEQUENCE("ONEORMORE", [..
				__( "EXPRESSION" ), ..
				LITERAL( "+", True ) ..
			])

		' OPTIONAL <- ( EXPRESSION "?" )
		grammar["OPTIONAL"] = ..
			SEQUENCE("OPTIONAL", [..
				__( "EXPRESSION" ), ..
				LITERAL( "?", True ) ..
			])

		' PEG <- ( ( EOI / LINE )* )
		grammar["PEG"] = ..
			CHOICE("PEG", [..
				ZEROORMORE( ..
					CHOICE("LINES", [..
						__( "EOI" ), ..
						__( "LINE" ) ..
					])..
				) ..
			])

		' PEXPR <- ( CHOICE / SEQUENCE / ZEROONEOPT / NOTPREDICATE / GROUP / #error{'Invalid Expression',( ( !EOL . )* EOL )} )
		grammar["PEXPR"] = ..
			CHOICE("PEXPR", [..
				__( "CHOICE" ), ..
				__( "SEQUENCE" ), ..
				__( "ZEROONEOPT" ), ..
				__( "NOTPREDICATE" ), ..
				__( "GROUP" ), ..
				ERROR( ..
					SEQUENCE([..
						ZEROORMORE( ..
							SEQUENCE([..
								NOTPRED( ..
									__( "EOL" )..
								), ..
								ANY() ..
							])..
						), ..
						__( "EOL" ) ..
					]), ..
					"Invalid Expression" ..
				) ..
			])

		' QSTRING <- ( [\q] ( ![\q] [ !#-~] )* [\q] )
		grammar["QSTRING"] = ..
			SEQUENCE("QSTRING", [..
				CHARSET( "\q" ), ..
				ZEROORMORE( ..
					SEQUENCE([..
						NOTPRED( ..
							CHARSET( "\q" )..
						), ..
						RANGE( "\x20!#-\x7E" ) ..
					])..
				), ..
				CHARSET( "\q" ) ..
			])

		' RULE <- ( NONTERMINAL WSP* "<-" WSP* PEXPR EOL )
		grammar["RULE"] = ..
			SEQUENCE("RULE", [..
				__( "NONTERMINAL" ), ..
				ZEROORMORE( ..
					__( "WSP" )..
				), ..
				LITERAL( "<-", True ), ..
				ZEROORMORE( ..
					__( "WSP" )..
				), ..
				__( "PEXPR" ), ..
				__( "EOL" ) ..
			])

		' SEARCH <- ( @ EXPRESSION )
		grammar["SEARCH"] = ..
			SEQUENCE("SEARCH", [..
				SYMBOL( "@" ), ..
				__( "EXPRESSION" ) ..
			])

		' SEQUENCE <- ( EXPRESSION EXPRESSION+ )
		grammar["SEQUENCE"] = ..
			SEQUENCE("SEQUENCE", [..
				__( "EXPRESSION" ), ..
				ONEORMORE( ..
					__( "EXPRESSION" )..
				) ..
			])

		' SP <- [\x20\t]
		grammar["SP"] = ..
			CHARSET( "\x20\t" )

		' TERMINAL <- ( ALPHA ALPHANUMUNDER* )
		grammar["TERMINAL"] = ..
			SEQUENCE("TERMINAL", [..
				__( "ALPHA" ), ..
				ZEROORMORE( ..
					__( "ALPHANUMUNDER" )..
				) ..
			])

		' WSP <- ( [\x20] / [\t] )
		grammar["WSP"] = ..
			CHOICE("WSP", [..
				CHARSET( "\x20" ), ..
				CHARSET( "\t" ) ..
			])

		' ZEROONEOPT <- ( EXPRESSION ONEORMORE OPTIONAL )
		grammar["ZEROONEOPT"] = ..
			SEQUENCE("ZEROONEOPT", [..
				__( "EXPRESSION" ), ..
				__( "ONEORMORE" ), ..
				__( "OPTIONAL" ) ..
			])

		' ZEROORMORE <- ( EXPRESSION * )
		grammar["ZEROORMORE"] = ..
			SEQUENCE("ZEROORMORE", [..
				__( "EXPRESSION" ), ..
				CHARSET( "*" ) ..
			])


		' VALIDATE RULES
		
		validate()

	End Method

	' SHORTCUT FOR NONTERMINAL PATTERNS
	
	Method __:TPattern( name:String )
		Assert grammar.contains( name ), "Undefined Pattern '"+name+"' in definition"
		Return New TNonTerminal( name, grammar )
	End Method
	
    ' DECLARE AST VISITORS

'    Method visit_default:TASTNode( ast:TASTNode )
'        Return ast
'    End Method

End Type


