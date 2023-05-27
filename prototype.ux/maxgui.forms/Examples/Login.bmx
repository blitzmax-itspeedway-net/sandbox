SuperStrict
'# LOGIN Example
'# Version 1.0
'# (c) Copyright Si Dunford, ITSpeedway.net, FEB 2015

Import Maxgui.drivers
Include "../maxgui-forms.bmx" 
'DebugStop

'Incbin "Login.bfd"


'Global login:LoginForm = New LoginForm
'login.Load( "Login.bfd" )	'# Loads a form HIDDEN


'If Not login Or Not login.show( MODAL ) Then End

'Notify( "Logged in successfully" )
'End

Global form:TForm = New TForm.Load( "Login.bfd", MessageQueue )
If Not form Then
	MessageQueue( "Failed to load form" )
	End
End If
'DebugStop
form.showmodal( True )

Repeat
	WaitEvent()
	Print CurrentEvent.ToString()
	Select EventID()
		Case EVENT_APPTERMINATE, EVENT_WINDOWCLOSE
			End
	End Select
Forever

'############################################################
Function MessageQueue( text:String, options:Int = 0 )
	DebugLog( text )
End Function
