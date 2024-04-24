SuperStrict

Local file:String = RealPath( AppFile )
Local path:String = ExtractDir( file )
Local name:String = StripAll( file )
Local extn:String = ExtractExt( file )
Local mode:Int    = FileMode( file )

Local temp:String = path + "/" + name + "_old." + extn
If FileType( temp )
	Print "OLD file exists"
	If Not DeleteFile( temp )
		Print "Unable to delete old file"
	End If
End If

Local state:Int = RenameFile( file, temp )
If state Then 
	Print "Renamed to "+temp
If CopyFile( "SayHello.debug", file )
	Print "File copied"
	SetFileMode( file, mode )
	Print "File updated"
	Local newfile:TProcess = CreateProcess( file )
	DetachProcess( newfile )
	End
Else
	Print "NEED TO FALLBACK"
End If
Else
	Print "UPDATE FAILED"
End If


	

