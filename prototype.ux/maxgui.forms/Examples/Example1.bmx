SuperStrict
'# EXAMPLE 1
'# This example loads a Blitzmax Form (*.bmf)

Import Maxgui.drivers
'Impot MaxGui.forms
Include "../maxgui-forms.bmx" 

'# Load a Blitzmax Form
'DebugStop
Global form:TForm = New TForm.Load( "example1.bfd", MessageQueue )
If Not form Then
	DebugLog "Failed to load form"
	End
End If
'DebugStop
form.show()

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



