'   LANGUAGE SERVER FOR BLITZMAX NG
'   (c) Copyright Si Dunford, September 2021, All Right Reserved
'
'	TOKEN & AST VISUALISATON TOOL

SuperStrict

' REQUIRED FOR THE GUI
Import maxgui.drivers
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

'Include "bin/TException.bmx"
'Include "bin/TToken.bmx"

Incbin "bin/16x16.png"

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

	' EVENT DISPATCHER

	Method onEvent:Object( event:TEvent )
		Select event.id
			'Case EVENT_APPRESUME		' Do nothing
			'Case EVENT_APPSUSPEND		' Do nothing
			Case EVENT_APPTERMINATE
				SaveWindow()
				End
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
		resize( event.x, event.y )
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
		
		' LOAD STATE
		Local x:Int = Int( String(config["top"]) )
		Local y:Int = Int( String(config["left"]) )
		Local w:Int = Int( String(config["width"]) )
		Local h:Int = Int( String(config["height"]) )
		Local mn:Int = Int( String(config["minim"]) )
		Local mx:Int = Int( String(config["maxim"]) )
		Local filename:String = String( config["filename"] )

		' CREATE WINDOW
		If w<WIN_MIN_WIDTH ; w=WIN_MIN_WIDTH
		If h<WIN_MIN_HEIGHT ; h=WIN_MIN_HEIGHT
		
		window = CreateWindow( "Visualisation Tool", x, y, w, h, Null, STYLE )
		SetMinWindowSize( window, WIN_MIN_WIDTH, WIN_MIN_HEIGHT )
		
		If mn ; MinimizeWindow( window )
		If mx ; MaximizeWindow( window )
		

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

		' LOAD FILE
		If filename
			editor.fileOpen( filename )
			parse()
		End If

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
				SaveWindow()
				End
			Case HELP_ABOUT
				Notify "Visualiser~n(c) Copyright, Si Dunford, September 2021, All Rights Reserved"
		End Select
	End Method
	
	' LANGUAGE SERVER INTERFACE
	Method parse()
	
		' PARSE THE SOURCE
		Local lexer:TLexer   = New TBlitzMaxLexer( editor.filedata )
		Local parser:TParser = New TBlitzMaxParser( lexer )
		Local ast:TASTNode   = parser.parse_ast()
		
		' UPDATE LEXER TOKENS		
		tokenview.update( lexer.tokens )
		
		' UPDATE AST
		ASTview.update( ast )
		
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
		SetGadgetFont( listbox, LookupGuiFont( GUIFONT_MONOSPACED, 10 ), True )
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
	
	Method update( tokens:TObjectList )

		' Clean down previous list
		ClearGadgetItems( listbox )

		' Display messge if there is nothing to display
		If tokens.isempty() 
			AddGadgetItem listbox, "(Nothing to display)"
			Return
		EndIf
		
		' Populate listbox
		For Local token:TToken = EachIn tokens
			Local line:String = ("("+token.line+","+token.pos+")")[..9] + token.class[..14] +" == " +token.value
			'Print line
			AddGadgetItem( listbox, Replace(line,"~n","\n") )
		Next
		
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
	Field tv:TGadget, root:TGadget, icons:TIconStrip

	' CONSTRUCTOR
	
	Method New( parent:TGadget )
		Super.New( parent )
		Print( "TASTView.new()" )

		tv   = CreateTreeView( 0, 0, 100, 100, window )
		root = TreeViewRoot( tv )

		icons = LoadIconStrip( "incbin::bin/16x16.png" )
		SetGadgetIconStrip( tv, icons )
		
		resize( ClientWidth( window ), ClientHeight( window ) )
		
	End Method
	
	' BEHAVIOUR
	
	Method resize( width:Int, height:Int )
		Local third:Int = width/3
		SetGadgetShape( tv, third*2, 0, third, height )
	End Method
	
	Method update( ast:TASTNode )

		' Clean down previous list
		ClearTreeView( tv )
		
		' Populate 
		Local visitor:TMotherInLaw = New TMotherInLaw( ast, root )
'DebugStop
		visitor.run()
		
	End Method
				
	' BEHAVIOUR

	' EVENT HANDLERS

'	Method onResize:Object( event:TEvent )
'	End Method
	
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
	
	Method New( ast:TASTNode, node:TGadget )
		Self.ast = ast
		Self.node = node
	End Method
	
	' Create source code from the AST
	Method run()
DebugStop
		visit( ast, node, "visit" )
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
		Local methd:TMethod = this.FindMethod( prefix+"_"+class )
		If methd
			methd.invoke( Self, [New TGift(node,mother)] )
		Else
			AddTreeViewNode( "** "+class+" - MISSING **", mother, ICON_RED )
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
'Local n:TASTNode = arg.node
		Local mother:TGadget = AddTreeViewNode( "** UNNAMED **", arg.gadget, ICON_YELLOW )
		visitChildren( arg.node, mother )
		ExpandTreeViewNode( mother )
	End Method

	Method visit_EOL( arg:TGift )
		AddTreeViewNode( "EOL", arg.gadget, ICON_WHITE )
	End Method

	Method visit_IGNORED( arg:TGift )
		Local node:TASTNode = arg.node
'DebugStop
'Local n:TASTNode = arg.node
		Local mother:TGadget = AddTreeViewNode( "** IGNORED **", arg.gadget, ICON_YELLOW )
		AddTreeViewNode( node.descr, mother )
		visitChildren( arg.node, mother )
		'ExpandTreeViewNode( mother )
	End Method

	Method visit_SKIPPED( arg:TGift )
		Local node:TASTNode = arg.node
DebugStop
		Local mother:TGadget = AddTreeViewNode( node.value+" ** SKIPPED **", arg.gadget, ICON_YELLOW )
		AddTreeViewNode( node.descr, mother )
		visitChildren( arg.node, mother )
		'ExpandTreeViewNode( mother )
	End Method

	Method visit_comment( arg:TGift )
		Local node:TASTNode = arg.node
DebugStop
		Local mother:TGadget = AddTreeViewNode( "COMMENT "+node.loc(), arg.gadget, ICON_WHITE )
		Local child:TGadget = AddTreeViewNode( node.value, mother )
		SetGadgetColor( child, $7f, $7f, $7f )
		'AddTreeViewNode( arg.node.value, mother )
	End Method

	Method visit_framework( arg:TGift )
		Local node:TAST_Framework = TAST_Framework( arg.node )
DebugStop
		Local icon:Int      = ICON_RED
		Local detail:String = "** INVALID **"
		If node.valid ; icon = ICON_WHITE
		
		If node.major And node.dot And node.minor
			detail = node.major.value + "." + node.minor.value
		End If
		
		AddTreeViewNode( "FRAMEWORK: "+detail, arg.gadget, icon )
	End Method
	
	Method visit_function( arg:TGift )
		Local node:TAST_Function = TAST_Function( arg.node )
DebugStop
		Local icon:Int      = ICON_RED
		Local detail:String = "** INVALID **"
		If arg.node.valid ; icon = ICON_WHITE

		'If arg.node.major And arg.node.dot And arg.node.minor
		'	detail = arg.node.major.value + "." + arg.node.minor.value
		'End If

		Local mother:TGadget = AddTreeViewNode( "FUNCTION "+detail, arg.gadget, icon )
		visitChildren( arg.node, mother )
		ExpandTreeViewNode( mother )
	End Method

	Method visit_strictmode( arg:TGift )
'DebugStop
'Local n:TASTNode = arg.node
		Local icon:Int      = ICON_RED
		Local detail:String = "** INVALID **"
		If arg.node.valid ; icon = ICON_WHITE
		AddTreeViewNode( "STRICTMODE: "+arg.node.value, arg.gadget, icon )
	End Method

	
	Method visit_type( arg:TGift )
DebugStop
Local n:TASTNode = arg.node
'		Local text:String = "Type "+arg.node.value
'		Local compound:TAST_Type = TAST_Type( arg.node )
'		If compound.supertype
'			text :+ " extends "+compound.supertype.value
'		EndIf
'		If arg.node.descr text :+ " ' "+arg.node.descr
'		text :+ "~n"+visitChildren( arg.node, "visit", arg.indent+TAB )
'		text :+ "EndType~n"
'		Return text
	End Method
	
End Type

'DebugStop
config.Load( CONFIG_FILE )

' Create Visualiser
Global app:TVisualiser = New TVisualiser
app.Run()

