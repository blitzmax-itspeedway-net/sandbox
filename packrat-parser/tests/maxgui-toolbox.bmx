SuperStrict
Import maxgui.drivers
DebugStop
toolbox( "EXAMPLE" )
DebugStop



Function toolbox( title:String )

	Local window:TGadget = CreateWindow( title, 100, 100, 320, 240 )
	Repeat
		WaitEvent()
		Select EventID()
		Case EVENT_MOUSEMOVE	' Hide these; it makes it easier to debug
		Case EVENT_APPTERMINATE, EVENT_WINDOWCLOSE
			Print CurrentEvent.ToString()
			Exit
		Default
			Print CurrentEvent.ToString()
		End Select
	Forever

	' When we get here, the window should be closed
	FreeGadget( window )
	window = Null	
	
	'	WHEN YOU GET HERE
	'	DO NOT PRESS STEP OR RUN
	'	WAIT AND YOU GET
	'	"Your application is not responding"
	DebugStop
End Function


Function eventhook

emiteventhook