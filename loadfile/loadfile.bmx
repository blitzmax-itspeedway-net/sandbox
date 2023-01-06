SuperStrict
 
Function LoadFile:String(filename:String)
	Local file:TStream = ReadStream( filename )
	If Not file Return ""
	Print "- File Size: "+file.size()+" bytes"
	Local content:String = ReadString( file, file.size() )
	CloseStream file
	Return content
End Function

Try
	DebugStop
    Local text:String = loadFile( "initialize.txt" )


    Print( "Loaded "+Len(text)+"bytes" )
    Print text
    DebugStop

    Print "I survived!"
Catch Exception:String
    Print "EXCEPTION:\n"+exception
End Try
