
SuperStrict

Const MAXSIZE:Int = 10

Struct SLocation
	Field x:Float, y:Float
End Struct

Global bank:TBank = CreateBank( Int( SizeOf( SLocation )*MAXSIZE ))

Function getreference:Byte Ptr( element:Int, recordsize:Int = 1 )
	Local buf:Byte Ptr = BankBuf( bank )
	Return buf + ( element ) * recordsize
End Function

For Local n:Int = 0 Until MAXSIZE
	'Local location:SLocation Ptr

	Local location:SLocation Ptr

	location = getreference( n, Int(SizeOf(SLocation)) )	'Varptr array[n]
	location[0].x = n
	
	'Varptr array[n] [0].x = n
Next

For Local n:Int = 0 Until MAXSIZE
	Local location:SLocation Ptr
	location = getreference( n, Int(SizeOf(SLocation)) )	'Varptr array[n]
	Print n+": "+Hex(Int(location))+"  "+location[0].x

	'location = Varptr array[n]
	'Print n+": "+Hex(Int(location))+"  "+array[n].x

	'location = Varptr array[n]
	'location[0].x = n
Next