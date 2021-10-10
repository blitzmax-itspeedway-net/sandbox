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

' COMMENTED OUT BECAUSE WE ARE TESTING LOCAL COPIES
'Import bmx.lexer
'Import bmx.parser
'Import bmx.blitzmaxparser
'Import bmx.transpiler

Include "bin/loadfile().bmx"

' SANDBOX LANGUAGE SERVER PROTOCOL DEFINITIONS
Include "bin/lsp.bmx"

' SANDBOX LEXER
Include "lexer/TLexer.bmx"
Include "lexer/TToken.bmx"
Include "lexer/TException.bmx"

' SANDBOX PARSER
Include "parser/TParser.bmx"
Include "parser/TASTNode.bmx"
Include "parser/TASTBinary.bmx"
Include "parser/TASTCompound.bmx"
Include "parser/TVisitor.bmx"
Include "parser/TParseValidator.bmx"

' Exception handler for Parse errors
Type TParseError Extends TException
End Type

Function ThrowParseError( message:String, line:Int=-1, pos:Int=-1 )
	Throw( New TParseError( message, line, pos ) )
End Function

' SANDBOX BLITZMAX LEXER/PARSER
Include "bmx/lexer-const-bmx.bmx"
Include "bmx/TBlitzMaxAST.bmx"
Include "bmx/TBlitzMaxLexer.bmx"
Include "bmx/TBlitzMaxParser.bmx"

' SANDBOX TRANSPILER
Include "transpiler/TTranspiler.bmx"
Include "transpiler/TTranspileBlitzMax.bmx"	' BlitzMax NG
Include "transpiler/TTranspileCPP.bmx"			' C++
Include "transpiler/TTranspileJava.bmx"		' Java
'Include "src/TTranspileJavaScript.bmx"	' HTML/JavaScr

'	DELIVERABLES
Include "bin/TSymbolTable.bmx"
Include "bin/TLanguageServerVisitor.bmx"
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
Const WIN_MIN_HEIGHT:Int = 800
Const WIN_MIN_WIDTH:Int = 1280

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

'	CREATE CONFIG MANAGER
Global config:TConfig = New TConfig()

'	CREATE DOCUMENT MANAGER
Global documents:TDocuments = New TDocuments()

AppTitle = "Visualisation Tool"

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
	Field parent:TGadget
	Field gadget:TGadget
	
	'Method New()
		'Print "TCONTROL.NEW()" + TTypeId.ForObject(Self).name
		'connect()
	'End Method

	Method New( parent:TGadget )
		Print "TCONTROL.NEW( gad )" '+ TTypeId.ForObject(Self).name
		Self.parent = parent
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
			Case EVENT_WINDOWSIZE		' Do nothing
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
	Method onGadgetAction:Object( event:TEvent ) ;	Return event	;	End Method
	Method onGadgetSelect:Object( event:TEvent ) ;	Return event	;	End Method
	Method onMenuAction:Object( event:TEvent )	;	Return event	;	End Method
	Method onResize:Object( event:TEvent )		;	Return event	;	End Method
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
	Field window:TGadget
	Field hsplitter:TSplitter, vsplitter:TSplitter
	Field tsplit:TGadget, bsplit:TGadget, lsplit:TGadget, rsplit:TGadget	' Top, Bot, Lft, Rgt
	
	Field editor:TEditor
	'Field tokenview:TTokenView
	Field ASTview:TASTView
	Field tabber:TGadget, tabs:TControl[], currenttab:TControl
	
	Field menu_edit_eol:TGadget
	Field menu_edit_comments:TGadget
	
	'	LANGUAGE SERVER
	Field lexer:TLexer
	Field parser:TParser
	Field ast:TASTNode   
		
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
		
		Local x:Int = Int( String(config["top"]) )
		Local y:Int = Int( String(config["left"]) )
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
		hsplitter = CreateSplitter( 0, 0, ClientWidth(window), ClientHeight(window), window, SPLIT_HORIZONTAL, 15 )
		SetGadgetLayout( hsplitter, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED )
		SetSplitterPosition( hsplitter, ClientHeight(window)/2 )
		'SetGadgetColor( hsplitter, 0,0,0 )
		tsplit = SplitterPanel( hsplitter, SPLITPANEL_MAIN )
		bsplit = SplitterPanel( hsplitter, SPLITPANEL_SIDEPANE )
		'SetGadgetLayout( tsplit, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED )
		'SetGadgetLayout( bsplit, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED )
		
		'	CREATE VERTICAL SPLITTER IN TOP
		
		' Split TOP panel vertically
		vsplitter = CreateSplitter( 0, 0, ClientWidth(tsplit), ClientHeight(tsplit), tsplit, SPLIT_VERTICAL )
		SetGadgetLayout( vsplitter, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED )
		SetSplitterPosition( vsplitter, ClientWidth(tsplit)/2 )
		'SetGadgetColor( vsplitter, 0,0,0 )
		lsplit = SplitterPanel( vsplitter, SPLITPANEL_MAIN )
		rsplit = SplitterPanel( vsplitter, SPLITPANEL_SIDEPANE )
		'SetGadgetLayout( lsplit, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED )
		'SetGadgetLayout( rsplit, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED )
		
		'	CREATE TOP COMPONENTS
		
		editor = New TEditor( lsplit )
		ASTview = New TASTView( rsplit )
		
		'	CREATE TAB BAR
		
		' Create a tab-view in the bottom split
		tabber = CreateTabber( 0, 0, ClientWidth( bsplit ), ClientHeight( bsplit ), bsplit )
		SetGadgetLayout( tabber, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED )
		
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
		
		AddGadgetItem( tabber, "Tokens" )
		tabs :+ [New TTokenView( tabber )]
		'SetGadgetLayout( tabs[TAB_TOKENVIEW], EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED )
		
		AddGadgetItem( tabber, "Diagnostics" )
		tabs :+ [New TDiagnostics( tabber )]
		'tabs[TAB_DIAGNOSTICS] = New TDiagnostics( bsplit )
		'SetGadgetLayout( tabs[TAB_DIAGNOSTICS], EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED )
		'HideGadget tabs[TAB_DIAGNOSTICS]

		AddGadgetItem( tabber, "Messages" )
		tabs :+ [New TMessages( tabber )]
		'tabs[TAB_MESSAGES] = New TMessages( bsplit )
		'SetGadgetLayout( tabs[TAB_MESSAGES], EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED )
		'HideGadget tabs[TAB_MESSAGES]

		AddGadgetItem( tabber, "Transpile" )
		tabs :+ [New TViewBMax( tabber )]

		AddGadgetItem( tabber, "C++" )
		tabs :+ [New TViewCPP( tabber )]

		AddGadgetItem( tabber, "Java" )
		tabs :+ [New TViewJava( tabber )]

		AddGadgetItem( tabber, "HTML" )
		tabs :+ [New TViewJava( tabber )]
		
		' Select SECOND tab to bypass bug in event handler when using tabber on linux
		currenttab = tabs[TAB_DIAGNOSTICS] 
		SelectGadgetItem(tabber:TGadget,1)
		ShowGadget( currenttab.gadget )
		EnableGadget( currenttab.gadget )

		' LOAD FILE
		If filename
			editor.fileOpen( filename )
			parse()
			update()
		End If

		' CONNECT EVENT HANDLER
		connect()
	End Method
	
	' ENTRY POINT
	
	Method run()

		' CONNECT EVENT HANDLERS
		
		'connect()
		
		' CREATE INDEX THREAD
		
		documents = New TDocuments()
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
		config["top"] = String( GadgetX( window ))
		config["left"] = String( GadgetY( window ))
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
				If filename 
'DebugStop
					editor.fileopen( filename )
					config.insert( "filename", filename )
					parse()
					update()
				End If
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
				update()
			Case VIEW_COMMENTS
				If MenuChecked( menu_edit_comments )
					UncheckMenu( menu_edit_comments )
				Else
					CheckMenu( menu_edit_comments )
				End If
				UpdateWindowMenu( window )
				update()
			Case HELP_ABOUT
				Notify "Visualiser~n(c) Copyright, Si Dunford, September 2021, All Rights Reserved"
		End Select
	End Method
	
	Method onGadgetAction:Object( event:TEvent )
		If event 
			Select event.source
			Case tabber
				HideGadget( currenttab.gadget )
				currenttab = tabs[ event.data ]
				ShowGadget( currenttab.gadget )
			Case editor.gadget
				'DebugStop
				'editor.filedata = TextAreaText( editor.gadget )
				parse()
				update()
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
	Method parse()	
		Local source:String = TextAreaText(editor.gadget)
		If source = "" Return
		' PARSE THE SOURCE
		lexer = New TBlitzMaxLexer( source )
		parser = New TBlitzMaxParser( lexer )
'DebugStop	
		ast = parser.parse_ast()
'Print( "PARSED" )
	End Method
	
	Method update()

		' Reset the visualiser title
		If editor And editor.document	
			SetGadgetText( window, AppTitle + ":" + StripDir(editor.document.uri) )
		Else
			SetGadgetText( window, AppTitle )
		End If
		
		' UPDATE LEXER TOKENS	

		TTokenView(tabs[TAB_TOKENVIEW]).update( lexer )
		
		' UPDATE AST
'DebugStop
		Local options:Int[] = [MenuChecked( menu_edit_eol ), MenuChecked( menu_edit_comments )]
		ASTview.update( ast, options )
		
		' Update Diagnostics
		'TDiagnostics( tabs[ TAB_DIAGNOSTICS ] ).update( ast )
		
		' Transpiler
		For Local tab:TControl = EachIn tabs
			tab.update( ast )
		Next
		
	End Method
	
End Type

Type TEditor Extends TControl
	'Field window:TGadget
	
	'Field filename:String
	Field document:TFullTextDocument
	
	' CONSTRUCTOR
	Method New( parent:TGadget )
		Super.New( parent )
		
		Print( "TEditor.new()" )

		' CREATE COMPONENT
		gadget = CreateTextArea( 0, 0, ClientWidth(parent), ClientHeight(parent), parent )
		SetGadgetLayout( gadget, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED )

		'	SET GADGET FONT
		'	(DOESN'T WORK)
		
		'Local monospacefont:TGuiFont = LookupGuiFont( GUIFONT_MONOSPACED, 11 ) 
		'Print FontName( monospacefont )
		
		Local monospacefont:TGuiFont = LoadGuiFont( "Courier New", 11 ) 
		'Local monospacefont:TGuiFont = LoadGuiFont( "FreeMono", 11 ) 
		Print FontName( monospacefont )
		If Not monospacefont monospacefont = LookupGuiFont( GUIFONT_MONOSPACED, 11 ) 

		SetTextAreaFont( gadget, monospacefont )

		'SetGadgetText( gadget, "EDITOR" )
		ActivateGadget( gadget )
		
		'SetStatusText( parent, "Line: 0 Char: 0" )
	End Method
	
	' BEHAVIOUR
	
	Method fileClose()
		If document documents.event_fileclose( document.uri )
		SetGadgetText( gadget, "" )
	End Method

	Method fileNew()
		fileClose()
		SetGadgetText( gadget, "" )
	End Method

	Method fileOpen( uri:String )
		If document documents.event_fileclose( document.uri )
		
		' Emulate Language Server
		document = documents.event_fileopen( uri )
		
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

'	Method onGadgetAction:Object( event:TEvent )
'		Local data:String = GadgetText( gadget )
'		If filedata=data Print "SAME" Else Print "DIFF"
'		filedata = data
'		If event.source = gadget
'		End If
'		Return event
'	End Method
	
End Type

Type TASTView Extends TControl
	Field tv:TGadget, root:TGadget, icons:TIconStrip

	' CONSTRUCTOR
	
	Method New( parent:TGadget )
		Super.New( parent )
		Print( "TASTView.new()" )

		tv   = CreateTreeView( 0, 0, ClientWidth(parent), ClientHeight(parent), parent )
		root = TreeViewRoot( tv )

		SetGadgetLayout( tv, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED )

		icons = LoadIconStrip( "incbin::bin/icons.png" )
		SetGadgetIconStrip( tv, icons )
		
	End Method
	
	' BEHAVIOUR
	
	Method update( ast:TASTNode, options:Int[]  )

		' Clean down previous list
		ClearTreeView( tv )
		
		' Populate 
		Local visitor:TMotherInLaw = New TMotherInLaw( ast, root, options:Int[] )
'DebugStop
		visitor.run()
		
	End Method
				
	' BEHAVIOUR

	' EVENT HANDLERS

End Type

Type TTokenView Extends TControl
	
	' CONSTRUCTOR

	Method New( parent:TGadget )
		Super.New( parent )
		Print( "TTokenView.new()" )
		
		gadget = CreateTextArea( 0, 0, ClientWidth(parent), ClientHeight(parent), parent )
		SetGadgetLayout( gadget, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED )
		
		SetGadgetText( gadget, "THIS IS AN EXAMPLE" )
		'ActivateGadget( gadget )
		
	End Method

	' BEHAVIOUR
		
	Method update( lexer:TLexer )

		SetGadgetText( gadget, lexer.reveal() )
		
	End Method

	' EVENT HANDLERS
	
End Type

Type TDiagnostics Extends TControl
	Method New( parent:TGadget )
		Super.New( parent )
		gadget = CreateTextArea( 0, 0, ClientWidth(parent), ClientHeight(parent), parent, TEXTAREA_READONLY )
		SetGadgetLayout( gadget, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED )
		SetGadgetText( gadget, "DIAGNOSTICS VIEWER" )
		'ActivateGadget( gadget )
		HideGadget( gadget )
	End Method
	
	Method update( ast:TASTNode )
		Local diags:String
		
		' Walk the AST Tree "In-Order"
'DebugStop
		'Print "INORDER TREE WALKER"
		Local list:TList = TList( ast.inorder( GetDiagnostic, New TList() ) )
		
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
		
		Function GetDiagnostic:Object( node:TASTNode, data:Object )
'DebugStop
			If node.errors.isEmpty() Return data
'DebugStop
			' Convert data into a Tlist and append to it
			Local list:TList = TList( data )
			'Local result:String
			For Local error:TDiagnostic = EachIn node.errors
				'result :+ errors[n] + "["+node.line+","+node.pos+"] "+node.error+" ("+node.getname()+")~n"
				'result :+ errors[n] + "["+node.line+","+node.pos+"] ("+node.getname()+")~n"
				list.addlast( error )
			Next 
			Return list 
		End Function
		
	End Method
	
End Type

Type TMessages Extends TControl
	Method New( parent:TGadget )
		Super.New( parent )
		gadget = CreateTextArea( 0, 0, ClientWidth(parent), ClientHeight(parent), parent, TEXTAREA_READONLY )
		SetGadgetLayout( gadget, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED )
		SetGadgetText( gadget, "MESSAGE VIEWER" )
		'ActivateGadget( gadget )
		HideGadget( gadget )
	End Method
End Type

Type TViewBMax Extends TControl
	Method New( parent:TGadget )
		Super.New( parent )
		gadget = CreateTextArea( 0, 0, ClientWidth(parent), ClientHeight(parent), parent, TEXTAREA_READONLY )
		SetGadgetLayout( gadget, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED )
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
			Local text:String = String( e )
			If exception 		;	result :+ "TException:~n"+exception.toString()
			If blitzexception	;	result :+ "TBlitzException:~n"+blitzexception.toString()
			If runtime			;	result :+ "TException:~n"+runtime.toString()
			If text				;	result :+ text
		End Try
		
		SetGadgetText( gadget, result )
		
	End Method
End Type

Type TViewCPP Extends TControl
	Method New( parent:TGadget )
		Super.New( parent )
		gadget = CreateTextArea( 0, 0, ClientWidth(parent), ClientHeight(parent), parent, TEXTAREA_READONLY )
		SetGadgetLayout( gadget, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED )
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
			Local text:String = String( e )
			If exception 		;	result :+ "TException:~n"+exception.toString()
			If blitzexception	;	result :+ "TBlitzException:~n"+blitzexception.toString()
			If runtime			;	result :+ "TException:~n"+runtime.toString()
			If text				;	result :+ text
		End Try
		
		SetGadgetText( gadget, result )
	
	End Method
End Type

Type TViewJava Extends TControl
	Method New( parent:TGadget )
		Super.New( parent )
		gadget = CreateTextArea( 0, 0, ClientWidth(parent), ClientHeight(parent), parent, TEXTAREA_READONLY )
		SetGadgetLayout( gadget, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED )
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
			Local text:String = String( e )
			If exception 		;	result :+ "TException:~n"+exception.toString()
			If blitzexception	;	result :+ "TBlitzException:~n"+blitzexception.toString()
			If runtime			;	result :+ "TException:~n"+runtime.toString()
			If text				;	result :+ text
		End Try
		
		SetGadgetText( gadget, result )
	
	End Method
End Type

Type TViewJavaScript Extends TControl

	Method New( parent:TGadget )
		Super.New( parent )
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
		If node And node.errors.isempty() Return isTrue
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
		If Not node.errors.isempty()
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

	Method visit_remark( arg:TGift )
		If options[1]
			Local node:TASTNode = arg.node
	'DebugStop
			Local mother:TGadget = AddTreeViewNode( "REMARK"+node.loc(), arg.gadget, status(node) )
			Local text:String = Replace( Replace( node.value, "~n", "\n" ), "~t", "\t" )
			Local child:TGadget = AddTreeViewNode( text, mother )
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

'DebugStop
config.Load( CONFIG_FILE )

' Create Visualiser
Global app:TVisualiser = New TVisualiser
app.Run()

