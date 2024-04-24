SuperStrict
Graphics 350,200

Local X:Int = 175
Local Y:Int = 100
Local speed:Float = 2.0

Repeat
	Cls
	DrawRect( x, Y, 10, 10 )
	x = x + (speed * KeyDown(KEY_RIGHT) * (x<338) ) - (speed * KeyDown(KEY_LEFT) * (x>speed) )
	y = y + (speed * KeyDown(KEY_DOWN) * (y<188) )  - (speed * KeyDown(KEY_UP) * (y>speed) )
	Flip
Until KeyHit( KEY_ESCAPE )