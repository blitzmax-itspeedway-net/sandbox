

' Colours
Global BLACK:SColor8 = New SColor8( $000000FF )
Global WHITE:SColor8 = New SColor8( $FFFFFFFF )

' Colors in the style sheet
Const IMGUI_COLOR_BACKGROUND:Int   = $00
Const IMGUI_COLOR_SURFACE:Int      = $01
Const IMGUI_COLOR_PRIMARY:Int      = $02
Const IMGUI_COLOR_SECONDARY:Int    = $03
Const IMGUI_COLOR_ERROR:Int        = $04
Const IMGUI_COLOR_ONBACKGROUND:Int = $05
Const IMGUI_COLOR_ONSURFACE:Int    = $06
Const IMGUI_COLOR_ONPRIMARY:Int    = $07
Const IMGUI_COLOR_ONSECONDARY:Int  = $08
Const IMGUI_COLOR_ONERROR:Int      = $09

' Icons

Const IMGUI_ICON_CLOSE:Int = 0

' Window styles

Const IMGUI_TITLEBAR_MASK:Int     = $C000  ' 01000000 00000000 00000000 00000000
Const IMGUI_TITLEBAR:Int          = $4000  ' 01000000 00000000 00000000 00000000
Const IMGUI_TITLEBAR_BIG:Int      = $8000  ' 10000000 00000000 00000000 00000000
Const IMGUI_TITLEBAR_CLOSE:Int    = $2000  ' 00100000 00000000 00000000 00000000

Const IMGUI_OUTLINE:Int           = $0100  ' 00000000 00000001 00000000 00000000

Const IMGUI_SLIDER_HORIZONTAL:Int = $0000  ' 00000000 00000000 00000000 00000000
Const IMGUI_SLIDER_VERTICAL:Int   = $0200  ' 00000000 00000010 00000000 00000000

Const IMGUI_BUTTON_LATCH:Int      = $0400  ' 00000000 00000100 00000000 00000000 - ON/OFF button

Struct GUIStyle

	Public
	Field palette:SColor8[10]
	Field padding:Int = 2
	Field margin:Int  = 2
	' Default widget size
	Field widget_width:Int = 80
	Field widget_height:Int = 30
	' Normal and Large titlebar heights
	Field titlebar_height:Int = 28
	Field titlebar_height_big:Int = 56
	' Icons
	Field iconsize:Int = 24
	Field iconsheet:TImage
	
	Method setDefaults()
		palette = [ ..
			New SColor8( $FF, $FF, $FF, $FF ), .. ' BACKGROUND
			New SColor8( $7F, $7F, $7F, $FF ), .. ' SURFACE
			New SColor8( $62, $00, $EE, $FF ), .. ' PRIMARY
			New SColor8( $37, $00, $B3, $FF ), .. ' SECONDARY
			New SColor8( $B0, $00, $20, $FF ), .. ' ERROR				
			BLACK, ..                             ' ON BACKGROUND
			BLACK, ..                             ' ON SURFACE
			WHITE, ..                             ' ON PRIMARY
			WHITE, ..                             ' ON SECONDARY
			WHITE ..                              ' ON ERROR
			]
		margin  = 2
		padding = 2
		widget_width = 80
		widget_height = 30
		' Normal and Large titlebar heights
		titlebar_height = 28
		titlebar_height_big = 56
		' Icons
		iconsize = 24
		iconsheet = LoadAnimImage( "../resources/iconsheet.png", iconsize, iconsize, 0, 16 )
'		DebugStop
	End Method

	'Protected
	'Field _init_:Int = False

EndStruct

Function test_colours( style:GUIStyle Var )
	style.palette = [ ..
		New SColor8( $FFFFFF ), .. ' BACKGROUND
		New SColor8( $2196F3 ), .. ' PRIMARY
		New SColor8( $EFE5FD ), .. ' SURFACE
		New SColor8( $FF9800 ), .. ' SECONDARY
		New SColor8( $B00020 ), .. ' ERROR
		BLACK, ..                  ' ON BACKGROUND
		BLACK, ..                  ' ON SURFACE
		WHITE, ..                  ' ON PRIMARY
		BLACK, ..                  ' ON SECONDARY
		WHITE ..                   ' ON ERROR
		]
End Function


