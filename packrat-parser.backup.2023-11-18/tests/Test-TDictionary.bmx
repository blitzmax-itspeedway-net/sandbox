SuperStrict

Import "../bin/TDictionary.bmx"

Function testmap( data:String[] )
	Print( "TMap()" )
	Local list:TMap = New TMap()

	For Local item:String = EachIn data
		list.insert( item, item )
	Next

	For Local item:String = EachIn list.keys()
		Print "  "+item
	Next
End Function

Function teststringmap( data:String[] )
	Print( "TStringMap()" )
	Local list:TStringMap = New TStringMap()

	For Local item:String = EachIn data
		list.insert( item, item )
	Next

	For Local item:String = EachIn list.keys()
		Print "  "+item
	Next
End Function

Function testdict( data:String[] )
	Print( "TDictionary()" )
	Local list:TDictionary = New TDictionary()

	For Local item:String = EachIn data
		list.addLast( item, item )
	Next

	For Local item:String = EachIn list.keys()
		Print "  "+item
	Next

End Function

Local data:String[] = ["ONE", "TWO", "THREE", "FOUR", "FIVE", "SIX", "SEVEN", "EIGHT" ]

testmap( data )
teststringmap( data )
testdict( data )

