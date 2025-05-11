
'
'	Console Library for BlitzMax
'	(c) Copyright Si Dunford [Scaremonger], May 2025
'

Type TConsoleBase

	Field H:Int, W:Int

	
	Method Close(); End Method

	Method Cls()
	EndMethod
	
	Method ConsoleError( message:String )
		Print message
		End
	EndMethod

	Method height:Int()
		Return H
	EndMethod
Rem	
	Method onFocus( event:TEvent )
		Print "FOCUS"
		End
	End Method

	Method onKey( event:TEvent )
		Print "KEY"
		End
	End Method
	
	Method onMenu( event:TEvent )
		Print "MENU"
		End
	End Method
	
	Method onMouse( eevnt:TEvent )
		Print "MOUSE"
		End
	End Method
	
	Method onResize( event:TEvent )
		Print "RESIZE"
		End
	End Method
EndRem

	Method Update() Abstract

	Method width:Int()
		Return W
	EndMethod
	
	Method write( Text:String )
		WriteStdout( Text )
	End Method
	
	Method write( x:Int, y:Int, Text:String )
	End Method
	
	Method move( x:Int, y:Int )
	End Method
	
	Method home()
	End Method
	
End Type