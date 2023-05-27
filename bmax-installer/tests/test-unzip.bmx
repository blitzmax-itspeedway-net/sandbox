
SuperStrict

Import "../bin/unzip.bmx"

DebugStop

Local ARCHIVE:String = "/home/si/BlitzMaxTest/setup/bah.mod-master.zip"

Local DESTINATION:String = "/home/si/BlitzMaxTest/test/"

' Callback for unzip
Function unzipNotifier( event:Int, pathname:String, data:Int=0 )
	Global begin:Int

	Select event
	Case EVENT_UNZIP_START
		Print( "Unzipping "+pathname )
		begin = MilliSecs()
	Case EVENT_UNZIP_ENTRY
		Print( "* "+pathname )
	Case EVENT_UNZIP_FINISH
		Print( "Completed in "+(MilliSecs()-begin)+"ms" )
	EndSelect
	
End Function

' Unzip and Overwrite
Try
	'unzip( ARCHIVE, DESTINATION, unzipNotifier )
	unzip( ARCHIVE, "bah.mod-master/clipboard.mod", "/home/si/BlitzMaxTest/mod/bah.mod/clipboard.mod", unzipnotifier )
Catch e:TRuntimeException
	Print e.error
Catch e:String
	Print e
End Try



