SuperStrict

'	TYPEGUI
'	Author: Si Dunford [Scaremonger], June 2023
'	Contributions from:
'		@GW		(Discord)
'		@mingw	(Discord)
'	Version 0.2, 3 JUN 2023

Import "typegui-02.bmx"

' This is going to be our GUI Form:

Type TExample Implements IForm {title="Example"}

	Field Username:String	{textbox label="User Name" Length=10}
	Field Password:String	{password}
	Field test:String
	Field Gender:Int = 0	{radio="Male,Female"}
	Field Over18:Int		{checkbox label="Over 18?"}
	
	Field ok:String = "OK" 	{button}
	
	Method New()
	End Method
	
	Method onGUI( fld:TFormField )
		Print( "onGUI() -> "+fld.fldName )
		'If fld.fldName = "Gender" Then fld.value = TForm.iif(fld.value<>"","","X")
		
		Print "- USERNAME: "+username
		Print "- PASSWORD: "+password
		Print "- GENDER:   "+gender
		Print "- OVER18?:  "+TForm.iif(Over18,"YES","NO")
	End Method
	
End Type

Graphics 400,300

Local myform:TExample = New TExample()

Local form:TForm = New TForm( myform )
form.setPalette( PALETTE_BLUE )

Repeat
	SetClsColor( $cc,$cc,$cc )
	Cls

	form.show()

	Flip
Until KeyHit( KEY_ESCAPE ) Or AppTerminate()
