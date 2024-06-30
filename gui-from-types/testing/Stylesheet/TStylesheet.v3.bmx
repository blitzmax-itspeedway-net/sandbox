' Stylesheet
' Si Dunford [Scaremonger]

' Valid Stylesheet Selectors
Const VALID_SELECTOR$ = ..
	"surface,"+..							' Colour of Outer (Padding)
	"border,margin-color,margin-colour"+..	' Colour of Bounds (Margin)
	"cursor-color,cursor-colour"+..
	"variant,"+..					' Variant colour (Handle within a gadget etc)
	"color,colour,"+..						' Foreground/Text
	"margin,padding,"+..
	"text-align"
'	"background-image,border,bottom,enabled,font-family,font-style,"+..
'	"font-size,font-weight,halign,hpos,height,left,opacity,position,
'	"right,text-decoration,top,valign,vpos,visibility,width"

Const FLAG_DISABLED:Int = $01
Const FLAG_HOVER:Int = $02
Const FLAG_FOCUS:Int = $04
Const FLAG_DRAG:Int = $08

' ALIGNMENT OPERATIONS
' 15/6/23, Converted to Float so we can calculate instead of select-case
Const ALIGN_TOP:Float    = 0.0
Const ALIGN_MIDDLE:Float = 0.5
Const ALIGN_BOTTOM:Float = 1.0
Const ALIGN_LEFT:Float   = 0.0
Const ALIGN_CENTRE:Float = 0.5	' British
'Const ALIGN_CENTER:Float = 0.5	' American
Const ALIGN_RIGHT:Float  = 1.0

Interface IStyleable
	Method GetName:String()
	Method GetClassList:String[]()
	Method flagset:Int( flag:Int )
	Method setAlignSelf( horz:Float, vert:Float )
	Method setAlignContent( horz:Float, vert:Float )
	Method setMargin( edges:SEdges )
	Method setPadding( edges:SEdges )
	Method setPalette( id:Int, color:SColor8 )
End Interface

' TLookup<V> is an Array-backed map that keeps your data in
' the order you insert it and doesn't sort it by key or hash 
' like TMap, TStringMap or TTreeMap do.

Type TLookup<V>

	Field list:String[]
	'Field index:String[]	' Hashed index
	Field data:V[]
	Field total:Int
	Field size:Int

	Field stepsize:Int = 50
	
	Method New()
	End Method

	Method add( key:String, value:V )
		Local id:Int = find( key, True )
		If id>=total; expand()
		If id>=size; size=id+1
		list[id]  = key
		data[id]  = value
		'index[id] = key.hash()
	End Method

	Method count:Int()
		Return size
	End Method
	
	Method expand()
		total :+ stepsize 
		list  = list[..total]
		data  = data[..total]
		'index = index[..total]
	End Method
		
	Method find:Int( key:String, getnext:Int = False )
		For Local id:Int = 0 Until size
			If list[id]=key; Return id
		Next
		' Not found
		If getnext; Return size
		Return -1
	End Method
	
	Method keys:String[]()
		Return list[..size]
	End Method

	' Add an object
	Method Operator[]=( key:String, value:V )
		add( key, value )
	End Method
		
	Method Operator[]:V( key:String )
		Return valueForKey( key )
	End Method

	Method Operator[]:V( index:Int )
		Return V(data[index])
	End Method
		
	Method valueForKey:V( key:String )
		Local id:Int = find( key, True )
		If id > total; Return Null
		Return data[id]
	End Method
End Type

' This is the final style that will be applied to a widget
Type SStyle
	Field alignContent:Float[2]
	Field alignSelf:Float[2]
	Field margin:SEdges
	Field palette:String[COLOR.length]
	Field padding:SEdges
	
	Method New()
		margin = New SEdges()
		padding = New SEdges()
	End Method
	
End Type

Type TStylesheet

	Field root:TMap						' Root variables defined in stylesheet
	Field stylesheet:TLookup<TMap>	' A Collection of styles in the stylesheet

	' Create a new default Stylesheet
	Method New()
		stylesheet = New TLookup<TMap>()
		parse( STYLE_DEFAULT )
	End Method
		
	' Create a new Stylesheet from a string definition
	Method New( raw:String )
		stylesheet = New TLookup<TMap>()
		parse( raw )
	End Method
	
	Method apply( widget:IStyleable )
		' Get widget details
		Local typeid:TTypeId   = TTypeId.forObject( widget )
		Local typename:String  = Lower( typeid.name() )
		Local name:String      = Lower( widget.GetName() )

		' Style is an index into stylesheet
		Local styleindex:Int[] = New Int[ stylesheet.count() ]
Print( "STYLESHEET.APPLY( " + name + " ): " + typeid.name() )
'If widget.name = "NAME"; DebugStop
		
		' Pre-process data speeds up the selector process
		Local widname:String = "#"+name
		Local flagname:String[]
		If widget.flagset( FLAG_DISABLED ); flagname :+ [":disabled"]
		If widget.flagset( FLAG_HOVER ); flagname :+ [":hover"]
		If widget.flagset( FLAG_FOCUS ); flagname :+ [":focus"]
		If widget.flagset( FLAG_DRAG ); flagname :+ [":drag"]
		Local classes:String[] = widget.getClassList()
		For Local index:Int = 0 Until classes.length
			classes[index] = "."+classes[index]
		Next
		
		' OPTIMISED: See optimise/test-style-selectors/
		
		'        TYPENAME  NAME  CLASS  FLAGS
		' 0000 = *
		' 0001 = typename  -      Yes   Yes
		' 0010 = -         #name  Yes   Yes
		' 0011 = typename  #name  Yes   Yes
		' 0100 = -         -      Yes   Yes
		Local rootname:String, basename:String, selector:String
		match( "*", styleIndex )
		For Local bitmask:Int = 1 To 4
			rootname = ""
			If (bitmask & $1); rootname = typename
			If (bitmask & $2)
				If Not name; Continue			' If name is blank (should't be)
				rootname :+ widname
			End If
			
			For Local class:Int = -1 Until classes.length
				basename = rootname
				If class>-1; basename :+ classes[class]
				For Local flag:Int = -1 Until flagname.length
					'# Create match string
					selector = basename
					If flag>-1; selector :+ flagname[flag]
					'
					If Not selector; Continue
					'Local t:String = (bitmask+"/"+class+"/"+flag+": ")
					'Print t[..8]+selector
					match( selector, styleIndex )
				Next
			Next	
		Next

DebugStop
Print( "APPLYING:" )
		Local style:SStyle = New SStyle()

		' Loop through style index
		For Local index:Int = 0 Until styleIndex.length
			' If style is not activated, move on
			If Not styleIndex[index]; Continue
			' Get the sheet for this index
			Local sheet:TMap = TMap( stylesheet[index] )
			
			' Apply styles
			For Local property:String = EachIn sheet.keys()
			
				Local value:String = String( MapValueForKey( sheet, property ) )
	Print( "- "+property+"="+value )
				Select property
				Case "align"
					style.alignSelf = ExtractAlignment( Lower(value) )
					'Local align:Float[] = ExtractAlignment( Lower(value) )
					'widget.setAlignSelf( align[0], align[1] )
				Case "surface"
					style.palette[ COLOR.SURFACE ] = value
					'SetColour( widget, COLOR.SURFACE, value )
				Case "border", "margin-color", "margin-colour"
					style.palette[ COLOR.BORDER ] = value
					'SetColour( widget, COLOR.BORDER, value )
				Case "color", "colour"
					style.palette[ COLOR.FOREGROUND ] = value
					'SetColour( widget, COLOR.FOREGROUND, value )
				Case "cursor-color", "cursor-colour"
					style.palette[ COLOR.SURFACE ] = value
					'SetColour( widget, COLOR.CURSOR, value )
				Case "margin"
					'DebugStop
					style.padding = ExtractEdges( Lower(value) )
					'widget.setMargin( ExtractEdges( Lower(value) ) )
				Case "padding"
					'DebugStop
					style.padding = ExtractEdges( Lower(value) )
					'widget.setPadding( ExtractEdges( Lower(value) ) )
				Case "variant", "variant"
					style.palette[ COLOR.VARIANT ] = value
					'SetColour( widget, COLOR.VARIANT, value )
				Case "text-align"
					'DebugStop
					style.alignContent = ExtractAlignment( Lower(value) )
					'Local align:Float[] = ExtractAlignment( Lower(value) )
					'widget.setAlignContent( align[0], align[1] )
				End Select
			Next
		Next
		
		' Apply the style to the widget
		widget.setAlignSelf( style.alignSelf[0], style.alignSelf[1] )
		widget.setAlignContent( style.alignContent[0], style.alignContent[1] )
		widget.setMargin( style.margin )
		widget.setPadding( style.padding )
		For Local palette:Int = 0 Until style.palette.length
			SetColour( widget, palette, style.palette[palette] )
		Next
		
	End Method

	' Merge one stylesheet into another.
	' Overlapping elements are replaced; New ones added to the end.
	Method merge( style:TStylesheet )
		'DebugStop
		For Local key:String = EachIn style.stylesheet.keys()
			stylesheet.add( key, style.stylesheet[ key ] )
		Next
	End Method
	
	Private
	
	Method extractAlignment:Float[]( text:String )
		Local items:String[] = text.split( "," )
		Local result:Float[]
		Select Len(items)
		Case 1
			Local align:Float = StrToAlignment( items[0] )
			Return [ align, align ]
		Case 2
			Return [ StrToAlignment( items[0] ), StrToAlignment( items[1] ) ]
		Default
			Return [ ALIGN_CENTRE, ALIGN_MIDDLE ]
		End Select
	End Method

	'# Support for Colour strings
	Method extractColour:SColor8( text:String )
	Local a:Int, r:Int, g:Int, b:Int
		' Stylesheet variables
		text = lookupVariable( text )
		' Process value
		If Left(text,1)="#"
			Select Len(text)
			Case 4	' #RGB
				a = $ff
				r = Int("$"+text[1..2]+text[1..2])
				g = Int("$"+text[2..3]+text[2..3])
				b = Int("$"+text[3..4]+text[3..4])
				Return New SColor8( r,g,b,a )
			Case 5	' #ARGB
				a = Int("$"+text[1..2]+text[1..2])
				r = Int("$"+text[2..3]+text[2..3])
				g = Int("$"+text[3..4]+text[3..4])
				b = Int("$"+text[4..5]+text[4..5])
				Return New SColor8( r,g,b,a )
			Case 7  ' #RRGGBB
				a = $ff
				r = Int("$"+text[1..3])
				g = Int("$"+text[3..5])
				b = Int("$"+text[5..7])
				Return New SColor8( r,g,b,a )
			Case 9  ' #AARRGGBB
				a = Int("$"+text[1..3])
				r = Int("$"+text[3..5])
				g = Int("$"+text[5..7])
				b = Int("$"+text[7..9])
				Return New SColor8( r,g,b,a )
			Default
				Return New SColor8( $ff,$ff,$ff,$ff ) ' Solid White
			End Select
		Else 
			'# Has a OS colour been requested?
			Return strToColour( text )
		End If
	End Method
		
	Method extractEdges:SEdges( text:String )
		Local edges:String[] = text.split( "," )
		Select Len(edges)
		Case 1
			' All Edges are the same
			Local trbl:Int = Int( edges[0] )
			Return New SEdges( trbl, trbl, trbl, trbl)
		Case 2
			' Top-Bottom and Right-Left
			Local tb:Int = Int( edges[0] )
			Local rl:Int = Int( edges[1] )
			Return New SEdges( tb, rl, tb, rl )
		Case 4
			' Edges specified separately
			Local t:Int = Int( edges[0] )
			Local r:Int = Int( edges[1] )
			Local b:Int = Int( edges[2] )
			Local l:Int = Int( edges[3] )
			Return New SEdges( t, r, b, l )
		End Select
	End Method
	
	' Lookup a stylesheet variable
	Method lookupVariable:String( variable:String )
'DebugStop
		If Not root Or Not variable.startswith( "--" ); Return variable
		Local value:String = String( MapValueForKey( root, variable ) )
		If value; Return value
		Return variable
	End Method
		
	' Match a selector to a style in the sheet
	Method match( selector:String, Style:Int[] )
Print( ": "+selector )
		Local id:Int = stylesheet.find( selector )
		If id<0; Return	' Not found
		style[id] = True
'		Local properties:TMap = TMap( styleSheet[selector] )
'		If Not properties; Return
'Print( "   -> Found" )
		'Local value:String
		'For Local property:String = EachIn MapKeys( properties )
		'	value = String( MapValueForKey( properties, property ) )
		'	MapInsert( style, property, value )
'Print( "      style: "+property+"=="+value )
		'Next
	End Method

	' Build a match query from an array
'	Method matchwith( selector:String, sep:String, options:String[], style:TMap )
'		For Local option:String = EachIn options
'			match( selector + sep + option, style )
'		Next
'	End Method

	' Parse a stylesheet
	Method Parse( raw:String )	', merge:Int=False )
		Print( "PARSING STYLESHEET" )
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
		'DebugStop
		p = 0
		Repeat
			pos1 = Instr( raw, "{", p )
			pos2 = Instr( raw, "}", pos1 )
			If pos1>0 And pos2>0
				'# Split selector from style definition
				selector = Lower(Trim(Mid( raw, p, pos1-p )))
				style    = Trim(Mid( raw, pos1+1, pos2-pos1-1 ))
				'DebugStop
				If selector And style
					styles = Null	'# Blank item array
					'# split style definition
					styles = style.split(";")
					'# MERGE (Added in V1.3)
					'If MapContains( stylesheet, selector )
					'	styledef = TMap( MapValueForKey( stylesheet, selector ))
					'Else
					styledef = New TMap()
					stylesheet.add( selector, styledef )
					'End If
					'#-----
					For Local n:Int = 0 Until Len(styles)
						If Not styles[n]; Continue
						item=Null	'# Blank item array
						item=styles[n].split(":")
						key = Trim(item[0])
						' Variable declaration
						If Len(item)=2 And key.startswith("--")
							MapInsert( styledef, Lower(key), Trim(item[1]) )
							Continue
						End If
						' Valid selector?
						'DebugStop
						If Len(item)=2 And Instr( VALID_SELECTOR, key ) 
							MapInsert( styledef, key, Trim(item[1]) )
						Else
							DebugLog( "STYLE ERROR: Invalid selector '"+key+"' in '"+selector+"'" )
						End If
					Next

				End If
				p=pos2+1
			End If
		Until pos1=0 Or pos2=0
		'DebugStop
		' Split out root variables
		root = TMap( stylesheet[":root"] )
		If root
			For Local key:String = EachIn root.keys()
				Print key+"="+String(root.valueforkey( key ))
			Next
		End If
		'DebugStop
	End Method

	Method SetColour( widget:IStyleable, index:Int, value:String )
		value = Lower(value)
		If value="none"
			widget.setPalette( index, New SColor8( 0,0,0,0 ) )	' Invisible
		Else
			widget.setPalette( index, ExtractColour( value ) )
		End If
	End Method
	
	Method strToAlignment:Float( text:String )
		Select Lower( text )
		Case "left", "top"
			Return 0.0
		Case "center", "centre", "middle"
			Return 0.5
		Case "right", "bottom"
			Return 1.0
		Default
			' Floating point number expected
			Return Min( 1.0, Max( 0.0, Float( text ) ))
		End Select
	End Method

	'# 16 HTML NAMED COLOURS
	Method strTocolour:SColor8( name:String )
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
	
End Type