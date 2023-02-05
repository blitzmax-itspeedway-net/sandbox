SuperStrict

' ## EXPERIMENTAL ##

' This doesn't work because you cannot declare multiple function/methods with
' different return values!

' I might be able to use SBOX instead of Byte ptr which will look nicer!
' But I still would need toInt(), toFloat(), etc...
Struct SBOX
	Field buffer:Byte Ptr
	Method New( buf:Byte Ptr )
		buffer = buf
	End Method
End Struct

Enum PRIMITIVE; PINT; PFLOAT; PDOUBLE; EndEnum

Function boxtype:PRIMITIVE( box:Byte Ptr )
	Return PRIMITIVE(Int(box[0]))
End Function

Function box:Byte Ptr( value:Int )
	Local buffer:Byte Ptr = MemAlloc( Size_T(SizeOf(value)+1) )
	buffer[ 0 ] = PRIMITIVE.PINT.ordinal()	' Insert datatype
	(Int Ptr( buffer+1 ) )[0] = value			' Insert value
	Return buffer
End Function

Function unbox:Int( buffer:Byte Ptr )
	Assert Byte(buffer[0])=PRIMITIVE.PINT.ordinal() Else "Invalid datatype"
	Local value:Int = (Int Ptr(buffer+1))[0]
	MemFree buffer
	Return value
End Function

Function box:Byte Ptr( value:Float )
	Local buffer:Byte Ptr = MemAlloc( Size_T(SizeOf(value)+1) )
	buffer[ 0 ] = PRIMITIVE.PFLOAT.ordinal()	' Insert datatype
	(Float Ptr( buffer+1 ) )[0] = value			' Insert value
	Return buffer
End Function

Function unbox:Float( buffer:Byte Ptr )
	Assert Byte(buffer[0])=PRIMITIVE.PFLOAT.ordinal() Else "Invalid datatype"
	Local value:Int = (Float Ptr(buffer+1))[0]
	MemFree buffer
	Return value
End Function

DebugStop
Local value:Byte Ptr

value = box( 23 )
Print Int(unbox(value)) + " : "+ boxtype( value ).toString()

value = box( 67.2 )
Print Float(unbox(value)) + " : "+ boxtype( value ).toString()
