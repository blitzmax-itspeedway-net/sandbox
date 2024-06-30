SuperStrict

'	Manual GUI
'	Author: Si Dunford [Scaremonger], June 2023
'	Contributions from:
'		@GW		(Discord)
'		@mingw	(Discord)

'TODO: Cannot import the "library", why?

Include "../typegui.0-6.bmx"

DebugStop
AppTitle = "Example #3 - Manual GUI"
AppTitle = "TypeGUI 0.6 Testing"
Graphics 400,300
'DebugStop

Global form:TForm = New TForm()

Local title:TWIdget = form.add( "lbltitle", New TLabel( "Manual GUI" ) )
title.setclass( "title" )

form.add( "lblName", New TLabel( "Name:" ) )
form.add( "fldName", New TTextBox( "", "What is your name?" ) )

form.add( "chkEnable", New TCheckbox( "Enable", True ) )
form.add( "chkVisible", New TCheckbox( "Visible", True ) )

form.add( "lblSlider", New TLabel( "Amount:" ) )
form.add( "fldamount", New TSlider( 0, 15, 6 ) )

Local group:TGroup = TGroup( form.add( New TGroup() ) )
group.add( "radOne", New TRadioButton( "One", 1 ) )
group.add( "radTwo", New TRadioButton( "Two", 2 ) )
group.setValue( 2 )	' Radio buttons save value in parent

Local progress:TWidget 
progress = form.add( "proSeconds", New TProgressBar( 0,59,MilliSecs()/1000 ) )

' Button Panel
Local panel:TPanel = New TPanel()
'DebugStop
panel.setLayout( LAYOUT_HORIZONTAL )
panel.add( "btnOK", New TButton( "OK" ) )
panel.add( "btnCancel", New TButton( "CANCEL" ) )
'DebugStop
form.add( panel )
form.setHandler( onGUI )

'form.pack() ' Resize to fit
form.setSize( 200,150 )

Local dialog:TForm = Null
Repeat
	SetClsColor( $33,$7a,$ff )
	Cls
'DebugStop
	Local seconds:Int = MilliSecs()/1000
	Local minutes:Float = Float( seconds ) /60.0
	progress.setValue( seconds-Int(minutes)*60)

	'Show dialog .OR. message
	If dialog
		dialog = form.show( True )
	Else
		Local text:String = "Click to open dialog"
		DrawText( text, (GraphicsWidth()-TextWidth( text ))/2, (GraphicsHeight()-TextHeight( text ))/2 )

		If MouseDown(1)
			dialog = form
			dialog.unsetFlag( FLAG_HIDDEN )
		End If
	EndIf
	
	Flip
Until KeyHit( KEY_ESCAPE ) Or AppTerminate()

Function onGUI( event:Int, widget:TWidget, data:Object )
	Select event
	Case EVENT_MOUSEENTER
	Case EVENT_MOUSELEAVE
	Case EVENT_WIDGETCLICK
		Select Lower(widget.GetName())
		Case "chkenable"
			'DebugStop
			Local state:Int = widget.GetInt()
			Local fld:TWidget = form.getWidgetByName( "fldamount" )
			If fld; fld.setFlag( FLAG_DISABLED, Not state )
		Case "chkvisible"
			'DebugStop
			Local state:Int = widget.GetInt()
			Local fld:TWidget = form.getWidgetByName( "fldamount" )
			If fld; fld.setFlag( FLAG_HIDDEN, Not state )
		Case "btnok"
			form.quit()
		Case "btncancel"
			form.quit()
		Default
			Print( "ONGUI: ONCLICK ("+widget.GetName()+")" )		
		End Select
	'Case EVENT_WIDGETCHANGED	
	Default
		If widget
			Print( "ONGUI: "+TEvent.DescriptionForId( event )+" ("+widget.GetName()+")" )
		Else
			Print( "ONGUI: "+TEvent.DescriptionForId( event )+" (NULL)" )
		End If
	End Select
End Function