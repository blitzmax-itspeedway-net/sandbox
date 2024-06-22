' Inline IF functions

Function iif:Int( expression:Int, isTrue:Int, iSFalse:Int )
	If expression; Return isTrue
	Return isFalse
End Function

Function iif:Long( expression:Int, isTrue:Long, iSFalse:Long )
	If expression; Return isTrue
	Return isFalse
End Function

Function iif:String( expression:Int, isTrue:String, iSFalse:String )
	If expression; Return isTrue
	Return isFalse
End Function
