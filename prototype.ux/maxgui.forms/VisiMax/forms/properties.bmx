'# INSPECTOR
'# VERSION 1.0
'#
'# CURRENTLY THIS IS PURE MAXGUI - LATER IT WILL BE FORMS
'#
Global inspectorform:TInspect_Form = New TInspect_Form.Create()

'############################################################
Type TInspect_Form Extends TGadget_Form

	'------------------------------------------------------------
	Method New()
	AddHook( EmitEventHook, EventHook, Self )
	name="Inspector"
	End Method
	
	'------------------------------------------------------------
	Method Delete()
	RemoveHook( EmitEventHook, EventHook, Self )
	End Method
	
	'------------------------------------------------------------
	Method Create:TInspect_Form()
	Local x:Int = GadgetX(mainform.win)
	Local y:Int = GadgetY(mainform.win)+GadgetHeight(mainform.win)
	Local w:Int = 200
	Local h:Int = ClientHeight( Desktop() ) -100 - y
	Local s:Int = WINDOW_TITLEBAR | WINDOW_TOOL '| WINDOW_HIDDEN
		'# WINDOW
		win = CreateWindow( "Inspector", x,y,w,h, Null, s )
		
		'# TABBAR
		
	Return Self
	End Method

	'------------------------------------------------------------
	Method show()
	ShowGadget(win)
	End Method

	'------------------------------------------------------------
	Method hide()
	HideGadget(win)
	End Method

	'------------------------------------------------------------
	Method onWindowClose:Int( event:TEvent )
'		hide()
	Return False
	End Method
	
End Type
	
	



