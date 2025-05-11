
'
'	Console Library for BlitzMax
'	(c) Copyright Si Dunford [Scaremonger], May 2025
'

SuperStrict
Import brl.retro	' hex()

Function debugstring:String( str:String )
	Local result:String = "["+Len(str)+"] "
	For Local n:Int = 0 Until Len(str)
		Select True
		Case str[n]<32,str[n]=127
			result :+ "\"+Hex( str[n] )[6..]+" "
		Case str[n]=32
			result :+ "<SP> "
		Default
			result :+ "'"+Chr(str[n])+"' "
		End Select
	Next
	Return result
EndFunction