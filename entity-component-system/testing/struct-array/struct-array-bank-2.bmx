
SuperStrict

Const MAXSIZE:Int = 10

Struct SLocation
	Field x:Float, y:Float
End Struct

Type TStructArray
	Field bank:TBank
	Field recordsize:Int
	Field buf:Byte Ptr
	
	Method New( recordsize:Int, quantity:Int )
		Self.recordsize = recordsize
		bank = CreateBank( recordsize * quantity )
		buf  = bank.Buf()
	End Method
	
	Method get:Byte Ptr( element:Int )
		Return buf + element * recordsize
	End Method
	
	Method Operator []:Byte Ptr( element:Int )
		Return buf + element * recordsize
	End Method
	
End Type

Global locations:TStructArray = New TStructArray( Int( SizeOf( SLocation ) ), MAXSIZE )
Local location:SLocation Ptr 

For Local n:Int = 0 Until MAXSIZE
	location = locations.get( n )
	location[0].x = n
Next

For Local n:Int = 0 Until MAXSIZE
	location = locations[n]
	Print n+": "+Hex(Int(location))+"  "+location[0].x
Next

