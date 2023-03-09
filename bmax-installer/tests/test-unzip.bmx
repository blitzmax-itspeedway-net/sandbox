
SuperStrict

Import archive.core
Import archive.zip

Import "../../bmx.datetime/datetime.bmx"

Local ARCHIVE:String = "/home/si/BlitzMax.Downloads.2023-02-08/bah.mod-master.zip"

Local DESTINATION:String = "/home/si/BlitzMax.Downloads.2023-02-08/bah.mod-master"

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

Local entry:TArchiveEntry = New TArchiveEntry

Local ra:TReadArchive = New TReadArchive
ra.SetFormat(EArchiveFormat.ZIP)
ra.Open( ARCHIVE )

While ra.ReadNextHeader(entry) = ARCHIVE_OK
	Print "File :    " + entry.Pathname()
	Print "Size :    " + entry.Size()
	Print "Type :    " + entry.FileType().ToString()
	Print "Access:   " + IIF( entry.accessTimeIsSet(), "SET", "UNSET" ) + ", " + entry.AccessTime()
	Print "Birth:    " + IIF( entry.birthTimeIsSet(), "SET", "UNSET" ) + ", " + entry.Birthtime()
	Print "Modified: " + IIF( entry.ModifiedTimeIsSet(), "SET", "UNSET" ) + ", " + entry.ModifiedTime()
	Local s:String = LoadText(ra.DataStream())
	Print "String size   : " + s.length
	Print "First n chars : " + s[0..17]
	Print
	DebugStop
Wend
