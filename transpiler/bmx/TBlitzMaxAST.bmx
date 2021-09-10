
'	BlitzMax Abstract Syntax Tree
'	(c) Copyright Si Dunford, July 2021, All Rights Reserved

'	CHANGE LOG
'	V1.0	17 AUG 21	Initial version
'	V1.1	22 AUG 21	Added TAST_Function(), TAST_Method() and TAST_Type()

' Diagnostics node used when an optional token is missing
Type TASTMissingOptional Extends TASTNode { class="diagnostic" }
	
	' descr field should hold some detail used by the language server to
	' help user recreate this, or force it
	' default value needs to be included so it can be "fixed"

	Method New( name:String, value:String )
		Self.name  = name
		Self.value = value
	End Method
		
End Type

' Diagnostics node used when an error has been found and a node has been skipped
Type TAST_Skipped Extends TASTNode { class="diagnostic" }
	
	' descr field should hold some detail used by the language server to
	' help user recreate this, or force it
	' default value needs to be included so it can be "fixed"

	Method New( name:String, value:String )
		Self.name  = name
		Self.value = value
	End Method
		
End Type

Type TAST_Framework Extends TASTNode { class="FRAMEWORK" }
	Field major:TToken
	Field dot:TToken
	Field minor:TToken
End Type

Type TAST_Function Extends TASTCompound { class="FUNCTION" }
	Field fnname:TToken
	Field colon:TTOken
	Field returntype:TToken
	Field lparen:TToken
	Field def:TASTCompound
	Field rparen:TToken
	Field body:TASTCompound
End Type

Type TAST_Import Extends TASTNode { class="IMPORT" }
	Field major:TToken
	Field dot:TToken
	Field minor:TToken

	Method New( token:TToken )
		name = "IMPORT"
		consume( token )
	End Method

End Type

Type TAST_Include Extends TASTNode { class="INCLUDE" }
	Field value:TToken

	Method New( token:TToken )
		name = "INCLUDE"
		consume( token )
	End Method

End Type

Type TAST_Method Extends TASTCompound { class="METHOD" }
	Field methodname:TToken
	Field colon:TTOken
	Field returntype:TToken
	Field lparen:TToken
	Field def:TASTCompound
	Field rparen:TToken
	Field body:TASTCompound
End Type

Type TAST_Module Extends TASTCompound { class="MODULE" }
	Field major:TToken
	Field dot:TToken
	Field minor:TToken
End Type

Type TAST_ModuleInfo Extends TASTNode { class="MODULEINFO" }
	Field value:TToken
End Type

Type TAST_Rem Extends TASTNode { class="REMARK" }
	Field closing:TToken

	Method New( token:TToken )
		name = "REMARK"
		consume( token )
	End Method

End Type

Type TAST_StrictMode Extends TASTNode { class="STRICTMODE" }

	Method New( token:TToken )
		name = "STRICTMODE"
		consume( token )
	End Method

End Type

Type TAST_Type Extends TASTCompound { class="SEQUENCE" }
	Field supertype:TToken

	Method New( token:TToken )
		name = "TYPE"
		consume( token )
	End Method

End Type

Rem Type TAST_Comment Extends TASTNode

	Method New( token:TToken )
		name = "COMMENT"
		consume( token )
	End Method
	
End Type
EndRem
Rem
Type TAST_Strictmode Extends TASTNode

	'	(STRICT|SUPERSTRICT) [COMMENT] EOL
	Method New( lexer:TLexer, token:TToken Var )
		name = "STRICTMODE"
		consume( token )
		'
		' Trailing comment is a description
		token = lexer.expect( [TK_COMMENT,TK_EOL] )
		If token.id = TK_COMMENT
			' Inline comment becomes the node description
			descr = token.value
			token = lexer.Expect( TK_EOL )
		End If
		token = lexer.getNext()
	End Method
	
End Type
		
Type TAST_Framework Extends TASTNode

	'	FRAMEWORK ALPHA PERIOD ALPHA [COMMENT] EOL
	Method New( lexer:TLexer, token:TToken Var )
		name = "FRAMEWORK"
		consume( token )
		'
		' Get module name
		token = lexer.expect( TK_ALPHA )
		value = token.value
		token = lexer.expect( TK_PERIOD )
		token = lexer.expect( TK_ALPHA )
		value :+ "."+token.value
		'
		' Trailing comment is a description
		token = lexer.expect( [TK_COMMENT,TK_EOL] )
		If token.id = TK_COMMENT
			' Inline comment becomes the node description
			descr = token.value
			token = lexer.Expect( TK_EOL )
		End If
		token = lexer.getNext()
	End Method
	
End Type

EndRem
Rem
Type TAST_Module Extends TASTCompound

	'	FRAMEWORK ALPHA PERIOD ALPHA [COMMENT] EOL
	Method New( lexer:TLexer, token:TToken Var )
		name = "MODULE"
		consume( token )
		'
		' Get module name
		token = lexer.expect( TK_ALPHA )
		value = token.value
		token = lexer.expect( TK_PERIOD )
		token = lexer.expect( TK_ALPHA )
		value :+ "."+token.value
		'
		' Trailing comment is a description
		token = lexer.expect( [TK_COMMENT,TK_EOL] )
		If token.id = TK_COMMENT
			' Inline comment becomes the node description
			descr = token.value
			token = lexer.Expect( TK_EOL )
		End If
		token = lexer.getNext()
		
	End Method
	
End Type
End Rem
