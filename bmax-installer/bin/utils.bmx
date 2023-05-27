'   BLITZMAX INSTALLER
'   (c) Copyright Si Dunford, May 2023, All Rights Reserved. 
'   VERSION: 1.0

'   CHANGES:
'   14 MAY 2023  Initial Creation
'

Function Die( title:String, subtitle:String="" )

	Print "## BMAX ERROR"
	Print "##"
	Print "## "+title
	If subtitle Print "##   "+subtitle
	exit_( 1 )
	
EndFunction

' Shows a block of strings
' You must set restoredata before calling
Function showdata( terminator:String="\\" )
	Local line:String
	ReadData( line )
	While line<>terminator
		Print line
		ReadData( line )
	Wend
	exit_(1)
End Function

' Creates a folder if it doesn't exist
Function MakeDirectory( folder:String )
	'DebugStop

	Select FileType(folder)
	Case FILETYPE_DIR	' Already exists
		Return
	Case 0				' Does not exist
		If Not CreateDir( folder )
			Print( "Unable to create '"+folder+"', please check your permissions" )
		End If
	Default				' A File of error condition
		Print( "Unable to create '"+folder+"'." )
	End Select
	
End Function

Function GetEnv:string( variable:String )
	Return getenv_( variable )
End Function
