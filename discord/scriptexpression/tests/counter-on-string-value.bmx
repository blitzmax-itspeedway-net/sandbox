SuperStrict

Local start:Int, counter:Int
Local example:String = "1"

Print "STRING CASTING"
counter = 0
start = MilliSecs()
For Local n:Int = 0 Until 1000000
	counter :+ Int( example )
Next
Print MilliSecs()-start + "ms"
Print "="+counter


Print "STRING COMPARE"
counter = 0
start = MilliSecs()
For Local n:Int = 0 Until 1000000
	If example="1"; counter :+ 1
Next
Print MilliSecs()-start + "ms"
Print "="+counter
