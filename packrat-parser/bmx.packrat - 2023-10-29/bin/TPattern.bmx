
Type TPattern

	Field kind:Int = KIND_NONE
	Field name:String = "NONAME"
	Field hidden:Int = False			' Used to hide core rules

	Field patterns:TPattern[] = []

	Method match:TParseNode( text:String, pos:Int=0, tab:String="" ) Abstract
	
	Method success:TParseNode()
		Return New TParsenode( True )
	End Method

	Method success:TParseNode( text:String, start:Int, finish:Int, children:TParseNode[]=[] )
		Return New TParsenode( Self, kind, text, start, finish, children )
	End Method
	
	Method failure:TParseNode()
		Return New TParsenode( False )
	End Method

	Method AsString:String()
		Return TTypeId.forobject( Self ).name()+"{"+name+"}"
	End Method

	Method getid:String()
		Local id:String = name
		If name=""; id="<noname>"
		Return TTypeId.forobject( Self ).name()+"{"+id+"}"
	End Method

	Method save:JSON() Abstract

	' Writes the expression as PEG
	Method PEG:String() Abstract
	
EndType

'Interface IPattern
'	Method match:TParseNode( text:String, pos:Int=0, tab:String="" )
'	Method AsString:String( )
'	Method getID:String()
'	Method save:JSON()
'	Method PEG:String()
'End Interface

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

Rem
Function debugline:TDebug( pattern:TPattern, text:String, start:Int, finish:Int=0 )
	Local line:String
	If finish=0
		line = text[ start..(start+13)]+".. "
	Else
		line = text[ start..finish ][..15]+" "
	End If
	'Local name:String = TTypeId.forobject( pattern ).name()
	Local name:String = pattern.getid()
	If Len(name)<15; name = name[..15]
	Return New TDebug( line + name )
End Function

Type TDebug
	Const MINIMUM:Int = 15
	
	Global DEBUGGER:Int = False
	
	Field base:String
	Field line:String

	Method New( base:String )
		Self.base = base
	End Method
	
	Function enable()
		DEBUGGER = True
	End Function
	
	Function disable()
		DEBUGGER = False
	End Function
	
	Method reset()
		line = ""
	End Method

	Method reset( text:String )
		line = ""
		add( text )
	End Method

	Method reset( lines:String[] )
		line = ""
		add( lines )
	End Method
	
	Method add( text:String )
		If Len(text) < MINIMUM; text = text[..MINIMUM]
		line :+ cleanse(text) + " "
	End Method

	Method add( lines:String[] )
		For Local text:String = EachIn lines
			add( text )
		Next
	End Method
	
	Method echo()
		If DEBUGGER; Debug base+" "+line
	End Method

	Method echo( text:String )
		add( text )
		If DEBUGGER; Debug base+" "+line
	End Method

	Method echo( lines:String[] )
		add( lines )
		If DEBUGGER; Debug base+" "+line
	End Method
	
EndType
EndRem





