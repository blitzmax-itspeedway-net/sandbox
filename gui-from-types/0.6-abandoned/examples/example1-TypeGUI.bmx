SuperStrict

'	TYPEGUI
'	Author: Si Dunford [Scaremonger], June 2023
'	Contributions from:
'		@GW		(Discord)
'		@mingw	(Discord)
'
'	Version 0.5

Include "../typegui.0-6.bmx"

AppTitle = "Example #1 - Type GUI"

' This is going to be our GUI Form:

Type TExample Implements IForm ..
	{ ..
		title="Candy Shop" ..
	}

	Field Name:String		{Type="textbox" label="Name" length=10}
	'Field Password:String	{type="password"}
	Field notshown:String
	Field Payment:Int = 1	{Type="radio" options="Cash,Card" disabled}
	Field Over18:Int = True	{Type="checkbox" label="Over 18?"}

'	Field sep:String		{Type="separator" }
	
	Method onGui( event:Int, widget:TWidget, data:Object )
	
		Select event
		Case EVENT_MOUSEENTER
		Case EVENT_MOUSELEAVE
		Case EVENT_WIDGETCLICK
			'DebugStop
			Select Lower(widget.GetName())
			Case "btnok"
				Local form:TForm = TForm( data )
				Local fld:TWidget
				
				'DebugStop

				' Update self with form details
				fld = form.getWidgetByName( "fldName" )
				If fld; name=fld.getString()

				fld = form.getWidgetByName( "fldPayment" )
				If fld; payment=fld.getInt()

				fld = form.getWidgetByName( "fldOver18" )
				If fld; over18=fld.getInt()
				
' QUESTION:
' Should we let the programmer update
' data or should the fields update the underlying Type data

				Print "- USERNAME: "+name
				'Print "- PASSWORD: "+password
				Print "- PAYMENT:  "+payment
				Print "- OVER18?:  "+TForm.iif(Over18,"YES","NO")

			Case "btncancel"
				Local form:TForm = TForm( data )
				' You may want to quit() the dialog or something...
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
		
	End Method
	
End Type

Graphics 400,300

Local myform:TExample = New TExample()
myform.name = "Scaremonger"

DebugStop
Local form:TForm = New TForm( myform )	', 10,10 )
form.addButtons( ["OK","CANCEL"] )

Repeat
	SetClsColor( $33,$7a,$ff )
	Cls

	form.show()

	Flip
Until KeyHit( KEY_ESCAPE ) Or AppTerminate()

