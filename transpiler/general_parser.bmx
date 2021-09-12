SuperStrict
'	GENERAL PARSER
'	(c) Copyright Si Dunford, July 2021, All Rights Reserved

Framework brl.retro
'Import brl.collections
'Import brl.map
Import brl.objectlist
Import brl.reflection
Import Text.RegEx

' COMMENTED OUT BECAUSE WE ARE TESTING LOCAL COPIES
'Import bmx.lexer
'Import bmx.parser
'Import bmx.blitzmaxparser
'Import bmx.transpiler

Include "bin/loadfile().bmx"

' SANDBOX LEXER
Include "lexer/TLexer.bmx"
Include "lexer/TToken.bmx"
Include "lexer/TException.bmx"

' SANDBOX PARSER
Include "parser/TParser.bmx"
Include "parser/TASTNode.bmx"
Include "parser/TASTBinary.bmx"
Include "parser/TASTCompound.bmx"
Include "parser/TVisitor.bmx"
Include "parser/TParseValidator.bmx"

' Exception handler for Parse errors
Type TParseError Extends TException
End Type

Function ThrowParseError( message:String, line:Int=-1, pos:Int=-1 )
	Throw( New TParseError( message, line, pos ) )
End Function

' SANDBOX BLITZMAX LEXER/PARSER
Include "bmx/lexer-const-bmx.bmx"
Include "bmx/TBlitzMaxAST.bmx"
Include "bmx/TBlitzMaxLexer.bmx"
Include "bmx/TBlitzMaxParser.bmx"

' SANDBOX TRANSPILER
Include "transpiler/TTranspiler.bmx"
Include "transpiler/TTranspileBlitzMax.bmx"	' BlitzMax NG
Include "transpiler/TTranspileCPP.bmx"			' C++
Include "transpiler/TTranspileJava.bmx"		' Java
'Include "src/TTranspileJavaScript.bmx"	' HTML/JavaScr

'	DELIVERABLES
Include "bin/TSymbolTable.bmx"
Include "bin/TLanguageServerVisitor.bmx"

'Include "bin/TException.bmx"
'Include "bin/TToken.bmx"


'	TYPES AND FUNCTIONS

Function Publish:Int( event:String, data:Object=Null, extra:Object=Null )
    Print "---> "+event + "; "+String( data )
End Function

		
Function test_file:Int( filepath:String, verbose:Int=False )
	Local source:String, lexer:TLexer, parser:TParser
	Local start:Int, finish:Int
	Local ast:TASTNode
	Local transpile:String = StripExt( filepath ) + ".transpile"

	Try		
		' 	Delete transpile file if it exists from previous run
		If FileType( transpile ) ; DeleteFile( transpile )
		
		'	Next we load and parse BlitzMax
		Print "STARTING BLITZMAX PARSER:"
		source = loadFile( filepath )
		'source = loadFile( "samples/1) Simple Blitzmax.bmx" )
		lexer  = New TBlitzMaxLexer( source )
	'DebugStop
		parser = New TBlitzMaxParser( lexer )
		start  = MilliSecs()
'DebugStop
		ast    = parser.parse_ast()
		finish = MilliSecs()
		Print( "BLITZMAX LEXER+PARSE TIME: "+(finish-start)+"ms" )

		' SHOW AST STRUCTURE
		Print "~nAST STRUCTURE:"
		Print "------------------------------------------------------------"
DebugStop
		Print ast.reveal()
		Print "------------------------------------------------------------"
		
		' SHOW AST STRICTURE
		Print "~nLANGUAGE SERVER:"
		Print "------------------------------------------------------------"
		Local langserv:TLanguageServerVisitor = New TLanguageServerVisitor( ast )
		Print langserv.getOutline( StripDir(filepath) )
		Print "------------------------------------------------------------"

		' Pretty print the AST back into BlitzMax (.transpile file)
		If Not ast
			Print "Cannot transpile until syntax corrected"
			Return False
		End If

		Print "~nTRANSPILE AST TO BLITZMAX:"	

		Local blitzmax:TTranspileBlitzMax = New TTranspileBlitzMax( ast )
'DebugStop
		source = blitzmax.run()
		Print "------------------------------------------------------------"
		Print source
		Print "------------------------------------------------------------"

		' Pretty print the AST into C++
		Print "~nTRANSPILE AST TO C++:"
		
		Local cpp:TTranspileCPP = New TTranspileCPP( ast )
		source = cpp.run()
		Print "------------------------------------------------------------"
		Print source
		Print "------------------------------------------------------------"
		
		' Pretty print the AST into Java
		Print "~nTRANSPILE AST TO Java+:"
		
		Local java:TTranspileJava = New TTranspileJava( ast )
		source = java.run()
		Print "------------------------------------------------------------"
		Print source
		Print "------------------------------------------------------------"

		
		Return True
		
	Catch e:Object
		Local exception:TException = TException( e )
		Local blitzexception:TBlitzException = TBlitzException( e )
		Local runtime:TRuntimeException = TRuntimeException( e )
		Local text:String = String( e )
		Local typ:TTypeId = TTypeId.ForObject( e )
		If exception Print "## Exception: "+exception.toString()+" ##"
		If blitzexception Print "## BLITZ Exception: "+blitzexception.toString()+" ##"
		If runtime Print "## Exception: "+runtime.toString()+" ##"
		If text Print "## Exception: '"+text+"' ##"
		Print "TYPE: "+typ.name
DebugStop
		Return False
	End Try

End Function

Function test_folder:Int( folder:String, verbose:Int=False )
	folder = StripSlash( folder )
	Local dir:String[] = LoadDir( folder )
	Print "~nTESTING FILES IN "+folder
	
	For Local filepath:String = EachIn dir
		If FileType(folder+"/"+filepath)=FILETYPE_FILE And ExtractExt(folder+"/"+filepath)="bmx"
			Print StripDir(filepath)+" - TESTING"
			If test_file( folder+"/"+filepath, verbose )
				Print StripDir(filepath)+" - SUCCESS"
			Else
				Print StripDir(filepath)+" - FAILURE"
			End If
		Else
			Print StripDir(filepath)+" - SKIPPED"
		End If
	Next
	
End Function

Local verbose:Int = True

' 	MAIN TESTING APPLICATION

test_file( "samples/test.bmx", verbose )


'test_file( "samples/framework.bmx", verbose )
'test_file( "samples/hello world strict.bmx", verbose )
'test_file( "samples/hello world.bmx", verbose )
'test_file( "samples/function.bmx", verbose )
'test_file( "samples/capabilities.bmx", verbose )

'test_file( "samples/blocks.bmx", verbose )
'test_file( "samples/nested blocks.bmx", verbose )

'test_folder( "samples/", verbose )
'test_folder( "samples/", verbose )

