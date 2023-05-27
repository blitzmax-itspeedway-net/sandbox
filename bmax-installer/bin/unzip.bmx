
'	Decompression functions
'	(c) Based on code by GWRon on Discord, 2023

SuperStrict

Import archive.core
Import archive.zip

Global EVENT_UNZIP_START:Int = AllocUserEventId( "Starting file unzip" )
Global EVENT_UNZIP_ENTRY:Int = AllocUserEventId( "Unzipping file" )
Global EVENT_UNZIP_FINISH:Int = AllocUserEventId( "Finished file unzip" )

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

Function unzip( source:String, target:String, callback( event:Int, message:String="", data:Int=0 )=Null )
	unzip( source, "", target, callback )
End Function

Function unzip( source:String, path:String, target:String, callback( event:Int, message:String="", data:Int=0 )=Null )

	'	VALIDATION
	
	Select FileType( source )
	Case FILETYPE_NONE; Throw New TRuntimeException( "Missing archive" )
	Case FILETYPE_DIR; Throw New TRuntimeException( "Invalid archive" )
	End Select
	
	target = target.Replace("\\","/")
	If Not (target.endswith("/")); target :+ "/"

	path = path.Replace("\\","/")
	If path<>"" And Not (path.endswith("/")); path :+ "/"
		
	'	OPEN ARCHIVE
	Local ra:TReadArchive = New TReadArchive
	If Not ra; Throw New TRuntimeException( "Unable to create TReadArchive" )
	ra.SetFormat(EArchiveFormat.ZIP)
	ra.Open( source )

	'	CREATE TARGET FOLDER
	'	Deleting it if it exists first!
	
	Select FileType( target )
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
	
	If callback; callback( EVENT_UNZIP_START, source )
	
	While ra.ReadNextHeader(entry) = ARCHIVE_OK

		'DebugStop
		Local pathname:String = entry.pathname()
		'Print pathname
		
		Local dst:String
		If path=""
			' No filter applied
			dst = target+pathname
		ElseIf pathname.startswith( path )
			' Confirm path is required
			If Len(pathname)<=Len(path) ; Continue
			' Apply filter
			dst = target + pathname[path.length..]
		Else
			' We do not want to unzip this entry
			Continue
		EndIf
		'DebugStop
		'Print target + entry.pathname()[path.length..]
	
		' Delete existing entry to allow replace
		'Local dst:String = target+entry.pathname()
		
		Select FileType( dst )
		Case FILETYPE_DIR
			DeleteDir( dst, True )
		Case FILETYPE_FILE
			DeleteFile( dst )
		End Select

		' Process Entry
		Select entry.FileType()
		Case EArchiveFileType.Dir
			If callback; callback( EVENT_UNZIP_ENTRY, entry.pathname(), FILETYPE_DIR )
			' Create new folder
			CreateDir( dst, True )
			If entry.ModifiedTimeIsSet(); SetFileTime( dst, entry.ModifiedTime() )
		Case EArchiveFileType.File
			If callback; callback( EVENT_UNZIP_ENTRY, entry.pathname(), FILETYPE_FILE )
			' Write file to disk
			Local stream:TStream = WriteStream( dst )
			CopyStream( ra.DataStream(), stream )
			CloseStream( stream )
			If entry.ModifiedTimeIsSet(); SetFileTime( dst, entry.ModifiedTime() )
		Default
			New TRuntimeException( "Unknown Entry.Filetype() = "+entry.FileType().toString() )
		End Select

	Wend
	
	If callback; callback( EVENT_UNZIP_FINISH, source )
	
End Function

