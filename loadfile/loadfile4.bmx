SuperStrict

Function CacheAndLoadText$(url:Object)
	Local tmpResult$
	Local tmpBytes:Byte[] = LoadByteArray(url)
	url = CreateRamStream( tmpBytes, tmpBytes.length, True, False )
	tmpResult = LoadText(url)
	TRamStream(url).Close()
	Return tmpResult
EndFunction

'DebugStop
Local bank:TBank = LoadBank( "initialize.txt" )
Local size:Int = BankSize( bank ) 
Print( "BANK SIZE: "+size)

'ResizeBank( bank, size + 1 )
'PokeByte( bank, size, 0 )

' Get bank contents and convert to a string
'Local buff:Byte Ptr = LockBank(bank)
'Local text:String  = String.FromCString( buff )
'UnlockBank(bank)
'bank = Null

Local text:String
For Local n:Int = 0 Until size
	text :+ Chr( bank.PeekByte(n) )
Next
text :+ "XX"

Print( "Loaded "+Len(text)+"bytes" )


DebugStop
hexdump( text )


Function HexDump( text:String )
	Local addr:String, textline:String, hexline:String
	addr = Hex(0)
	For Local n:Int = 0 Until Len(text)
		Local ch:Int = Asc( text[n..n+1] )
		' Save Hex value
		hexline :+ Hex(ch)[6..]+" "
		' Save Character
		If ch>=32 And ch<127
			textline :+ Chr(ch)
		Else
			textline :+ "."
		End If
		If n Mod 16 = 15
			Print addr+"  "+hexline+"  "+textline
			addr = Hex(n)
			hexline=""
			textline=""
		End If
	Next
	If textline<>"" Print addr+"  "+hexline[..48]+"  "+textline

End Function


