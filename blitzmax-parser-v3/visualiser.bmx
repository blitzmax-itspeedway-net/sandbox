'   LANGUAGE SERVER FOR BLITZMAX NG
'   (c) Copyright Si Dunford, September 2021, All Right Reserved
'
'	TOKEN & AST VISUALISATON TOOL

' NEXT TO FIX:
'* Diagnostic messages do not contain RANGE information

SuperStrict

' REQUIRED FOR THE GUI
Import maxgui.drivers
Import maxgui.proxygadgets
Import brl.eventqueue
Import brl.max2d
Import brl.retro
Import brl.timer
Import brl.timerdefault

' REQUIRED FOR THE LANGUAGE SERVER
Import brl.objectlist
Import brl.reflection
Import Text.RegEx
Import bah.DBSQLite		' Specifically for the Symbol table ;)

' COMMENTED OUT BECAUSE WE ARE TESTING LOCAL COPIES
Import bmx.json
Include "lexer.bmx"
'Import bmx.lexer
'Import bmx.parser
'Import bmx.blitzmaxparser
'Import bmx.transpiler

Include "bin/loadfile().bmx"

' SANDBOX LANGUAGE SERVER PROTOCOL DEFINITIONS
Include "bin/language-server-protocol.bmx"

' SANDBOX LEXER
'Include "lexer/TLexer.bmx"
'Include "lexer/TToken.bmx"
'Include "lexer/TException.bmx"

' SANDBOX PARSER
'Include "sandbox/bmx.parser/TParser.bmx"
'Include "sandbox/bmx.parser/TASTNode.bmx"
'Include "sandbox/bmx.parser/TASTBinary.bmx"
'Include "sandbox/bmx.parser/TASTCompound.bmx"
'Include "sandbox/bmx.parser/TVisitor.bmx"
'Include "sandbox/bmx.parser/TParseValidator.bmx"
'Include "sandbox/bmx.parser/TASTErrorMessage.bmx"

' SANDBOX BLITZMAX LEXER/PARSER
' Included here until stable release pushed back into module
'Include "sandbox/bmx.blitzmaxparser/lexer-const-bmx.bmx"
'Include "sandbox/bmx.blitzmaxparser/TBlitzMaxAST.bmx"
'Include "sandbox/bmx.blitzmaxparser/TBlitzMaxLexer.bmx"
'Include "sandbox/bmx.blitzmaxparser/TBlitzMaxParser.bmx"

' Exception handler for Parse errors
Type TParseError Extends TException
End Type

Function ThrowParseError( message:String, line:Int=-1, pos:Int=-1 )
	Throw( New TParseError( message, line, pos ) )
End Function

' SANDBOX TRANSPILER
'Include "transpiler/TTranspiler.bmx"
'Include "transpiler/TTranspileBlitzMax.bmx"	' BlitzMax NG
'Include "transpiler/TTranspileCPP.bmx"			' C++
'Include "transpiler/TTranspileJava.bmx"		' Java
'Include "src/TTranspileJavaScript.bmx"	' HTML/JavaScr

'	DELIVERABLES
'Include "bin/TSymbolTable.bmx"
'Include "bin/TLanguageServerVisitor.bmx"
Include "bin/TDocuments.bmx"			' Document Manager
Include "bin/TTextDocument.bmx"				' Text Document

'Include "bin/TException.bmx"
'Include "bin/TToken.bmx"

Incbin "bin/icons.png"

'	ENUMS
'Enum ASCII ; NUL=0, SOH, STX, ETX, EOT, ENQ, ACK, BEL, BS, HT, LF, VT, FF, CR, SO, SI, DLE, DC1, DC2, DC3, DC4, NAK, SYN, ETB, CAN, EM, SUB, ESC, FS, GS, RS, US, SPACE ; End Enum

'	TYPES AND FUNCTIONS

Function Publish:Int( event:String, data:Object=Null, extra:Object=Null )
    Print "---> "+event + "; "+String( data )
End Function

'	VISUALISER

Const CONFIG_FILE:String = "visualiser.config"
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
Global config:TConfig = New TConfig()

'	CREATE DOCUMENT MANAGER
Global documents:TDocuments = New TDocuments()

'	MONOSPACE FONT
'DebugStop
Global monospacefont:TGUIFont = LoadGuiFont("Courier", 10 )
'Global monospacefont:TGUIFont = LookupGuiFont(GUIFONT_SYSTEM,14)
'Global monospacefont:TGUIFont = LookupGuiFont(GUIFONT_MONOSPACED,10)

AppTitle = "Transpiler"

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
	Field parent:TGadget, mother:TControl
	Field gadget:TGadget
	
	Field children:TControl[]
	
	'Method New()
		'Print "TCONTROL.NEW()" + TTypeId.ForObject(Self).name
		'connect()
	'End Method

	Method New( mother:TControl, parent:TGadget )
		Print "TCONTROL.NEW( gad )" '+ TTypeId.ForObject(Self).name
		Self.parent = parent
		Self.mother = mother
		connect()
	End Method

	Method connect()
		AddHook( EmitEventHook, eventHook, Self )
	End Method
	
	Method disconnect()
		RemoveHook( EmitEventHook, eventHook, Self )
	End Method

	Method hide()
		HideGadget( gadget )
	End Method
	
	Method show()
		ShowGadget( gadget )
	End Method
	
	Method update( ast:TASTNode ) ; End Method

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
			Case EVENT_GADGETSELECT 	; Return onGadgetSelect( event )
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
				DebugStop
				Return onFileChange( event )
			Case EVENT_FILE_CLOSE		; Return onFileClose( event )
			Case EVENT_FILE_OPEN		; Return onFileOpen( event )
			Case EVENT_UPDATE			; Return onUpdate( event )
			Default
				Print "UNHANDLED: "+Event.tostring()
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
		Return control.onEvent( event )
	EndFunction
	
End Type

Type TVisualiser Extends TControl	
	Field window:TGadget
	'Field hsplitter:TSplitter, vsplitter:TSplitter
	'Field tsplit:TGadget, bsplit:TGadget, lsplit:TGadget, rsplit:TGadget	' Top, Bot, Lft, Rgt
	
	Field editor:TEditor
	'Field tokenview:TTokenView
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
	
	' CONSTRUCTOR
	
'	Field textarea:TGadget
	
	Method New()	
		
		'	LOAD STATE
		
		Local x:Int = Int( String(config["left"]) )
		Local y:Int = Int( String(config["top"]) )
		Local w:Int = Int( String(config["width"]) )
		Local h:Int = Int( String(config["height"]) )
		Local mn:Int = Int( String(config["minim"]) )
		Local mx:Int = Int( String(config["maxim"]) )
		Local filename:String = String( config["filename"] )

		'	CREATE WINDOW

		If w<WIN_MIN_WIDTH ; w=WIN_MIN_WIDTH
		If h<WIN_MIN_HEIGHT ; h=WIN_MIN_HEIGHT

		window = CreateWindow( AppTitle, x, y, w, h, Null, STYLE )
		SetGadgetLayout( window, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED )
		SetMinWindowSize( window, WIN_MIN_WIDTH, WIN_MIN_HEIGHT )
		
		If mn ; MinimizeWindow( window )
		If mx ; MaximizeWindow( window )

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
		
		'	CREATE LEFT PANEL CONTAINING EDITOR
		
		Local half:Int = ClientWidth( window ) /2
		panel = CreatePanel( 0,0,half,ClientHeight(window), window )
		SetGadgetLayout( panel, EDGE_ALIGNED, EDGE_RELATIVE, EDGE_ALIGNED, EDGE_ALIGNED )
		
		editor = New TEditor( Self, panel )
		'ASTview = New TASTView( Self, rsplit )
		
		children :+ [editor]
		'children :+ [ASTView]
		
		'	CREATE RIGHT PANEL CONTAINING TABS
		
		tabber = CreateTabber( half, 0, half, ClientHeight( window ), window )
		SetGadgetLayout( tabber, EDGE_RELATIVE, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED )
		
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
		
		AddGadgetItem( tabber, "AST" )
		tabs :+ [New TASTView( Self, tabber )]
		
		AddGadgetItem( tabber, "Tokens" )
		tabs :+ [New TTokenView( Self, tabber )]
		'SetGadgetLayout( tabs[TAB_TOKENVIEW], EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED )
		
		AddGadgetItem( tabber, "Diagnostics" )
		'tabs :+ [New TDiagnostics( Self, tabber )]
		'tabs[TAB_DIAGNOSTICS] = New TDiagnostics( bsplit )
		'SetGadgetLayout( tabs[TAB_DIAGNOSTICS], EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED )
		'HideGadget tabs[TAB_DIAGNOSTICS]

		AddGadgetItem( tabber, "Messages" )
		'tabs :+ [New TMessages( Self, tabber )]
		'tabs[TAB_MESSAGES] = New TMessages( bsplit )
		'SetGadgetLayout( tabs[TAB_MESSAGES], EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED )
		'HideGadget tabs[TAB_MESSAGES]

		AddGadgetItem( tabber, "Transpile" )
		'tabs :+ [New TViewBMax( Self, tabber )]

		AddGadgetItem( tabber, "C++" )
		'tabs :+ [New TViewCPP( Self, tabber )]

		AddGadgetItem( tabber, "Java" )
		'tabs :+ [New TViewJava( Self, tabber )]

		AddGadgetItem( tabber, "HTML" )
		'tabs :+ [New TViewJava( Self, tabber )]
		
		' Select SECOND tab to bypass bug in event handler when using tabber on linux
		currenttab = tabs[TAB_DIAGNOSTICS] 
		SelectGadgetItem(tabber:TGadget,1)
		ShowGadget( currenttab.gadget )
		EnableGadget( currenttab.gadget )

		For Local t:Int = 0 Until tabs.length
			children :+ [tabs[t]]
		Next

		' CONNECT EVENT HANDLER
		connect()
		
		' LOAD FILE
		If filename editor.fileOpen( filename )
		
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
		
		SaveWindow()

		' DISCONNECT EVENT HANDLERS
		
		'disconnect()
		
		'editor.disconnect()
		'tokenview.disconnect()
		'astview.disconnect()
	End Method

	' BEHAVIOUR

	Method SaveWindow()
Print("BYE")
		' Save window location
		config["left"] = String( GadgetX( window ))
		config["top"] = String( GadgetY( window ))
		config["width"] = String( GadgetWidth( window ))
		config["height"] = String( GadgetHeight( window ))
		config["minim"] = String( WindowMinimized( window ))
		config["maxim"] = String( WindowMaximized( window ))
		config.save(CONFIG_FILE)
	End Method
	'Method 

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
				editor.fileclose()
			Case FILE_NEW
				editor.fileclose()
			Case FILE_OPEN
				Local filter:String = "Source code:bmx;All Files:*"
				Local filename:String = RequestFile( "Select file to open",filter )
				If filename editor.fileopen( filename )
			'Case FILE_SAVE
			'	editor.filesave()
			'Case FILE_SAVEAS
			'	editor.filesaveas()
			Case FILE_EXIT
				SaveWindow()
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
		If event 
			DebugStop
			Select event.source
			Case tabber
'DebugStop
				HideGadget( currenttab.gadget )
				currenttab = tabs[ event.data ]
				ShowGadget( currenttab.gadget )
			Case editor.gadget
				DebugStop
			'	'editor.filedata = TextAreaText( editor.gadget )
			'	parse()
			'	update()
			End Select
		EndIf
		Return event
	End Method
	
	Method onGadgetSelect:Object( event:TEvent )
		If event.source = editor.gadget
			Local line:Int = TextAreaCursor( editor.gadget, TEXTAREA_LINES )
			Local char:Int = TextAreaCursor( editor.gadget, TEXTAREA_CHARS )
			SetStatusText( window, "Line: "+(line+1)+" Char: "+char )
		End If
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
		Local document:TTextDocument = TTextDocument( event.extra )
		'
DebugStop
		' Reset the visualiser title
		If document ; SetGadgetText( window, AppTitle + ":" + StripDir( document.get_uri()) )
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
	Field document:TFullTextDocument

	'	LANGUAGE SERVER
	Field lexer:TLexer
	Field parser:TParser
	Field ast:TASTNode   
		
	' CONSTRUCTOR
	Method New( mother:TControl, parent:TGadget )
		Super.New( mother, parent )
		
		Print( "TEditor.new()" )

		' CREATE COMPONENT
		gadget = CreateTextArea( 0, 0, ClientWidth(parent), ClientHeight(parent), parent )
		SetGadgetLayout( gadget, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED )
		SetGadgetFilter gadget, filter

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

	' Return a 1 when character allowed, 0 if not!
	Function filter:Int( event:TEvent, context:Object )
		DebugStop
		Select event.id
			Case EVENT_KEYDOWN
				Print "filtering keydown:"+event.data+","+event.mods
				If event.data=KEY_DOWN Return 0
				If event.data=13 Return 0
			Case EVENT_KEYCHAR
				Print "filtering charkey:"+event.data+","+event.mods
				If event.data=KEY_TAB Return 0
		End Select
		Return 1
	End Function
	
	' BEHAVIOUR
	
	Method fileClose()
		If document 
			documents.event_fileclose( document.uri )
			EmitEvent( CreateEvent( EVENT_FILE_CLOSE, parent, 0, 0, 0, 0, document ) )
		End If
		SetGadgetText( gadget, "" )
	End Method

	Method fileNew()
		fileClose()
		SetGadgetText( gadget, "" )
	End Method

	Method fileOpen( uri:String )
		If document documents.event_fileclose( document.get_uri() )
		
		DebugStop
		' Emulate Language Server
		document = TFullTextDocument( documents.getFile( uri ) )
		EmitEvent( CreateEvent( EVENT_FILE_OPEN, parent, 0, 0, 0, 0, document ) )
		
		' Fill text area
		SetGadgetText( gadget, document.getText() )
		'
		config["filename"]=uri
		config.save( CONFIG_FILE )		
	End Method
	
	Method fileSave()
	End Method
	
	Method fileSaveAs( name:String )
	End Method

	' EVENT HANDLERS

	' Textarea has been updated
	Method onGadgetAction:Object( event:TEvent )
DebugStop
		If event And event.source = gadget
			DebugStop
			Print( event.toString() )
			
			'NEED To GET LOCATION OF EDIT
			'WHAT HAS CHANGED
			
			'document.content = TextAreaText( gadget )
			'document.parse()
			'EmitEvent( CreateEvent( EVENT_FILE_CHANGE, parent, 0, 0, 0, 0, document ) )
		EndIf
		Return event	' Allow event to propogate
	End Method
	
	Method onUpdate:Object( event:TEvent )
		EmitEvent( CreateEvent( EVENT_FILE_CHANGE, parent, 0, 0, 0, 0, document ) )
	End Method
	
End Type

Type TASTView Extends TControl
	Field root:TGadget, icons:TIconStrip

	' CONSTRUCTOR
	
	Method New( mother:TControl, parent:TGadget )
		Super.New( mother, parent )
		Print( "TASTView.new()" )

		gadget = CreateTreeView( 0, 0, ClientWidth(parent), ClientHeight(parent), parent )
		root = TreeViewRoot( gadget )

		SetGadgetLayout( gadget, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED )

		icons = LoadIconStrip( "incbin::bin/icons.png" )
		SetGadgetIconStrip( gadget, icons )
		
	End Method
	
	' BEHAVIOUR
	
	Method update() 'document:TFullTextDocument )
		'ClearTreeView( gadget )

		'Local mum:TVisualiser = TVisualiser( mother )
		'Local options:Int[] = [MenuChecked( mum.menu_edit_eol ), MenuChecked( mum.menu_edit_comments )]

		'Local ast:TASTNode = document.ast
				
		' Populate 
		'Local visitor:TMotherInLaw = New TMotherInLaw( ast, root, options:Int[] )
		'visitor.run()
		
	End Method
				
	' BEHAVIOUR

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
	
End Type

Type TTokenView Extends TControl
	
	' CONSTRUCTOR

	Method New( mother:TControl, parent:TGadget )
		Super.New( mother, parent )
		Print( "TTokenView.new()" )
		
		gadget = CreateTextArea( 0, 0, ClientWidth(parent), ClientHeight(parent), parent )
		SetGadgetLayout( gadget, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED )
		'DebugStop
		SetGadgetFont( gadget, monospacefont )		' This does not work!
		SetTextAreaFont( gadget, monospacefont )	' nor does this!
		
		SetGadgetText( gadget, "THIS IS AN EXAMPLE" )
		'ActivateGadget( gadget )
		
	End Method

	' BEHAVIOUR
		
	Method update() ' document:TFullTextDocument )

		'If document ; SetGadgetText( gadget, document.lexer.reveal() )
		
	End Method

	' EVENT HANDLERS

	Method onFileChange:Object( event:TEvent )
		'update( TFullTextDocument(event.extra) )
		Return event	' Allow event to propogate
	End Method

	Method onFileOpen:Object( event:TEvent )
DebugStop
		'update( TFullTextDocument(event.extra) )
		Return event	' Allow event to propogate
	End Method

	Method onFileClose:Object( event:TEvent )
		SetGadgetText( gadget, "" )
		Return event	' Allow event to propogate
	End Method
		
End Type
Rem
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

'	AST VISITOR

Type TGift
	Field node:TASTNode
	Field gadget:TGadget
	Method New( node:TASTNode, gadget:TGadget )
		Self.node = node
		Self.gadget = gadget
	End Method
End Type

Type TMotherInLaw Extends TVisitor

	Field ast:TASTNode
	Field node:TGadget
	Field options:Int[2]
	
	Method New( ast:TASTNode, node:TGadget, options:Int[] )
		Self.ast = ast
		Self.node = node
		Self.options = options
	End Method
	
	' Create source code from the AST
	Method run()
'DebugStop
		visit( ast, node, "visit" )
	End Method

	Method addNode:TGadget( node:TASTNode, parent:TGadget, detail:String )
		Local gadget:TGadget = AddTreeViewNode( detail+node.loc(), parent, status( node ) )
		'If node.error.length>0
		'	For Local n:Int =AddTreeViewNode( node.error, gadget, ICON_ERROR )
		visitChildren( node, gadget )
		Return gadget
	End Method

	Method addNodeValue( node:TToken, parent:TGadget, detail:String, invalid:String = "*NIL*" )
		If node
			Local gadget:TGadget = AddTreeViewNode( detail+" "+node.value+node.loc(), parent, ICON_GREEN )
		Else
			Local gadget:TGadget = AddTreeViewNode( detail+" "+invalid, parent, ICON_ERROR )
		End If
	End Method

	Method addNodeValue( node:TASTNode, parent:TGadget, detail:String, invalid:String = "*NIL*" )
		If node
			Local gadget:TGadget = AddTreeViewNode( detail+" "+node.value+" "+node.loc(), parent, status( node ) )
		Else
			Local gadget:TGadget = AddTreeViewNode( detail+" "+invalid, parent, ICON_ERROR )
		End If
	End Method
			
	'Method value:String( token:TToken, invalid:String = "*NIL*" )
	'	If token Return token.value
	'	Return invalid
	'End Method
		
	Method status:Int( node:TASTNode, isTrue:Int = ICON_WHITE, isFalse:Int = ICON_RED )
		If node And node.errors.length = 0 Return isTrue
		Return isFalse
	End Method
	
	Method visit( node:TASTNode, mother:TGadget, prefix:String = "visit" )
'DebugStop
		If Not node 
			AddTreeViewNode( "NULL", mother, ICON_RED )
			Return
		End If

		' Use Reflection to call the visitor method (or an error)
		Local nodeid:TTypeId = TTypeId.ForObject( node )
		
		' Use Reflection to call the visitor method (or an error)
		Local this:TTypeId = TTypeId.ForObject( Self )
		' The visitor function is either defined in metadata or as node.name
		Local class:String = nodeid.metadata( "class" )
		If class = "" class = node.name
'DebugStop
		Local methd:TMethod = this.FindMethod( prefix+"_"+class )
		If methd
			methd.invoke( Self, [New TGift(node,mother)] )
		Else
			Local gadget:TGadget = AddTreeViewNode( "## WARNING ##", mother, ICON_RED )
			AddTreeViewNode( "Visualiser method '"+prefix+"_"+class+"()' is missing", gadget, ICON_ERROR )
		EndIf
		'If exception_on_missing_method ; exception( prefix+"_"+class )
		'Return ""
	End Method

	Method visitChildren( node:TASTNode, mother:TGadget  )
		Local compound:TASTCompound = TASTCompound( node )
'DebugStop
		If Not compound Return
		For Local child:TASTNode = EachIn compound.children
			visit( child, mother )
		Next
	End Method
		
	Method visit_( arg:TGift )
'DebugStop
		Local node:TASTNode = arg.node
		'Local name:String = "'"+node.name+"' ("+node.value+") is Not defined in visualiser"
		'Local mother:TGadget = AddTreeViewNode( name, arg.gadget, ICON_RED )

		Local mother:TGadget = AddTreeViewNode( "## WARNING ##", arg.gadget, ICON_RED )
		AddTreeViewNode( "Visualiser method for '"+node.name+"' ("+node.value+")' is not defined", mother, ICON_ERROR )

		visitChildren( arg.node, mother )
		ExpandTreeViewNode( mother )
	End Method

	' Missing optional 
	Method visit_missingoptional( arg:TGift )
'DebugStop
		Local node:TASTNode = arg.node
		Local detail:String = "OPTIONAL: "+node.name
		Local mother:TGadget = AddTreeViewNode( detail, arg.gadget, ICON_GREY )
	End Method
	
	Method visit_BODY( arg:TGift )
		Local mother:TGadget = AddTreeViewNode( "BODY", arg.gadget, ICON_WHITE )
		visitChildren( arg.node, mother )
		ExpandTreeViewNode( mother )
	End Method
	
	' We don't need to show these!
	Method visit_EOL( arg:TGift )
		If options[0]
			Local node:TASTNode = arg.node
			AddTreeViewNode( "EOL"+node.loc(), arg.gadget, ICON_WHITE )
		End If
	End Method

	Method visit_ERROR( arg:TGift )
		Local node:TASTNode = arg.node
		Local mother:TGadget = AddTreeViewNode( "## WARNING ## "+node.value+node.loc(), arg.gadget, ICON_RED )
		If Not node.errors.length = 0
			For Local error:TDiagnostic = EachIn node.errors
				AddTreeViewNode( error.reveal(), mother, ICON_ERROR )
			Next
		End If
		visitChildren( arg.node, mother )
		'ExpandTreeViewNode( mother )
	End Method
	
	Method visit_IGNORED( arg:TGift )
		Local node:TASTNode = arg.node
		Local mother:TGadget = AddTreeViewNode( "IGNORED TOKENS:", arg.gadget, ICON_YELLOW )
		'If node.error ; AddTreeViewNode( node.error, mother, ICON_ERROR )
		visitChildren( arg.node, mother )
		'ExpandTreeViewNode( mother )
	End Method

	Method visit_MODULE( arg:TGift )
		Local mother:TGadget = AddTreeViewNode( "MODULE", arg.gadget, ICON_WHITE )
		visitChildren( arg.node, mother )
		ExpandTreeViewNode( mother )
	End Method

	Method visit_NUMBER( arg:TGift )
		AddTreeViewNode( "NUMBER: ("+arg.node.value+")", arg.gadget, ICON_WHITE )
	End Method
	
	Method visit_PROGRAM( arg:TGift )
		Local mother:TGadget = AddTreeViewNode( "PROGRAM", arg.gadget, ICON_WHITE )
		visitChildren( arg.node, mother )
		ExpandTreeViewNode( mother )
	End Method
	
	Method visit_SKIPPED( arg:TGift )
		Local node:TASTNode = arg.node
		Local mother:TGadget = AddTreeViewNode( "SKIPPED: "+node.value+node.loc(), arg.gadget, ICON_YELLOW )
		'If node.error ; AddTreeViewNode( node.error, mother, ICON_ERROR )
		visitChildren( arg.node, mother )
		'ExpandTreeViewNode( mother )
	End Method

	Method visit_VARIABLE( arg:TGift )
		AddTreeViewNode( "VARIABLE: ("+arg.node.value+")", arg.gadget, ICON_WHITE )
	End Method
	
	Method visit_comment( arg:TGift )
		If options[1]
			Local node:TASTNode = arg.node
	'DebugStop
			Local mother:TGadget = AddTreeViewNode( "COMMENT"+node.loc(), arg.gadget, status(node) )
			Local child:TGadget = AddTreeViewNode( node.value, mother )
			SetGadgetColor( child, $7f, $7f, $7f )
			'AddTreeViewNode( arg.node.value, mother )
		End If
	End Method

	Method visit_framework( arg:TGift )
		Local node:TAST_Framework = TAST_Framework( arg.node )
'DebugStop
		'Local icon:Int      = ICON_RED
		Local detail:String = "FRAMEWORK "
		'If node.valid ; icon = ICON_WHITE
		
		If node.major And node.dot And node.minor
			detail :+ node.major.value + "." + node.minor.value
		Else
			detail :+ "?"
		End If
		
		' Add node to tree
		'Local mother:TGadget = 
		AddNode( node, arg.gadget, detail )
		'AddTreeViewNode( detail+node.loc(), arg.gadget, status( node ) )
	End Method
	
	Method visit_function( arg:TGift )
		Local temp:String
		Local node:TAST_Function = TAST_Function( arg.node )
'DebugStop
		'Local icon:Int      = ICON_RED
		Local detail:String  = "FUNCTION"
		'If arg.node.valid ; icon = ICON_WHITE

		If node.fnname ; detail :+ " "+node.fnname.value
		detail :+ ":"
		If node.returntype
			If node.returntype.id = TK_MISSING
				detail :+ "void"
			Else
				detail :+ node.returntype.value
			End If
		Else
			detail :+ "void"
		End If

		Local mother:TGadget = AddNode( node, arg.gadget, detail )

		' Add parameters:
		AddNodeValue( node.fnname, mother, "NAME:" )
		AddNodeValue( node.colon, mother, "COLON:" )
		AddNodeValue( node.returntype, mother, "RETURNTYPE:", "Void" )
		AddNodeValue( node.lparen, mother, "LPAREN:" )
		'AddTreeViewNode( "NAME: "+value( node.fnname ), mother, status( node.fnname ) )
		'AddTreeViewNode( "COLON: "+value( node.colon ), mother, ICON_WHITE )
		'AddTreeViewNode( "COLON: "+value( node.colon ), mother, ICON_WHITE )
		'AddTreeViewNode( "RETURNTYPE: "+value( node.returntype, "Void" ), mother, ICON_WHITE )
		visit( node.def, AddTreeViewNode( "DEFINITION", mother, ICON_WHITE ) )
		AddNodeValue( node.rparen, mother, "RPAREN:" )
		
		' Add function body
		If node.body visit( node.body, mother )
		'visitChildren( node, mother )
		ExpandTreeViewNode( mother )
	End Method

	Method visit_include( arg:TGift )
		Local node:TAST_Include = TAST_Include( arg.node )
'DebugStop
		Local detail:String  = "INCLUDE "+node.file.value
		Local mother:TGadget = AddNode( node, arg.gadget, detail )	
	End Method
	
	Method visit_remark( arg:TGift )
		If options[1]
			Local node:TASTNode = arg.node
	'DebugStop
			Local mother:TGadget = AddTreeViewNode( "REMARK"+node.loc(), arg.gadget, status(node) )
			Local Text:String = Replace( Replace( node.value, "~n", "\n" ), "~t", "\t" )
			Local child:TGadget = AddTreeViewNode( Text, mother )
		End If
	End Method
	
	Method visit_strictmode( arg:TGift )
		Local node:TASTNode = TASTNode( arg.node )
'DebugStop
'Local n:TASTNode = arg.node
		'Local icon:Int      = ICON_RED
		'Local detail:String = "** INVALID **"
		'If arg.node.valid ; icon = ICON_WHITE
		AddTreeViewNode( "STRICTMODE="+node.value+node.loc(), arg.gadget, status( node ) )
	End Method

	Method visit_type( arg:TGift )
		Local node:TAST_Type = TAST_Type( arg.node )
		Local detail:String  = "TYPE "+node.typename.value
		If node.extend And node.supertype ; detail :+ " Extends "+node.supertype.value
		Local mother:TGadget = AddNode( node, arg.gadget, detail )
		visitChildren( node, mother )
		ExpandTreeViewNode( mother )
	End Method

	Method visit_vardefinition( arg:TGift )
		Local node:TASTBinary = TASTBinary( arg.node )
'DebugStop
		Local detail:String = Upper( node.value )+" "
		If node.lnode 
			' LNODE is the definition which contains <ALPHA> <COLON> <KEYWORD|ALPHA>
			Local def:TASTBinary = TASTBinary( node.lnode )
			If def And def.lnode detail :+ def.lnode.value
		End If
		Local mother:TGadget = AddNode( node, arg.gadget, detail )
		visit( node.rnode, mother )
		'ExpandTreeViewNode( mother )		
	End Method
	
End Type
EndRem

'DebugStop
config.Load( CONFIG_FILE )

' Create Visualiser
Global app:TVisualiser = New TVisualiser
app.Run()

