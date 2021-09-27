'   LANGUAGE SERVER FOR BLITZMAX NG
'   (c) Copyright Si Dunford, September 2021, All Right Reserved
'
'	TOKEN & AST VISUALISATON TOOL

SuperStrict
Framework maxgui.drivers
Import brl.eventqueue
Import brl.max2d
Import brl.retro
Import brl.timer
Import brl.timerdefault

'Import brl.Graphics
'Import brl.reflection

Const CONFIG_FILE:String = "visualiser.config"

Global config:TConfig = New TConfig()

Type TConfig Extends TMap

	Method Load( filename:String )
		' Load configuration
		Local file:TStream = OpenFile( filename )
		If file 
			Self.clear()
			While Not Eof(file)
				Local line:String = ReadLine(file)
				Local pair:String[] = line.split("=")
				If pair.length>1
					Local value:String = "=".join( pair[1..] )
					Self.insert( Lower(pair[0]),value )
				End If
			Wend
			CloseStream file
		EndIf
	End Method
	
	Method Save( filename:String )
		' Save configuration
		Local file:TStream = OpenFile( filename, False, True )
		If file 
			For Local key:String = EachIn Self.keys()
				WriteLine( file, key+"="+String( Self.valueforkey( key )) )
			Next
			CloseStream file
		EndIf		
	End Method
	
End Type

Type TControl
	Field window:TGadget

	'Method New()
		'Print "TCONTROL.NEW()" + TTypeId.ForObject(Self).name
		'connect()
	'End Method

	Method New( parent:TGadget )
		Print "TCONTROL.NEW( gad )" '+ TTypeId.ForObject(Self).name
		window = parent
		connect()
	End Method

	Method connect()
		AddHook( EmitEventHook, eventHook, Self )
	End Method
	
	Method disconnect()
		RemoveHook( EmitEventHook, eventHook, Self )
	End Method
	
	Method resize( width:Int, height:Int ) Abstract

	' EVENT DISPATCHER

	Method onEvent:Object( event:TEvent )
		Select event.id
			'Case EVENT_APPRESUME		' Do nothing
			'Case EVENT_APPSUSPEND		' Do nothing
			Case EVENT_APPTERMINATE		; End
			Case EVENT_GADGETPAINT		' Do nothing	Return onPaint( event )
			Case EVENT_GADGETSELECT 	; Return onGadgetSelect( event )
			Case EVENT_GADGETLOSTFOCUS	' Do nothing
			'Case EVENT_TIMERTICK		; Return onTick( event )
			Case EVENT_MENUACTION		; Return onMenuAction( event )
			Case EVENT_MOUSEDOWN		' Do nothing
			Case EVENT_MOUSEENTER		' Do nothing
			Case EVENT_MOUSELEAVE		' Do nothing
			Case EVENT_MOUSEMOVE		' Do nothing
			Case EVENT_MOUSEUP			' Do nothing
			Case EVENT_WINDOWACTIVATE	' Do nothing
			Case EVENT_WINDOWCLOSE		; Return onClose( event )
			Case EVENT_WINDOWMOVE		' Do nothing
			Case EVENT_WINDOWSIZE		; Return onResize( event )
			Default
				Print Event.tostring()
		EndSelect
	Return event
	End Method

	' EVENT HANDLERS
	
	Method onClick:Object( event:TEvent )		;	Return event	;	End Method
'	Method onLoad:Object( event:TEvent )		;	Return event	;	End Method
	Method onClose:Object( event:TEvent )
		RemoveHook( EmitEventHook, eventHook, Self )
		Return event
	End Method
	Method onGadgetSelect:Object( event:TEvent ) ;	Return event	;	End Method
	Method onMenuAction:Object( event:TEvent )	;	Return event	;	End Method
	Method onResize:Object( event:TEvent )
'		resize( event.x, event.y )
		Return event
	End Method
	Method onTick:Object( event:TEvent )		;	Return event	;	End Method
	
	' EVENT HOOK
	
	Function eventHook:Object( ID:Int, Data:Object, Context:Object )
	Local event:TEvent = TEvent( Data )
	Local control:TControl = TControl( Context )
		If Not event Or Not control Then Return Data
		Return control.onEvent( event )
	EndFunction
	
End Type

Type TVisualiser Extends TControl	
	Field editor:TEditor
	Field tokenview:TTokenView
	Field ASTview:TASTView
	
	Const STYLE:Int = WINDOW_TITLEBAR|WINDOW_CLIENTCOORDS|WINDOW_MENU|WINDOW_RESIZABLE|WINDOW_CENTER| WINDOW_STATUS
	
	Const FILE_NEW:Int    = 101
	Const FILE_OPEN:Int   = 102
	'Const FILE_SAVE:Int   = 103
	'Const FILE_SAVEAS:Int = 104
	Const FILE_CLOSE:Int  = 105
	Const FILE_EXIT:Int   = 106

	'Const EDIT_CUT:Int   = 201
	'Const EDIT_COPY:Int  = 202
	'Const EDIT_PASTE:Int = 203

	Const HELP_ABOUT:Int  = 999
	
	' CONSTRUCTOR
	
'	Field textarea:TGadget
	
	Method New()	
		' CREATE WINDOW
		
		window = CreateWindow( "Visualisation Tool", 100, 100, 800, 400, Null, STYLE )	
		'SetGadgetColor( window, 0,0,0, True )

		Local filemenu:TGadget = CreateMenu( "&File", 0, WindowMenu( window ))
		CreateMenu( "&New",   FILE_NEW,   filemenu, KEY_N, MODIFIER_COMMAND )
		CreateMenu( "&Open",  FILE_OPEN,  filemenu, KEY_O, MODIFIER_COMMAND )
		CreateMenu( "&Close", FILE_CLOSE, filemenu, KEY_W, MODIFIER_COMMAND )
		CreateMenu( "",       0,          filemenu )
		'CreateMenu( "&Save",  FILE_SAVE,  filemenu, KEY_S, MODIFIER_COMMAND )
		CreateMenu( "",       0,          filemenu )
		CreateMenu( "E&xit",  FILE_EXIT,  filemenu, KEY_F4, MODIFIER_COMMAND )

		'Local editmenu:TGadget
		Local helpmenu:TGadget = CreateMenu( "&Help", 0, WindowMenu( window ))
		CreateMenu( "&About", HELP_ABOUT, helpmenu )

		UpdateWindowMenu( window )

		' CREATE COMPONENTS
		editor = New TEditor( window )
		tokenview = New TTokenView( window )
		ASTview = New TASTView( window )

		' LOAD STATE
		Local filename:String = String( config.valueforkey( "filename" ) )
		If filename ; editor.fileOpen( filename )

		' CONNECT EVENT HANDLER
		connect()
	End Method
	
	' ENTRY POINT
	
	Method run()

		' CONNECT EVENT HANDLERS
		
		'connect()
		
		'editor.connect()
		'tokenview.connect()
		'astview.connect()
				
		' GAME LOOP
		Repeat
			WaitEvent() 
		Until EventID()=EVENT_WINDOWCLOSE
		Print( "EVENT LOOP QUIT" )
		
		' DISCONNECT EVENT HANDLERS
		
		'disconnect()
		
		'editor.disconnect()
		'tokenview.disconnect()
		'astview.disconnect()
	End Method

	' BEHAVIOUR
	
	Method resize( width:Int, height:Int )
	End Method

	'Method 

	' EVENT HANDLERS
	
	Method onMenuAction:Object( event:TEvent )
		Select Int(event.data)
			Case FILE_CLOSE
				editor.fileclose()
			Case FILE_NEW
				editor.fileclose()
			Case FILE_OPEN
				Local filter:String = "Source code:bmx;All Files:*"
				Local filename:String = RequestFile( "Select file to open",filter )
				If filename 
					editor.fileopen( filename )
					config.insert( "filename", filename )
				End If
			'Case FILE_SAVE
			'	editor.filesave()
			'Case FILE_SAVEAS
			'	editor.filesaveas()
			Case FILE_EXIT
				End
			Case HELP_ABOUT
				Notify "Visualiser~n(c) Copyright, Si Dunford, September 2021, All Rights Reserved"
		End Select
	End Method
	
End Type

Type TEditor Extends TControl
	Field textarea:TGadget
	
	Field filename:String
	Field filedata:String
	
	' CONSTRUCTOR
	Method New( parent:TGadget )
		Super.New( parent )
		Print( "TEditor.new()" )

		' CREATE COMPONENT
		
		textarea = CreateTextArea( 0, 0, 100, 100, window )
		SetGadgetLayout( textarea, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED )
		filedata = "Just an example~nuntil we load"
		SetGadgetText( textarea, filedata )
		ActivateGadget( textarea )
		
		resize( ClientWidth( window ), ClientHeight( window ) )
		
		SetStatusText( window, "Line: 0 Char: 0" )
	End Method
	
	' BEHAVIOUR
	
	Method resize( width:Int, height:Int )
		SetGadgetShape( textarea, 0, 0, width/3, height )
	End Method
	
	Method fileClose()
		filename = ""
		filedata = ""
		SetGadgetText( textarea, filedata )
	End Method

	Method fileNew()
		fileClose()
	End Method

	Method fileOpen( name:String )
		filename = name
		filedata = ""
		Local file:TStream = OpenFile( filename )
		If file 
			While Not Eof(file)
				Local line:String = ReadLine(file)
				filedata :+ line + "~n"
			Wend
			CloseStream file
		EndIf
		SetGadgetText( textarea, filedata )
		'
		config["filename"]=name
		config.save( CONFIG_FILE )		
	End Method
	
	Method fileSave()
	End Method
	
	Method fileSaveAs( name:String )
	End Method
	
	' EVENT HANDLERS

	Method onGadgetSelect:Object( event:TEvent )
		Print( "EDITOR:~n"+event.toString()) 
		Local line:Int = TextAreaCursor( textarea, TEXTAREA_LINES )
		Local char:Int = TextAreaCursor( textarea, TEXTAREA_CHARS )
		SetStatusText( window, "Line: "+line+" Char: "+char )
	End Method
	
End Type

Type TTokenView Extends TControl

	Field panel:TGadget, listbox:TGadget
	'Field timer:TTimer
	
	' CONSTRUCTOR

	Method New( parent:TGadget )
		Super.New( parent )
		Print( "TTokenView.new()" )
		
		'timer = CreateTimer( 100 )
		panel   = CreatePanel( 0, 0, 100, 100, window, PANEL_ACTIVE|PANEL_SUNKEN )
		listbox = CreateListBox( 0, 0, 100,100, panel )
		SetGadgetLayout listbox, EDGE_RELATIVE, EDGE_RELATIVE, EDGE_RELATIVE, EDGE_RELATIVE
		'SetGadgetColor( listbox, 0,0,0,True)		
		resize( ClientWidth( window ), ClientHeight( window ) )
		
		AddGadgetItem listbox, "New", False, 0, "Create something."
		AddGadgetItem listbox, "Open", False, 1, "Open something."
		AddGadgetItem listbox, "Save", False, 2, "Save something.", "Extra Item Object!"
		AddGadgetItem listbox, "No Icon", False, -1, "This should not have an icon set."
	
		
	End Method

	' BEHAVIOUR
	
	Rem
	Method draw()
		SetGraphics CanvasGraphics( Canvas )
		SetClsColor( 0,0,0 )
		Cls
		For Local x:Int = 0 To 4
			For Local y:Int = 0 To 4
				'DrawRect( x*10,y*10,9,9)
			Next
		Next
		Flip
	End Method
EndRem

	Method resize( width:Int, height:Int )
		Local third:Int = width/3
		SetGadgetShape( panel, third, 0, third, height )
	End Method
	
	' EVENT HANDLERS

	'Method onPaint:Object( event:TEvent )
	'	Print( "TTokenView.onPaint()" )
	'	draw()
	'End Method
	
	'Method onTick:Object( event:TEvent )
'	'	Print( "TTokenView.onTick()" )
	'	Return onPaint( event )
	'End Method
	
End Type

Type TASTView Extends TControl
	Field tv:TGadget, root:TGadget

	' CONSTRUCTOR
	
	Method New( parent:TGadget )
		Super.New( parent )
		Print( "TASTView.new()" )
		
		tv     = CreateTreeView( 0, 0, 100, 100, window )
		root = TreeViewRoot( tv )
		


Local help:TGadget=AddTreeViewNode("Help",root)
AddTreeViewNode "Topic 1",help
AddTreeViewNode "Topic 2",help
AddTreeViewNode "Topic 3",help

Local projects:TGadget=AddTreeViewNode("Projects",root)
AddTreeViewNode("Sub Project",AddTreeViewNode("Project 1",projects))
AddTreeViewNode("Project 2",projects)
AddTreeViewNode("Project 3",projects)
		
		'SetGadgetLayout( tv, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED )
		resize( ClientWidth( window ), ClientHeight( window ) )
		
	End Method
	
	' BEHAVIOUR
	
	Method resize( width:Int, height:Int )
		Local third:Int = width/3
		SetGadgetShape( tv, third*2, 0, third, height )
	End Method
				
	' BEHAVIOUR

	' EVENT HANDLERS

'	Method onResize:Object( event:TEvent )
'	End Method
	
End Type

DebugStop
config.Load( CONFIG_FILE )

' Create Visualiser
New TVisualiser.Run()

