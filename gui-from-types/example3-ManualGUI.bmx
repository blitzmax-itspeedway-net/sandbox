SuperStrict

'	Manual GUI
'	Author: Si Dunford [Scaremonger], June 2023
'	Contributions from:
'		@GW		(Discord)
'		@mingw	(Discord)

Import "typegui.bmx"

AppTitle = "Example #3 - Manual GUI"

' Draw a GUI manually

Graphics 400,300

DebugStop
Local form:TForm = New TForm()
'form.setPalette( PALETTE_BLUE )
'form.setsize( 200, 200 )

DebugStop

print
Print " ## IN DEVELOPMENT"
Print " ## Not currently working or operational"
Print

'Local root:TFormField = New form.getRoot()
'root.setLayout( New TBoxLayout() )

form.add( form.MakeLabel( "ONE" ) )
form.add( form.MakeLabel( "TWO" ) )
form.add( form.MakeLabel( "THREE" ) )
form.add( form.MakeLabel( "FOUR" ) )
form.add( form.MakeLabel( "FIVE" ) )
'form.pack()

Repeat
	SetClsColor( $ff,$ff,$ff )
	Cls

	DebugStop
	form.show()	'True )

	Flip
Until KeyHit( KEY_ESCAPE ) Or AppTerminate()

