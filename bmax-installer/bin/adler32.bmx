
'	Implementation of the Adler-32 algorithm
'	https://en.wikipedia.org/wiki/Adler-32
'	Author: Si Dunford

Function Adler32_Checksum:Int( data:String, bytes:Int = 0 )
	Local A:Int = 0, B:Int = 0, ch:Byte, n:ULong
	Local size:Int = Len( data )
	If bytes > 0; size = Min( bytes, size )
	For n = 0 Until size
		ch = data[n]
		A = (A+ch) Mod $FFFF
		B = (B+A) Mod $FFFF	
	Next
	Return B Shl 16 | A
End Function
