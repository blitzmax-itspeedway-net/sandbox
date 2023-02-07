SuperStrict

' ## EXPERIMENTAL ##

Enum PRIMITIVE:Byte; PUNASSIGNED=0, PINT; PSHORT; PFLOAT; PDOUBLE; PTRUE; PFALSE; PSTRING; EndEnum

Type TPrimitive Extends Object
	Field datatype:PRIMITIVE
	
	Method getType:PRIMITIVE()
		Return datatype
	End Method
	
	Method is:Int( query:PRIMITIVE )
		Return ( query = datatype )
	End Method

End Type

Type PINT Extends TPrimitive
	Field value:Int
	Method New( value:Int )
		Self.datatype = PRIMITIVE.PINT
		Self.value = value
	End Method
	' We use a function here to prevent method get on NULL value
	Function get:Int( this:TPrimitive )
		If this And this.datatype = PRIMITIVE.PINT; Return PINT(this).value
		Return 0
	End Function
End Type

Type PFLOAT Extends TPrimitive
	Field value:Float
	Method New( value:Float )
		Self.datatype = PRIMITIVE.PFLOAT
		Self.value = value
	End Method	
	' We use a function here to prevent method get on NULL value
	Function get:Float( this:TPrimitive )
		If this And this.datatype = PRIMITIVE.PFLOAT; Return PFLOAT(this).value
		Return 0
	End Function
End Type

Type PDOUBLE Extends TPrimitive
	Field value:Double
	Method New( value:Double )
		Self.datatype = PRIMITIVE.PDOUBLE
		Self.value = value
	End Method
	' We use a function here to prevent method get on NULL value
	Function get:Double( this:TPrimitive )
		If this And this.datatype = PRIMITIVE.PDOUBLE; Return PDOUBLE(this).value
		Return 0
	End Function
End Type

Type PSTRING Extends TPrimitive
	Field value:String
	Method New( value:String )
		Self.datatype = PRIMITIVE.PSTRING
		Self.value = value
	End Method
	' We use a function here to prevent method get on NULL value
	Function get:String( this:TPrimitive )
		If this And this.datatype = PRIMITIVE.PSTRING; Return PSTRING(this).value
		Return ""
	End Function
End Type

Type PTRUE Extends TPrimitive
	Field value:Int
	Method New()
		Self.datatype = PRIMITIVE.PTRUE
		Self.value = value
	End Method
	' We use a function here to prevent method get on NULL value
	Function get:Int( this:TPrimitive )
		If this And this.datatype = PRIMITIVE.PTRUE; Return PTRUE(this).value
		Return False
	End Function
End Type

Type PFALSE Extends TPrimitive
	Field value:Int
	Method New( value:Int )
		Self.datatype = PRIMITIVE.PFALSE
		Self.value = value
	End Method
	' We use a function here to prevent method get on NULL value
	Function get:Int( this:TPrimitive )
		If this And this.datatype = PRIMITIVE.PFALSE; Return PFALSE(this).value
		Return False
	End Function
End Type

Function CreateGeneral:General()
	Return New General()
End Function

Type General Extends TObjectList

	Method push( primitive:TPrimitive )
		addlast( primitive )
	End Method
	
	Method push( value:Int )
		addlast( New PINT( 23 ) )
	End Method
	
	Method push( value:Float )
		addlast( New PFLOAT( value ) )
	End Method

	Method push( value:String )
		addlast( New PSTRING( value ) )
	End Method
	
	Method operator[]:TPrimitive( key:Int )
		Assert key>=0 And key<count() Else "Index out of bounds"
		Return TPrimitive( valueAtIndex( key ) )
	End Method
	
End Type

' TEST INDIVIDUAL VALUES

Local value:TPrimitive
Print "INT:"
value = New PINT( 23 )
Print "  " + PINT.get(value) + " : " +value.getType().toString()

Print "~nFLOAT:"
value = New PFLOAT(67.2)
Print "  " + PFLOAT.get(value) + " : " +value.getType().toString()

Print "~nDOUBLE:"
value = New PDOUBLE( 83.2 )
Print "  " + PDOUBLE.get(value) + " : " +value.getType().toString()

Print "~nSTRING:"
value = New PSTRING( "Hello World" )
Print "  " + PSTRING.get(value) + " : " +value.getType().toString()

' FUNCTION THAT RETURNS MULTIPLE TYPES

Function myfunc:General()

	Local results:General = CreateGeneral()
	results.push( 23 )
	results.push( Float(23) )
	results.push( "Hello World" )
	Return results
	
End Function

' CALL FUNCTION THAT RETURNS MULTIPLE TYPES

Local result:General = myfunc()

Print "~nARRAY USING OPERATOR INDEX"

For Local index:Int = 0 Until result.count()
	Select result[index].getType()
	Case PRIMITIVE.PINT
		Print PINT.get(result[index]) + " : INT = 23"
	Case PRIMITIVE.PFLOAT
		Print PFLOAT.get(result[index]) + " : FLOAT = 18.2"
	Case PRIMITIVE.PDOUBLE
		Print PDOUBLE.get(result[index]) + " : DOUBLE = 21.4"
	Case PRIMITIVE.PSTRING
		Print PSTRING.get(result[index]) + " : STRING"
	End Select
Next

Print "~nARRAY USING EACHIN"

For Local value:TPrimitive = EachIn result
	Select value.getType()
	Case PRIMITIVE.PINT
		Print PINT.get(value)
	Case PRIMITIVE.PFLOAT
		Print PFLOAT.get(value)
	Case PRIMITIVE.PDOUBLE
		Print PDOUBLE.get(value)
	Case PRIMITIVE.PSTRING
		Print PSTRING.get(value)
	End Select
Next

' TEST OUT IS() AND BAD CONVERSION

Local valueInt:Int '= PINT.get(result[0])
If result[0].is( PRIMITIVE.PINT ); valueInt = PINT.get(result[0])
Print "~nINT CONVERT: "+valueInt

' Attempt to extract an INT into a FLOAT will return zero!
Local valueFloat:Float = PFLOAT.get(result[0])
Print "BAD CONVERT: "+valueFloat

' TEST OUT A TWO VALUE RESULT

Function CreateError:General( state:TPrimitive, result:TPrimitive=Null )
	Local items:General = New General()
	items.push( state )
	items.push( result )
	Return items
End Function

Function CheckSomething:General()
	Print( "~nRunning Something..." )
	' blah, blah, blah...
	Return CreateError( New PTRUE(), New PSTRING( "Error in line 10" ) )
End Function

Local state:General = CheckSomething()

If state[0].is( PRIMITIVE.PTRUE ); Print PSTRING.get( state[1] )



