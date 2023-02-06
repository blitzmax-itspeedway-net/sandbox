SuperStrict

' ## EXPERIMENTAL ##

Enum PRIMITIVE; UNASSIGNED=0; PINT; PFLOAT; PDOUBLE; EndEnum

' I might be able to use SBOX instead of Byte ptr which will look nicer!
' But I still would need toInt(), toFloat(), etc...
Struct SBOX
	Field datatype:PRIMITIVE = PRIMITIVE.UNASSIGNED
	Field buffer:Byte Ptr
	Method New( buf:Byte Ptr )
		buffer = buf
	End Method
	
	Method New( value:Int )
		datatype = PRIMITIVE.PINT					' Insert datatype
		buffer = MemAlloc( Size_T(SizeOf(value)) )	' Create Buffer
		(Int Ptr( buffer ) )[0] = value				' Insert value
	End Method

	Method New( value:Float )
		datatype = PRIMITIVE.PFLOAT					' Insert datatype
		buffer = MemAlloc( Size_T(SizeOf(value)) )	' Create Buffer
		(Float Ptr( buffer ) )[0] = value			' Insert value
	End Method

	Method New( value:Double )
		datatype = PRIMITIVE.PDOUBLE				' Insert datatype
		buffer = MemAlloc( Size_T(SizeOf(value)) )	' Create Buffer
		(Double Ptr( buffer ) )[0] = value			' Insert value
	End Method
	
	Method getType:PRIMITIVE()
		Return datatype
	End Method
	
	' Deallocate memory only
	Method dealloc()
		If datatype = PRIMITIVE.UNASSIGNED; Return
		MemFree buffer
		datatype = PRIMITIVE.UNASSIGNED
	End Method
	
	Method toInt:Int()
		Assert datatype = PRIMITIVE.PINT Else "Invalid datatype"
		Local value:Int = (Int Ptr(buffer))[0]
		MemFree buffer
		datatype = PRIMITIVE.UNASSIGNED
		Return value
	End Method

	Method toFloat:Float()
		Assert datatype = PRIMITIVE.PFLOAT Else "Invalid datatype"
		Local value:Float = (Float Ptr(buffer))[0]
		MemFree buffer
		datatype = PRIMITIVE.UNASSIGNED
		Return value
	End Method

	Method toDouble:Double()
		Assert datatype = PRIMITIVE.PDOUBLE Else "Invalid datatype"
		Local value:Double = (Double Ptr(buffer))[0]
		MemFree buffer
		datatype = PRIMITIVE.UNASSIGNED
		Return value
	End Method
		
End Struct

Struct SARGS
	Field list:SBOX[]
	
	Method add( item:SBOX )
		list :+ [item]
	End Method
	
	Method size:Int()
		Return list.length
	End Method
	
	Method operator[]:SBOX( index:Int )
		If index < list.length; Return list[index]
	End Method
	
End Struct

Local value:SBOX

Print "INT:"
value = New SBOX( 23 )
Print "  " + value.toInt() + " : " +value.getType().toString()

Print "~nFLOAT:"
value = New SBOX( Float(67.2) )
Print "  " + value.toFloat() + " : " +value.getType().toString()

Print "~nDOUBLE:"
value = New SBOX( Double(67.2) )
Print "  " + value.toDouble() + " : " +value.getType().toString()

Print "~nDEALLOC:"
value = New SBOX( 16.2 )
value.dealloc()
Print "  " + value.getType().toString()

' TEST RETURNING ARRAYS OF DIFFERENT VALUES

Function testfn:SARGS()						' Or Function testfn:SBOX[]()
	Local result:SARGS
	result.add( New SBOX( 23 ) )
	result.add( New SBOX( Float(18.2) ) )
	result.add( New SBOX( Double(21.4) ) )
	Return result							' Or return result.list!
End Function

Local args:SARGS
Print "~nARRAY USING EACHIN"
args = testfn()
For Local arg:SBOX = EachIn args.list
	Select arg.getType()
	Case PRIMITIVE.PINT
		Print arg.toInt()
	Case PRIMITIVE.PFLOAT
		Print arg.toFloat()
	Case PRIMITIVE.PDOUBLE
		Print arg.toDouble()
	End Select
Next

' ## THIS DOES NOT WORK BECAUSE STRUCT DOES NOT ALLOW OPERATOR OVERLOAD
Rem
Print "~nARRAY USING OPERATOR INDEX"
args = testfn()
For Local index:Int = 0 Until args.size()
	Select args[index].getType()
	Case PRIMITIVE.PINT
		Print args[index].toInt()
	Case PRIMITIVE.PFLOAT
		Print args[index].toFloat()
	Case PRIMITIVE.PDOUBLE
		Print args[index].toDouble()
	End Select
Next
End Rem

Print "~nARRAY USING LIST INDEX"
args = testfn()								' You could just return the list!
For Local index:Int = 0 Until args.size()
	Select args.list[index].getType()
	Case PRIMITIVE.PINT
		Print args.list[index].toInt()
	Case PRIMITIVE.PFLOAT
		Print args.list[index].toFloat()
	Case PRIMITIVE.PDOUBLE
		Print args.list[index].toDouble()
	End Select
Next
