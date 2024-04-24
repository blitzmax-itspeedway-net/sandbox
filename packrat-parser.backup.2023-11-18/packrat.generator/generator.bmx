'   Packrat Parser Generator
'   (c) Copyright Si Dunford, MMM 2022, All Rights Reserved. 
'   VERSION: 1.0

'   CHANGES:
'   08 NOV 2023  Initial Creation
'

SuperStrict

Import text.format	' Used to format version numbers
Import text.regex	' Used by parser generator to perform keyword replacements

'Import bmx.packrat
Import "../packrat.parser/parser.bmx"

'Import bmx.visitor
'Import "../bmx.visitor/visitor.bmx"

'Include "bin/Compound.bmx"
'Include "bin/Constants.bmx"
'Include "bin/Exceptions.bmx"
'Include "bin/Extensions.bmx"
'Include "bin/Functions.bmx"
'Include "bin/Operators.bmx"
'Include "bin/Visitors.bmx"

'Include "bin/TGrammar.bmx"
'Include "bin/TParseNode.bmx"
'Include "bin/TParseTree.bmx"
'Include "bin/TParser.bmx"
'Include "bin/TPackrat_Parser.bmx"
'Include "bin/TPackrat_PEG_Parser.bmx"
'Include "bin/TPattern.bmx"
Include "bin/TParserGenerator.bmx"
'Include "bin/TMemoisation.bmx"
'Include "bin/TTextDocument.bmx"

Const VERSION:String   = "1.0"
Const GENERATOR:String = "Packrat Parser Generator for BlitzMax"
Const WEBLINK:String   = "https://github.com/blitzmaxmods/bmx.packrat/wiki"

