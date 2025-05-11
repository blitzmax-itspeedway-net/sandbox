
'
'	Console Library for BlitzMax
'	(c) Copyright Si Dunford [Scaremonger], May 2025
'

Import "TConsoleBase.bmx"

?windows

Print "UNTESTED ON WINDOWS"

' Need to check/set ENABLE_VIRTUAL_TERMINAL_PROCESSING flag using
' SetConsoleMode() and GetConsoleMode()

Rem
Const STD_INPUT_HANDLE:Int
const INVALID_HANDLE_VALUE:int
EndRem

' hConsoleHandle Parameters
' https://learn.microsoft.com/en-us/windows/console/setconsolemode
Const ENABLE_ECHO_INPUT:Int             = $0004
Const ENABLE_INSERT_MODE:Int            = $0020
Const ENABLE_LINE_INPUT:Int             = $0002
Const ENABLE_MOUSE_INPUT:Int            = $0010
Const ENABLE_PROCESSED_INPUT:Int        = $0001
Const ENABLE_QUICK_EDIT_MODE:Int        = $0040
Const ENABLE_WINDOW_INPUT:Int           = $0008
Const ENABLE_VIRTUAL_TERMINAL_INPUT:Int = $0200

' When hConsoleHandle is a screen buffer
Const ENABLE_PROCESSED_OUTPUT:Int            = $0001
Const ENABLE_WRAP_AT_EOL_OUTPUT:Int          = $0002
Const ENABLE_VIRTUAL_TERMINAL_PROCESSING:Int = $0004
Const DISABLE_NEWLINE_AUTO_RETURN:Int        = $0008
Const ENABLE_LVB_GRID_WORLDWIDE:Int          = $0010
	
' nStdHandle Parameters
' https://learn.microsoft.com/en-us/windows/console/getstdhandle
Const STD_INPUT_HANDLE:Int  = -10
Const STD_OUTPUT_HANDLE:Int = -11
Const STD_ERROR_HANDLE:Int  = -12


Extern "C"
	' https://learn.microsoft.com/en-us/windows/console/getstdhandle
	'Function __GetStdHandle:int( stdHandle:Int ) 

	' https://learn.microsoft.com/en-us/windows/console/setconsolemode
	'Function __SetConsoleMode:Int( hConsoleHandle:Int, lpMode:Long var )

	' https://learn.microsoft.com/en-us/windows/console/getconsolemode
	'Function __GetConsoleMode:Int( hConsoleHandle:Int, dwMode:Long )

	' https://learn.microsoft.com/en-us/windows/console/readconsoleinput
	'Function __readConsoleInput:Int( hConsoleHandle:Int, lpBuffer:Byte ptr, nLength:int, lpNumberOfEventsRead:Int var )
EndExtern

Type TConsole Extends TConsoleBase

	Field hStdIn:Int
	
	Method New()
	
		hStdIn = __getStdHandle( STD_INPUT_HANDLE )
		If hStdIn = INVALID_HANDLE_VALUE
			ConsoleError( "getStdHandle() failed" )
		EndIf
		
		If Not( __getConsoleMode( hStdIn, fdSaveOldMode )
			ConsoleError( "Failed to backup using getConsoleMode()" )
		EndIf
		
		' Enable window and mouse input
		fdwMode = ENABLE_WINDOW_INPUT | ENABLE_MOUSE_INPUT
		If Not __setConsoleMode( hStdIn, fdwMode )
			ConsoleError( "Failed to set flags using setConsoleMode()" )
		EndIf
		
	EndMethod

	Method close()
		' Restore input mode on exit
		SetConsoleMode( hStdIn, fdwSaveOldMode )
	End Method
	
	Method Cls()
		'tputs( _CL, 1, putchar )
		WriteStdout( CMD[TERMCAPS.CL] )
	EndMethod
	
	Method Update()
		Local irInBuf:INPUT_RECORD[128]
		Local numRead:Int
		
		If Not __readConsoleInput( ..
			hStdIn, ..		' Input buffer handle
			irInBuf, ..		' Buffer to read attributes into
			128, ..
			numRead Var )
			ConsoleError( "readConsoleInput() failed" )
		EndIf
		
		For Local i:Int = 0 Until numread
			Select irInBuf[i].EventType
			Case FOCUS_EVENT
				onFocus( irInBuf[i].event.keyEvent )
			Case KEY_EVENT
				onKey( irInBuf[i].event.keyEvent )
			Case MENU_EVENT
				onMenu( irInBuf[i].event.keyEvent )
			Case MOUSE_EVENT
				onMouse( irInBuf[i].event.mouseEvent )
			Case WINDOW_BUFFER_SIZE_EVENT
				onResize( irInBuf[i].event.windowBufferSizeEvent )
			Default
				DebugLog( "Unknown event type: "+irInBuf[i].EventType )
			EndSelect
		Next
	EndMethod

	Method ConsoleError( message:String )
		Print message
		close()
		End
	EndMethod

End Type

Type KEY_EVENT_RECORD
	'TBC
End Type

?
