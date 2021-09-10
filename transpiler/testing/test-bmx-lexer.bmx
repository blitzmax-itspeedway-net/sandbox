SuperStrict
'	BLITZMAX LEXER TEST
'	(c) Copyright Si Dunford, July 2021, All Rights Reserved

'	TIMINGS USING MAXIDE.BMX

'	DEBUG	PROD
'	281ms	56ms	Tlist+string - Incomplete symbols.
'	307ms	74ms	Tlist+integer (Symbols in defined:TMap)
'	269ms	60ms	Tlist+integer (Symbols in string[])

'Import bmx.lexer
'Import bmx.parser
Import Text.Regex

Include "../bin/loadfile().bmx"

'Include "bmx/AbstractSyntaxTree.bmx"

' SANDBOX LEXER
Include "../lexer/TLexer.bmx"
Include "../lexer/TToken.bmx"
Include "../lexer/TException.bmx"

' SANDBOX PARSER

Include "../parser/TParser.bmx"
Include "../parser/TASTNode.bmx"
Include "../parser/TASTBinary.bmx"
Include "../parser/TASTCompound.bmx"
Include "../parser/TVisitor.bmx"

' Exception handler for Parse errors
Type TParseError Extends TException
End Type

Function ThrowParseError( message:String, line:Int=-1, pos:Int=-1 )
	Throw( New TParseError( message, line, pos ) )
End Function

' SANDBOX BLITZMAX LEXER/PARSER
Include "../bmx/lexer-const-bmx.bmx"
Include "../bmx/TBlitzMaxAST.bmx"
Include "../bmx/TBlitzMaxLexer.bmx"
Include "../bmx/TBlitzMaxParser.bmx"

'Include "bin/TException.bmx"
'Include "bin/TToken.bmx"

'DebugStop
Local lexer:TLexer
Local start:Int, finish:Int

Try
	'DebugStop
	Local source:String = loadFile( "../samples/capabilites.bmx" )
	'Local source:String = loadFile( "samples/maxide.bmx" )
	Local lexer:TLexer = New TBlitzMaxLexer( source )
'DebugStop
	start  = MilliSecs()
	lexer.run()
	finish = MilliSecs()
	
	Print( "LEXER.TIME: "+(finish-start)+"ms" )
	
	Print( "Starting debug output...")
	Print( lexer.reveal() )

Catch exception:TException
	Print "## Exception: "+exception.toString()+" ##"
End Try








