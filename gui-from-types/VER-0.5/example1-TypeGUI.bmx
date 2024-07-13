SuperStrict

'	TYPEGUI EXAMPLE 1
'	Author: Si Dunford [Scaremonger], June 2023
'	Contributions from:
'		@GW		(Discord)
'		@mingw	(Discord)
'
'	Version 0.5, 7 JUN 2023

Import "typegui-05.bmx"

AppTitle = "Example #1 - Type GUI"

' This is going to be our GUI Form:

Type TExample Implements IForm ..
	{..
	title="Candy Shop" ..
	pos="25,25"..
	padding=4 ..
	margin=5 ..
	}

	Field Name:String		{textbox label="Name" Length=10}
	'Field Password:String	{password}
	Field notshown:String
	Field Payment:Int = 0	{radio="Cash,Card" disabled}
	Field Over18:Int		{checkbox label="Over 18?"}

	Field sep:String		{ separator }
	
	Field ok:String = "TEST" 	{button}
	Field btn:String[] = ["OK","CANCEL"] 	{button}
	
	'Method New()
	'End Method
	
	Method onGUI( form:TForm, fld:TFormField )
		Print( "onGUI() -> "+fld.fldName )

		'If fld.fldName = "Gender" Then fld.value = TForm.iif(fld.value<>"","","X")
		
		Print "- USERNAME: "+name
		'Print "- PASSWORD: "+password
		Print "- PAYMENT:  "+payment
		Print "- OVER18?:  "+TForm.iif(Over18,"YES","NO")
	End Method
	
End Type

Graphics 400,300

Local myform:TExample = New TExample()

'DebugStop
Local form:TForm = New TForm( myform )	', 10,10 )
'form.setPalette( PALETTE_BLUE )

Repeat
	SetClsColor( $ff,$ff,$ff )
	Cls

	form.show()	'True )

	Flip
Until KeyHit( KEY_ESCAPE ) Or AppTerminate()

