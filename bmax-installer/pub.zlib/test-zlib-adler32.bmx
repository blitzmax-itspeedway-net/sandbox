
'	Test ZLIB Adler32 Checksum

SuperStrict

Import "../pub.zlib/zlib-wrapper.bmx"
Import "../bin/adler32.bmx"

Const TESTCOUNT:Int = 100000

' Load some data

Local Lorem_Ipsum:String = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
Local start:Int, Checksum:UInt

' Scaremonger version
Print "Scaremonger: "+Hex( Adler32_Checksum( Lorem_Ipsum, Len(Lorem_Ipsum) ) )

start = MilliSecs()
For Local n:Int = 0 Until TESTCOUNT
	Checksum = Adler32_Checksum( Lorem_Ipsum, Len(Lorem_Ipsum) )
Next
Print MilliSecs()-start + "ms"

' Zlib Version
Print "Zlib: "+Hex( Zlib.Adler32( Lorem_Ipsum ) )

start = MilliSecs()
For Local n:Int = 0 Until TESTCOUNT
	Checksum = Zlib.Adler32( Lorem_Ipsum )
Next
Print MilliSecs()-start + "ms"


