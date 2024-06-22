'   NAME
'   (c) Copyright Si Dunford, MMM 2022, All Rights Reserved. 
'   VERSION: 1.0

'   CHANGES:
'   DD MMM YYYY  Initial Creation
'

' ##### RENDER COMMANDS

Const IMGUI_RENDER_CIRCLE:Int = 0
Const IMGUI_RENDER_RECT:Int   = 1
Const IMGUI_RENDER_ICON:Int   = 2
Const IMGUI_RENDER_IMAGE:Int  = 3
Const IMGUI_RENDER_LINE:Int   = 4
Const IMGUI_RENDER_TEXT:Int   = 5

' ##### OPTIONS

Const IMGUI_ALIGN_HMASK:UInt  = $0003  ' 00000000 00000011
Const IMGUI_ALIGN_VMASK:UInt  = $000C  ' 00000000 00001100
Const IMGUI_ALIGN_LEFT:UInt   = $0000  '                00
Const IMGUI_ALIGN_CENTER:UInt = $0001  '                01 - English
Const IMGUI_ALIGN_CENTRE:UInt = $0001  '                01 - American
Const IMGUI_ALIGN_RIGHT:UInt  = $0002  '                10
Const IMGUI_ALIGN_TOP:UInt    = $0000  '              00
Const IMGUI_ALIGN_MIDDLE:UInt = $0004  '              01
Const IMGUI_ALIGN_BOTTOM:UInt = $0008  '              10
Const IMGUI_ALIGN_TL:UInt     = $0000  '              0000
Const IMGUI_ALIGN_TC:UInt     = $0001  '              0001
Const IMGUI_ALIGN_TR:UInt     = $0002  '              0010
Const IMGUI_ALIGN_ML:UInt     = $0004  '              0100
Const IMGUI_ALIGN_MC:UInt     = $0005  '              0101
Const IMGUI_ALIGN_MR:UInt     = $0006  '              0110
Const IMGUI_ALIGN_BL:UInt     = $0008  '              1000
Const IMGUI_ALIGN_BC:UInt     = $0009  '              1001
Const IMGUI_ALIGN_BR:UInt     = $000A  '              1010

Struct SRenderer
	Field datatype:Int
	Field rect:SRect
	Field caption:String
	Field value:Int
	Field fg:Int, bg:Int
	Field options:UInt
	Field image:TImage
	
	Method New( datatype:Int, rect:SRect, caption:String, value:Int, fg:Int, bg:Int, options:UInt=0 )
		Self.datatype = datatype
		Self.rect = rect 
		Self.caption = caption
		Self.value = value
		Self.fg = fg
		Self.bg = bg
		Self.options = options
	End Method
	
End Struct

Function IMGUI_DrawCircle:SRenderer( rect:SRect, bg:Int, options:UInt=0 )
	Return New SRenderer( IMGUI_RENDER_CIRCLE, rect, "", 0, 0, bg, options )
End Function

Function IMGUI_DrawRect:SRenderer( rect:SRect, bg:Int, options:UInt=0 )
	Return New SRenderer( IMGUI_RENDER_RECT, rect, "", 0, 0, bg, options )
End Function

Function IMGUI_DrawIcon:SRenderer( icon:Int, rect:SRect, fg:Int, bg:Int, options:UInt=0 )
	Return New SRenderer( IMGUI_RENDER_ICON, rect, "", icon, fg, bg, options )
End Function

Function IMGUI_DrawImage:SRenderer( image:TImage, rect:SRect, options:UInt=IMGUI_ALIGN_MC )
	Local render:SRenderer = New SRenderer( IMGUI_RENDER_IMAGE, rect, "", 0, 0, 0, options )
	render.image = image
	Return render
End Function

Function IMGUI_DrawLine:SRenderer( rect:SRect, col:Int, options:UInt=0 )
	Return New SRenderer( IMGUI_RENDER_LINE, rect, "", 0, col, 0, options )
End Function

Function IMGUI_DrawText:SRenderer( caption:String, rect:SRect, fg:Int, options:UInt=IMGUI_ALIGN_ML )
	Return New SRenderer( IMGUI_RENDER_TEXT, rect, caption, 0, fg, 0, options )
End Function

Function IMGUI_default_renderer( ctx:IMGUI )
'DebugStop
	For Local render:SRenderer = EachIn ctx.pipeline
		Select render.datatype
		Case IMGUI_RENDER_CIRCLE
			SetColor( ctx.style.palette[render.bg] )
			DrawOval( render.rect.x, render.rect.y, render.rect.w, render.rect.h )
		Case IMGUI_RENDER_RECT
			SetColor( ctx.style.palette[render.bg] )
			If render.options & IMGUI_OUTLINE
				' Outline
				Local t:Int = render.rect.y
				Local l:Int = render.rect.x
				Local r:Int = render.rect.x+render.rect.w
				Local b:Int = render.rect.y+render.rect.h
				DrawLine( l, t, r, t )	' Top
				DrawLine( r, t, r, b )	' Right
				DrawLine( r, b, l, b )	' Bottom
				DrawLine( l, b, l, t )	' Left
			Else
				' Filled
				DrawRect( render.rect.x, render.rect.y, render.rect.w, render.rect.h )
			End If
		Case IMGUI_RENDER_LINE
			SetColor( ctx.style.palette[render.fg] )
			DrawLine( render.rect.x, render.rect.y, render.rect.w, render.rect.h )
		Case IMGUI_RENDER_ICON
			' Background
DebugStop
			SetColor( ctx.style.palette[render.fg] )
			DrawRect( render.rect.x, render.rect.y, render.rect.w, render.rect.h )
			' Foreground
			If ctx.style.iconsheet
				SetColor( ctx.style.palette[render.bg] )
				'DrawImage( ctx.style.iconsheet, render.rect.x, render.rect.y, render.value )  
			End If
		Case IMGUI_RENDER_IMAGE
		
			Local point:SPoint = ctx.align( render.rect, ImageWidth(render.image), ImageHeight(render.image), render.options )
			SetColor( WHITE )
			DrawImage( render.image, point.x, point.y )
		Case IMGUI_RENDER_TEXT
'DebugStop
			' Get alignment
			Local align:SPoint = ctx.align( render.rect, TextHeight( render.caption ), TextWidth( render.caption ), render.options )
			' Draw text
			SetColor( ctx.style.palette[render.fg] )
			DrawText( render.caption, align.x, align.y )
		End Select
	Next
End Function

