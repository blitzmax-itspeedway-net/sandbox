'   NAME
'   (c) Copyright Si Dunford, MMM 2022, All Rights Reserved. 
'   VERSION: 1.0

'   CHANGES:
'   DD MMM YYYY  Initial Creation
'
SuperStrict

'Module bmx.peg-compiler

'Import bmx.pnode
Import "../bmx.pnode/pnode.bmx"

'Import bmx.packrat
Import "../bmx.packrat/packrat.bmx"

'Import bmx.transpiler
Import "../bmx.transpiler/transpiler.bmx"

' TEST USING MANUAL (DEV) PARSER
Import "../bmx.peg-parser/bin/TPackrat_PEG_Parser_DEV.bmx"
DebugStop
Local Parser:TPackrat_Parser = New TPackrat_PEG_Parser_DEV()
Local PEGA:String = Parser.grammar.toPEG()

' INFINATE LOOP HERE:
DebugStop
Local Tree:TParseTree = Parser.parse( PEGA )
' *******************

Local PEGB:String = ParseTree2PEG( Tree )

Function ParseTree2PEG:String( tree:TParseTree )
	Local compiler:TPEGCompiler = New TPEGCompiler( tree.getroot() )
	Return compiler.run()
End Function

Type TPEGCompiler Extends TTranspiler	'Visitor

	' ABSTRACT METHODS

'	Method visit_program:String( arg:TVisitorArg ) 'node:TASTCompound, indent:String="" )
'DebugStop
'		Local text:String = header()
'		text :+ visitChildren( arg.node, "visit", "" )
'		Return text
'	End Method

'	Method visit_EOL:String( arg:TVisitorArg ) 'node:TASTNode, indent:String="" )
'		Return "~n"
'	End Method
	
End Type






