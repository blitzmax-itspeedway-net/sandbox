'
' In Application options; select "Build Console App"

'Framework bmx.console
Framework BRL.StandardIO
Import "bmx.console/console.bmx"

Global app:TApplication = New TApplication()

console.open()
'console.hidecursor()

Repeat
	
	app.update()
	app.render()
	
	'Delay(1)
	console.Flip()
	
Until app.quit

'console.showcursor()
console.close()
Print "CLOSED NORMALLY"

Type TApplication

	Field cursor:TPos = New TPos()
	Field quit:Int = False
	
	Method New()
		'console.hideCursor()
	End Method

	Method render()
		'console.clearScreen()
		
		Local size:TPos = console.getWindowSize()
		
		console.home()
		For Local row:Int = 1 Until size.y
			console.write( "~~"+ESC+"[K" )	' Clear to end of line
			If row < size.y; console.write( "~r~n" )
		Next
		console.pos( cursor.x, cursor.y )
		
	End Method

	Method update()
		Local key:Int = console.getkey()
		Select key
		Case 0
			Print "no-key"
		Case CTRL( Asc("q") )
			console.clearScreen()
			quit = True
		Case Asc("c")
			console.clearScreen()
		Case Asc("a")
			cursor.x = Max( 0, cursor.x-1 )
		Case Asc("w")
			cursor.y = Max( 0, cursor.y-1 )
		Case Asc("s")
			cursor.x = Min( console.size.x, cursor.x+1 )
		Case Asc("z")
			cursor.y = Max( console.size.y, cursor.y+1 )
		'Case Asc("d")
		'	app.drawscreen()
		Default
			Print Hex(key)+","+key
		End Select
	End Method
	
End Type