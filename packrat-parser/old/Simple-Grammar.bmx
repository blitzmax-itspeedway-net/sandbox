SuperStrict

' REMEMBER - MATCH START POSITION ARE ZERO-BASED

'Import packrat.parser
Import "../packrat.parser/parser.bmx"
Import "../packrat.functions/functions.bmx"

Import "../peg.parser/parser.bmx"

Import "../bin/TConfig.bmx"

Import "../gui/gui.bmx"

DebugStop
'tree.save( "examplecode/blitzmax.pac" ) ' Save a pakrat parser definition

' GET BLITZMAX GRAMMAR FROM PARSE TREE
Local blitzmax:TPackratParser = New TPackratParser( "BlitzMax" )
Local grammar:TGrammar = New TGrammar()
grammar = ExtractGrammar( tree )
blitzmax.setGrammar( grammar )



' USE BLITZMAX PARSER

title( "Blitzmax parser match" )
sourcecode = LoadString( "examplecode/1.bmx" )
Local ptree:TParseTree = blitzmax.parse( sourcecode, "blitzmax" ) 

title( "Other" )


