SuperStrict

'# Generate a Blitzmax Form from .lfm or 

Const CH_SPACE$ = ""
Const CH_LOWER$ = "abcdefghijklmnopqrstuvwxyz"
Const CH_UPPER$ = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
Const CH_NUMBER$ = "0123456789"
Const CH_ALPHA$ = CH_UPPER+CH_LOWER
Const CH_ALPHANUMERIC$ = CH_ALPHA+CH_NUMBER
Const CH_SYMBOL$ = Chr(34)+"!£$%^&*()_+-={}[]:@;'#<>?,./\|`¬"

Local filter$ = "Form Definition Files:lfm;All Files:*"
'Local filename$ = RequestFile( "Select Form definition file to open",filter$ )
Local filename$ = "unit3.lfm"
If Not filename Then End

Print filename

Global data:String = LoadText( filename )
Global dptr:Int = 1, lptr:Int = 1, cptr:Int = 1	'# Pointers
Global ch:String

DebugStop
'# Start off by creating a Window object...
New TDefWindow.Create()

'############################################################
Type TDataDef
Global data:String
'#
Field variable$

End Type

'############################################################
Type TDefWindow Extends TDataDef
Field caption$, x%, y%, w%, h%

	'------------------------------------------------------------
	Method Create:TDefWindow()
	Local ident$, sym$, key$, value$
		ident = GetNextIdentifier() 
		If Not Upper(ident) = "OBJECT" Then RuntimeError( "Bad file format" )
		'# Get variable name
		variable = GetNextIdentifier()
Print variable
DebugStop
		'# Ignore Colon and trailing identifier (as we will not use it)
		sym = GetNextSymbol()
		If Not sym=":" Then Error( ": expected" )
		ident = getNextIdentifier()
		
		'# Next follows KEY/VALUE pairs
		While Upper(ident)<>"END" And Upper(ident)<>"OBJECT"
			key = getNextIdentifier()
			If Not getNextSymbol() = "=" Then error "= expected"
			value = getNextIdentifier()
			Select Upper( key)
			Case "LEFT";	x=Int(value)
			Case "HEIGHT";	h=Int(value)
			Case "TOP";		y=Int(value)
			Case "WIDTH";	w=Int(value)
			Case "CAPTION";	caption = value
			End Select
		Wend
		
Print "local "+variable+"_style:Int = WINDOW_DEFAULT"
Print "Global "+variable+":TGadget = CreateWindow( "+Chr(34)+caption+Chr(34)+", "+x+", "+y+", "+w+", "+h+", Null, "+variable+"_style )"

DebugStop		
		While Upper(ident)="OBJECT"
			Print "yes"
		Wend
	End Method
End Type

'------------------------------------------------------------
Function getNextIdentifier$()
Local ident$
	IgnoreLeadingSpaces()
	If Not Instr( CH_ALPHA, ch ) Then error( "Bad Identifer" )	'# Identifiers must begin with a letter
	Repeat
		ident :+ ch
		ch = getNextChar()
	Until Not Instr( CH_ALPHANUMERIC+CH_SPACE, ch )
Return ident
End Function

'------------------------------------------------------------
Function getNextChar$()
'Local ch$ 
	dptr :+ 1
	ch = Mid( data, dptr, 1 )
'		cptr :+ 1
Return ch
End Function 

'------------------------------------------------------------
Function getNextSymbol$()
	IgnoreLeadingSpaces()
'	If Instr( CH_SYMBOL, ch ) Then error( "Symbol Expected" )
Return ch
End Function 

'------------------------------------------------------------
'# Leading spaces are dropped
Function IgnoreLeadingSpaces()
	While peekchar(" ")
		GetNextChar()
	Wend
End Function 

'------------------------------------------------------------
'# Forward-lookup of next character
Function peekChar%( expected$ )
Local ch$ = Mid( data, dptr, 1 )
Return (ch=expected)
End Function 

'------------------------------------------------------------
Function getTIdent()
DebugStop
Local ident$ 
While Instr( CH_ALPHA, Upper(ch) )
	ident :+ ch
	ch = getNextChar()
Wend
End Function 

'############################################################
Function Error( msg$ )
	Print( msg+ " at line "+lptr+", character "+cptr )
	End
End Function

