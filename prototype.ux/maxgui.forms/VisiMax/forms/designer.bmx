'# FORM DESIGNER
'# VERSION 1.0

'# The Designer is a window that controls the bulding of a form.

'# Create a list of windows containing forms that are being edited.
Global forms:TList = CreateList()

'############################################################
Type TDesigner_Form Extends TGadget_Form
'Field win:TGadget
'Field split:TSplitter, canvas:TGadget, panels:TGadget[2]
Field saved:Int = True
Field filename:String
Field form:TForm
	'------------------------------------------------------------
	Method New()
		AddHook( EmitEventHook, EventHook, Self )
		link = ListAddLast( forms, Self )
		name="Form"+CountList(forms)
	End Method
	
	'------------------------------------------------------------
	Method Delete()
		RemoveHook( EmitEventHook, EventHook, Self )
	End Method

	'------------------------------------------------------------
	Method Create:TDesigner_Form( filename:String="" )
	Local style:Int
	Local x:Int = 0
	Local y:Int = 0
'	Local w:Int = config.getint( "MAIN.W" )
'	Local h:Int = config.getint( "MAIN.H" )
'	Local s:Int = WINDOW_TITLEBAR | WINDOW_MENU | WINDOW_ACCEPTFILES
		'# WINDOW
'		win = CreateWindow( "Form Designer", x,y,w,h, Null, s )
'		split = CreateSplitter( 0, 0, ClientWidth(win), ClientHeight(win), win, SPLIT_VERTICAL, 5 )
'		SetSplitterBehavior( split, SPLIT_RESIZABLE|SPLIT_CANFLIP|SPLIT_LIMITPANESIZE )
'		SetSplitterPosition( split, 120 )
'		SetGadgetLayout split, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED
'		panels[0] = SplitterPanel( split, SPLITPANEL_MAIN )
'		panels[1] = SplitterPanel( split, SPLITPANEL_SIDEPANE )
		'#
		'# Load a MaxGUI.form if specified
		If filename And FileType( filename )=1 Then
			form = New TForm.Load( filename )
		End If
		'# Create a MaxGUI form if one doesn't exist
		If Not form Or Not form.window Then
			form = New TForm
			form.window = New TElement.Create( Null, "WINDOW", "New Form" )
			form.window.x = 0
			form.window.y = 0
			form.window.width = 320
			form.window.height = 400
			form.window.resize = True
			form.window.titlebar = 1			'# 0=None, 1=Titlebar, 2=Toolbar
			form.window.menu = False
			form.window.status = False
			form.window.center = False
			form.window.dragdrop = False
		End If
'DebugStop
		'# Extract the style
		Select form.window.titlebar
		Case 1 ; style :| WINDOW_TITLEBAR
		Case 2 ; style :| WINDOW_TOOL
		End Select
		
		If form.window.resize Then style :| WINDOW_RESIZABLE
		If form.window.menu Then style :| WINDOW_MENU
		If form.window.status Then style :| WINDOW_STATUS
		If form.window.center Then style :| WINDOW_CENTER
		If form.window.dragdrop Then style :| WINDOW_ACCEPTFILES
		
		'# INSPECTOR
		inspectorform.show()
		x= GadgetWidth(inspectorform.win) + (forms.count()-1)*20
		y= GadgetHeight( mainform.win) + (forms.count()-1)*20
		
		'# WINDOW
		win = CreateWindow( "New Form", x, y, form.window.width, form.window.height, Null, style )
		canvas = CreateCanvas( 0, 0, form.window.width, form.window.height, win )
'		SetGadgetLayout( canvas, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED)
		ActivateGadget Canvas
		SetGadgetShape( canvas, 0, 0, form.window.width, form.window.height )
		RedrawGadget( canvas )
		draw()
		
	Return Self
	End Method

	'------------------------------------------------------------
	Method FileSave:Int()
		If saved Then Return True
		If filename="" Then
			'# Get filename
		End If
		'# Save file
		Return True
	End Method

	'------------------------------------------------------------
	'# Draws the current form on the canvas.
	Method Draw()
		SetGraphics CanvasGraphics( canvas )
		SetVirtualResolution form.window.width, form.window.height
		SetViewport 0,0,form.window.width, form.window.height

		SetClsColor( $cc, $cc, $cc )
		Cls
		SetColor( $00, $00, $00 )
		For Local x:Int = 0 To GadgetWidth( canvas ) Step 10
			For Local y:Int = 0 To GadgetHeight( canvas ) Step 10
				Plot( x, y )
			Next
		Next
		DrawText( GadgetWidth(canvas),0,0)
		DrawText( GadgetWidth(win),0,15)
		Flip
	End Method

	'------------------------------------------------------------
	Method onExit:Int()
	Local save:Int
		If saved Then Return True
		save = Proceed( "File has changed~nSave now?" )
Print "Save: " +save
		If save Then
			If Not FileSave() Then Return False
			Return True
		End If
	Return False
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
'		Case EVENT_MENUACTION 		; Return onMenuAction( event )		' Menu has been selected 
'		Case EVENT_WINDOWMOVE 		; return onWindowMove( event )		' Window has been moved 
		Case EVENT_WINDOWSIZE 		; Return onWindowSize( event )		' Window has been resized 
		Case EVENT_WINDOWCLOSE 		; Return onWindowClose( event )		' Window close icon clicked 
'		Case EVENT_WINDOWACTIVATE	; return onWindowActivate( event )	' Window activated 
'		Case EVENT_WINDOWACCEPT 	; return onWindowAccept( event )	' Drag And Drop operation was attempted 
'		Case EVENT_GADGETACTION 	; return onGadgetAction( event )	' Gadget state has been updated 
		Case EVENT_GADGETPAINT 		; Return onGadgetPaint( event )		' A Canvas Gadget needs To be redrawn 
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
	Method onGadgetPaint:Int( event:TEvent )
Print "PAINTING"
'		If event.source<>canvas Then Return False
		draw()
	Return True
	End Method

	'------------------------------------------------------------
	Method onWindowClose:Int( event:TEvent )
		If event.source<>win Then Return False
		FreeGadget( win )
		RemoveLink( link )
		Return True
	End Method

	'------------------------------------------------------------
	Method onWindowSize:Int( event:TEvent )
'Print name+"] "+event.tostring()
		If event.source<>win Then Return False
'Print Event.ToString()
Print "WINDOWSIZE"
'		If event.source<>win Then Return False
If event.source = win Then 
	Print "  - Window"
Else
	Print "  - Something else!"
End If
Print "WINDOW: "+GadgetWidth(win)+" x "+GadgetHeight(win)
Print "CANVAS: "+GadgetWidth(canvas)+" x "+GadgetHeight(canvas)
		SetGadgetShape( canvas, 0, 0, event.x, event.y )
Print "CANVAS: "+GadgetWidth(canvas)+" x "+GadgetHeight(canvas)
		RedrawGadget( canvas )
		form.window.width = event.x
		form.window.height = event.y
	Return True
	End Method

	'============================================================
'	Function EventHook:Object( id:Int, data:Object, context:Object ) nodebug
'	Local event:TEvent = TEvent( data )
'	Local form:TDesigner_Form = TDesigner_Form( context )
'		If Not event Or Not form Then Return data
'		If form.onEvent( event ) Then Return Null
'	Return data
'	End Function
	
End Type
