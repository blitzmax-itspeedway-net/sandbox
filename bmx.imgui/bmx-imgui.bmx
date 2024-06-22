'   IMGUI for BlitzMax
'   (c) Copyright Si Dunford, JUN 2022, All Rights Reserved. 
'   VERSION: 3.0

'	Based on information found here
'	https://www.johno.se/book/imgui.html
'	https://solhsa.com/files/Assembly07_IMGUI.pdf

'	INSPIRATION:
'	https://immediate-mode-ui.github.io/Nuklear/doc/index.html#nuklear/example
'	https://www.sojamo.de/libraries/controlP5/
'	https://asawicki.info/Download/Productions/Lectures/Immediate%20Mode%20GUI.pdf
'	https://github.com/ocornut/imgui
'	https://www.forrestthewoods.com/blog/proving-immediate-mode-guis-are-performant/
'	https://discourse.julialang.org/t/ann-cimgui-jl-a-wrapper-for-bloat-free-immediate-mode-graphical-user-interface-dear-imgui/21268
'	

Include "bin/styles.bmx"
Include "bin/render.bmx"

' V3.0 Settings
Global IMGUI_PIPELINE_EXPAND:Int = 10	' Drawing Pipeline Commands
Global IMGUI_STACK_EXPAND:Int = 10		' Drawing Parameters

' V1.0 Constants

' Polled input does not capture INSERT key (On Linux at least)
' So a hook system added instead
'AddHook( EmitEventHook, UX._Hook, Null, 0 )

Const KEY_INSERT_BUG:Int = 67			' Insert returns 67 on some systems!

Const TITLE_HEIGHT_DEFAULT:Int = 56
Const TITLE_HEIGHT_EXTENDED:Int = 128

'Const VISIBLE:Int 			= 0
Const HIDDEN:Int 			= $0010		' 00000000 00000000 00000000 00001000
Const DISABLED:Int			= $80000000	' 10000000 00000000 00000000 00000000

' Point used in drawing and layout
Struct SPoint
	Field x:Int
	Field y:Int
	
	Method New( x:Int, y:Int )
		Self.x = x
		Self.y = y
	End Method
	
End Struct

' Rectangle used in drawing and layout
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

' Content Area
Struct SContentArea
	Field area:SRect      ' Current drawing area / body size
	Field x:Int, y:Int
	Field cx:Int, cy:Int  ' Drawing Cursor
End Struct

' SState
Struct SState
	Field active:ULong				' Widget that has mousedown
	' Keyboard
	Field focus:ULong = 0 			' ID of component with keyboard focus (0=None)
	Field keypressed:Int			' Latest key pressed
	Field keymod:Int				' Latest key modifier
	Field lastcomponent:ULong = 0	' Last component with focus (Used for tabbing)
	' Mouse
	Field mouseover:ULong			' Component that has mouseover
	Field mousepressed:Int			' Current mouse button state
	Field mouse_x:Int				' Current mouse X position
	Field mouse_y:Int				' Current mouse Y position
EndStruct

' A Structure to hold the current layout
' The cells array will grow but never shrink so should reach its maximum size
' in one frame and then not be resized again. It starts at 5 cells so might never
' resize!
Struct SLayout
	Field cell:Int    = -1          ' Current Cell
	Field count:Int	  = 0           ' Cells in this row
	Field cells:Int[] = [0,0,0,0,0]	' Start with 5 columns
	Field width:Int					' Width of row (All cells)
	Field repeats:Int = False       ' Row layout repeats for each line
	
	Method set( width:Int, count:Int, repeats:Int = False )
		Self.cell    = -1
		Self.count   = count
		Self.repeats = repeats
		Self.width   = width
		' Grow to required size
		If count > cells.Length; cells = cells[..count]
		'
		Local alloc:Int = width / count
		For Local col:Int = 0 Until count
			cells[col] = alloc
		Next
	End Method
	
	Method set( width:Int, columns:Int[], repeats:Int = False )
		Self.cell    = -1
		Self.count   = columns.Length
		Self.repeats = repeats
		' Grow to required size
		If count > cells.Length; cells = cells[..count]
		'
		' Loop through columns assigning widths
		Local sum:Int, autosize:Int=0, percent:Int=width/100
		For Local col:Int = 0 Until count
			If columns[col] = 0
				' Autosize
				cells[col] = 0	' Mark as autosize
				autosize :+ 1
			Else If columns[col] > 0
				' Percentage
				cells[col] = percent*columns[col]
				sum :+ cells[col]
			Else
				' Fixed width
				cells[col] = Abs( columns[col] )
				sum :+ cells[col]
			End If	
		Next
		' Loop through columns assigning autosize space
		If autosize>0
			Local alloc:Int = (width-sum)/autosize
			For Local col:Int = 0 Until count
				If cells[col]=0; cells[col]=alloc
			Next
		End If
	End Method
	
	Method clear()
		cell = -1
		count = 0
	End Method
		
	Method get:Int()
		If count = 0; Return width
		cell :+ 1
		If cell>=count
			If Not repeats; Return width
			cell = 0
		End If
		Return cells[cell]
	End Method
	
End Struct

' The heart of IMGUI is a state machine and singleton
Struct IMGUI

	' V3.0
	Private
	Field initialised:Int = False    ' Initialisation flag				
	Field style:GUIStyle             ' Replaceable stylesheet
	Field render( ctx:IMGUI )        ' Rendering function
	Field pipeline:SRenderer[] = []  ' Rendering list
	Field pipeline_count:Int         ' Records in Rendering Pipeline
	
	Field state:SState               ' Current UI state

	' V3.0 Heirarchial drawing stack
	Field stack:SContentArea[] = []  ' Heirarchical drawing stack
	Field stack_cursor:Int = 0       ' Points to next available stack position
	Field body:SContentArea          ' Current drawing parameters
	
	' V3.0 Simple Layout management
	Field layout:SLayout
	
	Private
	
	' V1.0
	Global _alpha_:Float = 0.7		' Background modal fade
	Global buttondown:Int = 0
	Global cursortime:Int = MilliSecs()
	Global cursorstate:Int = False
	Global cursorpos:Int = 0
	Global _insert_:Int = True

	Global _vpadding_:Int = 2, _hpadding_:Int = 2
	Global _textheight_:Int
	
	Global parentx:Int, parenty:Int
	
	' Keyboard
	'Global _scancode:Int[256]
	'Global _keyhits:Int[256]
	'Global _keyqueue:Int[256]
	'Global _keyptr:Int = 0
	
	' Define New() as private to prevent instance creation
	Private Method New() ; End Method

	' V3.0, Add renderer to the pipeline
	Public Method AddDraw( renderer:SRenderer )
'If pipeline_count >9; DebugStop
Print pipeline_count + "/"+Len(pipeline)
		' Do we need to expand the pipeline?
		If pipeline_count >= Len( pipeline )
Print "- pipeline expanding to "+Len(pipeline)
			Local resize:Int = Len(pipeline) + IMGUI_PIPELINE_EXPAND
			pipeline = pipeline[..resize]
		End If
Print "- setting pipeline["+pipeline_count+"] to "+["DRAWCIRCLE","DRAWRECT","DRAWICON","DRAWIMAGE","DRAWLINE","DRAWTEXT"][renderer.datatype]'+"="+renderer.value+"|'"+renderer.caption+"'"
		pipeline[pipeline_count] = renderer
		pipeline_count :+ 1 
	End Method
	
	' V3.0, Align rectangle within a rectangle
	Public Method Align:SPoint( rect:SRect, height:Int, width:Int, alignment:Int )
		Local pos:SPoint = New SPoint( rect.x, rect.y )
		
		' Vertical Alignment
		Select alignment & IMGUI_ALIGN_VMASK
		Case IMGUI_ALIGN_MIDDLE;	pos.y :+ ( rect.h - height ) / 2
		Case IMGUI_ALIGN_BOTTOM;	pos.y :+ rect.h - height
		End Select

		' Horizontal Alignment
		Select alignment & IMGUI_ALIGN_HMASK
		Case IMGUI_ALIGN_CENTRE;	pos.x :+ ( rect.w - width ) / 2
		Case IMGUI_ALIGN_RIGHT;		pos.x :+ rect.w - width
		End Select
		'
		Return pos
	End Method

	' V3.0, Updates the UI state using current keyboard and mouse
	Private Method UIState:Int( id:ULong, rect:SRect Var, clickable:Int = True )
		
		' KEYBOARD
		
		' If nothing has keyboard focus; then assign it.
		If state.focus = 0; state.focus = id		
		
		If state.keypressed = KEY_TAB
			' Lose focus (Next component will take it)
			state.focus = 0
			' If shift is pressed, select last component
			If KeyDown( KEY_LSHIFT ) Or KeyDown( KEY_RSHIFT );..
				state.focus = state.lastcomponent
			' Clear the processed key
			state.keypressed = 0
		End If

		' Save current as the last component (Enabled Shift-TAB)
		state.lastcomponent = id
		
		' debug focus by drawing a rectangle around it
		If state.focus = id
			Local focus:SRect = New SRect( rect.x-1, rect.y-2, rect.w+2, rect.h+2 )
			addDraw( IMGUI_DrawRect( focus, IMGUI_COLOR_ERROR ) )
		End If
				
		' MOUSE
		
		' Bounds check
		If state.mouse_x > rect.x And state.mouse_x < rect.x + rect.w And..
			state.mouse_y > rect.y And state.mouse_y < rect.y + rect.h
			
			state.mouseover = id
			If clickable And state.active = 0 And state.MouseDown
				state.active = id
			End If
		End If
		'
		If state.active = id And state.mouseover = id And Not state.mousepressed
			Return True
		EndIf
		
		Return False
	End Method
	
	' V3.0, Match state to colour
	Private Method Color_State:Int( onNormal:Int, onActive:Int, onMouseOver:Int )
		If state.active; Return onActive
		If state.mouseover; Return onMouseOver
		Return onNormal
	End Method
	
	' V3.0, Begin Draw initialises state
	Public Method BeginDraw:Int()
		If Not initialised; initialise()
		pipeline_count = 0
		' 
		state.mouse_x = MouseX()
		state.mouse_y = MouseY()
		state.mousepressed = MouseDown(0)
		'state.mousepressed[1] = MouseDown(1)
		state.mouseover = 0
		Return True
	End Method
	
	' V3.0, Completes state by drawing the interface
	Public Method EndDraw()
		If pipeline_count > 0 And render; render( Self ) 
	End Method

	' v3.0, Returns a string representation of an address pointer
	'       We use this to create unique indexes for components
	Method getaddr:String( value:Byte Ptr )
		' Create a pointer to a pointer
		Local b:Int Ptr = Varptr value	
		' Cast long pointer to integer in hex
		Return Hex( Int(b[1]) )+Hex( Int(b[0]) )
	End Method

	' V3.0, Create a hash from a given string
	Private Method hash:ULong( data:String )
		Local ascii:Byte
		Local hash:ULong = 0
		For Local i:Int = 0 Until Len( data )
			ascii = data[i]
			hash  = ((hash Shl 5) - hash) + ascii
			hash  = hash & hash
		Next
		Return hash
	End Method
			
	' V3.0, Retrieves the previous drawing stack
	Public Method pop()
		If stack_cursor <= 0; Return
'DebugStop
		stack_cursor :- 1
		body = stack[stack_cursor]
	End Method
	
	' V3.0, Push the current drawing structure to the stack
	Public Method push()
		' Do we need to expand the stack?
		If stack_cursor >= Len( stack )
			Local resize:Int = Len(stack) + IMGUI_STACK_EXPAND
			stack = stack[..resize]
Print "- stack expanding to "+Len(pipeline)
		End If
		stack[stack_cursor] = body
		body = New SContentArea()
		stack_cursor :+ 1 
	End Method
	
	' V3.0, Support replaceable stylesheet
	Public Method SetRender( renderer( ctx:IMGUI ) )
		If Not initialised; initialise()
		Self.render = renderer
	End Method

	' V3.0, Support replaceable stylesheet
	Public Method SetStyle( style:GUIStyle )
		If Not initialised; initialise()
		Self.style = style
	End Method
	
	' V1.0, Check rectangle mousebounds
	Private Method _MouseBounds_:Int( x:Int, y:Int, w:Int, h:Int )
		Local mx:Int = MouseX()
		Local my:Int = MouseY()
		If mx>x And mx<x+w And my>y And my<y+h Return True
		Return False
	End Method

	' V3.0, Initialisation
	Private Method initialise()
		If initialised; Return
		'containers = New TStack<TGUIContainer>
		'renderlist = New TList()
		'savestate = New TStringMap()
		'

		' Initialise the default renderer and the drawing pipeline
		render   = IMGUI_default_renderer
		pipeline = pipeline[..IMGUI_PIPELINE_EXPAND]

		' Set the default style
		style.setDefaults()
		
		' Mark self as initialised
		initialised = True
		
		' V1.0
		_textheight_ = TextHeight( "8" )
?linux
		' On Linux, default font height is mis-reported
		_textheight_ :- 4
?
	End Method

	Public Method SetColor( id:Int, colour:SColor8 )
		If id<0 Or id>IMGUI_COLOR_ONERROR; Return
		style.palette[ id ] = colour
	End Method
	
	Method GetColor:SColor8( id:Int )
		If id<0 Or id>IMGUI_COLOR_ONERROR; Return Null
		Return style.palette[ id ]
	End Method

	Method SetModal( level:Float )
		If level < 0.0 Or level > 1.0 Return
		_alpha_ = level
	End Method
	
	Method SetPadding( v:Int, h:Int )
		_hpadding_ = h
		_vpadding_ = v
	End Method
	
	Method setFocus( component:Int )
		buttondown = component
	End Method

	' ##### V1.0 COMPONENTS
	
Private Method __VERSION_1_0__()
End Method
	
	' Create a modal overlay
	Method Modal( x:Int = 0, y:Int = 0, w:Int = -1, h:Int = -1 )
		If w=-1; w = GraphicsWidth()
		If h=-1; h = GraphicsHeight()
		SetColor( style.palette[ IMGUI_COLOR_BACKGROUND ] )
		SetAlpha( _alpha_ )
		DrawRect( x, y, w, h )
		SetAlpha( 1.0 )
	End Method

	' Frame with Header
	Method Frame1( Caption:String, x:Int = 0, y:Int = 0, w:Int = -1, h:Int = -1 )
		If w = -1; w = GraphicsWidth()
		If h = -1; h = GraphicsHeight()
		Local height:Int = TITLE_HEIGHT_DEFAULT
		addDraw( IMGUI_DrawRect( New SRect( x,y,w,height ), IMGUI_COLOR_PRIMARY ) )
		'SetColor( style.palette[ IMGUI_COLOR_PRIMARY ] )
		'DrawRect( x, y, w, height )
		addDraw( IMGUI_DrawText( Caption, New SRect( x,y,w,height ), IMGUI_COLOR_ONPRIMARY, IMGUI_ALIGN_TC ) )
		'SetColor( style.palette[ IMGUI_COLOR_ONPRIMARY ] )
		'_DrawCaption_( Caption, x, y, w, height, ALIGN_CENTRE )
		Frame1( x, y+height, w, h-height )
	End Method

	' Frame without Header
	Method Frame1( x:Int = 0, y:Int = 0, w:Int = -1, h:Int = -1, flags:Int = 0 )
		If w = -1; w = GraphicsWidth()
		If h = -1; h = GraphicsHeight()
		addDraw( IMGUI_DrawRect( New SRect( x,y,w,h ), IMGUI_COLOR_SURFACE ) )
		'SetColor( style.palette[ IMGUI_COLOR_SURFACE ] )
		'DrawRect( x, y, w, h )
		' Save the parent position
		parentx = x
		parenty = y
	End Method
	
	Method Button:Int( id:Int, Caption:String, x:Int, y:Int, w:Int = -1, h:Int = -1, flags:Int = 0 )

		If flags & HIDDEN ; Return False

		If w = -1; w = TextWidth( caption ) + _vpadding_
		If h = -1; h = _textheight_ + _hpadding_

		Local _disabled:Int = False
		If flags & DISABLED; _disabled = True
		
		x :+ parentx
		y :+ parenty
		
		Local inside:Int = _MouseBounds_( x, y, w, h )
		Local pressed:Int = False
		Local BG:SColor8, FG:SColor8

		' Three states of the button
		Select True

		Case inside And MouseDown(1)		' Pressed
			addDraw( IMGUI_DrawRect( New SRect( x,y,w,h ), IMGUI_COLOR_SECONDARY ) )
			'SetColor( style.palette[ IMGUI_COLOR_SECONDARY ] )
			'DrawRect( x, y, w, h ) 	' Border and default background
			addDraw( IMGUI_DrawText( Caption, New SRect( x,y,w,h ), IMGUI_COLOR_ONSECONDARY, IMGUI_ALIGN_MC ) )
			'SetColor( style.palette[ IMGUI_COLOR_ONSECONDARY] )
			'_DrawCaption_( Caption, x, y, w, h, ALIGN_CENTRE )
			pressed = True
		Case inside	' And Not MouseDown(1)	' Mouseover
			addDraw( IMGUI_DrawRect( New SRect( x,y,w,h ), IMGUI_COLOR_PRIMARY ) )
			'SetColor( style.palette[ IMGUI_COLOR_PRIMARY ] )
			'DrawRect( x, y, w, h ) 	' Border and default background
			addDraw( IMGUI_DrawRect( New SRect( x+1,y+1,w-2,h-2 ), IMGUI_COLOR_ONPRIMARY ) )
			'SetColor( style.palette[ IMGUI_COLOR_ONPRIMARY ] )
			'DrawRect( x+1, y+1, w-2, h-2 )
			addDraw( IMGUI_DrawText( Caption, New SRect( x,y,w,h ), IMGUI_COLOR_PRIMARY, IMGUI_ALIGN_MC ) )
			'SetColor( style.palette[ IMGUI_COLOR_PRIMARY ] )
			'_DrawCaption_( Caption, x, y, w, h, ALIGN_CENTRE )
		Default								' Normal
			addDraw( IMGUI_DrawRect( New SRect( x,y,w,h ), IMGUI_COLOR_PRIMARY ) )
			'SetColor( style.palette[ IMGUI_COLOR_PRIMARY ] )
			'DrawRect( x, y, w, h ) 	' Border and default background
			addDraw( IMGUI_DrawText( Caption, New SRect( x,y,w,h ), IMGUI_COLOR_ONPRIMARY, IMGUI_ALIGN_MC ) )
			'SetColor( style.palette[ IMGUI_COLOR_ONPRIMARY ] )
			'_DrawCaption_( Caption, x, y, w, h, ALIGN_CENTRE )
		End Select

		' State
		If pressed 
			buttonDown = ID
		ElseIf buttonDown = ID
			' Button released
			buttonDown = 0
			Return True
		End If
		Return False
	End Method

	Method OnOffButton:Int( id:Int, Caption:String, buttonGroup:Int Var, x:Int, y:Int, w:Int = -1, h:Int = -1, flags:Int = 0 )
		If flags And HIDDEN = HIDDEN Return False
		If w = -1; w = TextWidth( caption ) + _vpadding_
		If h = -1; h = _textheight_ + _hpadding_
		
		x :+ parentx
		y :+ parenty
		
		Local inside:Int = _MouseBounds_( x, y, w, h )
		Local pressed:Int = False
		'Local BG:SColor8 = style.palette[ IMGUI_COLOR_PRIMARY ]
		'Local FG:SColor8 = style.palette[ IMGUI_COLOR_ONPRIMARY ]
		Local FG:Int = IMGUI_COLOR_ONPRIMARY
		Local BG:Int = IMGUI_COLOR_PRIMARY
		
		If inside And MouseDown(1) And buttonGroup <> ID
			pressed = True
			buttonGroup = ID
		EndIf
			
		If buttonGroup = ID
			BG = IMGUI_COLOR_SECONDARY
			FG = IMGUI_COLOR_ONSECONDARY
		End If
		
		' BACKGROUND
		addDraw( IMGUI_DrawRect( New SRect( x,y,w,h ), IMGUI_COLOR_PRIMARY ) )
		'SetColor( BG )
		'DrawRect( x, y, w, h )
		
		' FOREGROUND
		addDraw( IMGUI_DrawText( Caption, New SRect( x,y,w,h ), FG, IMGUI_ALIGN_MC ) )
		'SetColor( FG )
		'_DrawCaption_( Caption, x, y, w, h, ALIGN_CENTRE )

		'If pressed 
		'	buttonDown = ID
		'ElseIf buttonDown = ID
		'	' Button released
		'	buttonDown = 0
		'	Return True
		'End If
		Return Pressed
	End Method
	
	Method Label( Caption:String, x:Int, y:Int, h:Int = -1, flags:Int = 0 )
		If flags And HIDDEN = HIDDEN Return
		If h = -1; h = _textheight_ + _hpadding_
		addDraw( IMGUI_DrawText( Caption, New SRect( x+parentx,y+parenty,-1,h ), IMGUI_COLOR_ONSURFACE, IMGUI_ALIGN_MC ) )
		'SetColor( style.palette[ IMGUI_COLOR_ONSURFACE ] )
		'x :+ parentx
		'y :+ parenty
		'_DrawCaption_( caption, x, y, -1, h )
	End Method

	Method IntField( ID:Long, Value:Int Var, x:Int, y:Int, w:Int = -1, h:Int = -1, Length:Int = 5, flags:Int = 0 )
		If flags And HIDDEN = HIDDEN Return

		If w = -1; w = TextWidth( value ) + _vpadding_
		If h = -1; h = _textheight_ + _hpadding_
		Local charwidth:Int = TextWidth("W")
		
		x :+ parentx
		y :+ parenty
		
		Local inside:Int = _MouseBounds_( x, y, w, h )
		Local pressed:Int = False
		Local FG:Int = IMGUI_COLOR_ONPRIMARY
		Local BG:Int = IMGUI_COLOR_PRIMARY
		'Local BG:SColor8 = style.palette[ IMGUI_COLOR_PRIMARY ]	
		
		' BACKGROUND
		addDraw( IMGUI_DrawLine( New SRect( x,y+h,x+w,y+h ), BG ) )
		'SetColor( BG )
		'DrawLine( x, y+h, x+w, y+h )

		' FOREGROUND		
		Local caption:String = value
		Local alignedX:Int = x + w - TextWidth( caption ) - _hpadding_
		
		If inside And MouseDown(1)
			If buttondown<>ID; FlushKeys()
			buttondown = ID
			' Position cursor at mouse-click
			cursorpos = Max( 0, (MouseX()-alignedX)/charwidth )
		End If
		
		addDraw( IMGUI_DrawText( Caption, New SRect( alignedX,y,w,h ), FG, IMGUI_ALIGN_MC ) )
		'SetColor( FG )
		'_DrawCaption_( caption, alignedX, y, w, h )

		' Cursor
		If buttonDown = ID
			If cursortime < MilliSecs()
				cursorstate = Not cursorstate
				cursortime = MilliSecs() + 600
			End If
			If cursorstate
				'SetColor( BLACK )
				Local tx:Int = alignedX+cursorpos*charwidth
				If _insert_
					addDraw( IMGUI_DrawLine( New SRect( tx,y+4,tx,y+h+4 ), IMGUI_COLOR_ONPRIMARY ) )
					'DrawLine( tx, Y+4, tx, Y+H-4 )
				Else
					Local tx2:Int = alignedX+(cursorpos+1)*charwidth
					addDraw( IMGUI_DrawLine( New SRect( tx,y+h-3,tx2,y+h-3 ), IMGUI_COLOR_ONPRIMARY ) )
					'DrawLine( tx, Y+H-3, tx2, Y+H-3 )
				End If
			End If
		End If

		If KeyHit( KEY_LEFT ) ; cursorpos = Max( cursorpos - 1, 0 )
		If KeyHit( KEY_RIGHT );	cursorpos = Min( cursorpos + 1, Len( caption ) )
		If KeyHit( KEY_HOME ) ; cursorpos = 0
		If KeyHit( KEY_END ) ; cursorpos = Len( caption )
		If KeyHit( KEY_DELETE ) And cursorpos<Len( caption )
			caption = caption[..cursorpos]+caption[cursorpos+1..]
			value = Int( caption )
		End If
		If KeyHit( KEY_BACKSPACE )
			caption = caption[..cursorpos-1]+caption[cursorpos..]
			cursorpos = Max( cursorpos-1, 0 )
			value = Int( caption )
			If value=0 cursorpos=1
		End If
		If KeyHit( KEY_INSERT ) Or KeyHit( KEY_INSERT_BUG )
			_insert_ = Not _insert_
			Print( "INSERT TOGGLED TO "+["FALSE","TRUE"][_insert_] )
		End If
		
		Local ch:Int = GetChar()
		Select True
		Case ch>=KEY_0 And ch<=KEY_9
			'222DebugStop
			'Local c:String = caption[..cursorpos]
			'c :+ Chr(ch)
			'c :+ caption[..cursorpos]
			If _insert_ 
				If Len(caption)<=Length
					Local prevalid:String = caption[..cursorpos]+Chr(ch)+caption[cursorpos..]
					If Long( prevalid ) <= 65535
						value = Int( prevalid )
						cursorpos = Min( cursorpos + 1, Len(prevalid) )
					End If
				End If
			Else
				caption = caption[..cursorpos]+Chr(ch)+caption[cursorpos+1..]
				value = Int( caption )
				cursorpos = Min( cursorpos + 1, Len(caption)-1 )
			End If
		Case ch=0
		Default
			Print ch
		End Select
		
		' Stop cursor extending past last character in overwrite mode
		If Not _insert_; cursorpos = Min( cursorpos, 5 )

	End Method

Private Method __VERSION_3_0__LAYOUT__()
End Method

	' ##### V3.0 PANELS AND LAYOUTS
	
	' Apply cell layout to existing rectangle
	Protected Method Apply_Layout( rect:SRect Var )

		

		' Get cell from current layout
		
		layout.cell :+ 1
		If layout.cell > Len(layout.cells)
			' Layout finished. Start next row
			EndRow()
		End If
	
	End Method

	' V3.0, Starts a Window component which is a Frame with a header
	Public Method Frame:Int( rect:SRect, options:UInt=0 )
		push()	' Save current drawing parameters
		Return True
	End Method
	
	' V3.0, Completes Frame drawing
	Public Method EndFrame()
		pop()
	End Method
	
	' V3.0, Starts a Panel which is just a frame without a background
	Public Method Panel:Int( rect:SRect, options:UInt=0 )
		push()	' Save current drawing parameters
		Return True
	End Method

	' V3.0, Completes Panel drawing
	Public Method EndPanel()
		pop()
	End Method
		
	' V3.0, Creates a list of cells in this row
	Method Row( columns:Int[], repeating:Int = False )
		layout.set( body.area.w, columns, repeating )
	End Method
	Method Row( columns:Int, repeating:Int = False )
		layout.set( body.area.w, columns, repeating )
	End Method
	' V3.0, Completes Layout drawing
	Public Method EndRow()
		layout.clear()
	End Method

	' V3.0, Starts a Window component which is a Frame with a titlebar
	' Returns True unless close button pressed
	' NOTE: Alignment is used to position the Titlebar
	Public Method Window:Int( caption:String, rect:SRect, options:UInt = IMGUI_TITLEBAR | IMGUI_TITLEBAR_CLOSE )
		Local state:Int = True
		Local body:SRect = rect

		push()	' Save current drawing parameters
		
		' First we draw the top level frame
		addDraw( IMGUI_DrawRect( rect, IMGUI_COLOR_SURFACE ) )

		' Draw the (optional) titlebar
		If options & IMGUI_TITLEBAR_MASK
			Local tool:SRect = rect
			If options & IMGUI_TITLEBAR
				tool.h = style.titlebar_height
				addDraw( IMGUI_DrawRect( tool, IMGUI_COLOR_PRIMARY ) )
				addDraw( IMGUI_DrawText( Caption, tool, IMGUI_COLOR_ONPRIMARY, options ) )
			ElseIf options & IMGUI_TITLEBAR_BIG
				tool.h = style.titlebar_height_big		
				addDraw( IMGUI_DrawRect( tool, IMGUI_COLOR_PRIMARY ) )
				addDraw( IMGUI_DrawText( Caption, tool, IMGUI_COLOR_ONPRIMARY, options ) )
			End If
			body.y :+ tool.h
			body.h :- tool.h
			
			' Draw command button
			If options & IMGUI_TITLEBAR_CLOSE
				tool.w = style.iconsize
				tool.h = style.iconsize
				tool.x = body.x + body.w - tool.w - style.margin
				tool.y :+ style.margin
				addDraw( IMGUI_DrawIcon( IMGUI_ICON_CLOSE, tool, IMGUI_COLOR_SECONDARY, IMGUI_COLOR_ONSECONDARY ) )
			End If
		End If
		Return state
	End Method

	' V3.0, Completes window drawing
	Public Method EndWindow()
		pop()
	End Method

	' ##### V3.0 COMPONENTS

Private Method __VERSION_3_0__COMPONENTS__()
End Method

	' V3.0, Button
	Method Button:Int( caption:String, options:Int = IMGUI_ALIGN_MC )

		' Get unique ID by using the caption to create a hash
		Local id:ULong = hash( caption )
	
		' Size of button
		Local rect:SRect = New SRect( body.x, body.y, style.widget_width, style.widget_height )

		' Call layout manager to adjust component
		Apply_Layout( rect )

		' Calculate mouseover and button impact
		Local result:Int = UIState( id, rect )
		
		' Match colour to state (Normal, Active, Mouseover )
		Local BG:Int = color_state( IMGUI_COLOR_PRIMARY, IMGUI_COLOR_SECONDARY, IMGUI_COLOR_ONPRIMARY )
		Local FG:Int = color_state( IMGUI_COLOR_ONPRIMARY, IMGUI_COLOR_ONSECONDARY, IMGUI_COLOR_PRIMARY )

		' Draw button and text
		addDraw( IMGUI_DrawRect( rect, BG ) )
		addDraw( IMGUI_DrawText( Caption, rect, FG, IMGUI_ALIGN_MC ) )

		Return result	
	End Method
	Method Button:Int( image:TImage, options:Int = IMGUI_ALIGN_MC )
		' Must have an image or the button simply returns false
		If Not image; Return False

		' Get unique ID by using the image to create a hash
		Local id:ULong = hash( getaddr( Varptr image ) )
	
		' Size of button
		Local rect:SRect = New SRect( body.x, body.y, style.widget_width, style.widget_height )

		' Call layout manager to adjust component
		Apply_Layout( rect )

		' Calculate mouseover and button impact
		Local result:Int = UIState( id, rect )
		
		' Match colour to state (Normal, Active, Mouseover )
		Local BG:Int = color_state( IMGUI_COLOR_PRIMARY, IMGUI_COLOR_SECONDARY, IMGUI_COLOR_ONPRIMARY )

		' Draw button and image
		addDraw( IMGUI_DrawRect( rect, BG ) )
		addDraw( IMGUI_DrawImage( image, rect, IMGUI_ALIGN_MC ) )

		Return result		
		
	End Method

	' V3.0
	Method Checkbox:Int( value:Int Var, options:UInt=0 )

		' Get unique ID by using the value to create a hash
		Local id:ULong = hash( getaddr( Varptr value ) )
	
		' Size of button
		Local rect:SRect = New SRect( body.x, body.y, style.widget_width, style.widget_height )

		' Call layout manager to adjust component
		Apply_Layout( rect )

		' Calculate mouseover and button impact
		Local result:Int = UIState( id, rect )
		If result; value = Not value
		
		' Match colour to state (Normal, Active, Mouseover )
		Local BG:Int = color_state( IMGUI_COLOR_PRIMARY, IMGUI_COLOR_SECONDARY, IMGUI_COLOR_ONPRIMARY )

		' Draw button
		addDraw( IMGUI_DrawRect( rect, BG ) )

		Return value
	End Method

	' V3.0
	Method Dropdown( value:Int Var, list:String[], options:UInt=0 )
Rem
//implementation
void Gui::combo(unsigned int& aChoice, const int aX, const int aY, const char** someChoices)
{
    bool& h(handleState(&aChoice));

    //expanded
    if(h)
    {
        //current choice
        if(doButton(aX, aY, someChoices[aChoice]))
            h = false; //same choice

        //list
        unsigned int c(0);
        int y(aY);
        while(someChoices[c]) //terminate on NULL
        {
            if(doRadio(c == aChoice, aX, y += buttonHeight(), someChoices[c]))
            {
                aChoice = c;
                h = false;
            }
            c++;
        }
    }
    //collapsed
    else
    {
        if(doRadio(h, aX, aY, someChoices[aChoice]))
            h = true;
    }
}
EndRem
	End Method

	' V3.0
	Method Label( Text:String, options:UInt = IMGUI_ALIGN_ML )
		
		' Size of button
		Local rect:SRect = New SRect( body.x, body.y, style.widget_width, style.widget_height )

		' Call layout manager to adjust component
		Apply_Layout( rect )
		
		' Draw Label
		addDraw( IMGUI_DrawText( Text, rect, IMGUI_COLOR_ONPRIMARY, options ) )

	End Method

	' V3.0
	' When pressed, a radio button sets value to state
	Method Radio:Int( value:Int Var, state:Int, options:UInt=0 )

		' Get unique ID by using the value + state
		Local id:ULong = hash( getaddr( Varptr value ) + state )
	
		' Size of button
		Local rect:SRect = New SRect( body.x, body.y, style.widget_width, style.widget_height )

		' Call layout manager to adjust component
		Apply_Layout( rect )

		' Calculate mouseover and button impact
		Local result:Int = UIState( id, rect )
		If result; value = state
		
		' Match colour to state (Normal, Active, Mouseover )
		Local BG:Int = color_state( IMGUI_COLOR_PRIMARY, IMGUI_COLOR_SECONDARY, IMGUI_COLOR_ONPRIMARY )

		' Draw button
		addDraw( IMGUI_DrawCircle( rect, BG ) )

		Return value
	End Method
	
	' V3.0
	Method Slider:Float( value:Float Var, minvalue:Int=0, maxvalue:Int=100, options:UInt=0 )

		' Get unique ID by using the caption to create a hash
		Local id:ULong = hash( getaddr( Varptr value ) )
	
		' Size
		Local rect:SRect = New SRect( body.x, body.y, style.widget_width, style.widget_height )

		' Call layout manager to adjust component
		Apply_Layout( rect )

		' Calculate mouseover and button impact
		Local result:Int = UIState( id, rect )
		
		' Match colour to state (Normal, Active, Mouseover )
		Local BG:Int = color_state( IMGUI_COLOR_PRIMARY, IMGUI_COLOR_SECONDARY, IMGUI_COLOR_ONPRIMARY )
		Local FG:Int = color_state( IMGUI_COLOR_ONPRIMARY, IMGUI_COLOR_ONSECONDARY, IMGUI_COLOR_PRIMARY )

		' Draw Frame and text
		addDraw( IMGUI_DrawRect( rect, BG ) )
		'addDraw( IMGUI_DrawRect( rect, FG ) )
		addDraw( IMGUI_DrawText( value, rect, FG, IMGUI_ALIGN_LEFT ) )

		Return result
		
	End Method
	
	' V3.0
	Method TextBox( value:String Var, options:UInt=0 )
	
		' Get unique ID
		Local id:ULong = hash( getaddr( Varptr value ) )
	
		' Size
		Local rect:SRect = New SRect( body.x, body.y, style.widget_width, style.widget_height )

		' Call layout manager to adjust component
		Apply_Layout( rect )

		' Calculate mouseover and button impact
		Local result:Int = UIState( id, rect )
		
		' Match colour to state (Normal, Active, Mouseover )
		Local BG:Int = color_state( IMGUI_COLOR_PRIMARY, IMGUI_COLOR_SECONDARY, IMGUI_COLOR_ONPRIMARY )
		Local FG:Int = color_state( IMGUI_COLOR_ONPRIMARY, IMGUI_COLOR_ONSECONDARY, IMGUI_COLOR_PRIMARY )

		' Draw Frame and text
		addDraw( IMGUI_DrawRect( rect, BG ) )
		addDraw( IMGUI_DrawText( value, rect, FG, IMGUI_ALIGN_LEFT ) )
Rem
		If key>31 And key<127
			Print( "TEXTBOX.onKey(char): "+Chr(key) )
			valuestr = valuestr[..cursor]+Chr(key)+valuestr[cursor..]
			cursor :+ 1
		ElseIf code>0
			Select code
			Case KEY_HOME
				Print( "TEXTBOX=HOME" )
				cursor = 0
			Case KEY_END
				Print( "TEXTBOX=END" )
				cursor = valuestr.Length
			Case KEY_LEFT
				Print( "TEXTBOX=LEFT" )
				cursor :- 1
			Case KEY_RIGHT
				Print( "TEXTBOX=RIGHT" )
				cursor :+ 1
			Case KEY_DELETE
				Print( "TEXTBOX=DEL" )
				valuestr = valuestr[..cursor]+valuestr[cursor+1..]
			Case KEY_BACKSPACE
				Print( "TEXTBOX=BACKSPACE" )
				valuestr = valuestr[..cursor-1]+valuestr[cursor..]
				cursor = Max( cursor-1, 0 )
			Case KEY_INSERT
				Print( "TEXTBOX=INSERT" )
			Default
				Print( "TEXTBOX.onKey(code): "+code )
			End Select
			cursor = Max( 0, Min( cursor, valuestr.Length ))
			
			' Fit text to box
			'DebugStop
			Print( offset+","+cursor+": "+TextWidth( valuestr[offset..cursor])+"=="+inner.width )
			While TextWidth( valuestr[offset..cursor] ) >= inner.width
				'DebugStop
				offset :+ 1
			Wend 
			If cursor<offset; offset=cursor

		End If

EndRem
	End Method

End Struct

