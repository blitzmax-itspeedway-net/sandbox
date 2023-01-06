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
Local text:String = CacheAndLoadText( "initialize.txt" )
Print( "Loaded "+Len(text)+"bytes" )
text = text[.. text.length - 2]
'text = text + "}"
 
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


