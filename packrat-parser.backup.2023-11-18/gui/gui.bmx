'   LANGUAGE SERVER FOR BLITZMAX NG
'   (c) Copyright Si Dunford, September 2021, All Right Reserved
'
'	TOKEN & AST VISUALISATON TOOL

' NEXT TO FIX:
'* Diagnostic messages do not contain RANGE information

SuperStrict

Import maxgui.drivers
Import brl.reflection

Import "IViewable.bmx"

'Function Publish:Int( event:String, data:Object=Null, extra:Object=Null )
'    Print "---> "+event + "; "+String( data )
'End Function

'	VISUALISER

Const WIN_MIN_HEIGHT:Int = 600
Const WIN_MIN_WIDTH:Int = 800

Const ICON_GREY:Int = 0
Const ICON_RED:Int = 1
Const ICON_GREEN:Int = 2
Const ICON_YELLOW:Int = 3
Const ICON_BLUE:Int = 4
Const ICON_PURPLE:Int = 5
Const ICON_TEAL:Int = 6
Const ICON_WHITE:Int = 7
Const ICON_ERROR:Int = 8

Const TAB_TOKENVIEW:Int = 0
Const TAB_DIAGNOSTICS:Int = 1
Const TAB_MESSAGES:Int = 2

'	CUSTOM EVENTS

Global EVENT_FILE_CLOSE:Int = AllocUserEventId( "File close event" )
Global EVENT_FILE_OPEN:Int = AllocUserEventId( "File open event" )
Global EVENT_FILE_CHANGE:Int = AllocUserEventId( "File change event" )
Global EVENT_UPDATE:Int = AllocUserEventId( "System update event" )

'	CREATE CONFIG MANAGER
'Global config:TConfig = New TConfig()

'	MONOSPACE FONT
'DebugStop
Global monospacefont:TGUIFont = LoadGuiFont("Courier", 10 )
'Global monospacefont:TGUIFont = LookupGuiFont(GUIFONT_SYSTEM,14)
'Global monospacefont:TGUIFont = LookupGuiFont(GUIFONT_MONOSPACED,10)





Type TControl
	Field parent:TGadget, mother:TControl
	Field gadget:TGadget
	
	Field children:TControl[]
	
	'Method New()
		'Print "TCONTROL.NEW()" + TTypeId.ForObject(Self).name
		'connect()
	'End Method

	Method New( mother:TControl, parent:TGadget )
		'Print "TCONTROL.NEW( gad ) = " + TTypeId.ForObject(Self).name()
		Self.parent = parent
		Self.mother = mother
		connect()
	End Method

	Method initialise( mother:TControl, parent:TGadget )
		Self.parent = parent
		Self.mother = mother
		connect()
	End Method

	Method connect()'target:Object )
		'Print "CONNECTING EVENTS TO "+name()
		AddHook( EmitEventHook, eventHook, Self )
	End Method
	
	Method disconnect()
		'Print "REMOVING EVENTS FROM "+name()
		RemoveHook( EmitEventHook, eventHook, Self )
	End Method

	Method hide()
		HideGadget( gadget )
	End Method

	Method name:String()
'		DebugStop
		Return TTypeId.forObject(Self).name()
	End Method
	
	Method show()
		ShowGadget( gadget )
	End Method

	'	Asks control to show a specific control
	Method display( content:String )
	End Method
	
	' EVENT DISPATCHER

	Method onEvent:Object( event:TEvent )

		Select event.id
			'Case EVENT_APPRESUME		' Do nothing
			'Case EVENT_APPSUSPEND		' Do nothing
			Case EVENT_APPTERMINATE		; End
			Case EVENT_GADGETACTION 	; Return onGadgetAction( event )
			Case EVENT_GADGETCLOSE		' Do nothing
			Case EVENT_GADGETLOSTFOCUS	' Do nothing
			Case EVENT_GADGETOPEN		' Do nothing
			Case EVENT_GADGETPAINT		' Do nothing	Return onPaint( event )
			Case EVENT_GADGETSELECT
'				DebugStop
				; Return onGadgetSelect( event )
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
			Case EVENT_WINDOWSIZE		; Return OnWindowSize( event )
			
			Case EVENT_FILE_CHANGE		; 
			'DebugStop
			Return onFileChange( event )
			Case EVENT_FILE_CLOSE		; Return onFileClose( event )
			Case EVENT_FILE_OPEN		; Return onFileOpen( event )
			Case EVENT_UPDATE			; Return onUpdate( event )
			Default
				Print Event.tostring()
		EndSelect
	Return event
	End Method

'	Method Propogate:Object( event:TEvent )
'DebugStop
'		For Local child:TControl = EachIn children
'			child.onEvent( event )
'		Next
'		Return event
'	End Method

	' EVENT HANDLERS
	
	Method onClick:Object( event:TEvent )		;	Return event	;	End Method
'	Method onLoad:Object( event:TEvent )		;	Return event	;	End Method
	Method onClose:Object( event:TEvent )
		RemoveHook( EmitEventHook, eventHook, Self )
		Return event
	End Method
	Method onGadgetAction:Object( event:TEvent ) ;	Return event	;	End Method
	Method onGadgetSelect:Object( event:TEvent ) ;	Return event	;	End Method
	Method onMenuAction:Object( event:TEvent )	;	Return event	;	End Method
	Method onResize:Object( event:TEvent )		;	Return event	;	End Method
	Method onTick:Object( event:TEvent )		;	Return event	;	End Method
	Method OnWindowSize:Object( event:TEvent )		;	Return event	;	End Method
	
	Method onFileChange:Object( event:TEvent )		;	Return event	;	End Method
	Method onFileClose:Object( event:TEvent )		;	Return event	;	End Method
	Method onFileOpen:Object( event:TEvent )		;	Return event	;	End Method

	Method onUpdate:Object( event:TEvent )		;	Return event	;	End Method
	
	' EVENT HOOK
	
	Function eventHook:Object( ID:Int, Data:Object, Context:Object )
		Local event:TEvent = TEvent( Data )
	'If event And ( event.id = EVENT_FILE_OPEN Or event.id = EVENT_FILE_CHANGE ) DebugStop
	'If event And event.id = EVENT_FILE_OPEN DebugStop
		Local control:TControl = TControl( Context )
		If Not event Or Not control Then Return Data
'Select event.id
'Case EVENT_GADGETPAINT, EVENT_WINDOWSIZE, EVENT_GADGETLOSTFOCUS
'Default
'Print control.name()[..12] + event.id + " - " + event.toString()
'End Select

'		DebugStop
		Return control.onEvent( event )
	EndFunction
	
End Type

Type TVisualiser Extends TControl	
	Field window:TGadget
	'Field hsplitter:TSplitter, vsplitter:TSplitter
	'Field tsplit:TGadget, bsplit:TGadget, lsplit:TGadget, rsplit:TGadget	' Top, Bot, Lft, Rgt
		
	Field editor:TEditor
	Field logview:TLogView
	'Field ASTview:TASTView
	
	Field panel:TGadget
	Field tabber:TGadget, tabs:TControl[], currenttab:TControl
	
	Field menu_edit_eol:TGadget
	Field menu_edit_comments:TGadget
		
	'	CONSTANTS
	
	Const STYLE:Int = WINDOW_TITLEBAR|WINDOW_CLIENTCOORDS|WINDOW_MENU|WINDOW_RESIZABLE|WINDOW_STATUS
	
	Const FILE_NEW:Int    = 101
	Const FILE_OPEN:Int   = 102
	'Const FILE_SAVE:Int   = 103
	'Const FILE_SAVEAS:Int = 104
	Const FILE_CLOSE:Int  = 105
	Const FILE_EXIT:Int   = 106

	'Const EDIT_CUT:Int   = 201
	'Const EDIT_COPY:Int  = 202
	'Const EDIT_PASTE:Int = 203

	Const VIEW_EOL:Int      = 301
	Const VIEW_COMMENTS:Int = 302

	Const HELP_ABOUT:Int  = 999
	
	Field x:Int = 10
	Field y:Int = 10
	Field w:Int = 800
	Field h:Int = 600
	
	' CONSTRUCTOR
	
'	Field textarea:TGadget
	
	Method New()	
		
		'	LOAD STATE
		
		'Local x:Int = Int( String(config["left"]) )
		'Local y:Int = Int( String(config["top"]) )
		'Local w:Int = Int( String(config["width"]) )
		'Local h:Int = Int( String(config["height"]) )
		'Local mn:Int = Int( String(config["minim"]) )
		'Local mx:Int = Int( String(config["maxim"]) )
		'Local filename:String = String( config["filename"] )

		'	CREATE WINDOW

		If w<WIN_MIN_WIDTH ; w=WIN_MIN_WIDTH
		If h<WIN_MIN_HEIGHT ; h=WIN_MIN_HEIGHT

		window = CreateWindow( AppTitle, x, y, w, h, Null, STYLE )
		SetGadgetLayout( window, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED )
		SetMinWindowSize( window, WIN_MIN_WIDTH, WIN_MIN_HEIGHT )
		
		'If mn ; MinimizeWindow( window )
		'If mx ; MaximizeWindow( window )

		'	CREATE MENU

		Local filemenu:TGadget = CreateMenu( "&File", 0, WindowMenu( window ))
		CreateMenu( "&New",   FILE_NEW,   filemenu, KEY_N, MODIFIER_COMMAND )
		CreateMenu( "&Open",  FILE_OPEN,  filemenu, KEY_O, MODIFIER_COMMAND )
		CreateMenu( "&Close", FILE_CLOSE, filemenu, KEY_W, MODIFIER_COMMAND )
		CreateMenu( "",       0,          filemenu )
		'CreateMenu( "&Save",  FILE_SAVE,  filemenu, KEY_S, MODIFIER_COMMAND )
		CreateMenu( "",       0,          filemenu )
		CreateMenu( "E&xit",  FILE_EXIT,  filemenu, KEY_F4, MODIFIER_COMMAND )

		Local viewmenu:TGadget = CreateMenu( "&View", 0, WindowMenu( window ))
		menu_edit_eol = CreateMenu( "Show EOL",    VIEW_EOL,   viewmenu )
		menu_edit_comments = CreateMenu( "Show comments",    VIEW_COMMENTS,   viewmenu )
		CheckMenu( menu_edit_eol )
		CheckMenu( menu_edit_comments )
		
		'Local editmenu:TGadget
		Local helpmenu:TGadget = CreateMenu( "&Help", 0, WindowMenu( window ))
		CreateMenu( "&About", HELP_ABOUT, helpmenu )
		
		UpdateWindowMenu( window )

		'	CREATE HORIZONTAL SPLITTER
		
		' Split window horizontally
		'hsplitter = CreateSplitter( 0, 0, ClientWidth(window), ClientHeight(window), window, SPLIT_HORIZONTAL, 15 )
		'SetGadgetLayout( hsplitter, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED )
		'SetSplitterPosition( hsplitter, ClientHeight(window)/2 )
		'SetSplitterBehavior( hsplitter, 0 )
		'SetGadgetColor( hsplitter, 0,0,0 )
		'tsplit = SplitterPanel( hsplitter, SPLITPANEL_MAIN )
		'bsplit = SplitterPanel( hsplitter, SPLITPANEL_SIDEPANE )
		'SetGadgetLayout( tsplit, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED )
		'SetGadgetLayout( bsplit, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED )
		
		'	CREATE VERTICAL SPLITTER IN TOP
		
		' Split TOP panel vertically
		'vsplitter = CreateSplitter( 0, 0, ClientWidth(tsplit), ClientHeight(tsplit), tsplit, SPLIT_VERTICAL )
		'SetGadgetLayout( vsplitter, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED )
		'SetSplitterPosition( vsplitter, ClientWidth(tsplit)/2 )
		'SetSplitterBehavior( vsplitter, 0)
		'SetGadgetColor( vsplitter, 0,0,0 )
		'lsplit = SplitterPanel( vsplitter, SPLITPANEL_MAIN )
		'rsplit = SplitterPanel( vsplitter, SPLITPANEL_SIDEPANE )
		'SetGadgetLayout( lsplit, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED )
		'SetGadgetLayout( rsplit, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED )
			
		Local half:Int = ClientWidth( window ) /2

		'	CREATE LEFT PANEL CONTAINING TABS
		
		tabber = CreateTabber( 0, 0, half, ClientHeight(window), window )
		SetGadgetLayout( tabber, EDGE_RELATIVE, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED )

		'	CREATE RIGHT PANEL CONTAINING EDITOR
		
		panel = CreatePanel( half, 0, half, ClientHeight( window ), window )
		SetGadgetLayout( panel, EDGE_ALIGNED, EDGE_RELATIVE, EDGE_ALIGNED, EDGE_ALIGNED )
		
		'	ADD EDITOR TO RIGHT PANEL
		
		editor = New TEditor( Self, panel )
		'children :+ [editor]		
		
		'	ADD LOGVIEWER TO TABBER
		
		AddGadgetItem( tabber, "LOG" )
		logview = New TLogview( Self, tabber )
		logview.hide()
		tabs :+ [ logview ]
		currenttab = logview
		'DebugStop
		' Bug in TABBER means that tab 0 is curently selected but does not
		' show properly. Setting it to 0 doesn;t work and you have to have another
		' click to make it work
		'ActivateGadget( logview.gadget )
		'SelectGadgetItem( tabber, 0 )
		
		'tabs :+ [New TViewBMax( Self, tabber )]
		'children :+ [ASTView]
		
		'	TEST STUFF
		
		'Global t1:TGadget = CreateTextArea(0,0,ClientWidth(bsplit),ClientHeight(bsplit),bsplit,TEXTAREA_WORDWRAP)
		'SetGadgetLayout(t1,EDGE_ALIGNED,EDGE_ALIGNED,EDGE_ALIGNED,EDGE_ALIGNED)
		'AddTextAreaText(t1, "The quick brown fox jumped over the lazy dog.~n~n")
		'AddTextAreaText(t1, "The quick brown fox jumped over the lazy dog.~n~n")

		'Global t2:TGadget = CreateTextArea(0,0,ClientWidth(lsplit),ClientHeight(lsplit),lsplit,TEXTAREA_WORDWRAP)
		'SetGadgetLayout(t2,EDGE_ALIGNED,EDGE_ALIGNED,EDGE_ALIGNED,EDGE_ALIGNED)
		'AddTextAreaText(t2, "The quick brown rat jumped over the lazy cat.~n~n")
		'AddTextAreaText(t2, "The quick brown rat jumped over the lazy cat.~n~n")

		'Global t3:TGadget = CreateTextArea(0,0,ClientWidth(rsplit),ClientHeight(rsplit),rsplit,TEXTAREA_WORDWRAP)
		'SetGadgetLayout(t3,EDGE_ALIGNED,EDGE_ALIGNED,EDGE_ALIGNED,EDGE_ALIGNED)
		'AddTextAreaText(t3, "The quick brown pig jumped over the lazy bear.~n~n")
		'AddTextAreaText(t3, "The quick brown pig jumped over the lazy bear.~n~n")
		
		'	ADD TABBER COMPONENTS
		
	'	'AddGadgetItem( tabber, "AST" )
		'tabs :+ [New TASTView( Self, tabber )]
		
		'AddGadgetItem( tabber, "Tokens" )
		'tabs :+ [New TTokenView( Self, tabber )]
		'SetGadgetLayout( tabs[TAB_TOKENVIEW], EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED )
		
		'AddGadgetItem( tabber, "Diagnostics" )
		'tabs :+ [New TDiagnostics( Self, tabber )]
		'tabs[TAB_DIAGNOSTICS] = New TDiagnostics( bsplit )
		'SetGadgetLayout( tabs[TAB_DIAGNOSTICS], EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED )
		'HideGadget tabs[TAB_DIAGNOSTICS]

		'AddGadgetItem( tabber, "Messages" )
		'tabs :+ [New TMessages( Self, tabber )]
		'tabs[TAB_MESSAGES] = New TMessages( bsplit )
		'SetGadgetLayout( tabs[TAB_MESSAGES], EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED )
		'HideGadget tabs[TAB_MESSAGES]

		'AddGadgetItem( tabber, "Transpile" )
		'tabs :+ [New TViewBMax( Self, tabber )]

		'AddGadgetItem( tabber, "C++" )
		'tabs :+ [New TViewCPP( Self, tabber )]

		'AddGadgetItem( tabber, "Java" )
		'tabs :+ [New TViewJava( Self, tabber )]

		'AddGadgetItem( tabber, "HTML" )
		'tabs :+ [New TViewJava( Self, tabber )]
		
		' Select SECOND tab to bypass bug in event handler when using tabber on linux
		'currenttab = tabs[TAB_DIAGNOSTICS] 
		'SelectGadgetItem(tabber:TGadget,1)
		'ShowGadget( currenttab.gadget )
		'EnableGadget( currenttab.gadget )

		'For Local t:Int = 0 Until tabs.length
		'	children :+ [tabs[t]]
		'Next

		' CONNECT EVENT HANDLER
		connect()
		
		' LOAD FILE
		'If filename editor.fileOpen( filename )
		
	End Method
	
	' ENTRY POINT
	
	Method run()

		' CONNECT EVENT HANDLERS
		
		'connect()
		
		' CREATE INDEX THREAD
		
		'documents = New TDocuments()
		'documents.listen()
		
		'editor.connect()
		'tokenview.connect()
		'astview.connect()
				
		' GAME LOOP
		Repeat
			WaitEvent() 
		Until EventID()=EVENT_WINDOWCLOSE
		Print( "EVENT LOOP QUIT" )
		
		'SaveWindow()

		' DISCONNECT EVENT HANDLERS
		
		'disconnect()
		
		'editor.disconnect()
		'tokenview.disconnect()
		'astview.disconnect()
	End Method

	'	ADD A PANEL
	Method add( caption:String, component:TControl )
		
		component.initialise( Self, tabber )
		component.hide()

		' Add to tabber
		AddGadgetItem( tabber, Caption )
		tabs :+ [ component ]
		
		'SelectGadgetItem( tabber, tabs.length-1 )
		'component.show()

	End Method

	'	Displays a gadget in the right pane
	Method display( content:String )
		editor.set( content )
	End Method

	' BEHAVIOUR

	'Method SaveWindow()
'Print("BYE")
		' Save window location
	'	config["left"] = String( GadgetX( window ))
	'	config["top"] = String( GadgetY( window ))
	'	config["width"] = String( GadgetWidth( window ))
	'	config["height"] = String( GadgetHeight( window ))
	'	config["minim"] = String( WindowMinimized( window ))
	'	config["maxim"] = String( WindowMaximized( window ))
		'config.save()
	'End Method
	'Method 

	Method setPosition( x:Int, y:Int )
		Self.x = x
		Self.y = y
		SetGadgetShape( window, x, y, w, h )		
	End Method

	Method setSize( w:Int, h:Int )
		Self.w = w
		Self.h = h
		SetGadgetShape( window, x, y, w, h )
	End Method

	Method setShape( x:Int, y:Int, w:Int, h:Int )
		Self.x = x
		Self.y = y
		Self.w = w
		Self.h = h
		SetGadgetShape( window, x, y, w, h )
	End Method
	
'	Method selectTab( tab:Int )
'		For Local n:Int = 0 Until tabs.length
'			If n=tab
'				tabs[n].show()
'			Else
'				tabs[n].hide()
'			End If
'		Next
'		currenttab = tabs[tab].gadget
'	End Method

	' EVENT HANDLERS
	
	Method onMenuAction:Object( event:TEvent )
		Select Int(event.data)
			Case FILE_CLOSE
				'editor.fileclose()
			Case FILE_NEW
				'editor.fileclose()
			Case FILE_OPEN
				Local filter:String = "Source code:bmx;All Files:*"
				Local filename:String = RequestFile( "Select file to open",filter )
				'If filename editor.fileopen( filename )
			'Case FILE_SAVE
			'	editor.filesave()
			'Case FILE_SAVEAS
			'	editor.filesaveas()
			Case FILE_EXIT
				'SaveWindow()
				End
			Case VIEW_EOL
				If MenuChecked( menu_edit_eol )
					UncheckMenu( menu_edit_eol )
				Else
					CheckMenu( menu_edit_eol )
				End If
				UpdateWindowMenu( window )
				EmitEvent( CreateEvent( EVENT_UPDATE, Self ) )
			Case VIEW_COMMENTS
				If MenuChecked( menu_edit_comments )
					UncheckMenu( menu_edit_comments )
				Else
					CheckMenu( menu_edit_comments )
				End If
				UpdateWindowMenu( window )
				EmitEvent( CreateEvent( EVENT_UPDATE, Self ) )
			Case HELP_ABOUT
				Notify "Visualiser~n(c) Copyright, Si Dunford, September 2021, All Rights Reserved"
		End Select
	End Method
	
	Method onGadgetAction:Object( event:TEvent )
'DebugStop
		If event 
			Select event.source
			Case tabber
'DebugStop
				HideGadget( currenttab.gadget )
				currenttab = tabs[ event.data ]
				ShowGadget( currenttab.gadget )
			'Case editor.gadget
			'	'DebugStop
			'	'editor.filedata = TextAreaText( editor.gadget )
			'	parse()
			'	update()
			End Select
		EndIf
		Return event
	End Method
	
	Method onGadgetSelect:Object( event:TEvent )
'		If event.source = editor.gadget
'			Local line:Int = TextAreaCursor( editor.gadget, TEXTAREA_LINES )
'			Local char:Int = TextAreaCursor( editor.gadget, TEXTAREA_CHARS )
'			SetStatusText( window, "Line: "+(line+1)+" Char: "+char )
'			Return Null
'		End If
		Return event
	End Method
		
	' LANGUAGE SERVER INTERFACE
	
'	Method onFileChange:Object( event:TEvent )	
'		Local document:TTextDocument = TTextDocument( event.extra )
'
'		
'		' Transpiler
''		For Local tab:TControl = EachIn tabs
''			tab.update( ast )
''		Next
'		Return event	' Allow event to propogate		
'	End Method
	
	Method onFileOpen:Object( event:TEvent )
		'Local document:TTextDocument = TTextDocument( event.extra )
'DebugStop
		' Reset the visualiser title
		'If document ; SetGadgetText( window, AppTitle + ":" + StripDir( document.get_uri()) )
		'propogate( event )
		Return event	' Allow event to propogate
	End Method
	
	Method onFileClose:Object( event:TEvent )
		SetGadgetText( window, AppTitle )
		'propogate( event )
		Return event	' Allow event to propogate
	End Method
	
	Method OnWindowSize:Object( event:TEvent )
'DebugStop
		'SetSplitterPosition( hsplitter, event.y/2 )
		'SetSplitterPosition( vsplitter, event.x/2 )
		Return event
	End Method
	
End Type

Type TEditor Extends TControl
	'Field window:TGadget
	
	'Field filename:String
	'Field document:TFullTextDocument

	'	LANGUAGE SERVER
	'Field lexer:TLexer
	'Field parser:TParser
	'Field ast:TASTNode   
		
	' CONSTRUCTOR
	Method New( mother:TControl, parent:TGadget )
		Super.New( mother, parent )
		
		'Print( "TEditor.new()" )

		' CREATE COMPONENT
		gadget = CreateTextArea( 0, 0, ClientWidth(parent), ClientHeight(parent), parent )
		SetGadgetLayout( gadget, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED )

		'	SET GADGET FONT
		'	(DOESN'T WORK)
		
		'Local monospacefont:TGuiFont = LookupGuiFont( GUIFONT_MONOSPACED, 11 ) 
		'Print FontName( monospacefont )
		
		'Local monospacefont:TGuiFont = LoadGuiFont( "Courier New", 11 ) 
		'Local monospacefont:TGuiFont = LoadGuiFont( "FreeMono", 11 ) 
		'Print FontName( monospacefont )
		'If Not monospacefont monospacefont = LookupGuiFont( GUIFONT_MONOSPACED, 11 ) 

		'SetGadgetFont( gadget, monospacefont )	' This does not work!
		SetTextAreaFont( gadget, monospacefont )

		'SetGadgetText( gadget, "EDITOR" )
		ActivateGadget( gadget )
		
		'SetStatusText( parent, "Line: 0 Char: 0" )
	End Method
	
	' BEHAVIOUR
	
	Method fileClose()
		'If document 
		'	documents.event_fileclose( document.uri )
		'	EmitEvent( CreateEvent( EVENT_FILE_CLOSE, parent, 0, 0, 0, 0, document ) )
		'End If
		SetGadgetText( gadget, "" )
	End Method

	Method fileNew()
		fileClose()
		SetGadgetText( gadget, "" )
	End Method

	Method fileOpen( uri:String )
		'If document documents.event_fileclose( document.uri )
		
		'DebugStop
		' Emulate Language Server
		'document = TFullTextDocument( documents.getFile( uri ) )
		'EmitEvent( CreateEvent( EVENT_FILE_OPEN, parent, 0, 0, 0, 0, document ) )
		
		''' Fill text area
		'SetGadgetText( gadget, document.getText() )
		'
		'config["filename"]=uri
		'config.save()		
	End Method
	
	Method fileSave()
	End Method
	
	Method fileSaveAs( name:String )
	End Method

	Method set( content:String )
		SetGadgetText( gadget, content )
	End Method

	' EVENT HANDLERS

	' Textarea has been updated
	Method onGadgetAction:Object( event:TEvent )
		If event And event.source = Self
DebugStop
			'document.content = TextAreaText( gadget )
			'document.parse()
			'EmitEvent( CreateEvent( EVENT_FILE_CHANGE, parent, 0, 0, 0, 0, document ) )
		EndIf
		Return event	' Allow event to propogate
	End Method
	
	Method onUpdate:Object( event:TEvent )
		'EmitEvent( CreateEvent( EVENT_FILE_CHANGE, parent, 0, 0, 0, 0, document ) )
	End Method
	
End Type

Type TTreeView Extends TControl
	Field root:TGadget, icons:TIconStrip

	' CONSTRUCTOR

	Method New()
		'icons = LoadIconStrip( "incbin::bin/icons.png" )
		'SetGadgetIconStrip( gadget, icons )		
	End Method

	
	Method initialise( mother:TControl, parent:TGadget )
		'DebugStop
		Super.initialise( mother, parent )
		'Print( "TTreeView.new()" )

		gadget = CreateTreeView( 0, 0, ClientWidth(parent), ClientHeight(parent), parent )
		SetGadgetLayout( gadget, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED )
		root = TreeViewRoot( gadget )

		'icons = LoadIconStrip( "incbin::bin/icons.png" )
		'SetGadgetIconStrip( gadget, icons )
		
	End Method
	
	' BEHAVIOUR
	
	Method update() 'document:TFullTextDocument )
		ClearTreeView( gadget )

		Local mum:TVisualiser = TVisualiser( mother )
		Local options:Int[] = [MenuChecked( mum.menu_edit_eol ), MenuChecked( mum.menu_edit_comments )]

		'Local ast:TASTNode = document.ast
				
		' Populate 
		'Local visitor:TMotherInLaw = New TMotherInLaw( ast, root, options:Int[] )
		'visitor.run()
		
	End Method
				
	Method setTree( node:IViewable )
		buildtree( root, node )
	End Method
	
	Method buildtree( gadget:TGadget, node:IViewable )
		'DebugStop
		Local this:TGadget = AddTreeViewNode( node.getCaption(), gadget )
		this.extra = node
		'this.setText( node.getCaption() )
		For Local child:IViewable = EachIn node.getChildren()	
			buildtree( this, child )
		Next
		ExpandTreeViewNode( this )
	End Method

	' EVENT HANDLERS

	Method onFileChange:Object( event:TEvent )
		'update( TFullTextDocument(event.extra) )
		Return event	' Allow event to propogate
	End Method

	Method onFileOpen:Object( event:TEvent )
		'update( TFullTextDocument(event.extra) )
		Return event	' Allow event to propogate
	End Method

	Method onFileClose:Object( event:TEvent )
		ClearTreeView( gadget )
		Return event	' Allow event to propogate
	End Method
	
	Method onGadgetSelect:Object( event:TEvent )
'DebugStop
		'Print "GADGET SELECT"
		' Get Treeview node
		Local gadget:TGadget = TGadget( event.extra )
		If Not gadget; Return event
		' Get selected Node from gadget
		Local node:IViewable = IViewable( gadget.extra )
		If Not node; Return event
		
		Local echo:String = node.getCaption() + "~n"
		Local text:String = Trim( "~n".join(node.getText()) )
		If text
			echo :+ "--------------------~n"
			echo :+ text+"~n"
		EndIf
		Local children:IViewable[] = node.getChildren()
		If children And children.length>0
			echo :+ "--------------------~n"
			echo :+ "CHILDREN:~n"
			For Local child:IViewable = EachIn Children
				echo :+ "* "+child.getcaption()+"~n"
			Next
		End If
		mother.display( echo )
		
		Return event
	End Method
End Type

Type TLogView Extends TControl

	' CONSTRUCTOR
	
	Method New( mother:TControl, parent:TGadget )
		Super.New( mother, parent )
		'Print( name()+".new()" )
		
		gadget = CreateTextArea( 0, 0, ClientWidth(parent), ClientHeight(parent), parent )
		SetGadgetLayout( gadget, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED )
'		DebugStop
		SetGadgetFont( gadget, monospacefont )		' This does not work!
		SetTextAreaFont( gadget, monospacefont )	' nor does this!
		
		SetGadgetText( gadget, "THIS IS AN EXAMPLE LOG" )
		'ActivateGadget( gadget )
		
	End Method

	' BEHAVIOUR
		
	Method update( text:String )

		If gadget; SetGadgetText( gadget, text )
		
	End Method

	' EVENT HANDLERS
			
EndType

Rem

Type TTokenView Extends TControl
	
	' CONSTRUCTOR

	Method New( mother:TControl, parent:TGadget )
		Super.New( mother, parent )
		Print( "TTokenView.new()" )
		
		gadget = CreateTextArea( 0, 0, ClientWidth(parent), ClientHeight(parent), parent )
		SetGadgetLayout( gadget, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED )
		DebugStop
		SetGadgetFont( gadget, monospacefont )		' This does not work!
		SetTextAreaFont( gadget, monospacefont )	' nor does this!
		
		SetGadgetText( gadget, "THIS IS AN EXAMPLE" )
		'ActivateGadget( gadget )
		
	End Method

	' BEHAVIOUR
		
	Method update( document:TFullTextDocument )

		If document ; SetGadgetText( gadget, document.lexer.reveal() )
		
	End Method

	' EVENT HANDLERS

	Method onFileChange:Object( event:TEvent )
		update( TFullTextDocument(event.extra) )
		Return event	' Allow event to propogate
	End Method

	Method onFileOpen:Object( event:TEvent )
'DebugStop
		update( TFullTextDocument(event.extra) )
		Return event	' Allow event to propogate
	End Method

	Method onFileClose:Object( event:TEvent )
		SetGadgetText( gadget, "" )
		Return event	' Allow event to propogate
	End Method
		
End Type

Type TDiagnostics Extends TControl
	Method New( mother:TControl, parent:TGadget )
		Super.New( mother, parent )
		gadget = CreateTextArea( 0, 0, ClientWidth(parent), ClientHeight(parent), parent, TEXTAREA_READONLY )
		SetGadgetLayout( gadget, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED )
		'SetGadgetFont( gadget, monospacefont )	' This does not work!
		SetTextAreaFont( gadget, monospacefont )
		SetGadgetText( gadget, "DIAGNOSTICS VIEWER" )
		'ActivateGadget( gadget )
		HideGadget( gadget )
	End Method
	
	Method update( document:TFullTextDocument )
		'Local diags:String
		Local ast:TASTNode = document.ast
		' Walk the AST Tree "In-Order"
'DebugStop
		'Print "INORDER TREE WALKER"
		Local list:TDiagnostic[]
		list = TDiagnostic[]( ast.inorder( GetDiagnostic, list, 0 ) )
		
		' Convert diagnostics into a string so we can display it
		Local result:String
		For Local diag:TDiagnostic = EachIn list
			'result :+ "["+diag.range.start.line+","+diag.range.start.character+"] - "
			'result :+ "["+diag.range.ends.line+","+diag.range.ends.character+"]"
			'result :+ Upper( diag.severity.tostring() )
			'result :+ diag.source
			'result :+ diag.message
			result :+ diag.reveal()+"~n"
		Next
		SetGadgetText( gadget, result )
		
		Function GetDiagnostic:Object( node:TASTNode, data:Object, options:Int )
'DebugStop
			If node.errors.length = 0 Return data
'DebugStop
			' Convert data into a list and append to it
			Local list:TDiagnostic[] = TDiagnostic[]( data )
			'Local result:String
			'For Local i:Int = 0 Until node.errors.length
				'list :+ [ node.errors[i] ]
				'result :+ errors[n] + "["+node.line+","+node.pos+"] "+node.error+" ("+node.getname()+")~n"
				'result :+ errors[n] + "["+node.line+","+node.pos+"] ("+node.getname()+")~n"
			'	list.addlast( error )
			'Next 
			Return list + node.errors
		End Function
		
	End Method
	
	' EVENT HANDLERS

	Method onFileChange:Object( event:TEvent )
		update( TFullTextDocument(event.extra) )
		Return event	' Allow event to propogate
	End Method

	Method onFileOpen:Object( event:TEvent )
		update( TFullTextDocument(event.extra) )
		Return event	' Allow event to propogate
	End Method

	Method onFileClose:Object( event:TEvent )
		SetGadgetText( gadget, "" )
		Return event	' Allow event to propogate
	End Method
	
End Type

Type TMessages Extends TControl
	Method New( mother:TControl, parent:TGadget )
		Super.New( mother, parent )
		gadget = CreateTextArea( 0, 0, ClientWidth(parent), ClientHeight(parent), parent, TEXTAREA_READONLY )
		SetGadgetLayout( gadget, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED )
		'SetGadgetFont( gadget, monospacefont )	' This does not work!
		SetTextAreaFont( gadget, monospacefont )
		SetGadgetText( gadget, "MESSAGE VIEWER" )
		'ActivateGadget( gadget )
		HideGadget( gadget )
	End Method
End Type

Type TViewBMax Extends TControl
	Method New( mother:TControl, parent:TGadget )
		Super.New( mother, parent )
		gadget = CreateTextArea( 0, 0, ClientWidth(parent), ClientHeight(parent), parent, TEXTAREA_READONLY )
		SetGadgetLayout( gadget, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED )
		'SetGadgetFont( gadget, monospacefont )	' This does not work!
		SetTextAreaFont( gadget, monospacefont )
		SetGadgetText( gadget, "BlitzMax" )
		'ActivateGadget( gadget )
		HideGadget( gadget )
	End Method
	
	Method update( ast:TASTNode )
		
		Local result:String 
		Try
			Local transpiler:TTranspileBlitzMax = New TTranspileBlitzMax( ast )
			result = transpiler.run()
			
		Catch e:Object
			Local typ:TTypeId = TTypeId.ForObject( e )
			result =  typ.name + "~n"
			
			Local exception:TException = TException( e )
			Local blitzexception:TBlitzException = TBlitzException( e )
			Local runtime:TRuntimeException = TRuntimeException( e )
			Local Text:String = String( e )
			If exception 		;	result :+ "TException:~n"+exception.toString()
			If blitzexception	;	result :+ "TBlitzException:~n"+blitzexception.toString()
			If runtime			;	result :+ "TException:~n"+runtime.toString()
			If Text				;	result :+ Text
		End Try
		
		SetGadgetText( gadget, result )
		
	End Method
End Type

Type TViewCPP Extends TControl
	Method New( mother:TControl, parent:TGadget )
		Super.New( mother, parent )
		gadget = CreateTextArea( 0, 0, ClientWidth(parent), ClientHeight(parent), parent, TEXTAREA_READONLY )
		SetGadgetLayout( gadget, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED )
		'SetGadgetFont( gadget, monospacefont )	' This does not work!
		SetTextAreaFont( gadget, monospacefont )
		SetGadgetText( gadget, "C++" )
		'ActivateGadget( gadget )
		HideGadget( gadget )
	End Method
	
	Method update( ast:TASTNode )
		
		Local result:String 
		Try
			Local transpiler:TTranspileCPP = New TTranspileCPP( ast )
			result = transpiler.run()
			
		Catch e:Object
			Local typ:TTypeId = TTypeId.ForObject( e )
			result =  typ.name + "~n"
			
			Local exception:TException = TException( e )
			Local blitzexception:TBlitzException = TBlitzException( e )
			Local runtime:TRuntimeException = TRuntimeException( e )
			Local Text:String = String( e )
			If exception 		;	result :+ "TException:~n"+exception.toString()
			If blitzexception	;	result :+ "TBlitzException:~n"+blitzexception.toString()
			If runtime			;	result :+ "TException:~n"+runtime.toString()
			If Text				;	result :+ Text
		End Try
		
		SetGadgetText( gadget, result )
	
	End Method
End Type

Type TViewJava Extends TControl
	Method New( mother:TControl, parent:TGadget )
		Super.New( mother, parent )
		gadget = CreateTextArea( 0, 0, ClientWidth(parent), ClientHeight(parent), parent, TEXTAREA_READONLY )
		SetGadgetLayout( gadget, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED )
		'SetGadgetFont( gadget, monospacefont )	' This does not work!
		SetTextAreaFont( gadget, monospacefont )
		SetGadgetText( gadget, "JAVA" )
		'ActivateGadget( gadget )
		HideGadget( gadget )
	End Method
	
	Method update( ast:TASTNode )
		
		Local result:String 
		Try
			Local transpiler:TTranspileJava = New TTranspileJava( ast )
			result = transpiler.run()
			
		Catch e:Object
			Local typ:TTypeId = TTypeId.ForObject( e )
			result =  typ.name + "~n"
			
			Local exception:TException = TException( e )
			Local blitzexception:TBlitzException = TBlitzException( e )
			Local runtime:TRuntimeException = TRuntimeException( e )
			Local Text:String = String( e )
			If exception 		;	result :+ "TException:~n"+exception.toString()
			If blitzexception	;	result :+ "TBlitzException:~n"+blitzexception.toString()
			If runtime			;	result :+ "TException:~n"+runtime.toString()
			If Text				;	result :+ Text
		End Try
		
		SetGadgetText( gadget, result )
	
	End Method
End Type

Type TViewJavaScript Extends TControl

	Method New( mother:TControl, parent:TGadget )
		Super.New( mother, parent )
		gadget = CreateTextArea( 0, 0, ClientWidth(parent), ClientHeight(parent), parent, TEXTAREA_READONLY )
		SetGadgetLayout( gadget, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED )
		HideGadget( gadget )
	End Method
	
	Method update( ast:TASTNode )
		Local template:String = "<!DOCTYPE html>~n<html>~n<head>~n<title>{appname}</title>~n</head>~n<body>~n</body>~n</html>"
		SetGadgetText( gadget, template )
	End Method
	
End Type
End Rem

