SuperStrict

' ## EXPERIMENTAL ##

Enum PRIMITIVE:Byte; PINT=0; PSHORT; PFLOAT; PDOUBLE; PSTRING; EndEnum

Type TBOX

	Protected
	
	Field buffers:Byte Ptr[]
	
	Public
	
'	Method New()
'	End Method

	Method Delete()
		For Local buffer:Byte Ptr = EachIn buffers
			If buffer; MemFree buffer
		Next
	End Method

	Method push:TBox( value:Short )
		Local buffer:Byte Ptr = MemAlloc( Size_T(SizeOf(value)+1) )
		buffer[ 0 ] = Byte(PRIMITIVE.PSHORT.ordinal())	' Insert datatype
		(Short Ptr( buffer ) )[1] = value					' Insert value
		buffers :+ [buffer]
		Return Self
	End Method
		
	Method push:TBox( value:Int )
		Local buffer:Byte Ptr = MemAlloc( Size_T(SizeOf(value)+1) )
		buffer[ 0 ] = Byte(PRIMITIVE.PINT.ordinal())	' Insert datatype
		(Int Ptr( buffer ) )[1] = value					' Insert value
		buffers :+ [buffer]
		Return Self
	End Method

	Method push:TBox( value:Float )
		Local buffer:Byte Ptr = MemAlloc( Size_T(SizeOf(value)+1) )
		buffer[ 0 ] = Byte(PRIMITIVE.PFLOAT.ordinal())	' Insert datatype
		(Float Ptr( buffer ) )[1] = value				' Insert value
		buffers :+ [buffer]
		Return Self
	End Method

	Method push:TBox( value:Double )
		Local buffer:Byte Ptr = MemAlloc( Size_T(SizeOf(value)+1) )
		buffer[ 0 ] = Byte(PRIMITIVE.PDOUBLE.ordinal())	' Insert datatype
		(Double Ptr( buffer ) )[1] = value				' Insert value
		buffers :+ [buffer]
		Return Self
	End Method

	Rem DOES NOT WORK YET
	Method add:TBox( value:String )
		Local length:Size_T = Size_T( SizeOf(value) )
		Local buffer:Byte Ptr = MemAlloc( Size_T(5+length*SizeOf(length)) )	' includes type&size
		buffer[ 0 ] = Byte(PRIMITIVE.PSTRING.ordinal())			' Insert datatype
		(Size_T Ptr( buffer ) )[1] = length						' Insert size of string

DebugStop
		' Might be able to use memcopy here!
		MemCopy buffer+5, value, length
		'For Local i:Int = 0 Until length
		'	Local char:String = Chr(value[i])
		'	Local ch:Short = value[i]
		'	Local st:String = Hex( ch )
		'	Local p:Int = 5+i*2
		'	(Short Ptr( buffer ) )[5+i*2] = Short(value[i])
		'Next

		buffers :+ [buffer]
		Return Self
	End Method
	End Rem
	
	Rem
	bbdoc: Get a boxed variable type
	returns: A PRIMITIVE enum value
	about:
	EndRem
	Method getType:PRIMITIVE( index:Int = 0 )
		Assert index < buffers.length Else "Buffer index out of scope"
		Return PRIMITIVE(Byte(buffers[index][0]))
	End Method
	
	Method count:Int()
		Return buffers.length
	End Method
	
	Rem
		Method to extract a variable
	EndRem
	Method toShort:Int( index:Short = 0 )
		Assert index < buffers.length Else "Buffer index out of scope"
		Assert Byte(buffers[index][0]) = PRIMITIVE.PSHORT.ordinal() Else "Invalid datatype"
		Local value:Short = (Short Ptr(buffers[index]))[1]
		MemFree buffers[index]
		Return value
	End Method

	Method toInt:Int( index:Int = 0 )
		Assert index < buffers.length Else "Buffer index out of scope"
		Assert Byte(buffers[index][0]) = PRIMITIVE.PINT.ordinal() Else "Invalid datatype"
		Local value:Int = (Int Ptr(buffers[index]))[1]
		MemFree buffers[index]
		Return value
	End Method

	Method toFloat:Float( index:Int = 0 )
		Assert index < buffers.length Else "Buffer index out of scope"
		Assert Byte(buffers[index][0]) = PRIMITIVE.PFLOAT.ordinal() Else "Invalid datatype"
		Local value:Float = (Float Ptr(buffers[index]))[1]
		MemFree buffers[index]
		Return value
	End Method

	Method toDouble:Double( index:Int = 0 )
		Assert index < buffers.length Else "Buffer index out of scope"
		Assert Byte(buffers[index][0]) = PRIMITIVE.PDOUBLE.ordinal() Else "Invalid datatype"
		Local value:Double = (Double Ptr(buffers[index]))[1]
		MemFree buffers[index]
		Return value
	End Method
	
	Rem DOES NOT WORK YET
	Method toString:String( index:Int = 0 )
		DebugStop
		Assert index < buffers.length Else "Buffer index out of scope"
		Assert Byte(buffers[index][0]) = PRIMITIVE.PSTRING.ordinal() Else "Invalid datatype"
		Local length:Int = (Int Ptr(buffers[index]))[1]			' Size of string
		' Might be able to use memcopy here!
		'MemCopy buffer[1], value, SizeOf( value )
		Local value:String = " "[..length]
		For Local i:Int = 0 Until length
			value[ i ] = (Short Ptr(buffers[index]))[5+i*2]
		Next
		MemFree buffers[index]
		Return value
	End Method
	End Rem
	
End Type

Rem
Type TBoxEnumerator

	Field box:TBox
	Field index:Int = 0

	Method New( box:TBox )
		Self.box = box
	End Method
	
	Method HasNext()
		Return box.buffers.length > index
	End Method

	Method NextObject:TBox()
		Local value:TBox = T_link._value
		Assert value<>_link
		_link=_link._succ
		Return value
	End Method

End Type
EndRem

Local value:TBox

Print "INT:"
value = New TBox.push( 23 )
Print "  " + value.toInt() + " : " +value.getType().toString()

Print "~nFLOAT:"
value = New TBox.push( Float(67.2) )
Print "  " + value.toFloat() + " : " +value.getType().toString()

Print "~nDOUBLE:"
value = New TBox.push( Double(83.2) )
Print "  " + value.toDouble() + " : " +value.getType().toString()

DebugStop
'Print "~nSTRING:"
'value = New TBox.add( "Hello World" )
'Print "  " + value.toString() + " : " +value.getType().toString()

' TEST RETURNING ARRAYS OF DIFFERENT VALUES

Function testfn:TBox()
	Local result:TBox = New TBox()
	result.push( 23 ).push( Float(18.2) ).push( Double(21.4) )
	'result.add( "Hello World" )
	Return result
End Function

Local args:TBox

Print "~nARRAY USING OPERATOR INDEX"
args = testfn()
For Local index:Int = 0 Until args.count()
	Select args.getType( index )
	Case PRIMITIVE.PINT
		Print args.toInt( index ) + " = 23"
	Case PRIMITIVE.PFLOAT
		Print args.toFloat( index ) + " = 18.2"
	Case PRIMITIVE.PDOUBLE
		Print args.toDouble( index ) + " = 21.4"
'	Case PRIMITIVE.PSTRING
'		Print args.toString( index )
	End Select
Next

