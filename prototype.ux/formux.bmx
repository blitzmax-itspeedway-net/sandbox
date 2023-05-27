' FORM UX
' Form-Based GUI library

SuperStrict

Import "FormUX/FormUX.bmx"

'#	DRAWN GRAPHICS

Graphics 800,600

Local form:TForm = FormUX.load( "vbsform.frm" )

Repeat
	Cls
	
	form.showModal()
	
	Flip
Until KeyHit( KEY_ESCAPE_ ) Or AppTerminate()





