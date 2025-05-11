Strict

Rem
tails the god
15/02/2025, 21:44
Hey i was making a tooolbar with each of the icons being 18 x 18 but For some reason the icons 
are duplicating in the spots that suppose To be separators
Please help 

tails the god
16/02/2025, 19:42
Well its just the toolbar code i used in the documentation
But changed the pic To use the blitz3d ide_toolbar.bmp i converted To a png with alpha
End Rem

Import MaxGui.Drivers

AppTitle = "ToolBar Example"

Global window:TGadget = CreateWindow( AppTitle, 100, 100, 400, 32, Null, WINDOW_TITLEBAR|WINDOW_STATUS|WINDOW_RESIZABLE|WINDOW_CLIENTCOORDS )

	Global toolbar:TGadget = CreateToolBar( "ide_toolbar.bmp", 0, 0, 0, 0, window )

	DisableGadgetItem toolbar, 2
	
	SetToolBarTips toolbar, ["New", "Open", "Save should be disabled."] 
	
	AddGadgetItem toolbar, "", 0, GADGETICON_SEPARATOR	'Add a separator.
	AddGadgetItem toolbar, "Toggle", GADGETITEM_TOGGLE, 2, "This toggle button should change to a light bulb when clicked."

	'InsertGadgetItem toolbar, 2, "", GADGETICON_SEPARATOR	'Add a separator.

	Global button:TGadget = CreateButton( "Show/Hide Toolbar", 2, 2, 180, 28, window )
	SetGadgetLayout button, EDGE_ALIGNED, EDGE_CENTERED, EDGE_ALIGNED, EDGE_CENTERED
	
While WaitEvent()
	Print CurrentEvent.ToString()
	Select EventID()
		Case EVENT_WINDOWCLOSE, EVENT_APPTERMINATE;End
		'ToolBar Event(s)
		'EventData() holds the index of the toolbar item clicked.
		Case EVENT_GADGETACTION
			Select EventSource()
				Case button
					If GadgetHidden(toolbar) Then ShowGadget(toolbar) Else HideGadget(toolbar)
				Case toolbar 
					SetStatusText window, "Toolbar Item Clicked: " + EventData()
			EndSelect
	End Select
Wend