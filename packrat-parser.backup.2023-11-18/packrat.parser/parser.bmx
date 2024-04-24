' PACKRAT PARSER MODULE FOR BLITZMAXNG
' (c) Copyright Si Dunford [Scaremonger], 2023-date, All rights reserved.
' VERSION 1.0
'
'Module bmx.packrat

Import text.regex	' Used by parser generator to perform keyword replacements
'Import bmx.json

'Import bmx.pnode
Import "../packrat.pnode/pnode.bmx"

'Import bmx.visitor
Import "../bmx.visitor/visitor.bmx"

'Include "bin/Compound.bmx"
Include "bin/Constants.bmx"
'Include "bin/Exceptions.bmx"
Include "bin/Extensions.bmx"
'Include "bin/Functions.bmx"
Include "bin/Operators.bmx"
'nclude "bin/Visitors.bmx"

Include "bin/TGrammar.bmx"
Include "bin/TParseNode.bmx"
Include "bin/TParseTree.bmx"
'Include "bin/TParser.bmx"
Include "bin/TPackratParser.bmx"
'Include "bin/TPackrat_PEG_Parser.bmx"
Include "bin/TPattern.bmx"
'Include "bin/TParserGenerator.bmx"
Include "bin/TMemoisation.bmx"
Include "bin/TTextDocument.bmx"

'
Include "tools/ExtractGrammar.bmx"

Global DEBUGGER:Int = True

Function debug( depth:Int, doc:TTextDocument, start:Int, this:TPattern, optional:Object=Null, count:Int=0, total:Int=0 )
?debug
	If Not DEBUGGER; Return
	Local str:String, name:String, ptype:String
	name = this.name
	ptype = this.typeof()
	If name = ""; name = "(anon)"
	Local text:String = doc.content[ start..(start+4) ]+".. "
	text = text.Replace("~t","\t")
	text = text.Replace("~n","\n")
	text = text.Replace("~r","\r")
	str = Right("0000"+start,4)+" "+text+" "[..depth*2] + name + ":" + ptype
	If count>0 And total>0; str :+ "("+count+"/"+total+")" 
	'
	Local pattern:TPattern = TPattern( optional )
	Local message:String = String( optional )
	If pattern<>Null
		If pattern.name=""
			str :+ ", (anon)"
		Else
			str :+ ", "+pattern.name
		End If
		str :+ " <- " + pattern.PEG()
	ElseIf message <> ""
		str :+ ", "+ message
	End If
	Print( str )
?
End Function

Interface IViewable
	Method getChildren:IViewable[]()
	Method getText:String[]()
	Method getCaption:String()
End Interface

Rem
' Simple string cleanser to remove unDebugables.
Function Cleanse:String( text:String )
	'text = text.Replace( " ", "\s" )
	text = text.Replace( "~t", "\t" )
	text = text.Replace( "~n", "\n" )
	text = text.Replace( "~r", "\r" )
	Local result:String
'DebugStop
	For Local ch:Byte = EachIn text
		If ch>31 And ch<127
			result:+Chr(ch)
		Else
			result :+ "."
		EndIf
	Next
	Return result
End Function
EndRem

'Function escape_V1:String( text:String )
'	Local str:String 
'	For Local n:Int = 0 Until Len(text)
'		Local ch:Int = text[n..n+1]
'		Select True
'		Case ch=32;	str :+ "\s"
'		Case ch=34; str :+ "\q"
'		Case ch=33 Or ch>34 And ch<128
'			str :+ Chr(ch)
'		Case ch=09;	str :+ "\t"
'		Case ch=10;	str :+ "\n"
'		Case ch=13;	str :+ "\r"
'		Default
'			' This is an invalid character, so just drop it for now...
'		End Select
'	Next	
'	Return str
'End Function

Function escape:String( text:String )
	Local escaped:String	
	Local n:Int
	While n<text.length
		Local ch:Int = Asc(text[n..n+1])
		If ch=9 
			escaped :+ "\t"
		ElseIf ch=10
			escaped :+ "\n"
		ElseIf ch=13
			escaped :+ "\r"
		ElseIf ch<33 Or ch=92 Or ( ch>125 And ch<256 )
			escaped :+ "\x"+Hex(ch)[6..]
		ElseIf ch>256	'UNICODE
'TODO: Add full support for unicode
			DebugStop
			' THIS IS NOT TESTED - Should produce \uNNNN
			escaped :+ "\u"+Hex(ch)[4..]
			DebugStop		
		ElseIf ch=34
			escaped :+ "\q"
		Else
			escaped :+ Chr(ch)
		End If
		n:+1
	Wend
	Return escaped	
End Function

Function descape:String( text:String )
'TODO: Optimise and support unprintables

	DebugLog "DESCAPE() IS UNTESTED"
	DebugStop

	Local descaped:String
	Local n:Int
	While n<text.length
		Select text[n]
		Case "\"	' ESCAPED
DebugStop
			n:+1
			Select text[n..n+1]
			Case "\";	descaped :+ "\"
			Case "n";	descaped :+ "~n"
			Case "r";	descaped :+ "~r"
			Case "t";	descaped :+ "~t"
			Case "q";	descaped :+ "~q"
			Case Chr(34);	descaped :+ "~q"
			Case "x"
				descaped :+ Chr( Int( "$"+text[n..n+2] ) )
				n:+2
			Case "u"
				descaped :+ Chr( Int( "$"+text[n..n+4] ) )
				n:+4
			Default
				' Invalid encoded character, so ignore
			End Select
			n:+1
		Default
DebugStop
			descaped :+ text[n..n+1]
			n:+1
		End Select
	Wend
	Return descaped
End Function
