SuperStrict

Function CountDown( amount:Int )

	For Local c:Int = amount to 0 Step -1
		Show( c )
	Next
	
    Function Show( number:Int )
		Print( number )
    End Function

End Function

Countdown( 10 )
