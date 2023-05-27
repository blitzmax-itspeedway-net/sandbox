
SuperStrict

Const ARRAYSIZE:Int = 1000
Const REPEATCOUNT:Int = 1000

Struct SLocation
	Field x:Float, y:Float
End Struct

Struct TLocation
	Field x:Float, y:Float
End Struct

' TIMING VARIABLE
Local start:Int

' ARRAY OF STRUCT
'Local array:Struct<SLocation>[MAXSIZE]

' BANK OF STRUCT
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

' BANK OF STRUCTYPE
Type TLocationArray Extends TStructArray

	Method New( quantity:Int )
		Super.New( Int( SizeOf( SLocation ) ), quantity )
	End Method
	
	Method get:SLocation Ptr( element:Int )
		Local location:SLocation Ptr
		location = buf + element * recordsize
		Return location
	End Method
	
	Method Operator []:SLocation Ptr( element:Int )
		Local location:SLocation Ptr 
		location = buf + element * recordsize
		Return location
	End Method

End Type

Print "~nTEST ARRAY OF STRUCT"
Local array:SLocation[ARRAYSIZE]

	start = MilliSecs()
	For Local r:Int = 1 To REPEATCOUNT
		For Local n:Int = 0 Until ARRAYSIZE
			array[n].x = n
		Next
	Next
	Print( "- Test Set Array = "+(MilliSecs()-start)+"ms" )

	start = MilliSecs()
	For Local r:Int = 1 To REPEATCOUNT
		For Local n:Int = 0 Until ARRAYSIZE
			Local a:Float = array[n].x
		Next
	Next
	Print( "- Test Get Array = "+(MilliSecs()-start)+"ms" )


Print "~nTEST BANK OF STRUCT"
Local structBank:TStructArray = New TStructArray( Int( SizeOf( SLocation ) ), ARRAYSIZE )
Local structBankPtr:SLocation Ptr 

	start = MilliSecs()
	For Local r:Int = 1 To REPEATCOUNT
		For Local n:Int = 0 Until ARRAYSIZE
			structBankPtr = structBank.get( n )
			structBankPtr[0].x = n
		Next
	Next
	Print( "- Test Set Bank Struct = "+(MilliSecs()-start)+"ms" )

	start = MilliSecs()
	For Local r:Int = 1 To REPEATCOUNT
		For Local n:Int = 0 Until ARRAYSIZE
			structBankPtr = structBank[n]
			Local a:Float = structBankPtr[0].x
		Next
	Next
	Print( "- Test Get Bank Struct = "+(MilliSecs()-start)+"ms" )

Print "~nTEST BANK OF STRUCTTYPE"
Global structType:TLocationArray = New TLocationArray( ARRAYSIZE )

	start = MilliSecs()
	For Local r:Int = 1 To REPEATCOUNT
		For Local n:Int = 0 Until ARRAYSIZE
			Local structTypePtr:SLocation Ptr = structType.get( n )
			structTypePtr[0].x = n
		Next
	Next
	Print( "- Test Set Bank Structtype = "+(MilliSecs()-start)+"ms" )

	start = MilliSecs()
	For Local r:Int = 1 To REPEATCOUNT
		For Local n:Int = 0 Until ARRAYSIZE
			Local structTypePtr:SLocation Ptr = structType[n]
			Local a:Float = structTypePtr[0].x
		Next
	Next
	Print( "- Test Get Bank Structtype = "+(MilliSecs()-start)+"ms" )

Print "~nTYPE ARRAY"
Local tarray:TLocation[ARRAYSIZE]
For Local n:Int = 0 Until ARRAYSIZE
	tarray[n] = New TLocation()
Next

	start = MilliSecs()
	For Local r:Int = 1 To REPEATCOUNT
		For Local n:Int = 0 Until ARRAYSIZE
			tarray[n].x = n
		Next
	Next
	Print( "- Test Set TList Array = "+(MilliSecs()-start)+"ms" )

	start = MilliSecs()
	For Local r:Int = 1 To REPEATCOUNT
		For Local n:Int = 0 Until ARRAYSIZE
			Local a:Float = tarray[n].x
		Next
	Next
	Print( "- Test Get TList Array = "+(MilliSecs()-start)+"ms" )

