
SuperStrict

Import archive.core
Import archive.zip

'Import "../../bmx.datetime/datetime.bmx"

DebugStop

Local ARCHIVE:String = "/home/si/BlitzMax.Downloads.2023-02-08/bah.mod-master.zip"

Local DESTINATION:String = "/home/si/BlitzMax.Downloads.2023-02-08/example"

Function SetFileTime( path:String, time:Long, timeType:Int=FILETIME_MODIFIED)
	FixPath path
	If MaxIO.ioInitialized Then
		' Not available
	Else
		Select timetype
			Case FILETIME_MODIFIED
				utime_(path, timeType, time)
			Case FILETIME_ACCESSED
				utime_(path, timeType, time)
		End Select
	End If
End Function

Function IIF:String( bool:Int, isTrue:String, isFalse:String )
	If bool; Return isTrue
	Return isFalse
End Function

Function unzip( source:String, target:String, overwrite:Int = True )

	'	VALIDATION
	
	Select FileType( source )
	Case FILETYPE_NONE; Throw New TRuntimeException( "Missing archive" )
	Case FILETYPE_DIR; Throw New TRuntimeException( "Invalid archive" )
	End Select
	
	target = target.Replace("\\","/")
	If Not (target.endswith("/")); target :+ "/"
	
	Select FileType( target )
	Case FILETYPE_NONE
		CreateDir( target, True )
	Case FILETYPE_FILE
		If overwrite
	
	Local entry:TArchiveEntry = New TArchiveEntry

	Local ra:TReadArchive = New TReadArchive
	ra.SetFormat(EArchiveFormat.ZIP)
	ra.Open( source )
	DebugStop

	Local target:String = DESTINATION
	

	While ra.ReadNextHeader(entry) = ARCHIVE_OK
		Print "File :    " + entry.Pathname()
		Print "Size :    " + entry.Size()
		Local file_type:EArchiveFileType = entry.FileType()
		Print "Type :    " + entry.FileType().ToString()
		Print "Access:   " + IIF( entry.accessTimeIsSet(), "SET", "UNSET" ) + ", " + entry.AccessTime()
		Print "Birth:    " + IIF( entry.birthTimeIsSet(), "SET", "UNSET" ) + ", " + entry.Birthtime()
		Print "Modified: " + IIF( entry.ModifiedTimeIsSet(), "SET", "UNSET" ) + ", " + entry.ModifiedTime()
		Local s:String = LoadText(ra.DataStream())
		Print "String size   : " + s.length
		Print "First n chars : " + s[0..17]
		Print
		DebugStop
		'
		Select entry.FileType()
		Case EArchiveFileType.Dir
			Local dst:String = target+entry.pathname()
			Print "Destination: "+ dst
			Select FileType( dst )
			Case FILETYPE_DIR
				Print "- Directory already exists"
			Case FILETYPE_FILE
				Print "- File exists where directory should be"
			Default
				Print "- Make directory"
			End Select
		Default
			Print "Unknown Entry.Filetype() = "+entry.FileType().toString()
		End Select
		
	Wend
	
End Function

' Unzip and Overwrite
unzip( ARCHIVE, DESTINATION )


