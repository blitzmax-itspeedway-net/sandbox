'   Immediate Graphical User Interface
'   (c) Copyright Si Dunford, Sep 2022, All Rights Reserved. 
'   VERSION: 1.0

'   CHANGES:
'   19 Sep 2022  Initial structure
'

'Module im.gui

Global BLACK:SColor8 = New SColor8( $000000 )
Global WHITE:SColor8 = New SColor8( $FFFFFF )

' Polled input does not capture INSERT key (On Linux at least)
' So a hook system added instead
'AddHook( EmitEventHook, UX._Hook, Null, 0 )

' Create GUI in a namespace
Type UX
	' Colours
	Global COL_PRIMARY:Int 				= 0
	Global COL_PRIMARY_VARIANT:Int 		= 1
	Global COL_SECONDARY:Int 			= 2
	Global COL_SECONDARY_VARIANT:Int 	= 3

	Global COL_BACKGROUND:Int			= 4
	Global COL_SURFACE:Int				= 5
	Global COL_ERROR:Int 				= 6

	Global COL_ONPRIMARY:Int			= 7
	Global COL_ONPRIMARY_VARIANT:Int 	= 8
	Global COL_ONSECONDARY:Int 			= 9
	Global COL_ONSECONDARY_VARIANT:Int	= 10

	Global COL_ONBACKGROUND:Int 		= 11
	Global COL_ONSURFACE:Int 			= 12
	Global COL_ONERROR:Int				= 13
	
	Private
	
	' Colour scheme
	Global _colours_:SColor8[]
		
	Global _alpha_:Float = 0.7		' Background modal fade
	Global buttondown:Int = 0
	Global cursortime:Int = MilliSecs()
	Global cursorstate:Int = False
	Global cursorpos:Int = 0
	Global _insert_:Int = True

	' Fixed size controls
	'Global _width_:Int = 0
	'Global _height_:Int = 0
	
	Global _vpadding_:Int = 2, _hpadding_:Int = 2
	Global _textheight_:Int
	
	Global parentx:Int, parenty:Int
	
	' Keyboard
	'Global _scancode:Int[256]
	'Global _keyhits:Int[256]
	'Global _keyqueue:Int[256]
	'Global _keyptr:Int = 0
	
	Const KEY_INSERT_BUG:Int = 67			' Insert returns 67 on some systems!
	
	Const TITLE_HEIGHT_DEFAULT:Int = 56
	Const TITLE_HEIGHT_EXTENDED:Int = 128
	
	Const ALIGN_MASK:Int 		= $0003		' 00000000 00000000 00000000 00000111
	Const ALIGN_LEFT:Int 		= 0
	Const ALIGN_CENTRE:Int 		= 1
	Const ALIGN_RIGHT:Int 		= 2
	'Const ALIGN_JUSTIFY:Int 	= 3			' Not used

	'Const VISIBLE:Int 			= 0
	Const HIDDEN:Int 			= $0010		' 00000000 00000000 00000000 00001000

	' Define New() as private to prevent instance creation
	Method New() ; End Method

	' Check rectangle mousebounds
	Function _MouseBounds_:Int( x:Int, y:Int, w:Int, h:Int )
		Local mx:Int = MouseX()
		Local my:Int = MouseY()
		If mx>x And mx<x+w And my>y And my<y+h Return True
		Return False
	End Function
	
	Function _DrawCaption_( Caption:String, x:Int, y:Int, w:Int, h:Int, flags:Int = 0 )
	'DebugStop
		'Local th:Int = TextHeight( "h_" )	' We dont use the caption here as it may not be full height
		Local tw:Int = TextWidth( Caption )
		Local align:Int = flags And ALIGN_MASK
		Local tx:Int = x
		Local ty:Int = y + ( h - _textheight_ ) / 2
		Select align
			'Case ALIGN_LEFT:
			'	tx = x
			Case ALIGN_CENTRE
				tx = x + ( w - tw ) / 2
			Case ALIGN_RIGHT
				tx = x + w - tw
		End Select
		DrawText( Caption, tx, ty )
	End Function
	
	Public
	
	Function Init()
		_colours_ = [ ..
		New SColor8( $2196F3 ),		' PRIMARY
		New SColor8( $0D47A1 ),		' PRIMARY VARIANT
		New SColor8( $FF9800 ),		' SECONDARY
		New SColor8( $E65100 ),		' SECONDARY VARIANT
		New SColor8( $FFFFFF ),		' BACKGROUND
		New SColor8( $EFE5FD ),		' SURFACE
		New SColor8( $B00020 ),		' ERROR
		WHITE,						' ON PRIMARY
		WHITE,						' ON PRIMARY VARIANT
		BLACK,						' ON SECONDARY
		WHITE,						' ON SECONDARY VARIANT
		BLACK,						' ON BACKGROUND
		BLACK,						' ON SURFACE
		WHITE ..					' ON ERROR
		]
		'DebugStop

		_textheight_ = TextHeight( "8" )
?linux
		' On Linux, default font height is mis-reported
		_textheight_ :- 4
?

	End Function
	
	Function SetColor( id:Int, colour:SColor8 )
		If id<0 Or id>COL_ONERROR; Return
		_colours_[ id ] = colour
	End Function
	
	Function GetColor:SColor8( id:Int )
		If id<0 Or id>COL_ONERROR; Return Null
		Return _colours_[ id ]
	End Function

	Function SetModal( level:Float )
		If level < 0.0 Or level > 1.0 Return
		_alpha_ = level
	End Function
	
	Function SetPadding( v:Int, h:Int )
		_hpadding_ = h
		_vpadding_ = v
	End Function
	
	Function setFocus( component:Int )
		buttondown = component
	End Function
	
	' Create a modal overlay
	Function Modal( x:Int = 0, y:Int = 0, w:Int = -1, h:Int = -1 )
		If w=-1; w = GraphicsWidth()
		If h=-1; h = GraphicsHeight()
		SetColor( _colours_[ COL_BACKGROUND ] )
		SetAlpha( _alpha_ )
		DrawRect( x, y, w, h )
		SetAlpha( 1.0 )
	End Function

	' Frame with Header
	Function Frame( Caption:String, x:Int = 0, y:Int = 0, w:Int = -1, h:Int = -1 )
		If w = -1; w = GraphicsWidth()
		If h = -1; h = GraphicsHeight()
		Local height:Int = TITLE_HEIGHT_DEFAULT
		SetColor( _colours_[ COL_PRIMARY ] )
		DrawRect( x, y, w, height )
		SetColor( _colours_[ COL_ONPRIMARY ] )
		_DrawCaption_( Caption, x, y, w, height, ALIGN_CENTRE )
		Frame( x, y+height, w, h-height )
	End Function

	' Frame without Header
	Function Frame( x:Int = 0, y:Int = 0, w:Int = -1, h:Int = -1, flags:Int = 0 )
		If w = -1; w = GraphicsWidth()
		If h = -1; h = GraphicsHeight()
		SetColor( _colours_[ COL_SURFACE ] )
		DrawRect( x, y, w, h )
		' Save the parent position
		parentx = x
		parenty = y
	End Function
	
	Function Button:Int( id:Int, Caption:String, x:Int, y:Int, w:Int = -1, h:Int = -1, flags:Int = 0 )
		If flags And HIDDEN = HIDDEN Return False
		If w = -1; w = TextWidth( caption ) + _vpadding_
		If h = -1; h = _textheight_ + _hpadding_
		
		x :+ parentx
		y :+ parenty
		
		Local inside:Int = _MouseBounds_( x, y, w, h )
		Local pressed:Int = False
		Local BG:SColor8, FG:SColor8

		' Three states of the button
		Select True
		Case inside And MouseDown(1)		' Pressed
			SetColor( _colours_[ COL_PRIMARY_VARIANT ] )
			DrawRect( x, y, w, h ) 	' Border and default background
			SetColor( _colours_[ COL_ONPRIMARY_VARIANT ] )
			_DrawCaption_( Caption, x, y, w, h, ALIGN_CENTRE )
			pressed = True
		Case inside	' And Not MouseDown(1)	' Mouseover
			SetColor( _colours_[ COL_PRIMARY ] )
			DrawRect( x, y, w, h ) 	' Border and default background
			SetColor( _colours_[ COL_ONPRIMARY ] )
			DrawRect( x+1, y+1, w-2, h-2 )
			SetColor( _colours_[ COL_PRIMARY ] )
			_DrawCaption_( Caption, x, y, w, h, ALIGN_CENTRE )
		Default								' Normal
			SetColor( _colours_[ COL_PRIMARY ] )
			DrawRect( x, y, w, h ) 	' Border and default background
			SetColor( _colours_[ COL_ONPRIMARY ] )
			_DrawCaption_( Caption, x, y, w, h, ALIGN_CENTRE )
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
	End Function

	Function OnOffButton:Int( id:Int, Caption:String, buttonGroup:Int Var, x:Int, y:Int, w:Int = -1, h:Int = -1, flags:Int = 0 )
		If flags And HIDDEN = HIDDEN Return False
		If w = -1; w = TextWidth( caption ) + _vpadding_
		If h = -1; h = _textheight_ + _hpadding_
		
		x :+ parentx
		y :+ parenty
		
		Local inside:Int = _MouseBounds_( x, y, w, h )
		Local pressed:Int = False
		Local BG:SColor8 = _colours_[ COL_PRIMARY ]
		Local FG:SColor8 = _colours_[ COL_ONPRIMARY ]

		If inside And MouseDown(1) And buttonGroup <> ID
			pressed = True
			buttonGroup = ID
		EndIf
			
		If buttonGroup = ID
			BG = _colours_[ COL_PRIMARY_VARIANT ]
			FG = _colours_[ COL_ONPRIMARY_VARIANT ]	
		End If
		
		' BACKGROUND
		SetColor( BG )
		DrawRect( x, y, w, h )
		' FOREGROUND
		SetColor( FG )
		_DrawCaption_( Caption, x, y, w, h, ALIGN_CENTRE )

		'If pressed 
		'	buttonDown = ID
		'ElseIf buttonDown = ID
		'	' Button released
		'	buttonDown = 0
		'	Return True
		'End If
		Return Pressed
	End Function
	
	Function Label( Caption:String, x:Int, y:Int, h:Int = -1, flags:Int = 0 )
		If flags And HIDDEN = HIDDEN Return
		If h = -1; h = _textheight_ + _hpadding_
		SetColor( _colours_[ COL_ONSURFACE ] )
		x :+ parentx
		y :+ parenty
		_DrawCaption_( caption, x, y, -1, h )
	End Function

	Function IntField( ID:Long, Value:Int Var, x:Int, y:Int, w:Int = -1, h:Int = -1, length:Int = 5, flags:Int = 0 )
		If flags And HIDDEN = HIDDEN Return

		If w = -1; w = TextWidth( value ) + _vpadding_
		If h = -1; h = _textheight_ + _hpadding_
		Local charwidth:Int = TextWidth("W")
		
		x :+ parentx
		y :+ parenty
		
		Local inside:Int = _MouseBounds_( x, y, w, h )
		Local pressed:Int = False
		Local FG:SColor8 = _colours_[ COL_ONPRIMARY ]
		Local BG:SColor8 = _colours_[ COL_PRIMARY ]	
		
		' BACKGROUND
		SetColor( BG )
		'DrawRect( x, y, w, h )
		DrawLine( x, y+h, x+w, y+h )
		' FOREGROUND
		SetColor( FG )
		
		Local caption:String = value
		Local alignedX:Int = x + w - TextWidth( caption ) - _hpadding_
		
		If inside And MouseDown(1)
			If buttondown<>ID; FlushKeys()
			buttondown = ID
			' Position cursor at mouse-click
			cursorpos = Max( 0, (MouseX()-alignedX)/charwidth )
		End If
		
		_DrawCaption_( caption, alignedX, y, w, h )

		' Cursor
		If buttonDown = ID
			If cursortime < MilliSecs()
				cursorstate = Not cursorstate
				cursortime = MilliSecs() + 600
			End If
			If cursorstate
				SetColor( BLACK )
				If _insert_
					DrawLine( alignedX+cursorpos*charwidth, Y+4, alignedX+cursorpos*charwidth, Y+H-4 )
				Else
					DrawLine( alignedX+cursorpos*charwidth, Y+H-3, alignedX+(cursorpos+1)*charwidth, Y+H-3 )
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
				If Len(caption)<=length
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

	End Function

End Type




