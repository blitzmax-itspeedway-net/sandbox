
Import "console_linux.c"
Import "../TConsole.bmx"

Extern
	' Local Flags
	'Function get_lflag:Int()
	'Function set_lflag( value:Int )
	' Input flags
	'Function get_iflag:Int()
	'Function set_iflag( value:Int )
	' Output flags
	'Function get_oflag:Int()
	'Function set_oflag( value:Int )
	' Control flags
	'Function get_cflag:Int()
	'Function set_cflag( value:Int )
	'
	Function StdInRead:Int()
	Function StdOutWrite( text:Byte Ptr, size:Int )
	Function enableRawMode()
	Function disableRawMode()
	
	Function getWindowSize:Int( x:Int Var, y:Int Var )

End Extern

'	INITIALISE THE LINUX CONSOLE
TConsole.instance = New TLinuxConsole()

Print "STARTING"

?linux
Type TLinuxConsole Extends TConsole
	
'	Field lflag:Int, cflag:Int, iFlag:Int, oFlag:Int

	Function shutdown()
		If instance
			instance.showcursor()
			instance.flush()
		End If
		disableRawMode()
	End Function
		
	Method Open:Int()
	
		Local result:Int = enableRawMode()
		OnEnd( TLinuxConsole.Shutdown )
		Return result

	End Method
	
	Method getkey:Int()
		Return StdInRead()
	End Method

	' Read a device status report from the datastream
	Method DSR:String( terminator:Int )
		Local result:String
		Local ch:Int
		Repeat
			ch = getkey()
			result :+ Chr( ch )
		Until ch = terminator Or ch = 0
		Return result
	End Method

	Method getCursorPos:TPos()
		write( ESC+"[6n" )
		Local result:String = DSR( Asc("R") )	' Get Device Status Report: <esc>[<height>;<width>R
		'Print( "DSR="+result.Replace(ESC,"ESC") )
		Local data:String[] = result[2..].split(";")
		Return New TPos( Int(data[0]), Int(data[1]) )
	End Method
	
	Method getWindowSize:TPos()
		If getwindowsize( size.y, size.x ) = 0
			Return size
		End If
		' Using IOCTL is unreliable on some systems so we fall-back to
		' ANSI by moving the cursor to the right then to the end
		write( ESC+"[999C"+ESC+"[999B" )
		Return getCursorPos()
	End Method
	
	' Write the screen and reset the buffer for next frame
	Method Flip()
		StdOutWrite( frame.toCString(), Len(frame) )
		frame = ""
	End Method
		
End Type
?



