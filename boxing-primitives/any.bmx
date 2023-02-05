SuperStrict

Enum PRIMITIVE; PINT; PFLOAT; PDOUBLE; EndEnum

' ANY is related to a bank, but can store ANY primitive within it

Type ANY

	Field _buf:Byte Ptr
	Field _size:Int = 0
	Field _capacity:Int = 0
	
	Method New( value:Int )
		resize( SizeOf(value)+1 )
		_buf[ 0 ] = PRIMITIVE.PINT.ordinal()	' Insert datatype
		(Int Ptr( _buf+1 ) )[0] = value			' Insert value
	End Method

	Method New( value:Float )
		resize( SizeOf(value)+1 )
		_buf[ 0 ] = PRIMITIVE.PFLOAT.ordinal()	' Insert datatype
		(Int Ptr( _buf+1 ) )[0] = value			' Insert value
	End Method

	Method New( value:Double )
		resize( SizeOf(value)+1 )
		_buf[ 0 ] = PRIMITIVE.PDOUBLE.ordinal()	' Insert datatype
		(Int Ptr( _buf+1 ) )[0] = value			' Insert value
	End Method

	Method Resize( size:Int )
		If size>_capacity
			Local n:Int = _capacity*3/2
			If n<size n=size
			Local tmp:Byte Ptr=MemAlloc(n)
			MemCopy tmp,_buf,_size
			MemFree _buf
			_capacity=n
			_buf=tmp
		EndIf
		_size=size
	End Method

	Method getType:PRIMITIVE()
		Return PRIMITIVE(Int(_buf[0]))
	End Method
	
	Method toInt:Int()
		Assert Byte(_buf[0])=PRIMITIVE.PINT.ordinal() Else "Invalid datatype"
		Return (Int Ptr(_buf+1))[0]
	End Method
	
	Method toDouble:Double()
		Assert Byte(_buf[0])=PRIMITIVE.PDOUBLE.ordinal() Else "Invalid datatype"
		Return (Double Ptr(_buf+1))[0]
	End Method
	
	Method toFloat:Float()
		Assert Byte(_buf[0])=PRIMITIVE.PFLOAT.ordinal() Else "Invalid datatype"
		Return (Float Ptr(_buf+1))[0]
	End Method
	
End Type

DebugStop
Local Number:ANY = New ANY( 23 )
Print Number.getType().toString()
Print Number.toInt()
