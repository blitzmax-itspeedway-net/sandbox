'# MESSAGES WINDOW
'# VERSION 1.0
'#
'# CURRENTLY THIS IS PURE MAXGUI - LATER IT WILL BE FORMS
'#
Global MsgForm:TMsg_Form = New TMsg_Form.Create()


Const TEXTFORMAT_STYLE% = $0F
Const TEXTFORMAT_RED% = $10
Const TEXTFORMAT_GREEN% = $20
Const TEXTFORMAT_BLUE% = $40
Const TEXTFORMAT_WHITE% = $70
Const TEXTFORMAT_BLACK% = $00

'############################################################
Function MessageQueue( text:String, options:Int = 0 )
	msgform.writeln( text, options )
End Function

'############################################################
Type TMsg_Form Extends TGadget_Form
Field textarea:TGadget

	'------------------------------------------------------------
	Method New()
	AddHook( EmitEventHook, EventHook, Self )
	End Method
	
	'------------------------------------------------------------
	Method Delete()
	RemoveHook( EmitEventHook, EventHook, Self )
	End Method
	
	'------------------------------------------------------------
	Method Create:TMsg_Form()
	Local x:Int = 0
	Local y:Int = ClientHeight( Desktop() )-100
	Local w:Int = GadgetWidth( Desktop() )
	Local h:Int = 100
	Local s:Int = WINDOW_TITLEBAR | WINDOW_TOOL | WINDOW_RESIZABLE
		'# WINDOW
		win  = CreateWindow( "Messages", x,y,w,h, Null, s )
		name = "MsgForm"
		'# SCROLLING TEXT AREA
		textarea = CreateTextArea( 0, 0, w, h, win, TEXTAREA_WORDWRAP | TEXTAREA_READONLY )
	Return Self
	End Method

	'------------------------------------------------------------
	'# Only ever hide the toolbox windows.
	Method onWindowClose:Int( event:TEvent )
		If event.source<>win Then Return False
'		HideGadget( win )
'		Return True
		Return False
	End Method

	'------------------------------------------------------------
	Method WriteLn( text:String, options:Int = TEXTFORMAT_BLACK )
	Local start:Int = TextAreaLen( textarea )
	Local r:Int, g:Int, b:Int, style:Int
		AddTextAreaText( textarea, text )
		'#
		If options = 0 Then Return
		style = options & TEXTFORMAT_STYLE
		If (options & TEXTFORMAT_RED) Then r=$FF
		If (options & TEXTFORMAT_GREEN) Then g=$FF
		If (options & TEXTFORMAT_BLUE) Then B=$FF
		'# Select Newly added text
'		SelectTextAreaText( textarea, start, Len(text) )
		FormatTextAreaText( textarea, r, g, b, style, start ) 
	End Method
	
End Type
	
	



