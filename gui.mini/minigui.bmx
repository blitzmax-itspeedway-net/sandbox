' MINIGUI
' Immediate mode GUI for Blitzmax

Rem NOTES
* Context currently stores state as a hashed list of ULONG as strings - Can be improved
* State is a simple UINT but we need more features
* Commands objects are created each frame causing GC to dispose of lots of objects
	- Move this into a Used/Free list and re-use them
* TStacked is curretly using two Tlists; this may be quicker using an array or saving the
  Tlink into the object on creation and using that to remove it.
* FButton: icon is currently not implemented
End Rem

'Include "bin/struct.bmx"
'Include "bin/type.bmx"
Include "bin/components.bmx"
Include "bin/iif.bmx"
Include "bin/stack.bmx"

' FRAME OPTIONS (bitmapped)
Const GUI_POPUP:Int    = $0001
Const GUI_FRAME:Int    = $0002		' Do we draw a frame (background/border)
Const GUI_TITLEBAR:Int = $1000		' Do we draw a titlebar (Frame only)
Const GUI_CLOSEBTN:Int = $2000		' Do we draw a close button (frame only)

Const GUI_ALIGNLEFT:Int = 0
Const GUI_ALIGNCENTRE:Int = 1	' British English
Const GUI_ALIGNCENTER:Int = 1	' American English
Const GUI_ALIGNRIGHT:Int = 2

' Colors in the style sheet
Const PALETTE_BACKGROUND:Int   = $00
Const PALETTE_SURFACE:Int      = $01
Const PALETTE_PRIMARY:Int      = $02
Const PALETTE_SECONDARY:Int    = $03
Const PALETTE_ERROR:Int        = $04
Const PALETTE_ONBACKGROUND:Int = $05
Const PALETTE_ONSURFACE:Int    = $06
Const PALETTE_ONPRIMARY:Int    = $07
Const PALETTE_ONSECONDARY:Int  = $08
Const PALETTE_ONERROR:Int      = $09

'Const PALETTE_TEXT:Int        = 0	ONSURFACE
'Const PALETTE_BORDER:Int      = 1
'Const PALETTE_WINDOWBG:Int    = 2	SURFACE
'Const PALETTE_TITLEBG:Int     = 3	PRIMARY
'Const PALETTE_TITLETEXT:Int   = 4	ONPRIMARY
'Const PALETTE_PANELBG:Int     = 5	SURFACE
'Const PALETTE_BUTTON:Int      = 6	PRIMARY
'Const PALETTE_BUTTONHOVER:Int = 7	
'Const PALETTE_BUTTONFOCUS:Int = 8
'Const PALETTE_BASE:Int        = 9
'Const PALETTE_BASEHOVER:Int   = 10
'Const PALETTE_BASEFOCUS:Int   = 11
'Const PALETTE_SCROLLBASE:Int  = 12
'Const PALETTE_SCROLLTHUMB:Int = 13
'Const PALETTE_MAX:Int         = 14

' Rendering constants
Const GUI_TEXT_RENDER:Int  = $00
Const GUI_FRAME_RENDER:Int = $01
Const GUI_ICON_RENDER:Int  = $02
Const GUI_IMAGE_RENDER:Int = $03

' Component state (bitmapped)
Const GUI_STATE_CLOSED:Int = $0001

' Icons an mouse cursors
Const GUI_ICON_CLOSE:Int   = $0001

'Const GUI_CURSOR_EDIT:Int  = $0001

' The context contains the state of the current user interface
Struct GUIContext

	Field initialised:Int = False
	Field containers:TStack<TGUIContainer>

	Field renderer( ctx:GUIContext Var, cmd:TCommand )
	Field renderlist:TList
	
	Field style:SStyle
	
	Field focus:ULong 							' Component with Focus
	Field mouse_pressed:Int[] = [False,False]	' Has mouse been pressed
	Field mouse_released:Int[] = [False,False]	' Has mouse been release
	
	' State values for components
	Field savestate:TStringMap
	
	' Stacks
	Field layout_stack:SLayout[10]
	Field layout_stack_idx:Int
	
	' Body is the size of the drawing area calculated during layout
	Field body:SRect
	Field layout:SLayout	' Current Layout
	
	Method initialise()
		If initialised; Return
		containers = New TStack<TGUIContainer>
		renderlist = New TList()
		savestate = New TStringMap()
		'
		renderer = gui_default_renderer
		gui_default_style( style )
		
		initialised = True
	End Method

	' Replace the default renderer
	Method setRenderer( newrenderer( ctx:GUIContext Var, cmd:TCommand ) )
		renderer = newrenderer
	End Method

	' Add command to renderer
	Method addCommand( cmd:TCommand )
		renderlist.addlast( cmd )
	End Method
	
	' Start the GUI state
	' Always returns true to allow it to be added to an IF
	Method start:Int()
		If Not initialised; initialise()
		renderlist.clear()		' Reset the render list
		Return True
	End Method
	
	' End the GUI state by drawing all the components
	Method finish()
		If Not renderer; Return
		'DebugStop
		For Local cmd:TCommand = EachIn renderlist
			renderer( Self, cmd )
		Next			
	End Method

	' Get unique ID for a given component
	Method getid:ULong( name:String )
		Return makehash( name )
	End Method
	
	Method getid:ULong( number:ULong )
		Return makehash( String(number) )
	End Method
	
	Method getLayout( layout:SLayout Var )
		layout = layout_stack[ layout_stack_idx ]
	EndMethod

	' Get state record for a given ID
	Method getstate:ULong( id:ULong )
		Return ULong( String( savestate.valueforkey( id ) ) )
	End Method
	
	' Create a hash from a given string
	Method makehash:ULong( data:String )
		Local ascii:Byte
		Local hash:ULong = 0
		For Local i:Int = 0 Until Len( data )
			ascii = data[i]
			hash  = ((hash Shl 5) - hash) + ascii
			hash  = hash & hash
		Next
		Return hash
	End Method

	Method mouseover:Int( rect:SRect Var )
		If mouse_x > rect.x And mouse_x < rect.x+rect.w And mouse_y > rect.y And mouse_y < recy.y+rect.h; Return True
		Return False
	End Method
	
	Method mousepressed:Int( btn:Int )
		If btn>1 Or btn<0; Return False
		Return mouse_pressed[btn]
	End Method

	Method mousereleased:Int( btn:Int )
		If btn>1 Or btn<0; Return False
		Return mouse_released[btn]
	End Method

	' Set state record for a given ID
	Method setstate( id:ULong, state:ULong )
		savestate.insert( id, String( state ) )
	End Method

End Struct

' ## STYLES

Struct SStyle
	Field palette:SColor8[10]
	Field titlebar_height:Int = 20
	Field padding:Int = 2
	Field spacing:Int = 2
End Struct

Function gui_default_style( style:SStyle Var )
	style.palette = [ ..
		New SColor8( $FF, $FF, $FF, $FF ), .. ' BACKGROUND
		New SColor8( $7F, $7F, $7F, $FF ), .. ' SURFACE
		New SColor8( $62, $00, $EE, $FF ), .. ' PRIMARY
		New SColor8( $37, $00, $B3, $FF ), .. ' SECONDARY
		New SColor8( $B0, $00, $20, $FF ), .. ' ERROR				
		New SColor8( $00, $00, $00, $FF ), .. ' ON BACKGROUND
		New SColor8( $00, $00, $00, $FF ), .. ' ON SURFACE
		New SColor8( $FF, $FF, $FF, $FF ), .. ' ON PRIMARY
		New SColor8( $FF, $FF, $FF, $FF ), .. ' ON SECONDARY
		New SColor8( $FF, $FF, $FF, $FF ) ..  ' ON ERROR
		]
	style.titlebar_height:Int = 20
	style.padding:Int = 2
	style.spacing:Int = 2
End Function

' ## LAYOUT

Struct SLayout
	'Field body:SRect
	'Field nextlayout:SRect
	Field pos:SPoint
	Field size:SPoint
	'Field maximum:SPoint
	'Field widths[]
	'Field items:Int
	'Field item_index:Int
	'Field nextrow:Int
	'Field nexttype:Int
	'Field indent:Int
	
	' Move to next cell in layout
	Method getNext( ctx:GUIContext Var )
		
		
	End Method
	
End Struct

Function mg_layout_row( ctx:GUIContext Var, widths:Int[], height:Int )
	DebugStop
	Local layout:SLayout = New SLayout( ctx.body, widths, height )
	ctx.
EndFunction

' ## CONTAINERS

Type TGUIContainer

End Type

' Create a frame with header and close button
Function mg_begin_window:Int( ctx:GUIContext Var, title:String, rect:SRect, options:Int= GUI_FRAME | GUI_TITLEBAR | GUI_CLOSEBTN )

	' Create a frame
	mg_begin_frame( ctx, title, rect, options )

	' Always return true for BEGIN
	Return True	
End Function

' Create a basic frame
Function mg_begin_frame:Int( ctx:GUIContext Var, title:String, rect:SRect, options:Int=0 )

	' Save the size of the frame body
	Local body:SRect = rect

	' Draw background if required
	DebugStop
	If ( options & GUI_FRAME )
		ctx.addCommand( New TDrawFrameCommand( rect, PALETTE_BACKGROUND ) )
	EndIf

	' Draw titlebar if requested or title text is not empty
	If ( options & GUI_TITLEBAR Or title )
	
		' Add frame for title
		Local titlerect:SRect = rect
		titlerect.h = ctx.style.titlebar_height
		ctx.addCommand( New TDrawFrameCommand( titlerect, PALETTE_PRIMARY ) )
		
		' Reduce body size by the size of the titlebar
		body.h :- titlerect.h
		
		' Optionally add titlebar caption
		If title
			ctx.addCommand( New TDrawTextCommand( title, titlerect, PALETTE_ONPRIMARY ) )
		EndIf

		' Optionally add a close button
		If ( options & GUI_CLOSEBTN )
			Local buttonrect:SRect = titlerect
			buttonrect.x :+ buttonrect.w-buttonrect.w
			buttonrect.w = buttonrect.h
			ctx.addCommand( New TDrawIconCommand( GUI_ICON_CLOSE, buttonrect, PALETTE_ONPRIMARY, PALETTE_PRIMARY ) )
			'If MouseDown(1) And ctx.mouseinside( rect ) or ctx.focus=id and keydown( KEY_ENTER )
			'EndIf
		EndIf
	EndIf
	
	' Set the context body area
	ctx.body = body
	
	' Return True unless Close button has been pressed
	Return True	
End Function

' Create a basic panel
Function mg_begin_panel:Int( ctx:GUIContext Var, title:String, rect:SRect, options:Int=0 )
End Function

' Create a Popup menu
Function mg_open_popup( ctx:GUIContext Var, caption:String )
	DebugStop
	' Get object state
	Local id:ULong = ctx.getid( caption )
	Local state:ULong = ctx.getstate( id )
	' Apply OPEN state
	ctx.setstate( id, state & ~GUI_STATE_CLOSED )
End Function

' A Popup menu is a Frame with different options
Function mg_begin_popup:Int( ctx:GUIContext Var, caption:String )

	DebugStop
	' Get object state
	Local id:ULong = ctx.getid( caption )
	Local state:ULong = ctx.getstate( id )
	' Return if popup is closed
	If( state & GUI_STATE_CLOSED ); Return False
	
	Local options:Int = GUI_POPUP 
'  Int opt = MU_OPT_POPUP | MU_OPT_AUTOSIZE | MU_OPT_NORESIZE |
'            MU_OPT_NOSCROLL | MU_OPT_NOTITLE | MU_OPT_CLOSED;
	
	' close popup if mouse is not inside

'	Return mg_begin_frame( ctx, caption, New SRect(), options )

End Function

Function mg_end_popup( ctx:GUIContext Var )
End Function

Function mg_end_window( ctx:GUIContext Var )
End Function


' ## RENDERING

Function gui_default_renderer( ctx:GUIContext Var, cmd:TCommand )
	DebugStop
	Select cmd.class
	Case GUI_TEXT_RENDER
		Local tx:Int = cmd.rect.x
		Local ty:Int = cmd.rect.y + (cmd.rect.h - TextHeight( cmd.caption )/2 )
		'
		SetColor( ctx.style.palette[cmd.fg_color] )
		DrawText( cmd.caption, tx, ty )
	Case GUI_FRAME_RENDER
		SetColor( ctx.style.palette[cmd.bg_color] )
		DrawRect( cmd.rect.x, cmd.rect.y, cmd.rect.w, cmd.rect.h )
	Case GUI_ICON_RENDER
		' Background
		SetColor( ctx.style.palette[cmd.bg_color] )
		DrawRect( cmd.rect.x, cmd.rect.y, cmd.rect.w, cmd.rect.h )
		' Identify content
		Local content:String
		Select cmd.value
		Case GUI_ICON_CLOSE;	content = "X"
		Default
			content = "?"
		End Select
		' Calculate position
		Local tx:Int = cmd.rect.x + ( cmd.rect.w - TextWidth( content ) /2 )
		Local ty:Int = cmd.rect.y + ( cmd.rect.h - TextHeight( content ) /2 )
		' Foreground
		SetColor( ctx.style.palette[cmd.fg_color] )
		DrawText( content, tx, ty )	
	End Select
End Function

Type TStack

	Private
	Global stack:TList  = New TList()

	Public
	Method push( item:Object )
		stack.addlast( item )
	End Method
	
	Function pop:Object()
		Return stack.removelast()
	End Function

EndType

Type TPoint
	
	Field x:Int, y:Int
	
	Private
	Global usedlist:TList = New TList()
	Global freelist:TList = New TList()

	Field link:TLink

	Public
	
	Method New( x:Int, y:Int )
		Self.x = x
		Self.y = y
		Self.link = usedlist.addlast( Self )
	End Method

	' Get object from freelist or create new object
	Function get:TPoint( x:Int=0, y:Int=0 )
		Local item:TPoint = TPoint( freelist.removelast() )
		If item
			item.x = x
			item.y = y
			item.link = usedlist.addlast( item )
			Return item
		End If
		Return New TPoint( x, y )
	End Function
	
	' Move object from used list to freelist
	Method free()
		usedlist.removelink( link )
		freelist.addlast( Self )
	End Method
	
	Function spy:Int[]()
		Return [ usedlist.count(), freelist.count() ]
	End Function
		
End Type

Struct SPoint
	Field x:Int
	Field y:Int
	
	Method New( x:Int, y:Int )
		Self.x = x
		Self.y = y
	End Method
	
End Struct

Struct SRect
	Field x:Int
	Field y:Int
	Field w:Int
	Field h:Int
	
	Method New( x:Int, y:Int, w:Int, h:Int )
		Self.x = x
		Self.y = y
		Self.w = w
		Self.h = h
	End Method
	
End Struct

Type TCommand

	Field class:Int			' Commmand type
	Field caption:String	' Optional text
	Field rect:SRect		' Size of rendering area
	Field fg_color:Int
	Field bg_color:Int
	Field options:Int
	Field value:Int			' Icon

End Type

Type TDrawTextCommand Extends TCommand

	Method New( caption:String, rect:SRect, color:Int, options:Int=0 ) 
		Self.class    = GUI_TEXT_RENDER
		Self.caption  = caption
		Self.rect     = rect
		Self.fg_color = color
		Self.options  = options
	End Method
	
EndType

Type TDrawFrameCommand Extends TCommand

	Method New( rect:SRect, color:Int, options:Int=0 ) 
		Self.class    = GUI_FRAME_RENDER
		'Self.caption  = caption
		Self.rect     = rect
		Self.bg_color = color
		Self.options  = options
	End Method
	
EndType

Type TDrawIconCommand Extends TCommand

	Method New( icon:Int, rect:SRect, fg:Int, bg:Int, options:Int=0 ) 
		Self.class    = GUI_ICON_RENDER
		'Self.caption  = caption
		Self.rect     = rect
		Self.bg_color = bg
		Self.fg_color = bg
		Self.value    = icon
		Self.options  = options
	End Method
	
EndType
