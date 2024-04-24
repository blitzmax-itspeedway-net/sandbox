' STRUCT TEST

Struct SMatch
	Field start:Int
	Field finish:Int
	Field error:Int = False
	
	' Assigning SELF to a variable copies it
	Method toPointer:String()
		'DebugStop
		Local this:SMatch = Self
		Local P:Byte Ptr = Varptr this
		Return Hex(Int(P))
	End Method

	' Passing byref uses the original
	Method asPointer:String( this:SMatch Var )
		Local P:Byte Ptr = Varptr this
		Return Hex(Int(P))
	End Method	

End Struct

' The struct is created in the function but RETURN copies it
' The use of NEW() is optional and does not modify the struct (unless you pass arguments)
Function make:SMatch()
	'DebugStop
	Local S:SMatch
	'S = New SMatch()
	Local P:Byte Ptr = Varptr S
	Print "a."+Hex(Int(p))
	Print "b."+S.toPointer()
	Print "c."+S.asPointer( S )
	Return S
End Function

DebugStop

Print "UNDEFINED"

Local s:SMatch
Local P:Byte Ptr = Varptr S
Print "1."+Hex(Int(p))
Print "2."+S.toPointer()
Print "3."+S.asPointer( S )

Print "~nLOCAL VERSION"
s = New SMatch()
P = Varptr S
Print "1."+Hex(Int(p))
Print "2."+S.toPointer()
Print "3."+S.asPointer( S )

Print "~nFUNCTION"
s = make()
P = Varptr S
Print "1."+Hex(Int(p))
Print "2."+S.toPointer()
Print "3."+S.asPointer( S )

DebugStop


