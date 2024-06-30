SuperStrict

'	Manual GUI with Image template
'	Author: Si Dunford [Scaremonger], June 2023

Import "typegui.bmx"

AppTitle = "Example #4 - Image Template"

Print
Print " ## IN DEVELOPMENT"
Print " ## Not currently working or operational"
Print

Graphics 400,300

'	Create a sample form
DebugStop
Local form:TForm2 = New TForm2()
'form.setPalette( PALETTE_BLUE )
form.add( New TLabel( "Label" ) )
form.add( New TButton( "Button" ) )
form.add( New TTextBox( "TextBox" ) )
form.add( New TLabel( "Label" ) )
form.add( New TSlider( 15, 2 ) )
form.center()	' Center the form
form.pack()		' Resize to minimum (Uses layout manager)

' Apply a graphics template

New TImageRenderer( "gamegui.png" )

Type TImageRender

	Field template:TImage
	Field frameW:Int, frameH:Int

	Method New( filename:String, w:Int=5, h:Int=5 )
		template = LoadAnimImage( filename, width, height, 0, 9 )
		frameW = w
		frameH = h
		TButton.renderer = _TButton
	End Method
	
	Function _TButton( this:TWidget, ofsX:Int, ofsY:Int )
		DrawImage(     template, this.x,                   this.y, 0 )	' TOP LEFT
		DrawImageRect( template, this.x+frameW,            this.y,                     this.w-frameW*2, this.frameH,     1 )	' TOP CENTER		
		DrawImage(     template, this.x+this.width-frameW, this.y, 2 )	' TOP RIGHT
		DrawImageRect( template, this.x,                   this.y+frameH,              frameW,          this.h-frameH*2, 3 )	' MIDDLE LEFT
		DrawImageRect( template, this.x+frameW,            this.y+frameH,              this.w-frameW*2, this.h-frameH*2, 4 )	' CENTER
		DrawImageRect( template, this.x+this.width-frameW, this.y+frameH,              frameW,          this.h-frameH*2, 5 )	' MIDDLE RIGHT
		DrawImage(     template, this.x,                   this.y+this.height-frame.H, 6 )	' BOTTOM LEFT
		DrawImageRect( template, this.x+frameW,            this.y+this.height-frame.H, this.w-frameW*2, this.frameH,     7 )	' BOTTOM CENTER
		DrawImage(     template, this.x+this.width-frameW, this.y+this.height-frame.H, 8 )	' BOTTOM RIGHT
	End Function
	
End Type

Repeat
	SetClsColor( 0,0,0 )
	Cls

	DebugStop
	GUI.show()	'True )

	Flip
Until KeyHit( KEY_ESCAPE ) Or AppTerminate()

