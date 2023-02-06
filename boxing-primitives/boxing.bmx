SuperStrict

' ## EXPERIMENTAL ##

' I might be able to use SBOX instead of Byte ptr which will look nicer!
' But I still would need toInt(), toFloat(), etc...
Struct SBOX
	Field buffer:Byte Ptr
	Method New( buf:Byte Ptr )
		buffer = buf
	End Method
End Struct

Enum PRIMITIVE; PINT=0; PFLOAT; PDOUBLE; EndEnum

' MUST BE CALLED BEFORE UNBOXING OF BUFFER IS FREED
Function getType:PRIMITIVE( buffer:Byte Ptr )
	Return PRIMITIVE(Int(buffer[0]))
End Function

Function box:Byte Ptr( value:Int )
	Local buffer:Byte Ptr = MemAlloc( Size_T(SizeOf(value)+1) )
	buffer[ 0 ] = PRIMITIVE.PINT.ordinal()	' Insert datatype
	(Int Ptr( buffer+1 ) )[0] = value			' Insert value
	Return buffer
End Function

Function unbox( value:Int Var, buffer:Byte Ptr )
	Assert Byte(buffer[0])=PRIMITIVE.PINT.ordinal() Else "Invalid datatype"
	value = (Int Ptr(buffer+1))[0]
	MemFree buffer
End Function

Function box:Byte Ptr( value:Float )
	Local buffer:Byte Ptr = MemAlloc( Size_T(SizeOf(value)+1) )
	buffer[ 0 ] = PRIMITIVE.PFLOAT.ordinal()	' Insert datatype
	(Float Ptr( buffer+1 ) )[0] = value			' Insert value
	Return buffer
End Function

Function unbox( value:Float Var, buffer:Byte Ptr )
	Assert Byte(buffer[0])=PRIMITIVE.PFLOAT.ordinal() Else "Invalid datatype"
	value = (Float Ptr(buffer+1))[0]
	MemFree buffer
	'Return value
End Function

Local value:Byte Ptr

value = box( 23 )
Print getType( value ).toString() ' MUST BE CALLED BEFORE UNBOXING
Local _int:Int
unbox( _int, value )
Print _int

value = box( 67.2 )
Print getType( value ).toString()
Local _float:Float
unbox( _float, value )
Print _float
