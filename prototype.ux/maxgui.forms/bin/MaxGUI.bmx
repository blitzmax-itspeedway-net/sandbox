'# MaxGUI Object Factory
'#
'# 

'############################################################
Type TFormDriver
	'------------------------------------------------------------
	'# Object Factory
	Method GenerateObject:TGadget( this:TElement, parser:TFormParser ) Abstract

	'------------------------------------------------------------
	'# Compatability methods
	Method StatusText( gadget:TGadget, text:String ) Abstract

End Type

'############################################################
Type TFormDriverMAXGUI Extends TFormDriver

	'------------------------------------------------------------
	'# Object Factory
	Method GenerateObject:TGadget( this:TElement, parser:TFormParser )
	Local gadname$ = Upper( parser.translate( this.component ) )
	Local style%
'DebugStop
		Select gadname
		Case "WINDOW"
			Local parent:TGadget
			If this.parent Then parent = this.parent._gadget
			this.style = WINDOW_HIDDEN
			If this.titlebar = 1 Then this.style :| WINDOW_TITLEBAR
			If this.titlebar = 2 Then this.style :| WINDOW_TOOL
			If this.resize Then this.style :| WINDOW_RESIZABLE
			If this.menu Then this.style :| WINDOW_MENU
			If this.status Then this.style :| WINDOW_STATUS
			If this.center Then this.style :| WINDOW_CENTER
			If this.dragdrop Then this.style :| WINDOW_ACCEPTFILES
			Return CreateWindow( this.caption, this.x, this.y, this.width, this.height, parent, WINDOW_CLIENTCOORDS|this.style )
		Case "LABEL"
			If this.height<0 Then this.height = 22
			If this.width<0 Then this.width = 50
			Return CreateLabel( this.caption, this.x, this.y, this.width, this.height, this.parent._gadget, this.style )
		Case "PASSWORD"
			If this.height<0 Then this.height = 22
			If this.width<0 Then this.width = 100
			Return CreateTextField( this.x, this.y, this.width, this.height, this.parent._gadget, TEXTFIELD_PASSWORD )
		Case "TEXTBOX"
			If this.height<0 Then this.height = 22
'DebugStop
			If this.width<0 And this.parent Then this.width :+ this.parent.width - this.x
			Return CreateTextField( this.x, this.y, this.width, this.height, this.parent._gadget, 0 )
		Case "BUTTON"
			this.style = BUTTON_PUSH
			If this.y<0 Then this.y :+ this.parent.height 
			If this.x<0 Then this.x :+ this.parent.width			
			If this.height<0 Then this.height = 22
			If this.width<0 Then this.width = 75
			If this.command = -1 Then this.style :| BUTTON_OK
			If this.command = -1 Then this.style :| BUTTON_CANCEL
			Return CreateButton( this.caption, this.x, this.y, this.width, this.height, this.parent._gadget, this.style )
		Case "PANEL"
			this.style = this.border
'			If this.active Then this.style :| PANEL_ACTIVE
			If this.height<0 Then this.height :+ this.parent.height - this.y 
			If this.width<0 Then this.width :+ this.parent.width - this.x 
			Return CreatePanel( this.x, this.y, this.width, this.height, this.parent._gadget, this.style, this.caption )
		Default
		
			'# Using Reflection, check if type exists and if it does, create it.
		
		
Print "UNSUPPORTED OBJECT TYPE: " + this.Component
			Return Null
		End Select	
	End Method

	'------------------------------------------------------------
	Method StatusText( gadget:TGadget, text:String )
		SetStatusText( gadget, text )
	End Method
	
End Type