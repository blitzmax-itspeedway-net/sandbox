' PACKRAT PARSER MODULE FOR BLITZMAXNG
' (c) Copyright Si Dunford [Scaremonger], 2023-date, All rights reserved.
' VERSION 1.0
'
'Module bmx.packrat

Import text.regex	' Used by parser generator to perform keyword replacements
Import bmx.json

'Import bmx.visitor
Import "../bmx.visitor/visitor.bmx"

Include "bin/Compound.bmx"
Include "bin/Constants.bmx"
Include "bin/Extensions.bmx"
Include "bin/Functions.bmx"
Include "bin/Operators.bmx"
Include "bin/Visitors.bmx"

Include "bin/TGrammar.bmx"
Include "bin/TParseNode.bmx"
Include "bin/TParseTree.bmx"
Include "bin/TPackrat_Parser.bmx"
Include "bin/TPackrat_PEG_Parser.bmx"
Include "bin/TPattern.bmx"
Include "bin/TParserGenerator.bmx"
Include "bin/TMemoisation.bmx"

Global DEBUGGER:Int = False

Function debug( message:String )
?debug
	If DEBUGGER; Print( message )
?
End Function

Interface IViewable
	Method getChildren:IViewable[]()
	Method getText:String[]()
	Method getCaption:String()
End Interface

Type TPosition
	Field line:Int = 0
	Field col:Int = 0
	
	Method New( line:Int, col:Int )
		Self.line = line
		Self.col = col
	End Method
	
	Method format:String()
		Return "("+line+":"+col+")"
	End Method
	
End Type
