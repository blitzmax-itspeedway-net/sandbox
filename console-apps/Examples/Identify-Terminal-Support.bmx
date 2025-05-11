SuperStrict

' https://www.gnu.org/software/termutils/manual/termcap-1.3/html_chapter/termcap_2.html
' https://linux.die.net/man/3/tgetent

' PRE-REQUISITES:
' Linux:
'
'  sudo apt-get install libncurses5-dev libncursesw5-dev

' NEED TO TEST IF I CAN CAPTURE SYSTEMS WITHOUT THIS
' Uninstall the above after it is working and see what can be done.

Framework brl.standardio
Import brl.retro	' hex()

Import "../bmx.console/import.bmx"

' Command constants
'Const CC_CL:Int = 0
'Const CC_CM:Int = 1
'Const CC_AM:Int = 2



Local console:TConsole = New TConsole()

' Get Terminal Control Codes
'Local 

Local x:Float = 0
Local dx:Float = 0.1

console.Cls()

console.write( 0,0,"MENU" )
'console.SetColor( console.GREEN )

Repeat

	Local y:Int = console.height()/2
	console.write( x, y, " " )
	x :+ dx
	If x>=console.width() ; dx = -dx
	If x<=0 ; dx = -dx
	
	console.write( x, y, "O" )

	console.Update()
	
	console.onMouseclick()
	console.Flip()
Until False




