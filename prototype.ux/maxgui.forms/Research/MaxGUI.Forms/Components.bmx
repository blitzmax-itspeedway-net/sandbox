'# MaxGUI driver
'#
'# Version 1.0

'############################################################
Type GComponent Extends GGadget Abstract
Field gad:TGadget
End Type

'############################################################
Type GContainer Extends GComponent
Field children:TList = New TList
	'------------------------------------------------------------
	'# Add a component to this container
	Method addChild( C:GComponent )
		C.link = ListAddLast( children, C )
	End Method
End Type

'############################################################
Type GWindow Extends GContainer
End Type

Rem 
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
			Return CreateWindow( this.caption, this.x, this.y, this.width, this.height, parent, this.style )
		Case "LABEL"
			Return CreateLabel( this.caption, this.x, this.y, this.width, this.height, this.parent._gadget, this.style )
		Case "PASSWORD"
			Return CreateTextField( this.x, this.y, this.width, this.height, this.parent._gadget, TEXTFIELD_PASSWORD )
		Case "TEXTBOX"
			Return CreateTextField( this.x, this.y, this.width, this.height, this.parent._gadget, 0 )
		Case "BUTTON"
			this.style = BUTTON_PUSH
			If this.command = -1 Then this.style :| BUTTON_OK
			If this.command = -1 Then this.style :| BUTTON_CANCEL
			Return CreateButton( this.caption, this.x, this.y, this.width, this.height, this.parent._gadget, this.style )
		Default
Print "UNSUPPORTED OBJECT TYPE: " + this.Component
			Return Null
		End Select	
	End Method

	'------------------------------------------------------------
	Method StatusText( gadget:TGadget, text:String )
		SetStatusText( gadget, text )
	End Method
	
End Type

end rem