Function RAMdump( variable:Byte Ptr, size:Int )

	Local hexdump:String, values:String, position:Int = Int(variable)
	'Local finish:Int = SizeOf(Slocation)*MAXSIZE
	For Local d:Int = 0 Until size
		Local pointer:Byte Ptr
		Local value:Byte = variable[d]
		hexdump :+ Hex(value)[6..]+" "
		If value<32 Or value>127
			values :+ "."
		Else
			values :+ Chr(value)
		End If
		
		If d Mod 8 = 7
			Print Hex(position)[..10]+hexdump[..26]+values
			position = Int(variable)+d
			hexdump=""
			values=""
		End If
	Next
	If hexdump; Print Hex(position)[..10]+hexdump[..26]+values
End Function