
Import "const.bmx"

Type TConsole
	Global instance:TConsole
	
	Field frame:String
	Field size:TPos = New Tpos()
	
	'Field ScreenWidth:Int, ScreenHeight:Int
	
	Function Get:TConsole()
		Return instance
	End Function
	
	'Method on( event:Int, handler( event:TEvent ) )
	'End Method
	
	Method open:Int() Abstract 
	
	Method close:Int()
		If frame; write( frame )
	End Method
	
	Method getkey:Int() Abstract
	
	' Add text to the frame
	Method write( text:String )
		frame :+ text
	End Method
	
	' Reset the frame
	Method flush()
		If frame; write( frame )
		frame = ""
	End Method

	' Write the screen and reset the buffer for next frame
	Method Flip()
		flush()
	End Method

	' 	CLEAR THE SCREEN AND MOVE CURSOR TO TOP LEFT
	Method clearscreen()
		write( ESC+"[2J"+ESC+"[H" )		' CLEAR SCREEN / POSITION CURSOR
	End Method

	Method getCursorPos:TPos() Abstract
	Method getWindowSize:TPos() Abstract
	
	'	Move cursor to HOME (Top Left)
	Method home()
		write( ESC+"[H" )
	End Method
	
	Method hidecursor()
		write( ESC+"[?25l" )
	End Method
	
	Method showcursor()
		write( ESC+"[?25h" )
	End Method

	'	POSITION THE CURSOR
	Method pos( x:Int, y:Int )
		write( ESC+"["+Y+";"+X+"H" )
	End Method
	
End Type

Type Tpos
	Field x:Int
	Field y:Int
	Method New( x:Int, y:Int )
		Self.x = x
		Self.y = y
	End Method
End Type

