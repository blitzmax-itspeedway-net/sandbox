
SuperStrict
Import "RAMdump.bmx"

Const MAXSIZE:Int = 10

Struct SLocation
	Field x:Int, y:Int
End Struct

Local array:SLocation[MAXSIZE]

Local arrayptr:Byte Ptr
arrayptr = Varptr array

Print "ARRAY@ "+Hex(Int(arrayptr))

For Local n:Int = 0 Until MAXSIZE
	'Local location:SLocation Ptr

	'location = Varptr array[n]
	'location[0].x = n
	array[n].x = n
Next

For Local n:Int = 0 Until MAXSIZE
	Local location:SLocation Ptr
	location = Varptr array[n]
	Print n+": "+Hex(Int(location))+"  "+array[n].x
Next

RAMdump( Varptr array, SizeOf(Slocation)*MAXSIZE )

