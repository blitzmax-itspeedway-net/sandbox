
'Module bmx.console

' Linux based on information found here:
' https://viewsourcecode.org/snaptoken/kilo/02.enteringRawMode.html

Import BRL.StandardIO
Import brl.retro		' Hex()

?Linux
  Import "linux/console_linux.bmx"
  'Import "linux/termios.bmx"
?raspberrypi
?win32
?

Global Console:TConsole



Const KEY_CTRL:Int = $1f
Const KEY_LOWER:Int = $20
Const KEY_Q:Int = $51

?win32
Type TWindowsConsole Extends TConsole
	
	Method New()
	End Method
	
End Type
?


?linux
	Console = TLinuxConsole.get()
?win32
	Console = TWindowsConsole.get()
?

' Identifies if a key characters is a control character
Function isCtrl:Int( ch:Int )
	Return( ch<32 Or ch=127 )
End Function

' Get keycode when CTRL pressed
Function CTRL:Int( ch:Int )
	Return( ch & $1f )
End Function