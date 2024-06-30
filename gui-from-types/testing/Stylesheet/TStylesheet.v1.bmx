SuperStrict

Include "Default_style.bmx"

Const VALID_SELECTOR$ = ..
	"background-color,color,colour,margin,padding"
'	"color,colour,background-color,background-colour,background-image,border,bottom,enabled,font-family,font-style,"+..
'	"font-size,font-weight,halign,hpos,height,left,opacity,position,right,text-decoration,top,valign,vpos,visibility,width"

Type TStylesheet

	Const NONE:Int = 0
	Const BACKGROUND:Int = 1
	Const SURFACE:Int = 2
	Const PRIMARY:Int = 3
	Const SECONDARY:Int = 4
	Const DISABLED:Int = 5
	Const ONBACKGROUND:Int = 6
	Const ONSURFACE:Int = 7
	Const ONPRIMARY:Int = 8
	Const ONSECONDARY:Int = 9
	Const ONDISABLED:Int = 10
		
	Field stylesheet:TMap
	
	Method New( raw:String )
		stylesheet = New TMap()
		parse( raw )
	End Method

	'# Copy a style
	'Function CopyStyle:TMap( from:TMap = Null )
	'Local duplicate:TMap = CreateMap()
	'Local selector:TMap, property:String, value:String
	'	If from = Null; from = stylesheet	'# Default is to copy the stylesheet
	'	For Local key$ = EachIn MapKeys( from )
	'		selector = TMap( MapValueForKey( from, key ) )
	'		MapInsert( duplicate, key, CopyMap( selector ))
	'	Next
	'Return duplicate	
	'End Function

	' Merge a stylesheet
	'Function Merge( Sheet:String )
	'	parse( sheet )
	'	'# Optionally restyle
	'	If restyle; Self.restyle()
	'End Function

	' Parse a stylesheet
	Method Parse( raw:String )	', merge:Int=False )
	Local pos1:Int, pos2:Int, p:Int
	Local selector:String, style:String, key:String
	Local styles:String[],item:String[],styledef:TMap
		' Strip comments
		'DebugStop
		'p = 0
		Repeat
			pos1 = Instr( raw, "//", 0 )
			pos2 = Instr( raw, "~n", pos1 )
			If pos1=0; Continue 
			If pos2=0
				raw = raw[..pos1-1]
			Else
				raw = raw[..pos1-1]+raw[pos2..]
				'p = pos2
			End If
		Until pos1 = 0 Or pos2 = 0
		' Remove tabs and CRLF's
		raw = Replace( raw, "~t", "" )
		raw = Replace( raw, "~r", "" )
		raw = Replace( raw, "~n", "" )
		' Parse the text
		DebugStop
		p = 0
		Repeat
			pos1 = Instr( raw, "{", p )
			pos2 = Instr( raw, "}", pos1 )
			If pos1>0 And pos2>0 Then
				'# Split selector from style definition
				selector = Trim(Mid( raw, p, pos1-p ))
				style    = Trim(Mid( raw, pos1+1, pos2-pos1-1 ))
				If selector And style Then
					styles = Null	'# Blank item array
					'# split style definition
					styles = style.split(";")
					'# MERGE (Added in V1.3)
					'If MapContains( stylesheet, selector ) Then
					'	styledef = TMap( MapValueForKey( stylesheet, selector ))
					'Else
					styledef = New TMap()
					MapInsert( styleSheet, selector, styledef )
					'End If
					'#-----
					For Local n:Int = 0 Until Len(styles)
						If Not styles[n] Then Continue
						item=Null	'# Blank item array
						item=styles[n].split(":")
						key = Trim(item[0])
						' Variable declaration
						If Len(item)=2 And key.startswith("--")
							MapInsert( styledef, key, Trim(item[1]) )
							Continue
						End If
						' Valid selector?
						'DebugStop
						If Len(item)=2 And Instr( VALID_SELECTOR, key ) Then 
							Select key
							'Case "left"
							'	MapInsert( styledef, "halign", "left" )
							'	MapInsert( styledef, "hpos", Trim(item[1])) 
							'Case "right"
							'	MapInsert( styledef, "halign", "right" )
							'	MapInsert( styledef, "hpos", Trim(item[1])) 
							'Case "bottom"
							'	MapInsert( styledef, "valign", "bottom" )
							'	MapInsert( styledef, "vpos", Trim(item[1])) 
							'Case "top"
							'	MapInsert( styledef, "valign", "top" )
							'	MapInsert( styledef, "vpos", Trim(item[1])) 
							Default
								MapInsert( styledef, key, Trim(item[1]) )
							End Select
						Else
							DebugLog( "STYLE ERROR: Invalid selector '"+key+"' in '"+selector+"'" )
						End If
					Next

				End If
				p=pos2+1
			End If
		Until pos1=0 Or pos2=0
	End Method

	'# Apply a style to a gadget
	Method Apply:String( widget:TWidget )
		Local typeid:TTypeId = TTypeId.forObject( widget )
		Local element:String = Lower( typeid.name() )
		Local name:String    = Lower( widget.name )
		Local class:String   = Lower( String( widget.class ))
		Local value:String, selector:String, integer:Int, real:Float, item:String[], items:Int, styles:Int[]
		Local style:TMap = CreateMap()
		'# PROPERTIES
		'Local r:Byte, g:Byte, b:Byte
		'# COMPOUND PROPERTIES
		Local background:Int = False
		Local background_image:TPixmap = Null
		Local background_flags:Int = 0
		'
		'Local font:TGUIFont = Null, aFont:String[]
		Local font_family:String, font_size:Float, font_style:Int
		'
		Local x:Int, y:Int, w:Int, h:Int, pos_horizontal:Int, horizontal:Int, pos_vertical:Int, vertical:Int, height:Int, width:Int
		'#
		'##### Idenfiy selectors in stylesheet that match gadget
		'#
		For Local pri:Int = 0 To 15
			'# Create match string
			selector=""
			If pri = 0 Then
				selector= "*"
			Else
				If (pri & 1) Then selector= element	
				'If (pri & 2) Then selector:+ "~~" + platform
				If (pri & 4) Then 
					If Not name Then Continue
					selector:+ "#" + name
				End If
				If (pri & 8) Then
					If Not class Then Continue
					selector:+ "." + class
				End If
			End If
			'# Has a match been found?
			If selector Then match( selector, style )
		Next
		'#
		'##### Apply style properties
		'#
		For Local property:String = EachIn MapKeys( style )
			value = String(MapValueForKey( style, property ))
			Select property
			Case "background-color", "background-colour"
				If value="none" Then
					widget.palette[ BACKGROUND ] = New SColor8( 0,0,0,0 )
				Else
					widget.palette[ BACKGROUND ] = Colour( value )
				End If
			Case "background-image"		'# COMPOUND PROPERTY
				If value="none" Then
					background = True
					background_image = Null
				ElseIf FileType( value )=1 Then
					background = True
					background_image = LoadPixmap( value )
				End If
'			Case "background-repeat"
'				style = __identify( Lower(value), "tile,center,fit,clip,stretch", 0 )
'				SetGadgetPixmap( gadget, pixmap, flags )
'				gadget.SetPixmap( pixmap, style )
'			Case "border"
'				setgadgetborder( gadget, stringToValue( value, "none,threed,solid", 1 ) )
'			Case "bottom" is now valign:bottom;vpos=N
			Case "color", "colour"
				widget.palette[ BACKGROUND ] = Colour( value )
				'gadget.SetTextColor( r, g, b )
			Case "enabled"
				integer = StringToValue( value, ["false","rrue"], -1 )
				If integer <> -1 Then widget.SetEnable( integer )
			Case "font-family"
				font_family=value
			Case "font-size"
				font_size = Float(value)
			Case "font-style"
				Select value
				'Case "none" 	; font_style = Not( Not(font_style) | FONT_ITALIC )
				'Case "italic"	; font_style = font_style | FONT_ITALIC
				End Select
			Case "font-weight"
				Select value
				'Case "none" 	; font_style = Not( Not(font_style) | FONT_BOLD )
				'Case "bold"		; font_style = font_style | FONT_BOLD
				End Select
			Case "halign"		'# See left: and right:
				Select value
				Case "left"		;	pos_horizontal = -1
				Case "right"	;	pos_horizontal = 1
				End Select
			Case "hpos"			'# See left: and right:
				horizontal = Int( value )
			Case "height"
				height = Int(value)
'			Case "left" is now halign=right;hpos=N
			Case "opacity"
				real = StringToReal( value )
				widget.SetOpacity( real )
			Case "position"
'				'# This can be all, horizontal and vertical or all four sides
'				item=value.split(",")
'				items = Len( item )
'				If items = 1 Then	'# All the same
'					styles[0] = _Position( item[0] )
'					gadget.SetLayout styles[0],styles[0],styles[0],styles[0]
'				ElseIf items = 2 Then	'# TOP/BOT & LEFT/RIGHT
'					styles[0] = _Position( item[0] )
'					styles[1] = _Position( item[1] )
'					gadget.SetLayout styles[1],styles[1],styles[0],styles[0]
'				Else
'					item=item[..4]
'					styles[0] = _Position( item[0] )
'					styles[1] = _Position( item[1] )
'					styles[2] = _Position( item[2] )
'					styles[3] = _Position( item[3] )
'					gadget.SetLayout styles[1],styles[3],styles[0],styles[2]
'				End If
'			Case "right" is now halign=right;hpos=N
'			Case "text-decoration"
'				Select value
'				Case "none" 						; font_style = Not( Not(font_style) | FONT_UNDERLINE | FONT_STRIKETHROUGH )
'				Case "underline"					; font_style = font_style | FONT_UNDERLINE 
'				Case "strikethrough","line-through"	; font_style = font_style | FONT_STRIKETHROUGH 
'				End Select
'			Case "top" is now 'valign'
			Case "valign"		'# See top: and bottom:
				Select value
				Case "top"		;	pos_vertical = -1
				Case "bottom"	;	pos_vertical = 1
				End Select
			Case "vpos"			'# See top: and bottom:
				vertical = Int( value )
			Case "visibility"
				integer = StringToValue( value, ["hidden","visible"], -1 )
				If integer <> -1 Then widget.setVisible( integer )
			Case "width"
				width=Int(value)
			End Select
		Next
		'# Now apply compond properties
'		If background Then SetGadgetPixmap( gadget, background_image, background_flags )
		'# FONT ADDED V1.3
'		If font_family Or font_size>0 Or font_style Then
'			font = getfont( gadget )		'# EXPERIMENTAL
'
'			If font Then 
'				If Not font_family Then font_family=font.name
'				If font_size=0 Then font_size=font.size
'				If Not font_style Then font_style=font.style
'			Else
'				If font_size=0 Then font_size=11
'			End If
'			Select font_family
'			Case ""
'			Case "serif", "sans-serif", "script", "system", "monospace"
'				font = LookupGuiFont( stringtovalue(font_family,"system,monospace,sans-serif,serif,script",GUIFONT_SYSTEM), font_size, font_style )
'				If font Then SetGadgetFont( gadget, font )
'			Default
'				font = LoadGuiFont( font_family, font_size, (font_style&FONT_BOLD), (font_style&FONT_ITALIC), (font_style&FONT_UNDERLINE), (font_style&FONT_STRIKETHROUGH))
'				If font Then SetGadgetFont( gadget, font )
'			End Select
'		End If
		'# SIZE AND POSITION - Added as compound property V1.3
'		If pos_horizontal<>0 Or pos_vertical<>0 Or width<>0 Or height<>0 Then
'			x = gadget.GetXPos()
'			y = gadget.GetYPos()
'			w = gadget.GetWidth()
'			h = gadget.GetHeight()
'			parent = gadget.GetGroup()
'			If width > 0 Then w = width
'			If height > 0 Then h = height
'			Select pos_horizontal
'			Case -1							' N from Left
'				x=horizontal
'			Case 1							' N from Right
'				If parent Then x=parent.getwidth()-w-horizontal
'			End Select
'			Select pos_vertical
'			Case -1							' N from Top
'				y=vertical
'			Case 1							' N from Bottom
'				If parent Then y=parent.getheight()-h-vertical
'			End Select
'			gadget.SetShape x,y,w,h			
'		End If
	End Method

	'------------------------------------------------------------
	'# Support for Colour strings
	Method Colour:SColor8( value:String )
	Local r:Int, g:Int, b:Int
		If Left(value,1)="#"
			Select Len(value)
			Case 4	' #RGB
				r = Int("$"+value[1..2]+value[1..2])
				g = Int("$"+value[2..3]+value[2..3])
				b = Int("$"+value[3..4]+value[3..4])
				Return New SColor8( r,g,b )
			Case 7  ' #RRGGBB
				r = Int("$"+value[1..3])
				g = Int("$"+value[3..5])
				b = Int("$"+value[5..7])
				Return New SColor8( r,g,b )
			Default
				Return New SColor8( $ff,$ff,$ff )
			End Select
		Else 
			'# Has a OS colour been requested?
			'col = StringToValue( value, "windowbg,gadgetbg,gadgetfg,selectionbg,linkfg", -1 )
			'If col >=0 Then 
			'	Return LookupGuiColor( col, r, g, b )
			'Else
			Return ColourName( value )
			'End If
		End If
	End Method

	'------------------------------------------------------------
	'# 16 HTML NAMED COLOURS
	Method ColourName:SColor8( name:String )
		Select name
		Case "aqua"			; Return New SColor8( 0,   $ff, $ff )
		Case "black"		; Return New SColor8( 0,   0,   0 )
		Case "blue"			; Return New SColor8( 0,   0,   $ff )
		Case "fuchsia"		; Return New SColor8( $ff, 0,   $ff )
		Case "gray", "grey"	; Return New SColor8( $80, $80, $80 )
		Case "green"		; Return New SColor8( 0,   $80, 0 )
		Case "lime"			; Return New SColor8( 0,   $ff, 0 )
		Case "maroon"		; Return New SColor8( $80, 0,   0 )
		Case "navy"			; Return New SColor8( 0,   0,   $80 )
		Case "olive"		; Return New SColor8( $80, $80, 0 )
		Case "purple"		; Return New SColor8( $80, 0,   $80 )
		Case "red"			; Return New SColor8( $ff, 0,   0 )
		Case "silver"		; Return New SColor8( $c0, $c0, $c0 )
		Case "teal"			; Return New SColor8( 0,   $80, $80 )
		Case "white"		; Return New SColor8( $ff, $ff, $ff )
		Case "yellow"		; Return New SColor8( $ff, $ff, 0 )
		Default
			Return New SColor8( $ff, $ff, $ff )
		End Select
	End Method
		
	' Match a selector
	Method Match( selector:String, Style:TMap )
		Local properties:TMap = TMap( MapValueForKey( styleSheet, selector ))
		Local value:String
		If Not properties Then Return
		For Local property:String = EachIn MapKeys( properties )
			value = String( MapValueForKey( properties, property ) )
			MapInsert( style, property, value )
		Next
	End Method

	' Returns a float in the range 0.0 to 1.0
	Method StringToReal:Float( text:String )
		Return Min( 1.0, Max( 0.0, Float( text ) ))
	End Method
	
	'# Return numeric position of string in array
	Method StringToValue:Int( value:String, items:String[], def:Int=0 )
	'Local items$[] = options.split(",")
		For Local n:Int = 0 Until Len(items)
			If items[n]=value; Return n
		Next
		Return def
	End Method
		
End Type