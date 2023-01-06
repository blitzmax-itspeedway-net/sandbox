SuperStrict
 
Function LoadFile:String(filename:String)
	local file:TStream = ReadFile( filename )
	Local content:String
	if file
		While Not Eof( file )
			local line:string = ReadLine( file )
			content :+ line + "~n"
		Wend
		file.close()
	end if
	'file = ReadStream( filename )
	'If Not file Return ""
	'Print "- File Size: "+file.size()+" bytes"
	'content = ReadString( file, file.size() )
	'CloseStream file
	Return content
End Function

Try
	DebugStop
    Local text:String = loadFile( "initialize.txt" )
	DebugStop

    Print( "Loaded "+Len(text)+"bytes" )
    Print text
    DebugStop

    Print "I survived!"
Catch Exception:String
    Print "EXCEPTION:\n"+exception
End Try
