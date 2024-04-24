SuperStrict

' Creates 20 dummy include files in a folder that will be used for testing

Local numbers:String[] = ["One","Two","Three","Four","Five","Six","Seven","Eight","Nine","Ten","Eleven","Twelve","Thirteen","Fourteen","Fifteen","Sixteen","Seventeen","Eighteen","Nineteen","Twenty"]

If FileType( "includes" ) = FILETYPE_NONE; CreateDir( "includes" )

For Local num:String = EachIn numbers

	Local file:TStream = WriteStream( "includes/"+num+".bmx" )

	WriteLine( file, "SuperStrict" )
	WriteLine( file, "" )
	WriteLine( file, "Function "+num+"()" )
	WriteLine( file, "~tPrint "+Chr(34)+num+Chr(34) )
	WriteLine( file, "End Function" )

	CloseStream( file )

Next