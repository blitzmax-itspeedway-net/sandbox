'# IIF Module
'#
'# VERSION 1.0
'# (c) Copyright Si Dunford [Scaremonger], July 2024

Module bmx.iif

Function iif:Byte( condition:Int, ifTrue:Byte, ifFalse:Byte )
	If condition Return ifTrue Else Return ifFalse
EndFunction

Function iif:Short( condition:Int, ifTrue:Short, ifFalse:Short )
	If condition Return ifTrue Else Return ifFalse
EndFunction

Function iif:Int( condition:Int, ifTrue:Int, ifFalse:Int )
	If condition Return ifTrue Else Return ifFalse
EndFunction

Function iif:UInt( condition:Int, ifTrue:UInt, ifFalse:UInt )
	If condition Return ifTrue Else Return ifFalse
EndFunction

Function iif:Long( condition:Int, ifTrue:Long, ifFalse:Long )
	If condition Return ifTrue Else Return ifFalse
EndFunction

Function iif:ULong( condition:Int, ifTrue:ULong, ifFalse:ULong )
	If condition Return ifTrue Else Return ifFalse
EndFunction

Function iif:Size_T( condition:Int, ifTrue:Size_T, ifFalse:Size_T )
	If condition Return ifTrue Else Return ifFalse
EndFunction

?win32
Function iif:LParam( condition:Int, ifTrue:LParam, ifFalse:LParam )
	If condition Return ifTrue Else Return ifFalse
EndFunction

Function iif:WParam( condition:Int, ifTrue:WParam, ifFalse:WParam )
	If condition Return ifTrue Else Return ifFalse
EndFunction
?

Function iif:Float( condition:Int, ifTrue:Float, ifFalse:Float )
	If condition Return ifTrue Else Return ifFalse
EndFunction

Function iif:Double( condition:Int, ifTrue:Double, ifFalse:Double )
	If condition Return ifTrue Else Return ifFalse
EndFunction

Function iif:Int128( condition:Int, ifTrue:Int128, ifFalse:Int128 )
	If condition Return ifTrue Else Return ifFalse
EndFunction

Function iif:Float64( condition:Int, ifTrue:Float64, ifFalse:Float64 )
	If condition Return ifTrue Else Return ifFalse
EndFunction

Function iif:Float128( condition:Int, ifTrue:Float128, ifFalse:Float128 )
	If condition Return ifTrue Else Return ifFalse
EndFunction

Function iif:Double128( condition:Int, ifTrue:Double128, ifFalse:Double128 )
	If condition Return ifTrue Else Return ifFalse
EndFunction

Function iif:String( condition:Int, ifTrue:String, ifFalse:String )
	If condition Return ifTrue Else Return ifFalse
EndFunction

Function iif:Object( condition:Int, ifTrue:Object, ifFalse:Object )
	If condition Return ifTrue Else Return ifFalse
EndFunction

Function iif:Object( condition:Object, ifTrue:Object, ifFalse:Object )
	If condition Return ifTrue Else Return ifFalse
EndFunction

