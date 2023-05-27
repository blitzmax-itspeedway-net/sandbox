'# MAIN FORM
'# VERSION 1.0
'#
'# CURRENTLY THIS IS PURE MAXGUI - LATER IT WILL BE FORMS
'#
Global MainForm:TMain_Form = New TMain_Form.Create()

'############################################################
Type TMain_Form Extends TGadget_Form
'Field win:TGadget
Field menu:TGadget[10]
Field toolbar:TGadget
Field inspector:TInspect_Form

	Const MENU_FILEMENU:Int = 1
	Const MENU_EDITMENU:Int = 2
	Const MENU_HELPMENU:Int = 9
	
	Const MENU_NEW:Int		= 101
	Const MENU_OPEN:Int		= 102
	Const MENU_SAVE:Int		= 103
	Const MENU_CLOSE:Int	= 104
	Const MENU_EXIT:Int		= 105
	
	Const MENU_CUT:Int		= 206
	Const MENU_COPY:Int		= 207
	Const MENU_PASTE:Int	= 208
	
	Const MENU_ABOUT:Int	= 909

	'------------------------------------------------------------
	Method New()
	AddHook( EmitEventHook, EventHook, Self )
	name="WinMain"
	End Method
	
	'------------------------------------------------------------
	Method Delete()
	RemoveHook( EmitEventHook, EventHook, Self )
	End Method
	
	'------------------------------------------------------------
	Method Create:TMain_Form()
	Local x:Int = config.getint( "MAIN.X" )
	Local y:Int = config.getint( "MAIN.Y" )
	Local w:Int = config.getint( "MAIN.W" )
	Local h:Int = config.getint( "MAIN.H" )
	Local s:Int = WINDOW_TITLEBAR | WINDOW_MENU | WINDOW_ACCEPTFILES
		'# WINDOW
		win = CreateWindow( "Project", x,y,w,h, Null, s )
		
		'# MENU
		menu[ MENU_FILEMENU ] = CreateMenu( "&File", 0, WindowMenu( win ))
		CreateMenu "&New", MENU_NEW, menu[ MENU_FILEMENU ], KEY_N, MODIFIER_COMMAND
		CreateMenu "&Open", MENU_OPEN, menu[ MENU_FILEMENU ], KEY_O, MODIFIER_COMMAND
		CreateMenu "&Close", MENU_CLOSE, menu[ MENU_FILEMENU ], KEY_W, MODIFIER_COMMAND
		CreateMenu "", 0, menu[ MENU_FILEMENU ]
		CreateMenu "&Save", MENU_SAVE, menu[ MENU_FILEMENU ], KEY_S, MODIFIER_COMMAND
		CreateMenu "", 0, menu[ MENU_FILEMENU ]
		CreateMenu "E&xit", MENU_EXIT, menu[ MENU_FILEMENU ], KEY_F4, MODIFIER_COMMAND
		
		menu[ MENU_EDITMENU ] = CreateMenu( "&Edit", 0, WindowMenu( win ))
		CreateMenu "Cu&t", MENU_CUT, menu[ MENU_EDITMENU ], KEY_X, MODIFIER_COMMAND
		CreateMenu "&Copy", MENU_COPY, menu[ MENU_EDITMENU ], KEY_C, MODIFIER_COMMAND
		CreateMenu "&Paste", MENU_PASTE, menu[ MENU_EDITMENU ], KEY_V, MODIFIER_COMMAND
		
		menu[ MENU_HELPMENU ] =CreateMenu( "&Help", 0, WindowMenu( win ))
		CreateMenu "&About", MENU_ABOUT, menu[ MENU_HELPMENU ]
		
		UpdateWindowMenu win

		'# TOOLBAR
'		TIconStrip LoadIconstrip
		toolbar = CreateToolbar( "toolbar.png", 0, 0, 0, 0, win )
		SetToolbarTips toolbar, ["New", "Open", "Save should be disabled."] 
		
	Return Self
	End Method

	'------------------------------------------------------------
	'# Return value should whether you have processed or not
	Method xonEvent:Int( event:TEvent )
		If event.source<>win Then Return False	
		Select event.id
'		Case EVENT_APPSUSPEND 		; return onAppSuspend( event )		' Application suspended 
'		Case EVENT_APPRESUME 		; return onAppResume( event )		' Application resumed 
'		Case EVENT_APPTERMINATE 	; return onAppTerminate( event )	' Application wants To terminate 
'		Case EVENT_KEYDOWN 			; return onKeyDown( event )			' Key pressed. Event data contains keycode 
'		Case EVENT_KEYUP 			; return onKeyUp( event )			' Key released. Event data contains keycode 
'		Case EVENT_KEYCHAR 			; return onKeyChar( event )			' Key character. Event data contains unicode value 
'		Case EVENT_MOUSEDOWN 		; return onMouseDown( event )		' Mouse button pressed. Event data contains mouse button code 
'		Case EVENT_MOUSEUP 			; return onMouseUp( event )			' Mouse button released. Event data contains mouse button code 
'		Case EVENT_MOUSEMOVE 		; return onMouseMove( event )		' Mouse moved. Event x And y contain mouse coordinates 
'		Case EVENT_MOUSEWHEEL 		; return onMouseWheel( event )		' Mouse wheel spun. Event data contains delta clicks 
'		Case EVENT_MOUSEENTER 		; return onMouseEnter( event )		' Mouse entered gadget area 
'		Case EVENT_MOUSELEAVE 		; return onMouseLeave( event )		' Mouse Left gadget area 
'		Case EVENT_TIMERTICK 		; return onTimerTick( event )		' Timer ticked. Event source contains timer Object 
'		Case EVENT_HOTKEYHIT 		; return onHotKeyHit( event )		' Hot key hit. Event data And mods contains hotkey keycode And modifier 
		Case EVENT_MENUACTION 		; Return onMenuAction( event )		' Menu has been selected 
'		Case EVENT_WINDOWMOVE 		; return onWindowMove( event )		' Window has been moved 
'		Case EVENT_WINDOWSIZE 		; return onWindowSize( event )		' Window has been resized 
'		Case EVENT_WINDOWCLOSE 		; return onWindowClose( event )		' Window close icon clicked 
'		Case EVENT_WINDOWACTIVATE	; return onWindowActivate( event )	' Window activated 
'		Case EVENT_WINDOWACCEPT 	; return onWindowAccept( event )	' Drag And Drop operation was attempted 
'		Case EVENT_GADGETACTION 	; return onGadgetAction( event )	' Gadget state has been updated 
'		Case EVENT_GADGETPAINT 		; return onGadgetPaint( event )		' A Canvas Gadget needs To be redrawn 
'		Case EVENT_GADGETSELECT 	; return onGadgetSelect( event )	' A TreeView Node has been selected 
'		Case EVENT_GADGETMENU 		; return onGadgetMenu( event )		' User has Right clicked a TreeView Node Or TextArea gadget 
'		Case EVENT_GADGETOPEN 		; return onGadgetOpen( event )		' A TreeView Node has been expanded 
'		Case EVENT_GADGETCLOSE 		; return onGadgetClose( event )		' A TreeView Node has been collapsed 
'		Case EVENT_GADGETDONE 		; return onGadgetDone( event )		' An HTMLView has completed loading a page 
		Default
			DebugLog "NOT IMPLEMENTED: "+event.ToString()
		End Select
	Return False
	End Method
	
	'------------------------------------------------------------
	Method onMenuAction:Int( event:TEvent )
		Select event.data
		Case MENU_NEW
			ListAddLast( forms, New TDesigner_Form.Create() )
			Return True 
		Case MENU_OPEN
			Local filter:String = "BlitzMAX Form Definition:bfd"
			Local filename:String = RequestFile( "Select Form:", filter )
			If filename Then New TDesigner_Form.Create( filename )
		Case MENU_SAVE
		Case MENU_CLOSE
			'# Close current form designer
		Case MENU_EXIT
			For Local form:TDesigner_Form = EachIn forms
				If Not form.onExit() Then Return True
			Next
			End	
		Case MENU_CUT
		Case MENU_COPY
		Case MENU_PASTE
	
		Case MENU_ABOUT
			Notify "VisiMax~nBlitzMAX Form Builder for MaxGUI~n(c) Copyright Si Dunford, ITSpeedway.net"
			Return True
		End Select
	Return False
	End Method

	'------------------------------------------------------------
'	Method onWindowClose:Int( event:TEvent )
'	Return True
'	End Method
	
End Type
	
	



