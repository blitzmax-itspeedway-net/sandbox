
'	Blitzmax Datetime functions
'	(c) Copyright Si Dunford [Scaremonger], Feb 2023, All rights reserved

SuperStrict

Import Pub.StdC

Type DateTime

	' Return number of seconds since the epoch
	Function Time:Int()
		Local time:Byte[256]
		Return time_( time )
	End Function
	
End Type



