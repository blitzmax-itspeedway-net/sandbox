SuperStrict

'
'	Console Library for BlitzMax
'	(c) Copyright Si Dunford [Scaremonger], May 2025
'

Framework brl.standardio
Import "../bmx.console/import.bmx"
Import "lib/debugtools.bmx"

' Create a console object
Local console:TConsole = New TConsole()

Print "SCREEN: "+ console.width() + ", "+ console.height()

?linux
Print
Print "TERMCAPS:"

For Local CAP:TERMCAPS = EachIn TERMCAPS.values()
	Print CAP.ToString()+":  "+debugstring(console.cmd[CAP])
Next

?





