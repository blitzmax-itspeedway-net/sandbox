SuperStrict

' ## EXPERIMENTAL ##

Enum PRIMITIVE:Byte; UNASSIGNED=0; PINT; PFLOAT; PDOUBLE; PSTRING; PTRUE; PFALSE; EndEnum

Rem
Function Box:Byte[]( iValue:Int )
	Local aBoxed:Byte[SizeOf(iValue)+1]
	aBoxed[0] = PRIMITIVE.PINT.ordinal()
	Local pValue:Byte Ptr = Varptr iValue
	Local pBoxed:Byte Ptr = Varptr aBoxed
	MemCopy pBoxed+1, pValue, Size_T( SizeOf(iValue) )
	Return aBoxed
End Function

Function Unbox:Int( aBoxed:Byte[] )
	Local iValue:Int
	Local pValue:Byte Ptr = Varptr iValue
	Local pBoxed:Byte Ptr = Varptr aBoxed
	Assert aBoxed[0] = PRIMITIVE.PINT.ordinal() Else "Cannot unbox "+PRIMITIVE(aBoxed[0]).toString()+" to Int"
	MemCopy pValue, pBoxed+1, Size_T( SizeOf(iValue) )
	Return iValue
End Function
EndRem	

'Local boxedInt:Byte[] = box( 23 )
'DebugStop
'Print Unbox( boxedInt )

'DebugStop

Type TBoxException
	Field errtext:String
	Method New( message:String )
		errtext = message
	End Method
	Method toString:String()
		Return errtext
	End Method
End Type

Struct SBOX

	Field datatype:PRIMITIVE = PRIMITIVE.UNASSIGNED
	Field buffer:Byte[]
	Field p:Byte Ptr = Varptr buffer
	
	Method New( value:Int )
		_box( PRIMITIVE.PINT, SizeOf( value ), Varptr value )
	End Method
	
	Method New( value:Float )
		_box( PRIMITIVE.PFLOAT, SizeOf( value ), Varptr value )
	End Method

	Method New( value:Double )
		_box( PRIMITIVE.PDOUBLE, SizeOf( value ), Varptr value )
	End Method

'	Method New( value:String )
'		_box( PRIMITIVE.PSTRING, SizeOf( value ), Varptr value )
'	End Method
	
	' Special constructor for PTRUE/PFALSE
	Method New( datatype:PRIMITIVE )
		Local value:Int
		_box( PRIMITIVE.PINT, SizeOf( value ), Varptr value )
	End Method
	
	' Get the datatype
	Method getType:PRIMITIVE()
		Return datatype
	End Method
	
	' Check datatype
	Method is:Int( datatype:PRIMITIVE )
		Return ( Self.datatype = datatype )
	End Method
	
	' Box value into buffer
	Method _box( datatype:PRIMITIVE, size:Size_T, value:Byte Ptr )
		Self.datatype = datatype
		buffer = New Byte[ size ]
		MemCopy buffer, value, size
	End Method
	
	' Unbox value from buffer
	Method _unbox( datatype:PRIMITIVE, size:Size_T, value:Byte Ptr )
		If Self.datatype <> datatype; Throw New TBoxException( "Invalid datatype" )
		MemCopy value, buffer, size
	End Method
	
	Method toInt:Int()
		Local value:Int
		_unbox( PRIMITIVE.PINT, SizeOf( value ), Varptr( value ) )
		Return value
	End Method

	Method toFloat:Float()
		Local value:Float
		_unbox( PRIMITIVE.PFLOAT, SizeOf( value ), Varptr( value ) )
		Return value
	End Method

	Method toDouble:Double()
		Local value:Double
		_unbox( PRIMITIVE.PDOUBLE, SizeOf( value ), Varptr( value ) )
		Return value
	End Method

'	Method toString:String()
'		Local value:String
'		_unbox( PRIMITIVE.PSTRING, SizeOf( value ), Varptr value )
'		Return value
'	End Method
		
End Struct

' TEST INDIVIDUAL VALUES

Local box:SBOX

Print "INT:"
box = New SBOX( 23 )
Print "  " + box.toInt() + " : " +box.getType().toString()

Print "~nFLOAT:"
box = New SBOX( Float(67.2) )
Print "  " + box.toFloat() + " : " +box.getType().toString()

Print "~nDOUBLE:"
box = New SBOX( Double(67.2) )
Print "  " + box.toDouble() + " : " +box.getType().toString()

' FUNCTION THAT RETURNS MULTIPLE TYPES

Function testfn:SBOX[]()
	' blah, blah, blah...
	
	Local result:SBOX[] = [ ..
		New SBOX( 23 ), ..
		New SBOX( Float(18.2) ), ..
		New SBOX( Double(21.4) ) ..
		]
	Return result
End Function

' CALL FUNCTION THAT RETURNS MULTIPLE TYPES

Local args:SBOX[] = testfn()

Print "~nARRAY USING EACHIN"
For Local arg:SBOX = EachIn args
	Select arg.getType()
	Case PRIMITIVE.PINT
		Print arg.toInt() + " : INT "
	Case PRIMITIVE.PFLOAT
		Print arg.toFloat() + " : FLOAT "
	Case PRIMITIVE.PDOUBLE
		Print arg.toDouble() + " : DOUBLE "
	End Select
Next

Print "~nARRAY USING ARRAY INDEX"
For Local index:Int = 0 Until args.length
	Select args[index].getType()
	Case PRIMITIVE.PINT
		Print args[index].toInt()
	Case PRIMITIVE.PFLOAT
		Print args[index].toFloat()
	Case PRIMITIVE.PDOUBLE
		Print args[index].toDouble()
	End Select
Next

' TEST OUT IS()

Function iif:String( bool:Int, isTrue:String, isFalse:String )
	If bool Then Return isTrue Else Return isFalse
End Function

Print "~nTEST IS():"
box = New SBOX( 23 )
Print iif( box.is( PRIMITIVE.PINT ), "It is an INT", "It is not an INT" )
Print iif( box.is( PRIMITIVE.PFLOAT ), "It is a FLOAT", "It is not a FLOAT" )
	
' TEST BAD CONVERSION

Print "~nTEST BAD CONVERSION:"
box = New SBOX( 67 )
Try
	Local valueFloat:Float =  box.toFloat()
	Print( "Success" )
Catch e:TBoxException
	Print e.toString()
End Try

' TEST OUT A TWO VALUE RESULT

Rem STRING DOES NOT WORK YET

Function CreateError:SBOX[]( state:SBOX, result:SBOX )
	Return [ state, result ]
End Function

Function CheckSomething:SBOX[]()
	Print( "~nRunning Something..." )
	' blah, blah, blah...
	Return CreateError( New SBOX( PRIMITIVE.PTRUE ), New SBOX( "Error in line 10" ) )
End Function

Local state:SBOX[] = CheckSomething()
DebugStop
If state[0].is( PRIMITIVE.PTRUE )	' Is there an error?
	Print state[1].toString()
Else
	Print "- No error"
End If

endrem