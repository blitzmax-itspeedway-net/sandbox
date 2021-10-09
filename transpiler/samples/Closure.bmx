SuperStrict
' CLOSURE FUNCTION

Function GetCounter:Int()()
	Global count:Int = 0	'	THE CLOSURE
	
	Return _increment		'	INNER FUNCTION
	
	Function _increment:Int()
		count :+ 1			'	FREE VARIABLE (OUT OF LOCAL SCOPE) 
		Return count
	End Function
	
End Function

Local CounterA:Int() = GetCounter()
Print "COUNT: "+CounterA()	' Returns 1
Print "COUNT: "+CounterA()	' Returns 2

Local CounterB:Int() = GetCounter()
Print "COUNT: "+CounterB()	' Returns 1
Print "COUNT: "+CounterB()	' Returns 2
