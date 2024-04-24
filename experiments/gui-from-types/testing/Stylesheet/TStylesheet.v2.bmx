' Stylesheet
' Si Dunford [Scaremonger]

Rem ISSUES:

* Due to the way a MAP/StringMAP or TTreeMap work, order of the
  styles cannot be maintained and are difficult to predict which will
  be applied
  For example, having TLabel before :disabled, means that disabled should be
  applied AFTER TLabel, but because maps sort using hashes or key the actual 
  order is :Disabled, TLabel which prevents the from applying overlapping styles

End Rem

' Valid Stylesheet Selectors
Const VALID_SELECTOR$ = ..
	"surface-color,surface-colour,"+..	' Colour of Outer (Padding)
	"border-color,border-colour,"+..			' Colour of Bounds (Margin)
	"cursor-color,cursor-colour,"+..
	"variant-color,variant-colour"+..		' Variant colour (Handle within a gadget etc)
	"color,colour,"+..							' Foreground/Text
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

Type TStylesheet

	Field root:TMap		' Root variables defined in stylesheet
	Field stylesheet:TMap

	' Create a new default Stylesheet
	Method New()
		stylesheet = New TMap()
		parse( STYLE_DEFAULT )
	End Method
		
	' Create a new Stylesheet from a string definition
	Method New( raw:String )
		stylesheet = New TMap()
		parse( raw )
	End Method
	
	Method apply( widget:TWidget )
		' Get widget details
		Local typeid:TTypeId   = TTypeId.forObject( widget )
		Local typename:String  = Lower( typeid.name() )
		Local name:String      = Lower( widget.GetName() )

		Local style:TMap = CreateMap()
Print( "STYLESHEET.APPLY( " + widget.name + " ): " + typeid.name() )
'If widget.name = "NAME"; DebugStop
		
		' Pre-process data speeds up the selector process
		Local widname:String = "#"+name
		Local flagname:String[]
		If widget.flags.isset( FLAG_DISABLED ); flagname :+ [":disabled"]
		If widget.flags.isset( FLAG_HOVER ); flagname :+ [":hover"]
		If widget.flags.isset( FLAG_FOCUS ); flagname :+ [":focus"]
		If widget.flags.isset( FLAG_DRAG ); flagname :+ [":drag"]
		Local classes:String[] = []
		If widget.classlist; classes = widget.classlist.toArray()
		For Local index:Int = 0 Until classes.length
			classes[index] = "."+classes[index]
		Next
		
		' OPTIMISED: See optimise/test-style-selectors/
		
		' bitmask
		' 0000 = none
		' 0001 = typename
		' 0010 = name
		' 0011 = typename#name
		Local rootname:String, basename:String, selector:String
		match( "*", style )
		For Local bitmask:Int = 0 To 3
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
					match( selector, style )
				Next
			Next	
		Next

'DebugStop
'Print( "APPLYING:" )
		' Apply styles
		For Local property:String = EachIn MapKeys( style )
			Local value:String = String( MapValueForKey( style, property ) )
Print( "- "+property+"="+value )
			Select property
			Case "align"
				Local align:Float[] = ExtractAlignment( Lower(value) )
				widget.setAlignSelf( align[0], align[1] )
			Case "surface-color", "surface-colour"
				SetColour( widget, TForm.SURFACE, value )
			Case "border-color", "border-colour"
				SetColour( widget, TForm.BORDER, value )
			Case "color", "colour"
				SetColour( widget, TForm.FOREGROUND, value )
			Case "cursor-color", "cursor-colour"
				SetColour( widget, TForm.CURSOR, value )
			Case "margin"
				'DebugStop
				widget.setMargin( ExtractEdges( Lower(value) ) )
			Case "padding"
				'DebugStop
				widget.setPadding( ExtractEdges( Lower(value) ) )
			Case "variant-color", "variant-colour"
				SetColour( widget, TForm.VARIANT, value )
			Case "text-align"
				'DebugStop
				Local align:Float[] = ExtractAlignment( Lower(value) )
				widget.setAlignContent( align[0], align[1] )
			End Select
		Next
		
	End Method

	' Merge one stylesheet into another.
	Method merge( style:TStylesheet )
		'DebugStop
		For Local key:String = EachIn style.stylesheet.keys()
			stylesheet.insert( key, style.stylesheet.ValueForKey( key ) )
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
				Return New SColor8( $ff,$ff,$ff,$ff )

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
			' Top-Bottom and Rigth-Left
			Local tb:Int = Int( edges[0] )
			Local rl:Int = Int( edges[1] )
			Return New SEdges( tb, rl, tb, rl )
		Case 4
			' Top-Bottom and Rigth-Left
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
	Method match( selector:String, Style:TMap )
Print( ": "+selector )
		Local properties:TMap = TMap( MapValueForKey( styleSheet, selector ))
		If Not properties; Return
Print( "   -> Found" )
		Local value:String
		For Local property:String = EachIn MapKeys( properties )
			value = String( MapValueForKey( properties, property ) )
			MapInsert( style, property, value )
Print( "      style: "+property+"=="+value )
		Next
	End Method

	' Build a match query from an array
	Method matchwith( selector:String, sep:String, options:String[], style:TMap )
		For Local option:String = EachIn options
			match( selector + sep + option, style )
		Next
	End Method

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
					MapInsert( styleSheet, selector, styledef )
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
		'DebugStop
		' Split out root variables
		root = TMap( MapValueForKey( stylesheet, ":root" ) )
		If root
			For Local key:String = EachIn root.keys()
				Print key+"="+String(root.valueforkey( key ))
			Next
		End If
		'DebugStop
	End Method

	Method SetColour( widget:TWidget, index:Int, value:String )
		value = Lower(value)
		If value="none"
			widget.palette[ index ] = New SColor8( 0,0,0,0 )	' Invisible
		Else
			widget.palette[ index ] = ExtractColour( value )
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