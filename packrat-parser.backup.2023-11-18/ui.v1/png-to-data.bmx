' Converts a PNG cursor into data definitions

SuperStrict

Const COUNT:Int = 2
Const height:Int = 20
Const width:Int = 20

Local image:TPixmap = LoadPixmap( "cursors.png" )
Assert image, "cursors.png failed to load"

For Local frame:Int = 0 Until COUNT
	Local fx:Int = frame * width
	Print "DefData "+frame + "                     ' FRAME INDEX"
	For Local y:Int = 0 Until height
		Local line:String
		For Local x:Int = 0 Until width
			Local pixel:Int = ReadPixel( image, fx+x, y )
			'Print Hex(pixel)
			Select pixel
			Case $00000000;	line :+ "."		' Trasparent
			Case $FFFFFFFF; line :+ "*"		' White
			Case $FF000000; line :+ "#"		' Black
			Default
				line :+ "-"
			End Select
		Next
		Print "DefData "+Chr(34)+line+Chr(34)
	Next
Next




