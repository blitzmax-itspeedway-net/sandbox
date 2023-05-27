SuperStrict

Import maxgui.drivers

Const MENU_OPEN% = 101
Const MENU_EXIT% = 199

Global window:TGadget = CreateWindow( "Images", 0, 0, GadgetWidth( Desktop() ), 50, Null, WINDOW_TITLEBAR|WINDOW_MENU)
Local filemenu:TGadget = CreateMenu( "&File", 0, WindowMenu( window ))
CreateMenu "&Open", MENU_OPEN, filemenu, KEY_O, MODIFIER_COMMAND
CreateMenu "", 0, filemenu
CreateMenu "E&xit", MENU_EXIT, filemenu, KEY_F4, MODIFIER_COMMAND
UpdateWindowMenu window

Global images:TList = CreateList()

Repeat
	WaitEvent()
	Print "::"+CurrentEvent.ToString()
	Select EventID()
	Case EVENT_APPTERMINATE
		End
	Case EVENT_WINDOWCLOSE
		If EventSource()=window Then End
	Case EVENT_MENUACTION
		Select EventData()
		Case MENU_OPEN
			Local filter:String = "Picture:jpg"
			Local filename:String = RequestFile( "Select Picture:", filter )
			If filename Then New TPicture.Create( filename )
		Case MENU_EXIT
			End
		End Select
	End Select
Forever

'############################################################
Type TPicture
Field image:TImage
Field win:TGadget
Field link:TLink
	'------------------------------------------------------------
	Method New()
		AddHook( EmitEventHook, EventHook, Self )
		link = ListAddLast( images, Self )
	End Method

	'------------------------------------------------------------
	Method Create:TPicture( filename:String )
		win = CreateWindow( filename, CountList(images)*30, CountList(images)*30+GadgetHeight(window), 200,200, Null,WINDOW_TITLEBAR|WINDOW_TOOL|WINDOW_RESIZABLE)
	Return Self
	End Method

	'------------------------------------------------------------
	Method onEvent:Int( event:TEvent )
		Select event.id
		Case EVENT_WINDOWCLOSE
			If event.source = win Then
				FreeGadget( win )
				RemoveLink( link )
			End If
'		Return True
'		Case EVENT_GADGETPAINT
		End Select
	Return False
	End Method
End Type

'============================================================
Function EventHook:Object( id:Int, data:Object, context:Object )
Local event:TEvent = TEvent( data )
Local pic:TPicture = TPicture( context )
	If Not event Or Not pic Then Return data
	If pic.onEvent( event ) Then Return Null
Return data
End Function
