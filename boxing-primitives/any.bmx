SuperStrict

' ## EXPERIMENTAL ##

Enum PRIMITIVE; PINT; PFLOAT; PDOUBLE; EndEnum

' ANY is based on a TBank and can store ANY primitive within it
' Currenty it has limited primitive support

Type ANY

	Field _buf:Byte Ptr
	Field _size:Size_T = 0
	Field _capacity:Size_T = 0
	
	Method New( value:Int )
		resize( SizeOf(value)+1 )
		_buf[ 0 ] = PRIMITIVE.PINT.ordinal()	' Insert datatype
		(Int Ptr( _buf+1 ) )[0] = value			' Insert value
	End Method

	Method New( value:Float )
		resize( SizeOf(value)+1 )
		_buf[ 0 ] = PRIMITIVE.PFLOAT.ordinal()	' Insert datatype
		(Float Ptr( _buf+1 ) )[0] = value			' Insert value
	End Method

	Method New( value:Double )
		resize( SizeOf(value)+1 )
		_buf[ 0 ] = PRIMITIVE.PDOUBLE.ordinal()	' Insert datatype
		(Double Ptr( _buf+1 ) )[0] = value			' Insert value
	End Method

	Method Delete()
		If _capacity>=0; MemFree _buf
	End Method
	
	Method Resize( size:Int )
		If size>_capacity
			Local n:Size_T = _capacity*3/2
			If n<size n=size
			Local tmp:Byte Ptr=MemAlloc(n)
			MemCopy tmp,_buf, _size
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
Local Number:ANY

' Stick an Integer in the box
Number = New ANY( 23 )
Print Number.toInt() + " : " + Number.getType().toString()

' Stick a Float in the box
Number = New ANY( Float(67.2) )
Print Number.toFloat() + " : " + Number.getType().toString()

' Stick a Double in the box
Number = New ANY( Double(87.9922116) )
Print Number.toDouble() + " : " + Number.getType().toString()

