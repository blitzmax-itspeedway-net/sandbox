'# TFORM
'# (c) Copyright Si Dunford, ITSpeedway.net, Feb 2015

'############################################################
Type TForm
Field window:GWindow

	'------------------------------------------------------------
	Function Enable( driver:T)

	'------------------------------------------------------------
	Method New()
'		driver = New TFormDriverMAXGUI
	End Method

	'------------------------------------------------------------
	Method Hide()
	End Method

	'------------------------------------------------------------
	Method Load( content:String )
	End Method

	'------------------------------------------------------------
	Method Show( ModalForm:Int = False )
	End Method

	'------------------------------------------------------------
	Method Unload()
	End Method

End Type