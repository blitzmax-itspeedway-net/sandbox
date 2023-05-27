SuperStrict
Import maxgui.drivers
'Import MaxGUI.ProxyGadgets
'Import maxgui.forms
'Include "../maxgui-forms.bmx"

'# Configuration
'Include "bin/config.bmx"

'# CREATE THE APPLICATION WINDOWS
Include "../bin/TGadget_Form.bmx"


Global WinMain:TDock = New TDock.Create()

Const MENU_FILEMENU:Int = 1
Const MENU_VIEWMENU:Int = 3

Const MENU_EXIT:Int		= 105
	
Const MENU_DOCK:Int		= 300
Const MENU_ONE:Int		= 301
Const MENU_TWO:Int		= 302

'# Add dockable menus
New TDockable.Create( "First", MENU_ONE )
New TDockable.Create( "Second", MENU_TWO )

Type TDock Extends TGadget_Form
Field menu:TGadget[4]

	'------------------------------------------------------------
	Method New()
	AddHook( EmitEventHook, EventHook, Self )
	End Method
	
	'------------------------------------------------------------
	Method Delete()
	RemoveHook( EmitEventHook, EventHook, Self )
	End Method

	'------------------------------------------------------------
	Method Create:TDock()
	Local x:Int = 0
	Local y:Int = 0
	Local w:Int = 300
	Local h:Int = ClientHeight( Desktop() )
	Local s:Int = WINDOW_TITLEBAR | WINDOW_ACCEPTFILES | WINDOW_RESIZABLE
		'# WINDOW
		win  = CreateWindow( "Dock", x,y,w,h, Null, s )
		name = "Main"
		'# MENU
		menu[ MENU_FILEMENU ] = CreateMenu( "&File", 0, WindowMenu( win ))
		CreateMenu "E&xit", MENU_EXIT, menu[ MENU_FILEMENU ], KEY_F4, MODIFIER_COMMAND

		menu[ MENU_VIEWMENU ] = CreateMenu( "&View", 0, WindowMenu( win ))
		
		UpdateWindowMenu win
		
		Return Self
	End Method

	'------------------------------------------------------------
	Method onMenuAction:Int( event:TEvent )
		'# Handle menu options for dockable toolbars
'DebugStop
		Local docked:TDockable = TDockable(TGadget(event.source).extra)
		If docked Then Return docked.onMenuAction( event )
	Return False
	End Method

	'------------------------------------------------------------
	Method onMouseEnter:Int( event:TEvent )
	
	End Method

	'------------------------------------------------------------
	Method onMouseLeave:Int( event:TEvent )
	End Method

End Type

Type TDockable Extends TGadget_Form
Global dockable:TList = CreateList()
Field menuitem:TGadget
	'------------------------------------------------------------
	Method New()
		AddHook( EmitEventHook, EventHook, Self )
		link = ListAddLast( dockable, Self )
	End Method
	
	'------------------------------------------------------------
	Method Delete()
	RemoveHook( EmitEventHook, EventHook, Self )
	End Method

	'------------------------------------------------------------
	Method Create:TDockable( title:String, menu:Int )
	Local x:Int = GadgetWidth( winmain.win ) + (dockable.count()-1) * 30
	Local y:Int = (dockable.count()-1) * 30
	Local w:Int = 200
	Local h:Int = 200
	Local s:Int = WINDOW_TITLEBAR | WINDOW_TOOL | WINDOW_RESIZABLE
		'# WINDOW
		win  = CreateWindow( title, x,y,w,h, Null, s )
		name = title
'DebugStop
		'# Add self to Main Window Menu
		menuitem = CreateMenu( title, menu, winmain.menu[ MENU_VIEWMENU ] )
		menuitem.extra=Self
		CheckMenu( menuitem )

		UpdateWindowMenu winmain.win
'If Not menuitem Then DebugStop
		Return Self
	End Method

	'------------------------------------------------------------
	'# Only ever hide the toolbox windows.
	Method onWindowClose:Int( event:TEvent )
		If event.source<>win Then Return False
		UncheckMenu( menuitem )
		HideGadget( win )
		Return True
	End Method

	'------------------------------------------------------------
	Method onMenuAction:Int( event:TEvent )
'		If event.source<>Self Then Return False
		If MenuChecked( menuitem ) Then
			UncheckMenu( menuitem )
			HideGadget( win )
		Else
			CheckMenu( menuitem )
			ShowGadget( win )
		End If
		UpdateWindowMenu winmain.win
	Return True
	End Method

	'------------------------------------------------------------
	Method onMouseDown:Int( event:TEvent )
	End Method

	'------------------------------------------------------------
	Method onMouseUp:Int( event:TEvent )
	End Method

	'------------------------------------------------------------
	Method onMouseMove:Int( event:TEvent )
	End Method

End Type

Repeat
	WaitEvent()
	Print "::"+CurrentEvent.ToString()
	Select EventID()
	Case EVENT_APPTERMINATE,EVENT_WINDOWCLOSE
		If EventSource()=winmain.win Then End
	End Select
Forever






