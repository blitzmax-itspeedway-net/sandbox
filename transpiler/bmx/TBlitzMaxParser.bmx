
'	BlitzMax Parser
'	(c) Copyright Si Dunford, July 2021, All Rights Reserved

'	CHANGE LOG
'	V1.0	07 AUG 21	Initial version
'	V1.1	16 AUG 21	Removed BNF generic parsing due to limitations
'	V1.2	21 AUG 21	Re-organised program parsing, added parseHeader() ParseBlock()

Rem
PROGRAM
	COMMENT
	COMMENT
	STRICTMODE=Strict
	FRAMEWORK=brl.retro
	MODULE=its.btree
		MODULEINFO
		MODULEINFO
		MODULEINFO
	IMPORTS
		IMPORT brl.linkedlist
		IMPORT brl.retro
	INCLUDE=abc.bmx
	
End Rem

Rem THINGS TO DO
* Move sequence caller into a reflection caller instead of large select-case
* Parse_Local(), Parse_Global() and ParseField() are all similar, combine them
End Rem

Global SYM_HEADER:Int[] = [ TK_STRICT, TK_SUPERSTRICT, TK_FRAMEWORK, TK_MODULE, TK_IMPORT, TK_MODULEINFO ]

Global SYM_BLOCK_KEYWORDS:Int[] = [ TK_FOR, TK_REPEAT, TK_WHILE ]

Global SYM_PROGRAM_BODY:Int[] = [ TK_INCLUDE, TK_LOCAL, TK_GLOBAL, TK_FUNCTION, TK_TYPE ]
Global SYM_METHOD_BODY:Int[] = [ TK_INCLUDE, TK_LOCAL, TK_GLOBAL, TK_ALPHA, TK_FUNCTION ]+SYM_BLOCK_KEYWORDS
Global SYM_FUNCTION_BODY:Int[] = [ TK_INCLUDE, TK_LOCAL, TK_GLOBAL, TK_ALPHA, TK_FUNCTION ]+SYM_BLOCK_KEYWORDS
Global SYM_TYPE_BODY:Int[] = [ TK_INCLUDE, TK_FIELD, TK_GLOBAL, TK_METHOD, TK_FUNCTION ]
Global SYM_MODULE_BODY:Int[] = [ TK_INCLUDE, TK_MODULEINFO, TK_LOCAL, TK_GLOBAL, TK_FUNCTION, TK_TYPE ]

Global SYM_DATATYPES:Int[] = [ TK_BYTE, TK_DOUBLE, TK_FLOAT, TK_INT, TK_LONG, TK_SHORT, TK_STRING ]

Type TBlitzMaxParser Extends TParser
	
	Field strictmode:Int = 0
	'Field symbolTable:TSymbolTable = New TSymbolTable()	
	'
	'Field prev:TToken, save:TToken	' Used for lookback (Specifically for END XXX statements)
	'Field definition:TToken			' Used to identify a block definition comment
		
	Method New( lexer:TLexer )
		Super.New(lexer )
	End Method		

	' We do not need to over-ride the parser entry point
	' because it will call parse_program to begin

	' Every story starts, as they say, with a beginning...
	Method parse_program:TASTNode()
		Local fsm:Int = 0
'DebugStop	
		' Scan the tokens, creating children
		token = lexer.reset()	' Starting position
		'advance()
		'Local token:TToken = lexer.getToken()
		'token2 = token
		
		' FIRST WE DEAL WITH THE PROGRAM HEADER
		'Local ast:TASTCompound = New TASTCompound( "PROGRAM" )
		'ast = parseHeader( ast, token )

'DebugStop		
		'Local ast:TASTCompound = New TASTCompound( "PROGRAM" )
		'ast = parseHeader( ast )
		
		' Program block contains HEADER, PROGRAMBODY and APLNUMERIC TOKENS (Function names etc)
		ast = parseSequence( "PROGRAM", SYM_HEADER+SYM_PROGRAM_BODY+[TK_ALPHA] )	
		' Mop up trailing Comments and EOL
		'ParseCEOL( ast )
		
		' Capture Comments and EOL
		'If parseCEOL( ast ) Return ast
		'ast.add( Parse_Strictmode() )	' STRICTMODE
		
		' Capture Comments and EOL
		'If parseCEOL( ast ) Return ast
		'Local exists:TASTNode = Parse_FrameworkTEST()
		'If Not exists
		'	exists = Parse_ModuleTEST()
		'End If
		'ast.add( Parse_ImportTEST() )		' IMPORT

'		Return ast
		
		' NEXT WE DEAL WITH PROGRAM BODY
		'Local allow:Int[] = SYM_PROGRAMBODY
		'ast = parseBlock( 0, ast, token, allow, error_to_eol )
		
		' INSERT BODY INTO PROGRAM
		'For Local child:TASTNode = EachIn body.children
		'	ast.add( child )
		'Next
	
		'If token.id <> TK_EOF
		'	ThrowParseError( "Unexpected characters past end of program", token.line, token.pos )
		'End If
		
		' Validate the parsed AST
		ast.validate()
		
		Return ast
	End Method

Rem
	' Parses Comments and EOL
	Method parseCEOL:Int( ast:TASTCompound, token:TToken Var )
		Select token.id
		Case TK_EOL
'DebugStop
			' Empty lines mark the end of a block comment and not a defintion
			'If prev And prev.id=TK_EOL And definition
			'	ast.add( New TAST_Comment( definition ) )
			'	definition = Null
			'End If
			token = lexer.getnext()
			Return True
		Case TK_COMMENT
'DebugStop
			' No definition for this identifier
			'If definition
			'	ast.add( New TAST_Comment( definition ) )
			'	definition = Null					
			'End If
			ast.add( New TASTNode( "COMMENT", token ) )
			token = lexer.expect(TK_EOL)
			token = lexer.getNext()			' Skip EOL
			Return True
		End Select
		' Not a Comment or EOL
		Return False
	End Method


EndRem
	
	' Parses a block into an EXISTING ast compound node
	'	BlockType	- The type of block we are parsing (Used to tally-up END <BLOCKTYPE>)
	'	ast			- The AST Node we are building
	'	Token		- The Current Token
	'	Allowed		- List of allowed tokens...
Rem	Method parseBlock:TASTCompound( BlockType:Int, ast:TASTCompound, token:TToken Var, allowed:Int[], syntaxfn( lexer:TLexer, start:Int,finish:Int) )	
		
		' Identify token that would close this block type
		Local blockClose:Int = ClosingToken( BlockType )

		' Extend allowed list for generic tokens
		allowed :+ [ TK_EOL, TK_REM, TK_COMMENT, TK_END, BlockClose ]

		Repeat
			Try
				If Not token Throw( "Unexpected end of token stream (STRICTMODE)" )
				If token.id = TK_EOF Return ast
				If token.notin( allowed ) ThrowParseError( "'"+token.value+"' is unexpected", token.line, token.pos )
'DebugStop								
				' Parse this token
				Select token.id
				'Case TK_EOL
				'	ast.add( New TASTNode( "EOL" ) )
				'	token = lexer.getNext()
				'Case TK_COMMENT
				'	ast.add( Parse_Comment( token ) )
				'Case TK_REM
				'	ast.add( Parse_Rem( token ) )
'
				Case TK_END
'DebugStop
					' Identify if this is "END" or "END <BLOCK>"
					'Local peek:TToken = lexer.peek()
					'If peek.id = BlockType
					'	' THIS IS END OF THE BLOCK
					'	token = lexer.getnext() ' Consume END
					'	'token = lexer.getnext() ' Consume BlockType
					'	Return ast
					'Else
						' THIS IS AN END OF APPLICATION TOKEN
					ast.add( Parse_End() )
					'End If
				Case BlockClose
'DebugStop
					'token = lexer.getnext()
					Return ast
				Case TK_FUNCTION
					'ast.add( Parse_Function( token ) )
				Case TK_INCLUDE
					'ast.add( Parse_Include( token ) )			
				Case TK_METHOD
					'ast.add( Parse_Method( token ) )
				Case TK_TYPE
					'ast.add( Parse_Type( token ) )

				Default

					' If we encounter anything else; the block (SHOULD BE) complete
					Return ast
				End Select
		
			Catch e:Object
				Local parseerror:TParseError = TParseError(e)
				Local exception:TException = TException( e )
				Local runtime:TRuntimeException = TRuntimeException( e )
				Local text:String = String( e )
				Local typ:TTypeId = TTypeId.ForObject( e )
				'
				If parseerror
					publish( "syntax-error", parseerror.text + " at "+parseerror.line + ","+ parseerror.pos )
					token = lexer.fastFwd( TK_EOL )	' Skip to end of line
				End If
				If exception Print "## Exception: "+exception.toString()+" ##"
				If runtime Print "## Runtime: "+runtime.toString()+" ##"
				If text Print "## Exception: '"+text+"' ##"
				Print "TYPE: "+typ.name
DebugStop
			EndTry
		Forever

		'Return ast
	End Method
EndRem	
	
'	Method ParseContext:TASTNode( contains:Int[], optional:Int[], parent:TASTNode = Null )
	
		' Check identifier in "contains" or "optional"
		' if expected identifier, call its geenrator function 
		' if unexpected identifier, ask parent if they expect it?
		'	if parent doesn't know, generate UNEXPECTED symbol
		'		if error flag set
		'			Weve hit soemthign we cannot process.. 
		'			FAST FORWARD Until we find a token we DO understand
		'			Everythign else becomes "SKIPPED" tokens
		'		set error flag
		'	if parent does know
		'		Return back to parent for further processing
		
		
	
'	End Method

	' Parse a sequence.
	' The tokens MUST exist in order or not be present (Creating a missing token)
	Method parseSequence:TASTCompound( name:String, options:Int[], closing:Int[]=Null, parent:Int[]=Null )
		Local ast:TASTCompound = New TASTCompound( name )
		Return parseSequence( ast, options, closing, parent )
	End Method
		
	' The tokens MUST exist in order Or Not be present (Creating a missing token)
	Method parseSequence:TASTCompound( ast:TASTCompound, options:Int[], closing:Int[]=Null, parent:Int[]=Null )

		'If closing = Null

		' TRY HEADER
		If closing = Null
'DebugStop
			ParseCEOL( ast )
			ast.add( Parse_Strictmode() )
			ParseCEOL( ast )
			ast.add( Parse_Framework() )
			If token.id = TK_Module
				ParseCEOL( ast )
				ast.name = "MODULE"
				ast.add( Parse_Module() )
				Repeat
					ParseCEOL( ast )
					If token.id <> TK_ModuleInfo Exit
					ast.add( Parse_Moduleinfo() )
				Forever
			End If
			' Imports
			Repeat
				ParseCEOL( ast )
				If token.id <> TK_Import Exit
				ast.add( Parse_Import() )
			Forever
		End If
		' PARSE BODY
		Repeat	
'DebugStop					
			Try
				' Process EOL/Comments and Return at EOF
				If Not token Or parseCEOL( ast ) Return ast
'DebugStop				
				If token.in( options )
				
					' Parse this token
					Select token.id			
					Case TK_Function
						ast.add( Parse_Function( options ) )
					Case TK_Global
						ast.add( Parse_Global() )
					Case TK_Include
						ast.add( Parse_Include() )
					Case TK_Local
						ast.add( Parse_Local() )
'					Case TK_Method
'						ast.add( New TAST_Method() )
					Case TK_Type
						ast.add( Parse_Type() )
					Default
'DebugStop
						' ALL OPTIONS SHOULD BE ACCOUNTED FOR IN SELECT CASE
						' IF WE GET HERE, WE HAVE A BUG
						' SKIP UNTIL END OF LINE TO TRY TO RECOVER
						
						'Local skip:TAST_Skipped = New TAST_Skipped( token,  )
						'advance()
						'ast.add( skip )
						Local skip:TToken = token
						advance()
						Local error:TASTCompound = eatUntil( [TK_EOL,TK_EOF], skip )
						error.consume( skip )
						error.name = "ERROR"
						'skip.value = token.value
						error.errors :+ [ New TDiagnostic( "Unexpected symbol '"+skip.value+"'", DiagnosticSeverity.Warning ) ]
						error.status = AST_NODE_ERROR
						ast.add( error )
						
					End Select
		
				ElseIf closing And token.in(closing)
					' WE HAVE HIT THE CLOSING TOKEN
					Return ast
				
				Else	' TOKEN IS NOT IN THE OPTION LIST!
'DebugStop
					' Ask parent if they know about it
					'If parent.knows( token ) Return ast
					' Mark token as ERROR and skip until we find a token we do understand.
					'ast.add( New TAST_Skipped( "ERROR", token, "unexpected token" ) )
					'ast.add( eatUntil( options+[closing] ) )
					
					'DebugStop
					If parent And token.in(parent) Return ast

					Local skip:TToken = token
					advance()
					Local error:TASTCompound = eatUntil( options+closing, skip )
					error.consume( skip )
					error.name = "SKIPPED"
					'skip.value = token.value
					error.errors :+ [ New TDiagnostic( "~q"+skip.value + "~q was unexpected!", DiagnosticSeverity.Warning ) ]
					ast.add( error )
				
				End If
		
			Catch e:TParseError
DebugStop
				If e 
					token = lexer.fastFwd( TK_EOL )	' Skip to end of line
				End If

			EndTry
		Forever

		Return ast		
		
	
	
	End Method
		
	' Parses the application header into an EXISTING ast compound node
Rem
	Method parseHeaderTEST:TASTCompound( ast:TASTCompound )
		'Local ast:TASTCompound = New TASTCompound( "PROGRAM" )
		'Local ast_module:TASTCompound, ast_imports:TASTCompound
		
		' Parse out Whitespace, Comments, EOL and EOF
		If parseCEOL( ast ) Return ast
		' Parse Optional
Local debug:TToken = token
DebugStop
		ast.add( Parse_StrictmodeTEST() )
		
		Return ast
	End Method
End Rem

	' Parses Whitespace, Comments, EOL and EOF
	Method parseCEOL:Int( ast:TASTCompound )
'DebugStop
		Repeat
			Select token.id			
			Case TK_EOF
				Return True	
			Case TK_EOL
				ast.add( New TAST_EOL( token ) )
				advance()
			Case TK_COMMENT
				ast.add( New TAST_Comment( token ) )
				advance()
				'Local temp:TToken = eat(TK_EOL)	' SKIP REQUIRED "EOL"
			Case TK_REM
				Local node:TAST_Rem = New TAST_Rem( token ) 
				advance()
				node.closing = eat( TK_ENDREM )
				ast.add( node ) 
			Default
				' Finished with Comments and EOL!
				Return False
			End Select
		Forever
	End Method
	
	Method ParseExpression:TASTNode()
'DebugStop
        Local ast:TASTNode = ParseTerm()

		While token.in([ TK_PLUS, TK_hyphen ])
			Local operation:TToken = eat( [TK_PLUS,TK_hyphen] )
			ast = New TASTBinary( ast, operation, ParseTerm() )
		Wend
			
        Return ast
Rem
        """
        expr   : term ((PLUS | MINUS) term)*
        term   : factor ((MUL | DIV) factor)*
        factor : INTEGER | LPAREN expr RPAREN
        """
        node = self.term()

        while self.current_token.type in (PLUS, MINUS):
            token = self.current_token
            if token.type == PLUS:
                self.eat(PLUS)
            elif token.type == MINUS:
                self.eat(MINUS)

            node = BinOp(left=node, op=token, right=self.term())

        return node
End Rem
	End Method
	
	Method ParseFactor:TASTNode()
		Select token.id
		Case TK_Number
			Local ast:TASTNumber = New TASTNumber( token )
			advance()
			Return ast
		Case TK_Alpha
			Local ast:TASTVariable = New TASTVariable( token )
			advance()
			Return ast
		Case TK_LParen
'DebugStop
			advance()
			Local ast:TASTNode = ParseExpression()
			Local rparen:TToken = eat( TK_RParen )
			Return ast
		EndSelect
Rem
       """factor : INTEGER | LPAREN expr RPAREN"""
        token = self.current_token
        if token.type == INTEGER:
            self.eat(INTEGER)
            return Num(token)
        elif token.type == LPAREN:
            self.eat(LPAREN)
            node = self.expr()
            self.eat(RPAREN)
            return node
EndRem			
	End Method
	
	Method ParseTerm:TASTNode()
		Local ast:TASTNode = ParseFactor()
		While token.in( [TK_asterisk, TK_solidus] )					' MULTIPLY, DIVIDE
			Local operation:TToken = eat( [TK_asterisk, TK_solidus] )
			ast = New TASTBinary( ast, operation, ParseFactor() )
		Wend
		Return ast
Rem
        """term : factor ((MUL | DIV) factor)*"""
        node = self.factor()

        while self.current_token.type in (MUL, DIV):
            token = self.current_token
            if token.type == MUL:
                self.eat(MUL)
            elif token.type == DIV:
                self.eat(DIV)

            node = BinOp(left=node, op=token, right=self.factor())

        return node
End Rem
	End Method 
	
	' Parses the application header into an EXISTING ast compound node
	
Rem	Method parseHeader:TASTCompound( ast:TASTCompound )	
		Const FSM_STRICTMODE:Int = 0
		Const FSM_FRAMEWORK:Int = 1
		Const FSM_MODULE:Int = 2
		Const FSM_MODULEINFO:Int = 3
		Const FSM_IMPORT:Int = 4
		Const FSM_INCLUDE:Int = 5
		
		'Local ast:TASTCompound = New TASTCompound( "PROGRAM" )
		Local ast_module:TAST_Module, ast_imports:TASTCompound
		Local fsm:Int = FSM_STRICTMODE
'DebugStop	
		Repeat		
			Try
				If Not token Throw( "Unexpected end of token stream (STRICTMODE)" )
				
				' Parse Comments and EOL
				'If parseCEOL( ast, token ) Continue
				'If parseREM( ast, token ) Continue
				'If token.id = TK_EOF Return ast		' Source finished
				
				' Parse comments/eol and return as if at EOF
				If parseCEOL( ast ) Return ast

'DebugStop				
				' Parse this token
				Select token.id			
				'Case TK_EOF
				'	Return ast
				'Case TK_EOL
				'	ast.add( New TASTNode( "EOL" ) )
				'	token = lexer.getNext()
				'Case TK_COMMENT
				'	ast.add( Parse_Comment( token ) )
				'Case TK_REM
				'	ast.add( Parse_Rem( token ) )			
				Case TK_STRICT, TK_SUPERSTRICT
					If fsm > FSM_STRICTMODE
						ast.add( New TAST_Skipped( token )) ' MUST BE FIRST STATEMENT
					Else
						ast.add( Parse_Strictmode() )		' STRICTMODE
					End If
					fsm = FSM_FRAMEWORK
					
				Case TK_FRAMEWORK
					If fsm > FSM_FRAMEWORK
						ast.add( New TAST_Skipped( token ))  ' MUST BE BEFORE IMPORT
					Else
						ast.add( Parse_Framework() )
					End If
					fsm = FSM_IMPORT

				Case TK_MODULE
					If fsm > FSM_FRAMEWORK
						ast.add( New TAST_Skipped( token ) ) ' MUST BE BEFORE IMPORT
					Else
						' Change parent from "PROGRAM" to "MODULE"
						ast.name = "MODULE"
						ast_module = Parse_Module()
						ast.add( ast_module )
					End If
					fsm = FSM_MODULE
					'
				Case TK_MODULEINFO
					If fsm <> FSM_MODULE
						ast.add( New TAST_Skipped( token ) ) ' MUST BE AFTER MODULE
					Else
						ast_module.add( Parse_Moduleinfo() )
					End If
					'
				Case TK_IMPORT
'DebugStop
					If fsm > FSM_IMPORT
						ast.add( New TAST_SKIPPED( token ))  ' MUST BE BEFORE INCLUDE
					Else
						' Create an imports section if none exists
						If Not ast_imports
							ast_imports = New TASTCompound( "IMPORTS" )
							ast.add( ast_imports )
						End If
						
						' Add import 
						ast_imports.add( Parse_Import() )					
					End If

				Case TK_INCLUDE
					ast.add( Parse_Include() )
					fsm = FSM_INCLUDE
				Default
					' If we encounter anything else; the header is complete
					Return ast
				End Select
		
			Catch e:TParseError
DebugStop
				If e 
					token = lexer.fastFwd( TK_EOL )	' Skip to end of line
				End If

			EndTry
		Forever

		Return ast
	End Method
EndRem

Rem
	Method parseHeader:TASTCompound( ast:TASTCompound, token:TToken Var )	
		Const FSM_STRICTMODE:Int = 0
		Const FSM_FRAMEWORK:Int = 1
		Const FSM_MODULE:Int = 2
		Const FSM_MODULEINFO:Int = 3
		Const FSM_IMPORT:Int = 4
		
		'Local ast:TASTCompound = New TASTCompound( "PROGRAM" )
		Local ast_module:TASTCompound, ast_imports:TASTCompound
		Local fsm:Int = FSM_STRICTMODE
'DebugStop	
		Repeat		
			Try
				If Not token Throw( "Unexpected end of token stream (STRICTMODE)" )
				
				' Parse Comments and EOL
				'If parseCEOL( ast, token ) Continue
				'If parseREM( ast, token ) Continue
				'If token.id = TK_EOF Return ast		' Source finished

'DebugStop				
				' Parse this token
				Select token.id			
				Case TK_EOF
					Return ast
				Case TK_EOL
					ast.add( New TASTNode( "EOL" ) )
					token = lexer.getNext()
				Case TK_COMMENT
					ast.add( Parse_Comment( token ) )
				Case TK_REM
					ast.add( Parse_Rem( token ) )			
				Case TK_STRICT, TK_SUPERSTRICT
					If fsm > FSM_STRICTMODE
						Publish( "syntax-error", "'"+token.value+"' was unexpected at this time" )
						Continue
					End If
					fsm = FSM_FRAMEWORK
					'
					ast.add( Parse_Strictmode( token ) )
				Case TK_FRAMEWORK
					If fsm > FSM_FRAMEWORK
						publish( "syntax-error", "'"+token.value+"' was unexpected at this time" )
						Continue
					End If
					fsm = FSM_IMPORT
					'
					ast.add( Parse_Framework( token ) )
				Case TK_MODULE
					If fsm > FSM_FRAMEWORK
						publish( "syntax-error", "'"+token.value+"' was unexpected at this time" )
						Continue
					End If
					fsm = FSM_MODULE
					'
					ast_module = Parse_Module( token )
					ast.add( ast_module )
				Case TK_MODULEINFO
					If fsm <> FSM_MODULE
						publish( "syntax-error", "'"+token.value+"' was unexpected at this time" )
						Continue
					End If
					'
					ast_module.add( Parse_Moduleinfo( token ) )
				Case TK_IMPORT
'DebugStop
					If fsm > FSM_IMPORT
						publish( "syntax-error", "'"+token.value+"' was unexpected at this time" )
						Continue
					End If

					' Create an imports section if none exists
					If Not ast_imports
						ast_imports = New TASTCompound( "IMPORTS" )
						ast.add( ast_imports )
					End If
					
					' Add import 
					ast_imports.add( Parse_Import( token ) )
				Case TK_INCLUDE
					ast.add( Parse_Include( token ) )
				Default
					' If we encounter anything else; the header is complete
					Return ast
				End Select
		
			Catch e:TParseError
DebugStop
				If e 
					token = lexer.fastFwd( TK_EOL )	' Skip to end of line
				End If

			EndTry
		Forever

		Return ast
	End Method
End Rem	

	'	Looks for trailing comments
	'	These will become descriptions in the ast node
'	Method ParseDescription:String( token:TToken Var )
'		Local description:String
'		' Trailing comment is a description
'		token = lexer.expect( [TK_COMMENT,TK_EOL] )
'		If token.id = TK_COMMENT
'			' Inline comment becomes the node description
'			description = token.value
'			token = lexer.Expect( TK_EOL )
'		End If
'		Return description
'	End Method	

Rem
	Method Parse_CommentTEST:TASTNode()
		Local ast:TASTNode = New TASTNode( "COMMENT", token )
'DebugStop
		advance()
		Local temp:TToken = eat(TK_EOL)	' SKIP REQUIRED "EOL"
		'token2 = lexer.getNext()			' Skip EOL
		Return ast
	End Method
End Rem	

	'Method Parse_Comment:TASTNode( token:TToken Var )
	'	Local ast:TASTNode = New TASTNode( "COMMENT", token )
	'	token = lexer.expect(TK_EOL)
	'	token = lexer.getNext()			' Skip EOL
	'	Return ast
	'End Method

	Method Parse_End:TASTNode()
		Local ast:TASTNode = New TASTNode( "END", token )
		advance()
		' Trailing comment is a description
		'ast.comment = eatOptional( [TK_COMMENT], Null )
		Return ast
	End Method

	Method Parse_Field:TASTNode()
		Local ast:TASTBinary = New TASTBinary( token )	' LOCAL, GLOBAL or FIELD
		ast.name = "vardecl"
'DebugStop
		advance()
		ast.lnode = New TASTNode( token )
		
'TODO: Implement variable definition
		ast.operation  = eat( TK_Equals )
		ast.rnode = eatUntil( [TK_EOL], token )
		Return ast
	End Method
	
	'	framework = framework ALPHA PERIOD ALPHA [COMMENT] EOL
	Method Parse_Framework:TASTNode()
'DebugStop
		Local fwork:TToken = eatOptional( TK_FRAMEWORK, Null )
		'If Not token Return New TASTMissingOptional( "FRAMEWORK", "Framework" )
		If Not fwork 
			Local starts:TPosition = New TPosition( token )
			Local ends:TPosition =  New TPosition( token )
			ends.character :+ token.value.length
			Local ast:TASTMissingOptional = New TASTMissingOptional( "FRAMEWORK", "Framework" )
			ast.errors :+ [ New TDiagnostic( "'Framework' is recommended", DiagnosticSeverity.Hint, New TRange( starts, ends ) ) ]
			Return ast
		End If
		'
		Local ast:TAST_Framework = New TAST_Framework( token )
		'advance()
		' Get properties
		ast.major = eat( TK_ALPHA )
		ast.dot = eat( TK_PERIOD )
		ast.minor = eat( TK_ALPHA )
		' Trailing comment is a description
		'ast.comment = eatOptional( [TK_COMMENT], Null )
		Return ast
	End Method

	'	function = function [ ":" <vartype> ] "(" [<args>] ")" [COMMENT] EOL
	Method Parse_Function:TASTNode( parent:Int[] )
		Local ast:TAST_Function = New TAST_Function( token )
		Local start:TPosition = New TPosition( token )
		advance()

		' PROPERTIES
		
		ast.fnname = eat( TK_ALPHA, Null )
		ast.colon = eatOptional( TK_COLON, Null )
		If ast.colon ast.returntype = eat( TK_ALPHA, Null )
		ast.lparen = eat( TK_lparen, Null )
		ast.def = eatUntil( [TK_rparen,TK_EOL], token)
		ast.rparen = eat( TK_rparen, Null )
		
		' VALIDATION
DebugStop

		'Local valid:Int = True
		'valid = valid & (ast.fnname<>Null) & (ast.lparen<>Null) & (ast.rparen<>Null)

		'	VALIDATE FUNCTION NAME
		
'TODO: Must be unique and not a keyword

		'	VALIDATE RETURN TYPE

		If ast.returntype And ast.returntype.notin( [TK_Int,TK_String,TK_Double,TK_Float] )

'TODO: Need to check return type against SYMBOL TABLE

			Local starts:TPosition = New TPosition( ast.returntype )
			Local ends:TPosition = New TPosition( ast.returntype )
			ends.character :+ ast.returntype.value.length	' Add length of token
			Local range:TRange = New TRange( starts, ends )
			ast.errors :+ [ New TDiagnostic( "Invalid return type", DiagnosticSeverity.Warning, range ) ]
		End If

		'	VALIDATE PARENTHESIS

		Local range:TRange = New TRange( start, New TPosition( token ) )
		If Not ast.lparen 
			ast.errors :+ [ New TDiagnostic( "Missing parenthesis", DiagnosticSeverity.Warning, range ) ]
		ElseIf Not ast.rparen 
			ast.errors :+ [ New TDiagnostic( "Missing parenthesis", DiagnosticSeverity.Warning, range ) ]
		ElseIf ast.lparen<>ast.rparen	' Mismatch "(" and NULL or Null and ")"
			ast.errors :+ [ New TDiagnostic( "Mismatching parenthesis", DiagnosticSeverity.Warning, range ) ]
		End If

		'	READ BODY

		If ast.fnname And ast.lparen And ast.rparen
			'Local body:TASTCompound 
			ast.body = parseSequence( "BODY", SYM_FUNCTION_BODY+[TK_ALPHA], [TK_EndFunction], parent )	
		Else
			ast.errors :+ [ New TDiagnostic( "Invalid function definition", DiagnosticSeverity.Warning, range ) ] 
		End If
		' For the sake of simplicity at the moment, this will not parse the body
		'ast.add( eatUntil( [TK_EndFunction], token ) )
		'ast.add( body )
Rem
		Local finished:Int = False
		Repeat
			token = lexer.getNext()
			If token.id = TK_END
				token = lexer.getNext()
				If token.id = TK_FUNCTION ; finished = True
			End If
		Until token.id = TK_ENDFUNCTION Or finished
End Rem
		' End of block
		
		' CLOSING KEYWORD
		
		ast.ending = eat( TK_EndFunction )
		Return ast
	End Method

	Method Parse_Global:TASTNode()
		Local ast:TASTBinary = New TASTBinary( token )	' LOCAL, GLOBAL or FIELD
		ast.name = "vardecl"
'DebugStop
		advance()
		ast.lnode = New TASTNode( token )
'TODO: Implement variable definition
		ast.rnode = eatUntil( [TK_EOL], token )
		Return ast
	End Method
		
	'	Create an AST Node for Import containing all imported modules as children
	'	import = import ALPHA PERIOD ALPHA [COMMENT] EOL
	Method Parse_Import:TASTNode()
		Local ast:TAST_Import = New TAST_Import( "IMPORT", token )
		advance()
		' Get module name
		ast.major = eat( TK_ALPHA )
		ast.dot = eat( TK_PERIOD )
		ast.minor = eat( TK_ALPHA )
		' Trailing comment is a description
		'ast.comment = eatOptional( [TK_COMMENT], Null )
		Return ast
	End Method

	'	Create an AST Node for Import
	Method Parse_Include:TASTNode()
		Local ast:TAST_Include = New TAST_Include( "INCLUDE", token )
		advance()
		' Get module name
		ast.file = eat( TK_QSTRING )
DebugStop		
		' Request document is opened (If it isn't already)
		If ast.file And ast.file.id=TK_QSTRING
			Local file:String = ast.file.value
			Local included:TTextDocument = documents.getFile( file )
		End If
		' Trailing comment is a description
		'ast.comment = eatOptional( [TK_COMMENT], Null )
		Return ast
	End Method

	Method Parse_Local:TASTNode()
		Local ast:TASTBinary = New TASTBinary( token )	' LOCAL, GLOBAL or FIELD
		ast.name = "vardefinition"
'DebugStop
		advance()
		ast.lnode = Parse_VarDecl()
		'advance()
		ast.operation  = eat( TK_Equals )
'DebugStop
		ast.rnode = ParseExpression()

'TODO: Implement variable definition
		'ast.rnode = eatUntil( [TK_EOL], token )
		Return ast
	End Method
	
	'	method = method [ ":" <vartype> ] "(" [<args>] ")" [COMMENT] EOL
	Method Parse_Method:TAST_Method()
		Local ast:TAST_Method = New TAST_Method( token )
		advance()

		' Get properties
		ast.methodname = eat( TK_ALPHA )
		ast.colon = eatOptional( TK_COLON, Null )
		If ast.colon ast.returntype = eat( TK_ALPHA )
		ast.lparen = eat( TK_lparen )
		ast.def = eatUntil( [TK_rparen], token )
		ast.rparen = eat( TK_rparen )
		' Trailing comment is a description
		'ast.comment = eatOptional( [TK_COMMENT], Null )
		
		' BODY OF THE FUNCTION
		
		' For the sake of simplicity at the moment, this will not parse the body
		' ast.add( ParseBlock( [ TK_LOCAL, TK_GLOBAL, TK_REPEAT, etc] )
		ast.add( eatUntil( [TK_EndMethod], ast.rparen ) )
Rem
		Local finished:Int = False
		Repeat
			token = lexer.getNext()
			If token.id = TK_END
				token = lexer.getNext()
				If token.id = TK_FUNCTION ; finished = True
			End If
		Until token.id = TK_ENDFUNCTION Or finished
End Rem
		' End of block
		ast.ending = eat( TK_EndMethod )
		Return ast
	End Method
		
	Method Parse_Module:TAST_Module()
		Local token:TToken = eatOptional( TK_MODULE, Null )
		If Not token Return Null
		'
		Local ast:TAST_Module = New TAST_Module( token )
		advance()
		' Get module name
		ast.major = eat( TK_ALPHA )
		ast.dot = eat( TK_PERIOD )
		ast.minor = eat( TK_ALPHA )
		' Trailing comment is a description
		'ast.comment = eatOptional( [TK_COMMENT], Null )
		Return ast
	End Method

	Method Parse_ModuleInfo:TASTNode()
		Local token:TToken = eatOptional( TK_MODULEINFO, Null )
		If Not token Return Null
		'
		Local ast:TAST_ModuleInfo = New TAST_ModuleInfo( token )
		advance()
		' Get module name
		ast.value = eat( TK_QSTRING )
		' Trailing comment is a description
		'ast.comment = eatOptional( [TK_COMMENT], Null )
		Return ast
	End Method
	
Rem	Method Parse_Rem:TASTNode()
		Local ast:TASTNode = New TASTNode( "REMARK", token )
'DebugStop
		' Now look for ENDREM or END REM
		token = lexer.expect( [TK_ENDREM, TK_END] )
		If token.id = TK_END lexer.expect( TK_REM )
		
		' Next we look for a weird trailing comment
		' If it exists, we treat it as a newline
		Local peek:TToken = lexer.peek()
		If peek.id = TK_COMMENT 
			token = lexer.getNext()
			Return ast
		End If
		
		token = lexer.expect( TK_EOL )
		token = lexer.getNext()
		Return ast
	End Method
EndRem

	'	strictmode = (strict|superstrict) [COMMENT] EOL
'	Method Parse_Strictmode:TASTNode( token:TToken Var )
'		Local ast:TASTNode = New TASTNode( "STRICTMODE", token )
'		'
'		' Trailing comment is a description
'		ast.descr = ParseDescription( token )
'		token = lexer.getNext()
'		Return ast
'	End Method

	'	strictmode = (strict|superstrict) [COMMENT] EOL
	Method Parse_Strictmode:TASTNode()
		Local Strictmode:TToken = eatOptional( [TK_STRICT, TK_SUPERSTRICT], Null )
		If Not Strictmode 
			Local starts:TPosition = New TPosition( token )
			Local ends:TPosition =  New TPosition( token )
			ends.character :+ token.value.length
			Local ast:TASTMissingOptional = New TASTMissingOptional( "STRICTMODE", "superstrict~n" )
			ast.errors :+ [ New TDiagnostic( "'SuperStrict' is recommended", DiagnosticSeverity.Hint, New TRange( starts, ends ) ) ]
			Return ast
		End If
'DebugStop
		Local ast:TAST_Strictmode = New TAST_Strictmode( token )
		'advance()
		' Trailing comment is a description
		'ast.comment = eatOptional( [TK_COMMENT], Null )
		Return ast
	End Method
	
	'	type = type ALPHA [ extends ALPHA ] [COMMENT] EOL
Rem	Method Parse_Type:TASTNode( token:TToken Var )
		Local ast:TAST_Type = New TAST_Type( token )
'DebugStop
		' Get name
		token = lexer.expect( TK_ALPHA )
		ast.value = token.value
		
		' Get extend Type
		Local peek:TToken = lexer.peek()
		If peek.id = TK_EXTENDS
			token = lexer.getnext()	' Skip "EXTENDS"
			token = lexer.getNext() ' Get the super type
			ast.supertype = token
			'token = lexer.getNext()	' Skip supertype
		End If
		
		' Trailing comment is a description
		ast.descr = ParseDescription( token )
		token = lexer.getNext()

		' Parse TYPE into ast
'DebugStop
		ast = TAST_Type( ParseBlock( TK_TYPE, ast, token, SYM_TYPEBODY, Null ) )

		'Rem
		'Local finished:Int = False
		'Repeat
		'	token = lexer.getNext()
		'	If token.id = TK_END
		'		token = lexer.getNext()
		'		If token.id = TK_TYPE ; finished = True
		'	End If
		'Until token.id = TK_ENDTYPE Or finished
		'End Rem
		
		'
		' Trailing comment is a description
		Local descr:String = ParseDescription( token )
		If descr ast.descr :+ " "+descr
		token = lexer.getNext()
		Return ast
	End Method
End Rem

	Method Parse_Type:TASTNode()
'DebugStop
		Local ast:TAST_Type = New TAST_Type( token )
		advance()

		' Get properties
		ast.typename = eat( TK_ALPHA )
		ast.extend = eatOptional( TK_Extends, Null )
		If ast.extend ast.supertype = eat( TK_ALPHA )

		' Trailing comment is a description
		'ast.comment = eatOptional( [TK_COMMENT], Null )
		
		' BODY OF THE TYPE
		
		' For the sake of simplicity at the moment, this will not parse the body
		' ast.add( ParseBlock( [ TK_LOCAL, TK_GLOBAL, TK_REPEAT, etc] )
		ast.add( eatUntil( [TK_EndType], token ) )
		'ListAddLast( ast.children, New TASTNode("ERROR" ) )

		' End of block
		ast.ending = eat( TK_EndType )
		Return ast
	End Method


	Rem PARSES
	Local X:Int = 25
	Local X:Int = 10*a
	Local X( y:Int ) = something
	Local X:Int( y:Int ) = something
	End Rem
	Method Parse_VarDecl:TASTNode()
'DebugStop
		Local ltoken:TTOken = eat( TK_ALPHA )
		Local colon:TToken = eatOptional( TK_Colon, Null )
		Local vartype:TTOken
		If colon vartype = eat( SYM_DATATYPES+[TK_ALPHA] )
		Local paren:TToken = eatOptional( TK_LParen, Null )
		
		' Identify Function variable declaration
		If paren
			Local ast:TAST_Function = New TAST_Function()
			advance()
			ast.fnname = ltoken
			ast.colon = colon
			ast.returntype = vartype
			ast.lparen = paren
			ast.def = eatUntil( [TK_rparen], token)
			ast.rparen = eat( TK_rparen )		
			Return ast
		End If

		' Standard Variable declaration
		Local ast:TASTBinary = New TASTBinary( "vardefinition" )
		ast.lnode = New TASTNode( ltoken )
		ast.operation = colon
		ast.rnode = New TASTNode( vartype )
		Return ast
	End Method
		
	' Obtain closing token for a given blocktype
	Method closingToken:Int( tokenid:Int )
		Select tokenid
		Case TK_EXTERN		;	Return TK_ENDEXTERN
		Case TK_FUNCTION	;	Return TK_ENDFUNCTION
		Case TK_IF			;	Return TK_ENDIF
		Case TK_INTERFACE	;	Return TK_ENDINTERFACE
		Case TK_METHOD		;	Return TK_ENDMETHOD
		Case TK_REM			;	Return TK_ENDREM
		Case TK_REPEAT		;	Return Null	'[ TK_FOREVER, TK_UNTIL ]
		Case TK_SELECT		;	Return TK_ENDSELECT
		Case TK_STRUCT		;	Return TK_ENDSTRUCT
		Case TK_TRY			;	Return TK_ENDTRY
		Case TK_TYPE		;	Return TK_ENDTYPE
		Case TK_WHILE		;	Return Null 'TK_ENDWHILE, TK_WEND]
		End Select
	End Method

	' Dump the symbol table into a string
	'Method reveal:String()
	'	Local report:String = "POSITION  SCOPE     NAME      TYPE~n"
	'	For Local row:TSymbolTableRow = EachIn symbolTable.list
	'		report :+ (row.line+","+row.pos)[..8]+"  "+row.scope[..8]+"  "+row.name[..8]+"  "+row.class[..8]+"~n"
	'	Next
	'	Return report
	'End Method
	
	' Recover from syntax errors
	' Called by parse method during try-catch for TParseError()
	Method error_recovery()
		Rem
		local peek:TToken
		repeat
			peek = lexer.peek()
			select peek.id
			case TK_End
				' End marks the end of a block and we dont want the
				' following token to be mis-interpreted as the start of a new block 
				' so we have to drop it
				lexer.getnext()
				lexer.getnext()
				continue
			case TK_Function, TK_Method, TK_Type, TK_Struct, TK_For, TK_Local, TK_Field, TK_If
				return
			default
				' Consume the token as we are uncertain following an error
				lexer.getnext()
			end select
		until peek.id=TK_EOF
		End Rem
	End Method
	
	'	DYNAMIC METHODS
	'	CALLED BY REFLECTOR

Rem 	
	Method rule_program:TASTNode( syntax:TASTNode[] )
'DebugStop
		Local tree:TASTCompound = New TASTCompound( "PROGRAM" )
		For Local ast:TASTNode = EachIn syntax
			If ast.token.id <> TK_EOL ; tree.add( ast )
		Next
		Return tree
	End Method

	Method rule_ceol:TASTNode( syntax:TASTNode[] )
		' EOL is ignored, but comments are added to the tree
		'	Create an AST for this statement
'DebugStop
		Select syntax.length
		Case 1	' 	c-eol = EOL
			'syntax[0].name = "EOL"
			Return syntax[0]
		Case 2	'	c-eol = COMMENT EOL
			' We will recycle the comment
			syntax[0].name = "linecomment"
			syntax[0].descr = syntax[0].token.value
			'Return New TASTNode( "comment", syntax[0] )
			Return syntax[0]
		Default
			Throw "rule_ceol(), FAILED, Invalid arguments"
		End Select
	End Method

	Method rule_strictmode:TASTNode( syntax:TASTNode[] )		
		Print "RULE STRICTMODE"
'DebugStop
		'	Set Parser state to selected strict mode
		strictmode = syntax[0].token.id

		'	Create an AST for this statement
		Select syntax.length
		Case 1	' 	strictmode = MODE EOL
			syntax[0].name = "strictmode"
			'Return New TASTNode( "strictmode", syntax[0] )
			Return syntax[0]
		Case 2	' 	strictmode = MODE COMMENT EOL
'DebugStop
			syntax[0].name = "strictmode"
			syntax[0].descr = syntax[1].token.value
			'Return New TASTNode( "strictmode", syntax[0], syntax[1].value )
			Return syntax[0]
		Default
			Throw "rule_strictmode(), FAILED, Invalid arguments"
		End Select

	End Method
End Rem
	
Rem
	' Field = "field" VarDecl *[ "," VarDecl ]
	Method token_field( token:TToken )
		Parse_VarDeclarations( "field", token )
	End Method
	
	' Framework = "framework" ModuleIdentifier EOL
	' ModuleIdentifier = Name DOT Name
	' Name = ALPHA *(ALPHA / DIGIT / UNDERSCORE )
	Method token_framework( token:TToken )
		Local moduleIdentifier:String = Parse_ModuleIdentifier()
		' Add to symbol table
		symbolTable.add( token, "global", moduleIdentifier ) 
	End Method

	' Global = "global" VarDecl *[ "," VarDecl ]
	Method token_global( token:TToken )
		Parse_VarDeclarations( "global", token )
	End Method

	' Local = "local" VarDecl *[ "," VarDecl ]
	Method token_local( token:TToken )
'DebugStop
		Parse_VarDeclarations( "local", token )
'Print "LOCAL DONE"
	End Method
	
	' StrictMode = "superstrict" / "strict" EOL
	Method token_strictmode( token:TToken )
		Select token.class
		Case "strict"		;	strictmode = 1
		Case "superstrict"	;	strictmode = 2
		End Select
		'lexer.expect( "EOL" )
	End Method
	
	'	STATIC METHODS
	'	CALLED DIRECTLY
	
	' ApplicationBody = Local / Global / Function / Struct / Type / BlockBody
	Method Parse_Body:String( expected:String[] )
		Local token:TToken
		Local found:TToken
		Repeat
			token = lexer.peek()
'DebugStop
			If token.class="EOF" 
				lexer.getNext()
				Exit
			End If
			If token.class="EOL" Or token.class="comment"
				lexer.getNext()
				Continue
			End If
			found = Null
			For Local expect:String = EachIn expected
				If expect=token.class 
					found = token
					Exit
				End If
			Next
			'
			If found  ' Expected token
				reflect( lexer.getNext() )
				' 
'				Local token:TToken = lexer.getNext()
'				Select token.class
'				Case "field"		;	Parse_VarDeclarations( "field", token )
'				Case "global"		;	Parse_VarDeclarations( "global", token )
'				Case "local"		;	Parse_VarDeclarations( "local", token )
'				Default
'					ThrowException( "Unhandled token '"+token.value+"'", token.line, token.pos )
'				End Select
			Else
				' Unexpected token...
				ThrowException( "Unexpected token '"+token.value+"'", token.line, token.pos )
			End If
		Forever
	End Method

	' ModuleIdentifier = Name DOT Name
	Method Parse_ModuleIdentifier:String()
		Local collection:TToken = lexer.Expect( "alpha" )
		lexer.Expect( "symbol", "." )
		Local name:TToken = lexer.Expect( "alpha" )
		Return collection.value + "." + name.value
	End Method
	
	' VarDeclarations = VarDecl *[ "," VarDecl ]
	Method Parse_VarDeclarations( scope:String, token:TToken )
		Local tok:TToken
'DebugStop
		Repeat
			Parse_VarDecl( token, scope )
			tok = lexer.peek()
		Until tok.class = "EOF" Or tok.class<>"comma"		
	End Method

	' VarDecl = Name ":" VarType [ "=" Expression ]
	Method Parse_VarDecl( definition:TToken, scope:String )
'DebugStop
		' Parse Variable defintion
		Local name:TToken = lexer.Expect( "alpha" )
		lexer.expect( "colon" )
		Local varType:String = Parse_VarType()
		' Parse optional declaration
		If lexer.peek( "equals" )
			Local sym:TToken
			' Throw away the expression. NOT IMPLEMENTED YET
			Repeat
				sym = lexer.getNext()
				'Print sym.class
			Until sym.in( [TK_EOF,TK_EOL,TK_comma,TK_Comment] )
		End If
		' Create Defintion Table
		symbolTable.add( definition, scope, name.value, vartype )
	End Method

	' VarType = "byte" / "int" / "string" / "double" / "float" / "size_t"
	Method Parse_VarType:String()
		Local sym:TToken = lexer.getNext()
		Return sym.value
	End Method
End Rem

	'	ERROR RECOVERY FUNCTIONS
	
	Function error_to_eol( lexer:TLexer, ignore1:Int, ignore2:Int )
DebugStop
	End Function

	Function error_until_end( lexer:TLexer, starttag:Int, endtag:Int )
DebugStop
	End Function
	
End Type

'Type AST_strictmode Extends TAbSynTree
'	Field comment:String
'	Field strictmode:Int
'	Method New( strictmode:TToken, comment:TToken )
'		Self.strictmode = strictmode.id
'		If comment Self.comment = comment.value
'	End Method
'End Type

Type TCodeBlock
	Field start:TToken
	Field finish:TToken
	Method New( start:TToken, finish:TToken )
		Self.start = start
		Self.finish = finish
	End Method
End Type
