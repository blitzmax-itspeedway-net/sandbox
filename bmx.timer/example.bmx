SuperStrict

' This example uses a fliphook

Import "timers.bmx"

Graphics 800,600
TLowResTimer.UseFlipHook()	' Use Flip Hook

Const RESOLUTION:Int = 20

' Create some things
For Local x:Int = 0 Until GraphicsWidth() Step RESOLUTION*2
	For Local y:Int = 0 Until GraphicsHeight() Step RESOLUTION*2
		New TThing( x, y )
	Next
Next
 
Type TThing
	Global list:TList = New TList()
	Field x:Int, y:Int
	Field angle:Int = 0
	
	Method New( x:Int, y:Int )
		Self.x = x + 5
		Self.y = y + 5
		angle = Rand( 0, 360 )
		setInterval( Rand(100,1000), fn_rotate, Self ) 
		ListAddLast( list, Self )
	End Method
	
	Method rotate()
		angle = ( 360 + angle + 10 ) Mod 360
	End Method
	
	Method render()
		'DebugStop
		SetColor( $ff,0,0 )
		DrawLine( x,y, x+RESOLUTION*Cos(angle), y+RESOLUTION*Sin(angle) )
	End Method
	
	Function fn_rotate( context:Object )
		TThing( context ).rotate()
	End Function
End Type
 
Repeat
	Cls
	For Local thing:TThing = EachIn TThing.list
		thing.render()
	Next
	Flip
Until KeyHit( KEY_ESCAPE ) Or AppTerminate()