
SuperStrict

Extern
	Function bmx_stringbuilder_matches:Int(buffer:Byte Ptr, beginIndex:Int, subString:String)
End Extern

Type TStringBuilderPlus Extends TStringBuilder

	Rem
	bbdoc: Returns true if string starts with @subString.
	End Rem
	Method StartsWith:Int( subString:String, start:Int )
		Return bmx_stringbuilder_matches( buffer, start, subString )
	End Method
End Type


Local sb:TStringBuilderPlus = New TStringBuilderPlus()

sb.append( "Hello World, what a great day" )

If sb.startswith( "World", 6 ); Print "YES"