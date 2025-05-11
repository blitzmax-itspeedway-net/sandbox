SuperStrict

'example

Const ITERATIONS:Int = 100000

Local start:Int, test:Int
Local example:String = "Some_Identifier_999 in the string"

' ========================================
Print( "GET INDENTIFIER BY CHAR" )

Function getNextIdentifierByChar:String( example:String, start:Int = 0 )
	Local str:String, cursor:Int = start
	While example[cursor] = Asc("_") ..
		Or ( example[cursor] >= 48 And example[cursor] <= 57 ) ..		' NUMBER
		Or ( example[cursor] >= 65 And example[cursor] <= 90 ) ..		' UPPERCASE
		Or ( example[cursor] >= 97 And example[cursor] <= 122 )		' LOWERCASE
			str :+ Chr(example[cursor])
			cursor :+ 1
	Wend
	Return str
End Function

start = MilliSecs()
For Local n:Int = 1 To ITERATIONS
	Local str:String = getNextIdentifierByChar( example )
Next
Print "= "+ (MilliSecs()-start)+"ms"

' ========================================
Print( "GET INDENTIFIER BY INDEX" )

Function getNextIdentifierByIndex:String( example:String, cursor:Int = 0 )
	Local start:Int = cursor, finish:Int = cursor
	While example[finish] = Asc("_") ..
		Or ( example[finish] >= 48 And example[finish] <= 57 ) ..		' NUMBER
		Or ( example[finish] >= 65 And example[finish] <= 90 ) ..		' UPPERCASE
		Or ( example[finish] >= 97 And example[finish] <= 122 )		' LOWERCASE
		finish :+ 1
	Wend
	Return example[ start..finish ]
End Function

start = MilliSecs()
For Local n:Int = 1 To ITERATIONS
	Local str:String = getNextIdentifierByIndex( example )
Next
Print "= "+ (MilliSecs()-start)+"ms"


