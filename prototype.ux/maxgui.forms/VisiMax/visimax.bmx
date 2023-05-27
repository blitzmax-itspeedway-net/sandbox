'# VisiMAX
'# A WYSIWYG Form Developer for MaxGUI
'#
'# All used forms are created by this application (WILL BE LATER)
'#
SuperStrict
Import maxgui.drivers
Import MaxGUI.ProxyGadgets
'Import maxgui.forms
Include "../maxgui-forms.bmx"

'# Configuration
Include "bin/config.bmx"

'# CREATE THE APPLICATION WINDOWS
Include "bin/TGadget_Form.bmx"
Include "forms/designer.bmx"

'# MAIN WINDOW
'incbin "forms/main.bfd"
'local main:TForm = LoadForm( "incbin::forms/main.bfd" )
Include "forms/main.bmx"

'# OBJECT PROPERTIES
'incbin "forms/properties.bfd"
'local properties:TForm = LoadForm( "incbin::forms/properties.bfd" )
Include "forms/properties.bmx"

'# TOOLBOX
'incbin "forms/toolbox.bfd"
'local toolbox:TForm = LoadForm( "incbin::forms/toolbox.bfd" )
Include "forms/toolbox.bmx"

'# MESSAGE WINDOW
'incbin "forms/messages.bfd"
'local messages:TForm = LoadForm( "incbin::forms/messages.bfd" )
Include "forms/messages.bmx"

Repeat
	WaitEvent()
	Print "::"+CurrentEvent.ToString()
	Select EventID()
	Case EVENT_APPTERMINATE,EVENT_WINDOWCLOSE
		If EventSource()=mainform.win Then End
	End Select
Forever

