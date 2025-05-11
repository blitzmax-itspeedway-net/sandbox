SuperStrict

'
'	Console Library for BlitzMax
'	(c) Copyright Si Dunford [Scaremonger], May 2025
'

Framework brl.standardio
Import brl.retro	' hex()

Import "../bmx.console/import.bmx"

Local console:TConsole = New TConsole()


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




