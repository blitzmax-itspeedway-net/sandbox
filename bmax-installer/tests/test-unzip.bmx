
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

Function unzip( source:String, target:String )

	'	VALIDATION
	
	Select FileType( source )
	Case FILETYPE_NONE; Throw New TRuntimeException( "Missing archive" )
	Case FILETYPE_DIR; Throw New TRuntimeException( "Invalid archive" )
	End Select
	
	target = target.Replace("\\","/")
	If Not (target.endswith("/")); target :+ "/"
		
	'	OPEN ARCHIVE
	Local ra:TReadArchive = New TReadArchive
	If Not ra; Throw New TRuntimeException( "Unable to create TReadArchive" )
	ra.SetFormat(EArchiveFormat.ZIP)
	ra.Open( source )

	'	CREATE TARGET FOLDER
	
	Select FileType( target )
	'Case FILETYPE_NONE
	'	CreateDir( target, True )
	Case FILETYPE_FILE
		DeleteFile( target )
	Case FILETYPE_DIR
		DeleteDir( target, True )
	End Select
	CreateDir( target, True )
	SetFileTime( target, FileTime( source ) )

	'	Loop through archive records

	Local entry:TArchiveEntry = New TArchiveEntry
	If Not entry; Throw New TRuntimeException( "Unable to create TArchiveEntry" )
	
	While ra.ReadNextHeader(entry) = ARCHIVE_OK
		Print "File :    " + entry.Pathname()
		'Print "Size :    " + entry.Size()
		'Local file_type:EArchiveFileType = entry.FileType()
		'Print "Type :    " + entry.FileType().ToString()
		'Print "Access:   " + IIF( entry.accessTimeIsSet(), "SET", "UNSET" ) + ", " + entry.AccessTime()
		'Print "Birth:    " + IIF( entry.birthTimeIsSet(), "SET", "UNSET" ) + ", " + entry.Birthtime()
		'Print "Modified: " + IIF( entry.ModifiedTimeIsSet(), "SET", "UNSET" ) + ", " + entry.ModifiedTime()
		'Local s:String = LoadText(ra.DataStream())
		'Print "String size   : " + s.length
		'Print "First n chars : " + s[0..17]
		'Print
		'DebugStop
		'
		Local dst:String = target+entry.pathname()
		'Print "Destination: "+ dst
		
		Select entry.FileType()
		Case EArchiveFileType.Dir
			Select FileType( dst )
			'Case FILETYPE_NONE
			'	Print "- Make directory"
			'	CreateDir( dst, True )
			Case FILETYPE_FILE
			'	Print "- File exists where directory should be"
				DeleteFile( dst )
			Case FILETYPE_DIR
			'	Print "- Directory already exists"
				DeleteDir( dst, True )
			End Select
			' Create new folder
			CreateDir( dst, True )
			If entry.ModifiedTimeIsSet()
				SetFileTime( dst, entry.ModifiedTime() )
			End If
		Case EArchiveFileType.File
			'DebugStop
			Select FileType( dst )
			'Case FILETYPE_NONE
			'	Print "- New File"
			Case FILETYPE_DIR
			'	Print "- Directory exists where file should be"
				DeleteDir( dst, True )
			Case FILETYPE_FILE
			'	Print "- File exists"
				DeleteFile( dst )
			End Select
			' Write file to disk
			Local stream:TStream = WriteStream( dst )
			CopyStream( ra.DataStream(), stream )
			CloseStream( stream )
			If entry.ModifiedTimeIsSet()
				SetFileTime( dst, entry.ModifiedTime() )
			End If
		Default
			New TRuntimeException( "Unknown Entry.Filetype() = "+entry.FileType().toString() )
		End Select
		
	Wend
	
End Function

' Unzip and Overwrite
Try
	unzip( ARCHIVE, DESTINATION )
Catch e:TRuntimeException
	Print e.error
Catch e:String
	Print e
End Try



