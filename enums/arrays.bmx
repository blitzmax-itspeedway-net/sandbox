SuperStrict

Const TK_ALPHA:Int = 0
Const TK_NUMBER:Int = 1
Const TK_SYMBOL:Int = 2
Const TK_LOCAL:Int = 3
Const TK_GLOBAL:Int = 4

Local alphanumeric:Int[] = [ TK_ALPHA , TK_NUMBER ]
Local vardef:Int[] = [ TK_LOCAL, TK_GLOBAL ]

Function parse( name:String, expected:ETokens )

	If ( expected & ETokens.TK_LOCAL) = ETokens.TK_LOCAL
		Print name + ": EXISTS"
	Else
		Print name + ": MISSING"
	End If

End Function

parse( "ONE", alphanumeric )
parse( "TWO", alphanumeric + vardef )





