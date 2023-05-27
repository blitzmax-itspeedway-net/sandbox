
'# TASK 1 - Counter
'# Example based on "7GUIs: A GUI Programming Benchmark"
'# https://eugenkiss.github.io/7guis/
'#
'# Version 1.0

Import MaxGUI.drivers
'Import MaxGUI.sizer
Include "../../maxgui.sizer/sizer-module.bmx"
' Import MaxGUI.forms
Include "../maxgui-forms.bmx"

Global form:TForm = New TForm.Load( "Task1-Counter.bfd" )
Global value:TTexbox = TTextbox( form.find("value") )

'form.find("button").event( EVENT_ONCLICK, onClick )
form.setevent( "button", EVENT_ONCLICK, onClick )

form.show()
form.wait()

Function onClick( event:TEvent )
	value.set( value.getint() + 1 )	
End Function

Rem "Task1-Counter.bfd"
; TASK 1 - Counter
FORM "Counter"
	SIZER HORIZONTAL
		TTextBox "value" "0"
			readonly=1
		END
		TButton "button"
		END
	END
END
end rem