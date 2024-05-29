SuperStrict
'# GENERIC PARSER FOR BLITZMAX
'# (c) Copyright Si Dunford, August 2021, All Rights Reserved
'# V2.0

Import BRL.Reflection
Import "../lexer/lexer.bmx"

' PARSER COMPONENTS
Include "src/TParser.bmx"
Include "src/TParseValidator.bmx"

' ABSTRACT SYNTAX TREE COMPONENTS
Include "src/TASTNode.bmx"
Include "src/TASTBinary.bmx"
Include "src/TASTCompound.bmx"
Include "src/TVisitor.bmx"

' ERROR MESSAGES FOR AST NODE
Include "src/TASTErrorMessage.bmx"

' Exception handler for Parse errors
Type TParseError Extends TException
End Type

Function ThrowParseError( message:String, line:Int=-1, pos:Int=-1 )
	Throw( New TParseError( message, line, pos ) )
End Function
