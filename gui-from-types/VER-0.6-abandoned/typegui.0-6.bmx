'SuperStrict

'	TYPEGUI
'	Author: Si Dunford [Scaremonger], June 2023
'	Contributions from:
'		@GW		(Discord)
'		@mingw	(Discord)
'
'	Version 0.6

Rem TYPE TREE
TWidget
  TButton
  TContainer
    TForm
    TPanel
  TLabel
  TSlider
  TTextBox

Need To Add:
  TContainer:
	TCheckbox (TToggleButton and a TLabel)
	TRadio    (TToggleButton and a TLabel)
  TToggleButton
  TImage
* TTextArea
* TMenuItem
* Text area formatting, hidden characters etc
* Scroll bars

EndRem

Rem ISSUES

* Box layout space distribution isn;t working properly
  - It is giving a percentage of space instead of evenly
  - distributing it.
* Split border and margin-colour
	- margin-colour is the background fill
	- border-color is the colour of the "outline"
	- border can be a single or double value 
		none	DEFAULT, Do not draw an outline border
		thin	Draw outline border
		(color) The colour
* Add stylesheet support for fonts
* Add support for image-based widget rendering
End Rem

Rem DESIGN NOTES

	getMinimumSize()		Returns minimum size of component including whitespace

End Rem


'DebugStop

'Global SUPPORTED_TYPES:String[] = ["button","checkbox","password","radio","textbox","separator"]
' Others: color,slider,icon,dropdown,textarea,intbox
'Global SUPPORTED_METADATA:String[] = ["disable","label","options","Type"]

' LAYOUT DIRECTIONS
'Const LAYOUT_NONE:Int = 0
Const LAYOUT_HORIZONTAL:Int = 1
Const LAYOUT_VERTICAL:Int = 2
Const LAYOUT_FORM:Int = 3
Const LAYOUT_INSPECTOR:Int = 4

' Constant used in TRBL arrays
'Const NT:Int = 0
'Const NR:Int = 1
'Const NB:Int = 2
'Const NL:Int = 3

' Constants used in Style array		LABEL	BUTTON   TEXTBOX
'Const ST_BACKGROUND:Int = 0		'	n/a		SURFACE  SURFACE
'Const ST_FOREGROUND:Int = 1		'	CAPTION	CAPTION  VALUE
'Const ST_BORDER:Int = 2			'	n/a		n/a      BORDER
'Const ST_SHADOW:Int = 3			'	n/a		n/a      n/a
'Const ST_ALT:Int = 4			'	n/a		n/a      CURSOR

' Constants used in properties array
'Const PR_ALIGNMENT:Int = 0

' ALIGNMENT OPERATIONS
' 15/6/23, Converted to Float so we can calculate instead of select-case
Const ALIGN_TOP:Float    = 0.0
Const ALIGN_MIDDLE:Float = 0.5
Const ALIGN_BOTTOM:Float = 1.0
Const ALIGN_LEFT:Float   = 0.0
Const ALIGN_CENTRE:Float = 0.5	' British
'Const ALIGN_CENTER:Float = 0.5	' American
Const ALIGN_RIGHT:Float  = 1.0

' SIZE OF A DEFAULT PALETTE
'Const PALETTE_SIZE:Int = 10	' Depreciated, use COLOR.length

' OTHER
Const AUTO:Int = -1

Const VALID_SELECTOR$ = ..
	"surface,"+..						' Colour of Outer (Padding)
	"margin-color,margin-colour"+..		' Colour of Bounds (Margin)
	"cursor-color,cursor-colour"+..
	"variant,"+..					' Variant colour (Handle within a gadget etc)
	"color,colour,"+..						' Foreground/Text
	"margin,padding,"+..
	"height,width,"+..
	"text-align"
'	"background-image,border,bottom,enabled,font-family,font-style,"+..
'	"font-size,font-weight,halign,hpos,height,left,opacity,position,
'	"right,text-decoration,top,valign,vpos,visibility,width"

' EVENTS
Global EVENT_WIDGETCLICK:Int = AllocUserEventId( "Widget Clicked" )
Global EVENT_WIDGETCHANGED:Int = AllocUserEventId( "Widget Changed" )

' WIDGET ATTRIBUTE FLAGS
Global FLAG_HIDDEN:Int = $01    ' Widget is hidden
Global FLAG_DISABLED:Int = $02  ' Widget is disabled
Global FLAG_HOVER:Int = $04     ' Widget is under mouse
Global FLAG_FOCUS:Int = $08     ' Widget has keyboard focus
Global FLAG_PRESSED:Int = $10   ' Widget is pressed
Global FLAG_DRAG:Int = $20      ' TODO: Widget is being dragged
'Global FLAG_TBC:Int = $40      ' Reserved for future expansion
Global FLAG_INVALID:Int = $80	' Widget has been invalidated	

Interface IForm
	Method onGui( event:Int, widget:TWidget, data:Object )
End Interface

' NOTE:
' We use a Type here instead of a Struct because we check for NULL
Type TDimension
	Field height:Int
	Field width:Int
	
	Method New( w:Int, h:Int )
		width = w
		height = h
	End Method

	Method New( size:SPoint )
		width = size.x
		height = size.y
	End Method
		
	' Create a copy of another TDimension
	Method New( template:TDimension )
		width = template.width
		height = template.height
	End Method
	
End Type

Struct SAlign
	Field x:Float = ALIGN_CENTRE
	Field y:Float = ALIGN_MIDDLE

	Method New( x:Float, y:Float )
		Self.x = x
		Self.y = y
	End Method
	
End Struct

' Edges of a components
Struct SEdges
	Field T:Int, R:Int, B:Int, L:Int
	
	Method New( n:Int )
		set( n,  n,  n,  n )
	End Method
	
	Method New( TB:Int, LR:Int )
		set( TB, LR, TB, LR )
	End Method
	
	Method New( T:Int, R:Int, B:Int, L:Int )
		set( T,  R,  B,  L )
	End Method

	Method set( T:Int, R:Int, B:Int, L:Int )
		Self.T = T
		Self.R = R
		Self.B = B
		Self.L = L
	End Method
End Struct

' FLAG functions
'TODO: Change this to a STRUCT
Type SFlag
	Field flag:Int
	
	Method New( flag:Int )
		Self.flag = flag
	End Method
	
	Method isSet:Int( mask:Int )
		Return ( flag & mask ) = mask
	End Method
	
	Method set( mask:Int )
		flag :| mask
	End Method
	
	Method unset( mask:Int )
		flag = flag & ~mask
	End Method

	Method isZero:Int()
		Return flag = 0
	End Method

	Method toString:String()
		Return Bin( flag )
	End Method
		
End Type

' A Layout measure of minimum and compound minimum
Struct sLayoutMeasure
	Field minwidth:Int
	Field minheight:Int
	Field sumwidth:Int
	Field sumheight:Int
	Field width:Int
	Field height:Int
End Struct

' A Simple point
Struct SPoint
	Field x:Int
	Field y:Int
	Method New( x:Int, y:Int )
		Self.x = x
		Self.y = y
	End Method
End Struct

Struct SRectangle

	Field x:Int
	Field y:Int
	Field width:Int
	Field height:Int
	
	Method New( x:Int, y:Int, w:Int, h:Int )
		Self.x = x
		Self.y = y
		Self.width = w
		Self.height = h
	End Method

	Method New( pos:SPoint, size:TDimension )
		Self.x = pos.x
		Self.y = pos.y
		Self.width = size.width
		Self.height = size.height
	End Method

	Method contains:Int( px:Int, py:Int )
		If px>x And py>y And px<x+width And py<y+height; Return True
		Return False
	End Method
	
	'Method getsize:TDimension()
	'	Return New TDimension( Self.width, Self.height )
	'End Method
	
	'Method setSize( size:TDimension Var )
	'	Self.width = size.width
	'	Self.height = size.height
	'End Method
	
	Method outline()
		DrawLine( x,         y,          x+width-1, y )
		DrawLine( x+width-1, y,          x+width-1, y+height-1 )
		DrawLine( x+width-1, y+height-1, x,       y+height-1 )
		DrawLine( x,         y+height-1, x,       y )
	End Method

	Method outline( color:SColor8 )
		SetAlpha( color.a/256.0 )
		SetColor( color )
		outline()
	End Method
	
	Method fill()
		DrawRect( x, y, width, height )
	End Method
	
	Method fill( color:SColor8 )
		SetColor( color )
		SetAlpha( color.a/256.0 )
		DrawRect( x, y, width, height )
	End Method
	
	Method shrink( size:Int )
		x :+ size
		y :+ size
		width :- size*2
		height :- size*2
	End Method

	Method shrink( edges:SEdges )
		x :+ edges.L
		y :+ edges.T
		width :- (edges.L + edges.R)
		height :- (edges.T + edges.B)
	End Method
	
	Method shrink( T:Int, R:Int, B:Int, L:Int )
		x :+ L
		y :+ T
		width :- (L + R)
		height :- (T + B)
	End Method
	
	Method expand( size:Int )
		x :- size
		y :- size
		width :+ size*2
		height :+ size*2
	End Method
	
	Method expand( edges:SEdges )
		x :- edges.L
		y :- edges.T
		width :+ (edges.L + edges.R)
		height :+ (edges.T + edges.B)
	End Method
	
	Method expand( T:Int, R:Int, B:Int, L:Int )
		x :- L
		y :- T
		width :+ (L + R)
		height :+ (T + B)
	End Method
	
	Method toString:String()
		Return x+","+y+":"+width+","+height
	End Method
	
Rem
	'DEPRECIATED
	Method minus:SRectangle( trbl:Int[] )
		Assert trbl.length = 4, "Invalid array detected"
		Return New SRectangle( x+trbl[NL], y+trbl[NT], width-trbl[NL]-trbl[NR], height-trbl[NT]-trbl[NB] )
	End Method

	'DEPRECIATED
	Method minus:SRectangle( size:SVector )
		Self.width :- size.x
		Self.height :- size.y
		Return Self
	End Method
End Rem	
End Struct

'DEPRECIATED


'Struct SVector
'
'	Field x:Int
'	Field y:Int
'	
'	Method New( x:Int, y:Int )
'		Self.x = x
'		Self.y = y
'	End Method
'	
'	Method add:SVector( addition:SVector )
'		x :+ addition.x
'		y :+ addition.y
'		Return Self
'	End Method
'
'	Method add:SVector( w:Int, h:Int )
'		x :+ w
'		y :+ h
'		Return Self
'	End Method
'	
'End Struct


' An array-backed object to replace TWidget[]
Type TWidgetArray Extends TObjectList
	Method operator[]:TWidget( index:Int )
		Return TWidget( valueAtIndex( index ) )
	End Method
End Type

' Color constants
Type COLOR
	Const NONE:Int=0
	Const BORDER:Int=1		' Colour of bounds
	Const SURFACE:Int=2		' Colour of outer (Inside margin, includes padding)
	Const FOREGROUND:Int=3	' Forground colour
	Const VARIANT:Int=4		' Variant Color
	Const CURSOR:Int=5		' Cursor Color (Textbox mostly)
	'
	Const length:Int=6
	
	Function debug( palette:SColor8[] )
		DebugLog( "DEBUG PALETTE:" )
		If palette.length<> length DebugLog( "* Invalid palette size" )
		DebugLog( "  NONE:       #"+Hex(palette[COLOR.NONE].toARGB()) )
		DebugLog( "  BORDER:     #"+Hex(palette[COLOR.BORDER].toARGB()) )
		DebugLog( "  SURFACE:    #"+Hex(palette[COLOR.SURFACE].toARGB()) )
		DebugLog( "  FOREGROUND: #"+Hex(palette[COLOR.FOREGROUND].toARGB()) )
		DebugLog( "  VARIANT:    #"+Hex(palette[COLOR.VARIANT].toARGB()) )
		DebugLog( "  CURSOR:     #"+Hex(palette[COLOR.CURSOR].toARGB()) )
	End Function
End Type

' System handler for GUI
Type TGUISys
	Global cursortimer:TTimer	' System cursor timer
	Global cursorState:Int		' System cursor state
	Global forms:TList			' Event handlers
	Global functions( event:Int, widget:TWidget, data:Object )[]	' Event handlers
	
	Function initialise()
		If Not cursortimer; cursortimer = CreateTimer( 2 )
		forms = New TList()
	End Function
	
	Function register( handler:IForm )
		forms.addlast( handler )
	End Function

	Function register( handler( event:Int, widget:TWidget, data:Object ) )
		functions :+ [handler]
	End Function

	Function emit( event:Int, widget:TWidget, data:Object )
		For Local handler:IForm = EachIn forms
			handler.onGUI( event, widget, data )
		Next
		For Local handler( event:Int, widget:TWidget, data:Object ) = EachIn functions
			handler( event, widget, data )
		Next
		
		' Pass to IForm handler
		'Local target:IForm = IForm(parent)
		'If target; target.onGUI( event, Self, widget )
'		If handler; handler( event, TWidget( widget ), Null )
		
	End Function
	
	
End Type
TGUISys.initialise()

'Interface IComponent
'	Method getMinimumSize:TDimension()
'	'Method recalculate()
'	Method render()
'End Interface

Type TWidget Implements IStyleable
	Global autoincrement:Int = 0

	Field fld:TField			' Map a Type Field to a widget
	
	Private
	
	Field name:String
	'Field invalid:Int = True	' Needs to be recalculated
	Field parent:TContainer
	'Field runstyle:Int = True	' Style needs to be applied
	Field stylesheet:TStylesheet

	Field classlist:TSet<String>				' A bit like "class" in CSS

	Field bounds:SRectangle = New SRectangle()	' OUtside size (Including margin and padding)
	Field outer:SRectangle						' Size including padding
	Field inner:SRectangle						' ** CLIENT SIZE OF CONTENT **
	'Field cliparea:SRectangle					' See ClipArea()
	
	Field actualSize:TDimension					' Manual size
	
	Field margin:SEdges = New SEdges( 1 )
	Field padding:SEdges = New SEdges( 1 )
	
	Field flags:SFlag = New SFlag()

	Field minsize:TDimension		' If set, manually overridden
	Field expand:SPoint				' Allow expansion of widget inside layout (0=no)
	
	' Alignment of widget inside parent container
	Field alignSelf:SAlign = New SAlign( ALIGN_CENTRE, ALIGN_MIDDLE )
	
	' Alignment of content within a field
	Field alignContent:SAlign = New SAlign( ALIGN_LEFT, ALIGN_MIDDLE )

	Field palette:SColor8[6]
	
	' Supported widget value types
	' Widget must manage which one it uses and deal with casting.
	Field valueFloat:Float = 0.0
	Field valueInt:Int = 0
	Field valueStr:String = ""
	
	Field caption:String
	
	Public
	
	Method New()
		autoincrement :+ 1
		name = Hex(autoincrement)
	End Method
	
	Method addStyle( style:String )
		If Not style; Return
		Local sheet:TStylesheet = New TStylesheet( style )
		stylesheet.merge( sheet )
	End Method

	' Confirm if location without bounds
	Method contains:Int( x:Int, y:Int )
		If x>bounds.x And x<bounds.x+bounds.width And y>bounds.y And y<bounds.y+bounds.height; Return True
		Return False
	End Method

	Method flagset:Int( flag:Int )
		Return flags.isset( flag )
	End Method
	
	Method GetClassList:String[]()
		If Not classlist; Return []
		Return classlist.toArray()
	End Method	
	
	'Method GetClass:String()
	'	Return name
	'End Method
	
	' Get the client (inner) space
	Method GetInner:SRectangle()
		Return inner
	End Method

	Protected Method _getMinimumSize:TDimension()
		' User provided minimum size
		If minsize; Return minsize
		' Recalculate size
		outer = inner
		outer.expand( padding )
		bounds = outer
		bounds.expand( margin )
		
		' Actual boundary size
		Return New TDimension( bounds.width, bounds.height ) ' bounds includes whitespace
	End Method

	Public 
	
	Method GetName:String()
		Return name
	End Method
	
	' Get widget at a specific location
	Method getWidgetAt:TWidget( x:Int, y:Int )
		If contains( x, y ); Return Self
		Return Null
	End Method
	
	Method getWidgetByName:TWidget( criteria:String )
		If Lower(criteria) = name; Return Self
	End Method
	
	' Position and align text within client area
	Method getTextPos:SPoint( text:String )
		Return getTextPos( text, inner )
	End Method
	
	Method getTextPos:SPoint( text:String, surface:SRectangle )
		Local point:SPoint = New SPoint()
		point.x = surface.x+(surface.width-TextWidth( text )) * alignContent.X
		point.y = surface.y+(surface.height-TextHeight( text )) * alignContent.Y
		Return point
	End Method

	Method GetFloat:Float()
		Return valueFloat
	End Method

	Method GetInt:Int()
		Return valueint
	End Method

	Method GetString:String()
		Return valuestr
	End Method
	
	Method onDrag( x:Int, y:Int ); End Method

	Method onGetFocus( x:Int, y:Int )
'		Print( "WIDGET.onGetFocus: "+name )
		flags.set( FLAG_FOCUS )
		invalidate()
	End Method

	Method onKey( code:Int, key:Int )
'		Print( "WIDGET.onKey: "+name )
	End Method

	Method onLoseFocus( x:Int, y:Int )
'		Print( "WIDGET.onLoseFocus: "+name )
		flags.unset( FLAG_FOCUS )
		invalidate()
	End Method
	
	Method onMouseClick( x:Int, y:Int )
'		Print( "WIDGET.onMouseClick: "+name )
	End Method
	
	Method onMouseDown( x:Int, y:Int )
'		Print( "WIDGET.onMouseDown: "+name )
		flags.set( FLAG_PRESSED )
	End Method
	
	Method onMouseMove( x:Int, y:Int ); End Method
	
	Method onMouseEnter( x:Int, y:Int )
'		Print( "WIDGET.onMouseEnter: "+name )
		flags.set( FLAG_HOVER )
		invalidate()
	End Method
	
	Method onMouseLeave( x:Int, y:Int )
'		Print( "WIDGET.onMouseLeave: "+name )
		flags.unset( FLAG_HOVER )
		invalidate()
	End Method

	Method onMouseUp( x:Int, y:Int )
'		Print( "WIDGET.onMouseUp: "+name )
		flags.unset( FLAG_PRESSED )
	End Method
	
	Method removeClass( class:String )
		If Not classlist; Return
		classlist.remove( Lower(class) )
		invalidate()
	End Method
		
	' Set alignment within parent container
	Method setAlignSelf( horz:Float, vert:Float )
		alignSelf = New SAlign( horz, vert )
		invalidate()
	End Method

	' Set alignment of content
	Method setAlignContent( horz:Float, vert:Float )
		alignContent = New SAlign( horz, vert )
	End Method

	' Set display class
	Method setClass( class:String )
		If Not classlist; classlist = New TSet<String>
		classlist.add( Lower(class) )
		invalidate()
	End Method

	Method setClass( classes:String[] )
		If Not classlist; classlist = New TSet<String>
		For Local class:String = EachIn classes
			classlist.add( Lower(class) )
		Next
		invalidate()
	End Method
	
	' Save and restore the clip area to prevent overflow
	Method setClipArea( save:Int = True )
		Global cliparea:SRectangle
		If save
			GetViewport( cliparea.x, cliparea.y, cliparea.width, cliparea.height )
			SetViewport( inner.x, inner.y, inner.width, inner.height )
		Else
			SetViewport( cliparea.x, cliparea.y, cliparea.width, cliparea.height )
		End If
	End Method
				
	Method setExpand( both:Int )
		expand.x = both
		expand.y = both
	End Method
	
	Method setExpand( x:Int, y:Int )
		expand.x = x
		expand.y = y
	End Method
	
	' Set Attribute Flag
	Method setFlag( attr:Int, state:Int = True )
		If state
			flags.set( attr )
		Else
			flags.unset( attr )
		End If
		' Invalidate for some flags
		Select attr
		Case FLAG_DISABLED, FLAG_HIDDEN, FLAG_FOCUS
			invalidate()
		End Select
	End Method

	' Sets an individual palette colour
	' CALLED BY LAYOUT MANAGER
	Method _setPalette( id:Int, color:SColor8 )
		palette[id] = color
	End Method
			
	' Sets a stylesheet
	Method setStyle( style:String )
		If style<>""; setstyle( New TStylesheet( style ) )
	End Method
	
	Method setStyle( style:TStylesheet = Null )
		If Not style; style = New TStylesheet()
		stylesheet = style
		flags.set( FLAG_INVALID )
	End Method

	Method setValue( value:Float )
		valueFloat = value
	End Method

	Method setValue( value:Int )
		valueInt = value
	End Method

	Method setValue( value:String )
		valueStr = value
	End Method
	
	' If class doesn't exist, it adds it
	' Otherwise it removes it.
	Method toggleClass( class:String )
		If Not classlist; classlist = New TSet<String>
		class = Lower(class)
		If classlist.contains( class )
			classlist.remove( class )
		Else
			classlist.add( class )
		End If
		invalidate()
	End Method

	Method unsetFlag( flag:Int )
		flags.unset( flag )
	End Method
				
	'------------------------------------------------------------
	Protected Method __PROTECTED__() ; End Method

	Method getExpand:Spoint()
		Return expand
	End Method

	' Invalidates the widget layout
	Method invalidate()
		' If already invalid, we dont need to go further
		If flags.isset( FLAG_INVALID ); Return
		flags.set( FLAG_INVALID )
		If parent; parent.invalidate()
	End Method
		
	Method render()
		bounds.fill( New SColor8( $ffff0000 ) )
	End Method

	' Called by parent to achieve two things
	' 1. Distribute a stylesheet if child doesn't have one
	' 2. Inform child it needs to apply the stylesheet

	
	' Recalculate the size and style of this widget
	'Method recalculate()
	'	If stylevalid; Return
	'	If stylesheet; stylesheet.apply( Self )
	'	outer = inner
	'	outer.expand( padding )
	'	bounds = outer
	'	bounds.expand( margin )
	'	stylevalid = True
	'End Method
	
	' Apply the stylesheet
	Protected Method _refreshStyle( style:TStylesheet )
		If Not stylesheet Or stylesheet<> style; stylesheet = style
		stylesheet.apply( Self )
	End Method
	
	' Set outer bounds
	' CALLED BY LAYOUT MANAGER
	Protected Method _setBounds( rect:SRectangle )
		bounds = rect
		rect.shrink( margin )
		outer = rect
		rect.shrink( padding )
		inner = rect
	End Method

	' Set client size
	' CALLED BY PACK()
	Protected Method _setInner( rect:SRectangle )
		inner = rect
		rect.expand( padding )
		outer = rect
		rect.expand( margin )
		bounds = rect
	End Method

	' CALLED BY LAYOUT MANAGER
	'Method setMargin( all:Int ) ;        setMargin( all, all, all, all ) ; End Method
	'Method setMargin( TB:Int, LR:Int ) ; setMargin( TB, LR, TB, LR ) ;     End Method
	'Method setMargin( T:Int, R:Int, B:Int, L:Int )
	'	If margin.T=T And margin.R=R And margin.B=B And margin.L=L; Return
	'	margin.T = T
	'	margin.R = R
	'	margin.B = B
	'	margin.L = L
	'	invalidate()
	'End Method
	'Method setMargin( edges:SEdges )
	'	If margin.T=edges.T And margin.R=edges.R And margin.B=edges.B And margin.L=edges.L; Return
	'	margin = edges
	'	invalidate()
	'End Method

	' Allows client to set the ACTUAL size of a component
	Method setSize( w:Int, h:Int )
		If actualSize
			actualsize.width = w
			actualsize.height = h
		Else
			actualSize = New TDimension( w, h )
		End If
	End Method
	'Method setSize( w:Int, h:Int )
	'	If minsize
	'		minsize.width = w
	'		minsize.height = h
	'	Else
	'		minsize = New TDimension( w, h )
	'	End If
	'End Method
	
	' CALLED BY LAYOUT MANAGER
	'Method setPadding( all:Int ) ;        setPadding( all, all, all, all ) ; End Method
	'Method setPadding( TB:Int, LR:Int ) ; setPadding( TB, LR, TB, LR ) ;     End Method
	'Method setPadding( T:Int, R:Int, B:Int, L:Int )
	'	If padding.T=T And padding.R=R And padding.B=B And padding.L=L; Return
	'	padding.T = T
	'	padding.R = R
	'	padding.B = B
	'	padding.L = L
	'	invalidate()
	'End Method
	'Method setPadding( edges:SEdges )
	'	If padding.T=edges.T And padding.R=edges.R And padding.B=edges.B And padding.L=edges.L; Return
	'	padding = edges 
	'	invalidate()
	'End Method
		
	' Set a minimum size for a widget
	Method validate()
		If stylesheet; stylesheet.apply( Self )
	End Method
	
	' Get the widget whitespace total
	Method WhitespaceX:Int()
		Return margin.L+margin.R+padding.L+padding.R
	End Method
	
	Method WhitespaceY:Int()
		Return margin.T+margin.B+padding.T+padding.B
	End Method
		
End Type

Type TButton Extends TWidget 'Implements IComponent

	Method New( caption:String="" )
		Self.caption = caption
		Self.expand.x = 1
	End Method
	
	' Get minimum size of widget
	' This must include margin and padding
	Method getMinimumSize:TDimension()
		' User provided minimum size
		If minsize; Return minsize
		' Use size of content
		Return New TDimension( TextWidth( caption )+whitespaceX(), TextHeight( caption )+whitespaceY() )
	End Method

	Method render()
		' Draw border (Only visible if margin>0)
		bounds.outline( palette[ COLOR.BORDER ] )
		' Draw surface
		Local surface:SRectangle = outer
		If Flagset( FLAG_PRESSED )
			surface.x :+ 2
			surface.y :+ 2
		End If
		surface.fill( palette[ COLOR.SURFACE ] )
		' Draw content
		Local pos:SPoint = getTextPos( caption, surface )
		SetAlpha( palette[COLOR.FOREGROUND].a/256.0 )
		SetColor( palette[COLOR.FOREGROUND] )
		DrawText( caption, pos.x, pos.y )
	End Method
	
End Type

Type TCheckbox Extends TToggle 'Implements IComponent

	Field state:Int

	Method New( caption:String, state:Int=False )
		Self.caption = caption
		Self.state = state
		valueint = state
		'
		size = TextHeight( "8p" )
	End Method
	
	Method onMouseDown( x:Int, y:Int )
		Print( "TOGGLE.onMouseDown: "+name )
		valueint = Not valueint
	End Method
	
	Method render()
		If state <> valueint
			state = valueint
			'TODO
			' Emit CHANGED event
			TGUISys.Emit( EVENT_WIDGETCHANGED, Self, Null )
		End If
		' Draw border (Only visible if margin>0)
		bounds.outline( palette[ COLOR.BORDER ] )
		' Background
		outer.fill( palette[ COLOR.SURFACE ] )
		' Toggle box
		toggle.fill( palette[ COLOR.VARIANT ] )
		' handle
		If state
			handle.fill( palette[ COLOR.FOREGROUND ] )
		End If
		'
		Local pos:SPoint = getTextPos( caption, label )
		SetAlpha( palette[COLOR.FOREGROUND].a/256.0 )
		SetColor( palette[COLOR.FOREGROUND] )
		DrawText( caption, pos.x, pos.y )
	End Method
	
End Type

Type TContainer Extends TWidget

	Private
	
	Field children:TList = New TList()
	Field layout:ILayout

	Public
	
	Method New( layout:Int = LAYOUT_VERTICAL )
		Select layout
		Case LAYOUT_FORM
			setlayout( New TGridLayout( LAYOUT_VERTICAL, 2 ) )
		Case LAYOUT_INSPECTOR
			setlayout( New TGridLayout( LAYOUT_VERTICAL, 3 ) )
		'Case LAYOUT_HORIZONTAL, LAYOUT_VERTICAL
		Default
			setLayout( New TBoxLayout( layout ) )
		End Select
	End Method

	' V0.6
	Method add:TWidget( widget:TWidget )
		If widget.parent; widget.invalidate()
		widget.parent = Self
		' Add to list
		children.addlast( widget )
		Return widget
	End Method
	
	Method add:TWidget( name:String, widget:TWidget )
		widget.name = Lower(name)
		Return add( widget )
	End Method
	
	Method getWidgetAt:TWidget( x:Int, y:Int )
	
		' Check coordinates are within self
		If Not contains( x, y ); Return Null
		If Not children; Return Null
		
		For Local child:TWidget = EachIn children
			Local inside:TWidget = child.getwidgetAt( x, y )
			If inside; Return inside
		Next
		Return Self
		
	End Method

	Method getWidgetByName:TWidget( criteria:String )
		Local found:TWidget
		If Lower(criteria) = name; Return Self
		For Local child:TWidget = EachIn children
			found = child.getWidgetByName( criteria )
			If found; Return found
		Next
	End Method

	' Sets a layout
	Method setLayout( layout:Int=LAYOUT_VERTICAL )
		Select layout
		Case LAYOUT_HORIZONTAL, LAYOUT_VERTICAL
			setLayout( New TBoxLayout( layout ) )
		End Select
	End Method
	
	Method setLayout( layout:ILayout )
		Self.layout = layout
		layout.setParent( Self )
		invalidate()
	End Method

	' Sets a stylesheet
	Method setStyle( style:TStylesheet = Null )
		Super.setStyle( style )
		For Local child:TWidget = EachIn children
			child.setstyle( stylesheet )
		Next
		flags.set( FLAG_INVALID )
	End Method
	
	'------------------------------------------------------------
	Protected Method __PROTECTED__() ; End Method

	' A container should use a layout manager to calculate its minimum size
	Method getMinimumSize:TDimension()
		' User provided minimum size
		If minsize; Return minsize
		If Not layout; setLayout( New TBoxLayout() )
		Return layout.getMinimumSize()
	End Method
	
	' Get a list of visible children
	Method getChildren:TWidgetArray()
		Local result:TWidgetArray = New TWidgetArray()
		For Local child:TWidget = EachIn children
			If child.flags.isSet( FLAG_HIDDEN ); Continue
			result.addlast( child )
		Next
		Return result
	End Method

	' Invalidates the widget layout
	Method invalidate()
		' If already invalid, we dont need to go further
		If flags.isset( FLAG_INVALID ); Return
		If layout; layout.invalidate()
		Super.invalidate()
	End Method

	' Apply the stylesheet
	Protected Method _refreshStyle( style:TStylesheet )
		Super._refreshStyle( style )
		For Local child:TWidget = EachIn children
			child._refreshStyle( style )
		Next	
	End Method
	
	Method render()
		' Container is invisible. If you want style, use a panel!
		For Local child:TWidget = EachIn children
			If child.flags.isSet( FLAG_HIDDEN); Continue
			'If child.runstyle; child.restyle( stylesheet )
			child.render()
		Next		
	End Method
	
	'Method runLayout()
	'	If layout; layout.run()
	'End Method
		
	' Recalculate the size and style of this widget
	'Method recalculate()
	'	For Local child:TWidget = EachIn children
	'		If child.flags.isSet( FLAG_HIDDEN ); Continue
	'		child.recalculate()
	'	Next
		'If stylevalid; Return	
	'End Method
		
	Method validate()
		Super.validate()
		'
		For Local child:TWidget = EachIn children
			If child.flags.isset( FLAG_HIDDEN ); Continue
			If child.flags.isset( FLAG_INVALID )
				child.validate()
				child.flags.unset( FLAG_INVALID )
			End If
		Next
		'
		' We use a layout manager to validate ourself
		If Not layout; layout = New TBoxLayout()
		'setSize( layout.getMinimumSize() )	' Layout must do this.
		layout.run()
		'
		flags.unset( FLAG_INVALID )
	End Method
	
End Type

Type TForm Extends TContainer Implements IForm

	Const BLINKSPEED:Int = 500

	'Const NONE:Int = 0
	'Const BORDER:Int = 1		' Colour of bounds
	'Const SURFACE:Int = 2		' Colour of outer (Inside margin, includes padding)
	'Const FOREGROUND:Int = 3	' Forground colour
	'Const VARIANT:Int = 4		' Variant Color
	'Const CURSOR:Int = 5		' Cursor Color (Textbox mostly)
		
	'Const _CENTRE_:Int = $0001	' For the Brits
	'Const _CENTER_:Int = $0001	' For the Americans
	
	'Field MARGIN:Int = 5
	'Field PADDING:Int = 4
	
	Field parent:Object 'IForm
	'Field title:String
	'Field fields:TList			' Widgets in the form
	Field xpos:Int = AUTO
	Field ypos:Int = AUTO
	'Field width:Int, height:Int
	'Field widths:Int[2]
	'Field flags:Int = _CENTRE_
	
	' Depreciated
	'Field focus:TFormfield		' Field with focus
	
	'Field cursorstate:Int		' Current cursor state
	'Field cursortimer:Int		' Depreciated in 0.6
	'Field cursorpos:Int		' Depreciated in 0.6
	
	'V05
	Field invalid:Int = True
	'Field quit:Int = False		' Used by inspector
	
	'V06
	'Field root:TContainer

	Field dragged:TWidget		' widget being dragged
	Field hovered:TWidget		' widget under mouse
	Field focused:TWidget		' widget with keyboard focus
	Field mousefocus:TWidget	' widget with mouse focus
	Field pressed:TWidget		' currently pressed widget
	
	Field handler( event:Int, widget:TWidget, data:Object )
	
	Field modal:Int = False		' Set when show() is called
	
	' Manual GUI
	Method New()
		' Style sheet
		setStyle()				' Set default stylesheet
		' Screen position
		xpos = AUTO
		ypos = AUTO
		' Event handler
		AddHook( EmitEventHook, EventHook, Self )
	End Method
	
	' TypeGUI - View a Type as a GUI
	Method New( form:IForm, fx:Int=AUTO, fy:Int=AUTO )
		'DebugStop
		parent = form
		' Style sheet
		setStyle()				' Set default stylesheet		
		' Screen position
		xpos = fx
		ypos = fy		
		' Event handler
		AddHook( EmitEventHook, EventHook, Self )
		
		' Add type as title (if provided)
		Local t:TTypeId = TTypeId.ForObject( form )
		Local title:String = t.metadata("title")
		If title
			Local label:TWidget = add( "title", New TLabel( title ) )
			label.setclass( "title" )
		End If
		
		' Add Two Column Layout for Name/Field grid data
		Local grid:TContainer = New TContainer()
		grid.setLayout( New TGridLayout( LAYOUT_VERTICAL, 2 ) )
		add( grid )

		' Add fields in type
		For Local fld:TField = EachIn t.EnumFields()
			'Only include fields with metadata
			If Not fld.metadata(); Continue
			
			'Local row:TFormField = New TFormField()
			
			' Create the label
			Local name:String = fld.name()
			Local caption:String = fld.metadata("label")
			If caption = ""; caption = name
			Local label:TWidget = New TLabel(caption+":")

			Local widget:TWidget = CreateWidget( form, fld )
Rem
			' Get the field type
			Local widget:TWidget 
			Local metaType:String = fld.metadata("type")
			Local fldtype:String = fld.typeid().name() 
			'DebugStop
			Select fldtype
			Case "Byte"
				widget = New TLabel( fld.getByte( form ) )
			Case "Short"
				widget = New TLabel( fld.getShort( form ) )
			Case "Double"
				widget = New TLabel( fld.getDouble( form ) )
			Case "Float"
				widget = New TLabel( fld.getFloat( form ) )
			Case "Int"
				'widget = New TLabel( fld.getInt( form ) )
				Select metatype
				Case "checkbox"
					Local value:Int = ( fld.getInt( form ) = True )	
					widget = New TCheckbox( name,value )
				Case "radio"
					'DebugStop
					Local opts:String = fld.metadata("options")
					Local options:String[] = opts.split(",")
					If options.length = 0
						Local value:Int = fld.getInt( form )
						widget = New TRadioButton( caption, value ) 
					Else
						' Add a group (panel) of radio buttons
						widget = New TGroup()
						For Local option:Int = 0 Until options.length
							TContainer(widget).add( New TRadioButton( options[option], option ) )
						Next
						Local value:Int = fld.getInt( form )
						widget.setvalue( value )
					End If
				Default
					Local value:Int = fld.getInt( form ) 
					widget = New TTextBox( value, "" )
				EndSelect
			Case "Long"
				widget = New TLabel( fld.getLong( form ) )
			Case "String"
				'DebugStop
				Local value:String = fld.getString( form )
				widget = New TTextBox( value, "" )
			Default
				'DebugStop
				If fld.typeid().extendsType( ArrayTypeId )
					widget = New TLabel( "(array)" )
				ElseIf fld.typeid().extendsType( ObjectTypeId )					
					widget = New TLabel( "(object)" )
				Else
					widget = New TLabel( "(NOT IMPLEMENTED)" )
					DebugLog( "TypeGUI: '" + fld.typeid().name() + "' is Not supported" )
				End If
			End Select
End Rem
			' Add fields to form grid
			grid.add( "lbl"+name, label )
			grid.add( "fld"+name, widget )
			
			' Save original field object
			widget.fld = fld

			If fld.hasmetadata( "disabled" ); widget.setFlag( FLAG_DISABLED )

		Next
		
		' Add the form event handler
		setHandler( form )
		' Resize to fit
		pack()
		
	End Method

	' Object Inspector
	Method New( form:Object, fx:Int, fy:Int )
		'DebugStop
		parent = form
		' Style sheet
		setStyle( STYLE_INSPECTOR )				' Set stylesheet		
		' Screen position
		xpos = fx
		ypos = fy		
		' Event handler
		AddHook( EmitEventHook, EventHook, Self )

		Local t:TTypeId = TTypeId.ForObject( form )
		
		' Add type as title
		Local title:String = t.metadata("title")
		If Not title; title = t.name()
		Local label:TWidget = add( "title", New TLabel( title ) )
		label.setclass( "title" )
		label.setExpand( 1 )

		' Add Three Column Layout for Name/Type/Field grid data
		Local grid:TContainer = New TContainer()
		grid.setLayout( New TGridLayout( LAYOUT_VERTICAL, 3 ) )
		add( grid )

		' Add fields in type
		For Local fld:TField = EachIn t.EnumFields()
			Local label:TLabel
			Local name:String = fld.name()
			
			' Add field name to column 1
			label = New TLabel( name )
			label.setClass( "inspector" )
			grid.add( label )
			
			' Add field type to Column 2
			label = New TLabel( fld.typeid().name() )
			label.setClass( "inspector" )
			grid.add( label )
			
			' Add widget to Column 3	
			Local widget:TWidget = CreateWidget( form, fld, "inspector" )
			grid.add( "fld"+name, widget )
			
			If fld.hasmetadata( "disabled" ); widget.setFlag( FLAG_DISABLED )

		Next

		AddButtons( ["APPLY","CANCEL"] )
		
		setHandler( InspectorFormHandler )
		' Resize to fit
		pack()
		
	End Method 

	Method Delete()
		DebugStop
	End Method
	
	Function EventHook:Object( id:Int, data:Object, context:Object )
		Local form:TForm = TForm(context)
		Local event:TEvent = TEvent( data )
		If Not form Or Not event; Return data
		' Don't listen unless visiable and enabled:
		If form.flags.isset( FLAG_HIDDEN ) Or form.flags.isset( FLAG_DISABLED ); Return data
		'
		'If form.onEvent( id, event ); Return Null
		Select event.id
		Case EVENT_APPSUSPEND
			' Ignored
		Case EVENT_APPRESUME
			' Ignored
		Case EVENT_APPTERMINATE
			' Ignored
		Case EVENT_KEYCHAR
			Return form.onKeyChar( event )
		Case EVENT_KEYDOWN
			Return form.onKeyDown( event )
		Case EVENT_KEYUP
			Return form.onKeyUp( event )
		Case EVENT_KEYREPEAT
			Return form.onKeyRepeat( event )		
		Case EVENT_MOUSEDOWN
			Return form.OnMouseDown( event )
		Case EVENT_MOUSEUP
			Return form.OnMouseUp( event )
		Case EVENT_MOUSEMOVE
			Return form.OnMouseMove( event )
		Case EVENT_MOUSEWHEEL
			' Ignored
		Case EVENT_TIMERTICK
			Local c:TTimer = TTimer(event.source)
			If c = TGUISys.cursortimer
				TGUISys.cursorState = Not TGUISys.cursorState
				Return Null
			End If
		Default
			DebugLog( "[UNHANDLED EVENT] TForm=>"+event.toString() )
		End Select
		
		Return data
	End Function

	Function InspectorFormHandler( event:Int, widget:TWidget, data:Object )

		Select event
		'Case EVENT_WIDGET_CLICK; Print( "-> Clicked, "+ widget.GetName() )
		Case EVENT_MOUSEENTER
		Case EVENT_MOUSELEAVE
		Case EVENT_WIDGETCLICK
			Select Lower(widget.GetName())
			Case "btnapply"
				Local form:TForm = TForm(data)
				form.quit()
			Case "btncancel"
				Local form:TForm = TForm(data)
				form.quit()
			Default
				DebugLog( "[UNHANDLED EVENT] INSPECTOR/Handler=>ONCLICK ("+widget.GetName()+")" )		
			End Select
		'Case EVENT_WIDGETCHANGED	
		Default
			If widget
				DebugLog( "[UNHANDLED EVENT] INSPECTOR/Handler=>"+TEvent.DescriptionForId( event )+" ("+widget.GetName()+")" )
			Else
				DebugLog( "[UNHANDLED EVENT] INSPECTOR/Handler=>"+TEvent.DescriptionForId( event )+" (NULL)" )
			End If
		End Select
	End Function
	
	' V05
'	Method add( fld:TFormField )
'		fields.addlast( fld )
'		' V0.6
'		If Not children; children = New TList()
'		children.addlast( fld )
'	End Method

'	Method add( fieldtype:String, name:String )
'		fields.addlast( make( fieldtype, name ) )
'		' V0.6
'		If Not children; children = New TList()
'		children.addlast( fld )
'	End Method
		
	' Emit an event to the form handler
	' Depreciated, use TGUISys
'	Method emit( event:Int, widget:TWidget )
'		Local target:IForm = IForm(parent)
'		If target; target.onGUI( event, Self, TFormField(widget) )
'		If handler; handler( event, TWidget( widget ), Null )
'	End Method

	' Adds a panel containing buttons to the form
	Method addButtons( buttons:String[] )
		Local panel:TPanel = New TPanel()
		panel.setclass( "buttonbox" )
		panel.setLayout( LAYOUT_HORIZONTAL )
		For Local button:String = EachIn buttons
			panel.add( "btn"+Lower(button), New TButton( button ) )
		Next
		add( panel )
	End Method

	' Creates a widget for a given form/field based on type
	' 13 JUL 2023: Reflection does not support Struct or Enum
	Method CreateWidget:TWidget( form:Object, fld:TField, class:String="" )

		' Get the field type
		Local widget:TWidget 
		Local metaType:String = fld.metadata("type")
		Local fldtype:String = fld.typeid().name() 
		
		' Create an appropriate widget
		Select fldtype
		Case "Byte"
			widget = New TLabel( fld.getByte( form ) )
		Case "Short"
			widget = New TLabel( fld.getShort( form ) )
		Case "Double"
			widget = New TLabel( fld.getDouble( form ) )
		Case "Float"
			widget = New TLabel( fld.getFloat( form ) )
		Case "Int"
			'widget = New TLabel( fld.getInt( form ) )
			Select metatype
			Case "checkbox"
				Local value:Int = ( fld.getInt( form ) = True )	
				widget = New TCheckbox( "",value )
			Case "radio"
				'DebugStop
				Local opts:String = fld.metadata("options")
				Local options:String[] = opts.split(",")
				If options.length = 0
					Local value:Int = fld.getInt( form )
					widget = New TRadioButton( caption, value ) 
				Else
					' Add a group (panel) of radio buttons
					widget = New TGroup()
					For Local option:Int = 0 Until options.length
						TContainer(widget).add( New TRadioButton( options[option], option ) )
					Next
					Local value:Int = fld.getInt( form )
					widget.setvalue( value )
				End If
			Default
				Local value:Int = fld.getInt( form ) 
				widget = New TTextBox( value, "" )
			EndSelect
		Case "Long"
			widget = New TLabel( fld.getLong( form ) )
		Case "String"
			'DebugStop
			Local value:String = fld.getString( form )
			widget = New TTextBox( value, "" )
		Default
			'DebugStop
			If fld.typeid().extendsType( ArrayTypeId )
				widget = New TLabel( "(array)" )
			ElseIf fld.typeid().extendsType( ObjectTypeId )					
				widget = New TLabel( "(object)" )
			Else
				widget = New TLabel( "(NOT IMPLEMENTED)" )
				DebugLog( "TypeGUI: '" + fld.typeid().name() + "' is Not supported" )
			End If
		End Select
		
		'DebugStop
		If class; widget.setClass( class )
		'Print "CLASS:"+(",".join( widget.getclasslist() ))
		
		Return widget
	End Method
	'
	Method onGui( event:Int, widget:TWidget, data:Object )
		Print( "TForm.onGui: "+TEvent.DescriptionForId(event)+", "+widget.GetName() )
	End Method

	Method onKeyChar:TEvent( event:TEvent )
		Print( "FORM.onKeyChar: "+event.toString() )
		If Not focused; Return event
		focused.onKey( 0, event.data )
	End Method

	Method onKeyRepeat:TEvent( event:TEvent )
		Print( "FORM.onKeyRepeat: "+event.toString() )
		If Not focused; Return event
		focused.onKey( event.data, 0 )
	End Method

	Method onKeyDown:TEvent( event:TEvent )
		Print( "FORM.onKeyDown: "+event.toString() )
		If Not focused; Return event
		focused.onKey( event.data, 0 )
	End Method

	Method onKeyUp:TEvent( event:TEvent )
		Print( "FORM.onKeyUp: "+event.toString() )
		Return event
	End Method

	Method onMouseDown:TEvent( event:TEvent )
		
		' Only interested in button 1
		If event.data <> 1; Return Null
		' Get widget under button
		pressed = getWidgetAt( event.x, event.y )
		If Not pressed; Return Null
		'
		pressed.onMouseDown(event.x, event.y)
		'
		' Deal with Focus
		If focused; focused.onLoseFocus( event.x, event.y )
		focused = pressed
		focused.onGetFocus( event.x, event.y )
	End Method
		
	Method onMouseMove:TEvent( event:TEvent )
		If dragged
			dragged.onDrag( event.x, event.y )
			Return Null
		End If

		Local widget:TWidget

		' Mouseover / Hover!
		If hovered; widget = hovered.getWidgetAt( event.x, event.y )
		If Not widget; widget = getWidgetAt( event.x, event.y )
		If (widget And widget <> hovered) Or (Not widget And hovered)
			If hovered
				hovered.onMouseLeave(event.x, event.y)
				'emit( EVENT_MOUSELEAVE, hovered )
				TGUISys.emit( EVENT_MOUSELEAVE, hovered, Self )
			End If
			If widget
				widget.onMouseEnter(event.x, event.y)
				'emit( EVENT_MOUSEENTER, widget )
				TGUISys.emit( EVENT_MOUSEENTER, widget, Self )
			End If
			hovered = widget
		End If
		If hovered; hovered.onMouseMove(event.x, event.y)
		
	End Method

	Method onMouseUp:TEvent( event:TEvent )
		' Only interested in button 1
		If event.data <> 1; Return Null
		If Not pressed; Return Null
		' Get widget under button
		Local widget:TWidget = getWidgetAt( event.x, event.y )
		If pressed; pressed.onMouseUp( event.x, event.y )
		If Not widget; Return Null
		If widget = pressed
			' Mouse CLick event
			'emit( EVENT_WIDGETCLICK, pressed )
			TGUISys.emit( EVENT_WIDGETCLICK, pressed, Self )
			pressed.onMouseClick(event.x, event.y)
		End If
		pressed = Null
	End Method

	' Resize form to fit its components
	Method pack()
		'DebugStop
		If Not layout; setLayout( New TBoxLayout() )
		
		' Refresh style, applying margins etc!
		If Not stylesheet; stylesheet = New TStylesheet()
		_refreshStyle( stylesheet )
		
		Local size:TDimension = layout.getMinimumSize()
		Local pos:SPoint = New SPoint( xpos, ypos )
		
		' A Form aligns to given position, or centre
		If xpos = AUTO; pos.x = ( GraphicsWidth() - size.width ) /2 '* alignSelf.x
		If ypos = AUTO; pos.y = ( GraphicsHeight() - size.height ) /2 '* alignSelf.y
		
		' Resize the form
		Local rect:SRectangle = New SRectangle( pos, size )
		_setInner( rect )
		
	End Method
	
	' Helper function - You should really use setFlag( FLAG_HIDDEN )
	Method quit()
		setflag( FLAG_HIDDEN )
	End Method
	
'	Method resize()
'		pack()
'		layout.run()
'		invalid = False
'	End Method
	
	' Forms render differently than containers
	'
	Method render()
		'DebugStop
		bounds.fill( palette[ COLOR.BORDER ] )
		outer.fill( palette[ COLOR.SURFACE ] )
		'inner.fill( palette[ BACKGROUND ] )
		Super.render()
	End Method
	
	' Set a function handler to receive events
	Method setHandler( handler( event:Int, widget:TWidget, data:Object ) )
		'Self.handler = handler
		TGUISys.register( handler )
	End Method

	Method setHandler( handler:IForm )
		'Self.handler = handler
		TGUISys.register( handler )
	End Method

	Method setPos( x:Int, y:Int )
		xpos = x
		ypos = y
	End Method
	
	Method show:TForm( modal:Int = False, opacity:Float=0.7 )
		DebugLog( "SHOW()" )
		
		' Save application settings
		Local alpha:Int = GetAlpha()
		Local blend:Int = GetBlend()

		SetBlend( ALPHABLEND )
		
		' Draw modal background
		Self.modal = modal
		If modal
			SetAlpha( opacity )
			SetColor( 0, 0, 0 )
			DrawRect( 0, 0, GraphicsWidth(), GraphicsHeight() )
		EndIf 	
		
		' Validate tree
		DebugStop
		If flags.isset( FLAG_INVALID )
			validate()
			'layout.run()
			'invalid = False
		End If
		'If invalid; resize()
		
		' Draw tree
		'DebugStop
		render()
		
		' Restore application settings
		SetAlpha( alpha )
		SetBlend( blend )
		
		' Return null if quit flag set
		If flags.isset( FLAG_HIDDEN ); Return Null
		Return Self
	End Method
	
'	Method colour( state:Int, isTrue:Int, isFalse:Int )
'		If state
'			SetColor( palette[ isTrue ] )
'		Else
'			SetColor( palette[ isFalse ] )
'		End If
'	End Method
	
	Function iif:String( state:Int, isTrue:String, isFalse:String )
		If state Return isTrue Else Return isFalse
	End Function

	Function iif:SColor8( state:Int, isTrue:SColor8, isFalse:SColor8 )
		If state Return isTrue Else Return isFalse
	End Function
	
'	Method stringRepeat:String( char:String, count:Int )
'		Return " "[..count].Replace(" ",char)
'	End Method

	' Depreciated in version 0.6 in favour of stylesheet
	'Method _SetPalette( element:Int, color:Int )
	'	Assert element >=0 And element < palette.length, "Invalid colour element"
	'	Self.palette[ element ] = New SColor8( color )
	'End Method

	' Depreciated in version 0.6 in favour of stylesheet
	'Method _setPalette( palette:Int[] )
	'	Assert palette.length = Self.palette.length, "Invalid palette"
	'	For Local element:Int = 0 Until palette.length
	'		_SetPalette( element, palette[element] )
	'	Next
	'End Method
	
'	Function boundscheck:Int( x:Int, y:Int, w:Int, h:Int )
'		If MouseX()>x And MouseY()>y And MouseX()<x+w And MouseY()<y+h; Return True
'		Return False
'	End Function
	
	'Method drawborder( colour:Int, x:Int, y:Int, w:Int, h:Int )
	'	SetColor( palette[ colour ] )
	'	DrawLine( x,     y,     x+w-1, y )
	'	DrawLine( x+w-1, y,     x+w-1, y+h-1 )
	'	DrawLine( x+w-1, y+h-1, x,     y+h-1 )
	'	DrawLine( x,     y+h-1, x,     y )
	'End Method
	
	'Method hasfocus:Int( fld:TFormField )
	'	Return (focus = fld)
	'End Method
	
	'Method setfocus( fld:TFormField )
	'	focus = fld	
	'End Method
	
	'Method Disable( caption:String )
    '    For Local r:TFormField = EachIn fields
    '        If r.caption=caption Then r.disable=True
    '    Next
    'End Method

    'Method Enable( caption:String )
    '    For Local r:TFormField=EachIn fields
    '        If r.caption=caption Then r.disable=False
    '    Next
    'End Method
	
End Type

Rem
' Draw a default widget - Must return client area
Function _DrawWidget:SRectangle( form:TForm, widget:TFormField, shape:SRectangle )
	'DebugStop
	'Local area:SRectangle
	' BORDER
	'SetColor( widget.colors[ ST_BORDER ] )
	'area = shape.minus( widget.margin )
	'DrawRect( area.x, area.y, area.width, area.height )
	widget.outer.fill( widget.colors[ ST_BORDER ] )
	' BACKGROUND
	'SetColor( widget.colors[ ST_BACKGROUND ] )
	'area = area.minus( widget.border )
	'DrawRect( area.x, area.y, area.width, area.height )
	widget.inner.fill( widget.colors[ ST_BACKGROUND ] )
	' PADDING
	'Return area.minus( widget.padding )
	Return widget.inner
End Function

Function _DrawCaption:SRectangle( form:TForm, fld:TFormField, shape:SRectangle )
	SetColor( fld.colors[ ST_FOREGROUND ] )
	DrawText( fld.caption, shape.x, shape.y )
End Function

Function _DrawEditBox:SRectangle( form:TForm, fld:TFormField, shape:SRectangle )
	Const BLINKSPEED:Int = 500
	Global cursorstate:Int = False
	Global cursortimer:Int = 0
	Global cursorpos:Int
	
	' Flash Cursor
	If MilliSecs() > cursortimer
		cursorstate = Not cursorstate
		cursortimer = MilliSecs() + BLINKSPEED 
	End If	

	SetColor( fld.colors[ ST_FOREGROUND ] )
	DrawText( fld.value, shape.x, shape.y )
	
	' Cursor
	If form.hasfocus( fld )
		If KeyHit( KEY_HOME ); cursorpos = 0
		If KeyHit( KEY_END ); cursorpos = fld.value.length
		If KeyHit( KEY_LEFT ); cursorpos :- 1
		If KeyHit( KEY_RIGHT ); cursorpos :+ 1
		cursorpos = Max( 0, Min( cursorpos, fld.value.length ))	' Bounds validation
		If KeyHit( KEY_DELETE ); fld.value = fld.value[..cursorpos]+fld.value[cursorpos+1..]
		If KeyHit( KEY_BACKSPACE )
			fld.value = fld.value[..cursorpos-1]+fld.value[cursorpos..]
			cursorpos = Max(cursorpos-1,0)
		End If
		Local key:Int = GetChar()
		If key>31 And key<127
			'DebugStop
			fld.value = fld.value[..cursorpos]+Chr(key)+fld.value[cursorpos..]
			cursorpos :+ 1
		End If
		' Draw cursor
		If cursorstate
			SetColor( fld.colors[ ST_FOREGROUND ] )
			'colour( inside, ONPRIMARY, ONSURFACE )
		Else
			SetColor( fld.colors[ ST_FOREGROUND ] )
			'colour( fld.disable, DISABLED, SURFACE )
		End If
		Local offset:Int = TextWidth( fld.value[..cursorpos] )
		DrawLine( shape.x+offset, shape.y+2, shape.x+offset, shape.y+shape.height-2 )

	End If	
	
End Function
End Rem

' A Container that is used by Radio buttons
' By default it draws a 1px margin, but is otherwise
' invisible
Type TGroup Extends TContainer 'Implements IComponent

	'Method getMinimumSize:TDimension()
	'	Return Super.getMinimumSize()
	'End Method

	Method render()
		'bounds.fill( palette[ COLOR.SURFACE ] )
		outer.fill( palette[ COLOR.SURFACE ] )
		outer.outline( palette[ COLOR.BORDER ] )
		Super.render()
	End Method
	
End Type

Type TLabel Extends TWidget 'Implements IComponent

	Method New( caption:String="" )
		Self.caption = caption
	End Method

	Protected
	
	' Get minimum size of widget
	' This must include margin and padding
	Method getMinimumSize:TDimension()
		' User provided minimum size
		If minsize; Return minsize
		' Use size of content
		Return New TDimension( TextWidth( caption )+whitespaceX(), TextHeight( caption )+whitespaceY() )
	End Method

	Method render()
		bounds.fill( palette[ COLOR.BORDER ] )
		outer.fill( palette[ COLOR.SURFACE ] )
		Local pos:SPoint = getTextPos( caption )
		SetAlpha( palette[COLOR.FOREGROUND].a/256.0 )
		SetColor( palette[COLOR.FOREGROUND] )
		DrawText( caption, pos.x, pos.y )
	End Method
	
	' To validate, we must reset our minimum size
	Method validate()
		Super.validate()
'		setSize( TextWidth( caption ), TextHeight( caption ) )
	End Method
	
End Type

Type TPanel Extends TContainer 'Implements IComponent

	Method getMinimumSize:TDimension()
		'DebugStop
		Return Super.getMinimumSize()
	End Method

	Method render()
		bounds.fill( palette[ COLOR.BORDER ] )
		outer.fill( palette[ COLOR.SURFACE ] )
		Super.render()
	End Method
	
End Type

Type TProgressBar Extends TWidget 'Implements IComponent

	Const MINIMUM_WIDTH:Int = 100

	' Value and range
	Field lo:Int = 0	' Minimum value
	Field hi:Int		' Maximum value
	Field value:Int			' Current value
	
	Field size:SPoint		' Size of slider
	
	Field handle:SRectangle = New SRectangle()
		
	Method New( lo:Int, hi:Int, value:Int=0 )
		Self.lo = lo
		Self.hi = hi
		Self.valueint = value
		size.y = TextHeight( "8p" )
		size.x = MINIMUM_WIDTH
		calcHandle()
	End Method
	
	' Get minimum size of widget
	' This must include margin and padding
	Method getMinimumSize:TDimension()
		' User provided minimum size
		If minsize; Return minsize
		' Use size of content
		Return New TDimension( TextWidth( value )+whitespaceX(), TextHeight( value )+whitespaceY() )
	End Method

	Method render()
	'DebugStop
		If value<>valueint; calchandle()
		' Draw border (Only visible if margin>0)
		bounds.outline( palette[ COLOR.BORDER ] )
		' Draw surface
		outer.fill( palette[ COLOR.SURFACE ] )
		' Draw handle
		handle.fill( palette[ COLOR.VARIANT ] )	
		' Draw Text
		Local pos:SPoint = getTextPos( value )
		SetAlpha( palette[COLOR.FOREGROUND].a/256.0 )
		SetColor( palette[COLOR.FOREGROUND] )
		DrawText( value, pos.x, pos.y )			
	End Method

	Private

	Method calcHandle()
		value = Max(lo,Min(hi,valueint))	' Get value from TWidget
		Local pixPerInt:Int = inner.width/(hi-lo)
		Local width:Int = pixPerInt*(value-lo)
		handle.x = inner.x
		handle.y = inner.y
		handle.width  = width
		handle.height = inner.height
	End Method
		
End Type

Type TRadioButton Extends TToggle 'Implements IComponent

	Field value:Int
	
	Method New( caption:String, state:Int=0 )
		Self.caption = caption
		value = state
		'
		size = TextHeight( "8p" )
	End Method
	
	Method onMouseDown( x:Int, y:Int )
		Print( "TOGGLE.onMouseDown: "+name )
		parent.valueint = value
	End Method
	
	Method render()
		' Draw border (Only visible if margin>0)
		bounds.outline( palette[ COLOR.BORDER ] )
		' Background
		outer.fill( palette[ COLOR.SURFACE ] )
		' Toggle box
		SetAlpha( palette[ COLOR.VARIANT].a/256.0 )
		SetColor( palette[ COLOR.VARIANT ] )
		DrawOval( toggle.x, toggle.y, toggle.width, toggle.height )
		' handle
		If parent.valueint = value
			SetAlpha( palette[ COLOR.FOREGROUND ].a/256.0 )
			SetColor( palette[ COLOR.FOREGROUND ] )
			DrawOval( handle.x, handle.y, handle.width, handle.height )
		End If
		'
		Local pos:SPoint = getTextPos( caption, label )
		SetAlpha( palette[COLOR.FOREGROUND].a/256.0 )
		SetColor( palette[COLOR.FOREGROUND] )
		DrawText( caption, pos.x, pos.y )
	End Method
		
End Type

Type TSlider Extends TWidget 'Implements IComponent

	Const MINIMUM_WIDTH:Int = 100

	' Value and range
	Field lo:Int = 0	' Minimum value
	Field hi:Int		' Maximum value
	Field value:Int			' Current value
	
	'Field size:SPoint		' Size of slider
	
	'Field dragging:Int = False
	Field handle:SRectangle = New SRectangle()
	
	Field minhandlewidth:Int = 15
	
	Method New( lo:Int, hi:Int, value:Int=0 )
		Self.lo = lo
		Self.hi = hi
		valueint = value
		'size.y = TextHeight( "8p" )
		'size.x = MINIMUM_WIDTH
		calcHandle()
	End Method
	
	' Get minimum size of widget
	' This must include margin and padding
	Method getMinimumSize:TDimension()
		' User provided minimum size
		If minsize; Return minsize
		' Use size of content
		Return New TDimension( TextWidth( value )+whitespaceX(), TextHeight( value )+whitespaceY() )
	End Method

	Method onMouseDown( x:Int, y:Int )
		Super.onMouseDown(x,y)
		Print( "SLIDER.onMouseDown: "+name )
		'DebugStop
		snapTomouse( x, y )
	End Method

	Method onMouseMove( x:Int, y:Int )
		If FlagSet( FLAG_PRESSED ); snapTomouse( x, y )
	End Method
	
	Method render()
		If value <> valueint
			value = valueint
			'TForm.emit( EVENT_TEXTCHANGED, Self )	'TODO
		End If
		' Draw border (Only visible if margin>0)
		bounds.outline( palette[ COLOR.BORDER ] )
		' Draw surface
		outer.fill( palette[ COLOR.SURFACE ] )
		' Draw handle
		calcHandle()
		handle.fill( palette[ COLOR.VARIANT ] )
		' Draw Text
		Local pos:SPoint = getTextPos( valueint )
		SetAlpha( palette[COLOR.FOREGROUND].a/256.0 )
		SetColor( palette[COLOR.FOREGROUND] )
		DrawText( value, pos.x, pos.y )			
		
	End Method

	Private

	Method calcHandle()
		handle.x = inner.x + inner.width/(hi-lo)*(valueint-lo) 
		handle.y = inner.y
		handle.width = Min( minhandlewidth, inner.width/(hi-lo) )
		handle.height = inner.height
	End Method

	Method snapToMouse( mx:Int, my:Int )
		Local pos:Int = Min( inner.width, Max(0, mx - inner.x ))
		valueint = lo+(Float(pos)/Float(inner.width)*Float(hi-lo))
		calcHandle()
	End Method
		
End Type

Type TTextBox Extends TWidget 'Implements IComponent

	Field value:String			' Saved value (used for TEXTCHANGE event)
	Field length:Int = 20		' Default size of a textbox

	Field cursor:Int			' Cursor position
	Field offset:Int			' Cursor offset
	
	Method New( value:String="" )
		Self.value = value
	End Method

	Method New( value:String, caption:String )
		Self.caption = caption
		Self.valuestr = value
	End Method
	
	' Get minimum size of widget
	' This must include margin and padding
	Method getMinimumSize:TDimension()
		' User provided minimum size
		If minsize; Return minsize
		' Use textbox size in characters
		Local w:Int = TextWidth( "w"[..length] )+whitespaceX()
		Local h:Int = TextHeight( "8y" )+whitespaceY()
		Return New TDimension( w,h )
	End Method

	' User has pressed a key
	' Control keys will send code, ascii keys send char
	Method onKey( code:Int, key:Int )
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
				cursor = valuestr.length
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
			cursor = Max( 0, Min( cursor, valuestr.length ))
			
			' Fit text to box
			'DebugStop
			Print( offset+","+cursor+": "+TextWidth( valuestr[offset..cursor])+"=="+inner.width )
			While TextWidth( valuestr[offset..cursor] ) >= inner.width
				'DebugStop
				offset :+ 1
			Wend 
			If cursor<offset; offset=cursor

		End If
	End Method

	Method render()
		If value <> valuestr
			value = valuestr
			'TForm.emit( EVENT_TEXTCHANGED, Self )	'TODO
			TGUISys.Emit( EVENT_WIDGETCHANGED, Self, Null )
		End If
		' Draw border (Only visible if margin>0)
		bounds.outline( palette[ COLOR.BORDER ] )
		' Draw surface
		outer.fill( palette[ COLOR.SURFACE ] )
		
		' Draw content
		setClipArea()
		Local pos:SPoint
		If value = ""
			pos = getTextPos( caption )
			SetAlpha( palette[COLOR.VARIANT].a/256.0 )
			SetColor( palette[COLOR.VARIANT] )
			'DebugStop
			DrawText( caption, pos.x, pos.y )
		Else
			pos = getTextPos( value )
			SetAlpha( palette[COLOR.FOREGROUND].a/256.0 )
			SetColor( palette[COLOR.FOREGROUND] )
			DrawText( valuestr[offset..], pos.x, pos.y )
		End If
		setClipArea( False )
		
		If FlagSet( FLAG_FOCUS ) And TGUISys.cursorState
		'DebugStop
			Local pos:Int = TextWidth( value[offset..cursor] )
			'If insertmode
			SetAlpha( palette[ COLOR.CURSOR ].a/256.0 )
			SetColor( palette[ COLOR.CURSOR ] )
			DrawLine( inner.x+pos, inner.y, inner.x+pos, inner.y+inner.height-1)
		End If
		
	End Method

End Type

Type TToggle Extends TWidget 'Implements IComponent

	Field size:Int	
	Field label:SRectangle
	Field toggle:SRectangle
	Field handle:SRectangle

	' Resize self
'	Method setInner( rect:SRectangle, update:Int = False )
'	'DebugStop
'		Super.setInner( rect, update )
'		label = rect
'		label.x :+ size + whitespaceX()
'		label.width :- size + whitespaceX()
'		'
'		toggle = rect
'		toggle.width = toggle.height
'		handle = toggle
'		handle.shrink( 4 )
'		
'	End Method
	
	' Get minimum size of widget
	' This must include margin and padding
	Method getMinimumSize:TDimension()
		' User provided minimum size
		If minsize; Return minsize
		' Use size of content
		Return New TDimension( TextWidth( caption )+whitespaceX(), TextHeight( caption )+whitespaceY() )
	End Method
	
	Method render() Abstract
	
End Type

'Type TLayout

'	Method run( form:TForm ); End Method
'	Method run( form:TContainer, resize:Int = False ); End Method
	
'End Type

Interface ILayout
	Method run()
	Method invalidate()
	Method getMinimumSize:TDimension()
	Method setParent( container:TContainer )
End Interface

' A Very simple layout
Rem
Type TInspectorLayout Extends TLayout Implements ILayout

	Const COLUMNS:Int = 3
	
	Method run( form:TForm )
		Local widths:Int[]
		Local heights:Int[]
		Local xsum:Int[]		' Compound X Positions
		Local ysum:Int[]		' Compound Y positions
		If form.fields.count() = 0; Return
		
		widths = New Int[ COLUMNS ]
		heights = New Int[ 1 + ( form.fields.count()-1 ) / COLUMNS ]
		xsum = New Int[ COLUMNS+1 ]
		ysum = New Int[ 2 + ( form.fields.count()-1 ) / COLUMNS ]

		'Local xpos:Int[] = New Int[ widths.length*heights.length ]
		'Local ypos:Int[] = New Int[ widths.length*heights.length ]
		
		' Loop through gadgets, obtaining the dimensions
		Local id:Int = 0, col:Int, row:Int
		'DebugStop
		For Local widget:TFormField = EachIn form.fields
			col = ( id Mod COLUMNS )
			row = ( id / COLUMNS )
			widths[col]  = Max( widths[col], widget.getWidth() )
			heights[row] = Max( heights[row], widget.getHeight() )
			id :+ 1
		Next

		' Calculate space required by form
		Local minheight:Int, minwidth:Int
		For Local h:Int = 0 Until heights.length
			minheight :+ heights[h]
			ysum[h+1] = ysum[h]+heights[h]
		Next
		For Local w:Int = 0 Until widths.length
			minwidth :+ widths[w]
			xsum[w+1] = xsum[w]+widths[w]
		Next
				
		' Set the size of the form
		form.height = minheight + form.margin.T*2 + form.PADDING.T*(heights.length-1)
		form.width = minwidth + form.margin.L*2 + form.padding.L*(COLUMNS-1)
		
		' Centralise form (if Required )
		'Print( Hex(flag) )
		If ( form.flag & form._CENTRE_ )
			form.xpos = (GraphicsWidth()-form.width)/2
			form.ypos = (GraphicsHeight()-form.height)/2		
		End If
		
		' Loop through gadgets, setting their positions
		Local y:Int = form.ypos + form.margin.T
		Local x:Int = form.xpos + form.margin.L
		id = 0
		For Local widget:TFormField = EachIn form.fields
			col = id Mod COLUMNS 
			row = id / COLUMNS
			widget.setShape( x+xsum[col], y+ysum[row], widths[col], heights[row] )
			id :+ 1
		Next
	
	End Method

	Method run()
	End Method
	Method invalidate()
	End Method
	Method getMinimumSize:TDimension()
	End Method
	
End Type
EndRem



Type TBoxLayout Implements ILayout
	
	Field container:TContainer
	Field direction:Int = LAYOUT_VERTICAL
	
	Field children:TWidgetArray
	Field childRect:SRectangle[]	' Calculated size and position of children
	Field minsize:TDimension		' Minimum size required for this container
	Field sumsize:TDimension		' Sum of sizes (Compound)
	Field childExpands:SPoint[]		' Expansion bids for children
	Field expansion:Spoint			' Total expansion bids
	
	'Method New()
	'	Assert False, "TBoxLayout arguments are not optional" 
	'End Method
	
	Method New( direction:Int = LAYOUT_VERTICAL )
		'container = form
		Self.direction = direction
		'children = New TWidgetArray()
	End Method
		
	' This calculates the containers size if not already calculated.
	Method _getMinimumSize:TDimension()
		Assert container<>Null, "setParent() has not been called"
		
		' Do not recalculate if we already have the information
		If minsize; Return minsize
		
		' Allocate fields
		children     = container.getChildren()
		childRect    = New SRectangle[ children.count() ]
		childExpands = New SPoint[ children.count() ]
		minsize      = New TDimension()
		sumsize      = New TDimension()
		expansion    = New SPoint()
		
		' calculate minimum size
		For Local index:Int = 0 Until children.count()
			' Save the minimum size of the child
'Print children[index].name
			'DebugStop
			Local size:TDimension = children[index]._getMinimumSize()
			'childRect[index].setSize( children[index]._getMinimumSize() )
			'childRect[index].setSize( size )
			childRect[Index].width = size.width
			childRect[Index].height = size.height
			
			' Calculate minimum size
			If direction = LAYOUT_HORIZONTAL
				' Minimum Height is height of tallest child
				' Minimum Width is sum of children widths
				minsize.height = Max( minsize.height, childRect[index].height )
				minsize.width :+ childRect[index].width				
			Else	' VERTICAL
				' Minimum Height is sum of children heights
				' Minimum Width is width of widest child
				minsize.height :+ childRect[index].height
				minsize.width = Max( minsize.width, childRect[index].width )
			End If
			
			' Calculate compound size
			sumsize.height :+ childRect[index].height
			sumsize.width  :+ childRect[index].width
			
			' Get expansion bids and total
			childExpands[ index ] = children[index].getExpand()
			expansion.x :+ childExpands[index].x
			expansion.y :+ childExpands[index].y
		Next
		
		' Add whitespace
		minsize.width :+ container.whitespaceX()
		minsize.height :+ container.whitespaceY()
		
		Return minsize
	End Method

	Method invalidate()
		' Remove old data
		If children; children.clear()
		childRect = Null
		childExpands = Null
		minsize = Null
		sumsize = Null
	End Method

	' Layout children within the container area
	Method run()
		Assert container<>Null, "setParent() has not been called"

		' ALL CHILDREN GET SAME SPACE AT THE MOMENT
		' LATER WE WILL ADD EXPAND / MAXIMUMSIZE
		
		' A Box layout is a 1 column/row grid, so we can use this
		' for a multi column/row grid at a later time

		Local rect:SRectangle = container.getInner()

		If direction = LAYOUT_HORIZONTAL
			distributeHorizontally( rect )
		Else	' VERTICAL
			distributeVertically( rect )
		End If
		
		reposition()
	End Method
	
	' Distribute space horizontally
	Method distributeHorizontally( rect:SRectangle )
		
		' Calculate surplus space inside container
		'Local surplus:Int = minsize.width - sumsize.width
		Local surplus:Int = rect.width - sumsize.width
		
		' If we dont have space, turn on scrollbars or something!
'		If surplus < 0; Return
' TODO: Auto Scrollbars?
'		End If	
		'If surplus <= 0 ; Return
		
		'# Get the allocation for each bid
		Local bidsize:Float
		If surplus>0 And expansion.x>0; bidsize = surplus / expansion.x
			
		'# Calculate child size by splitting surplus between bidders
		Local xpos:Int = container.inner.x
		Local ypos:Int = container.inner.y
		For Local index:Int = 0 Until children.count()
			
			' Check if this child expands
			If childExpands[index].x > 0 And bidsize > 0
				
				' Add allocation to widget
				Local allocation:Float = bidsize * childExpands[index].x
					
				' Expand child
				childRect[index].width :+ allocation
				'available :- allocation

			End If
			
			' Position child
			childRect[index].x = xpos
			childRect[index].y = ypos
			
			' Update position
			xpos :+ childRect[index].width

			' Fill space
			childRect[index].height = minsize.height
				
			' If child is a container; ask it to layout
			'ISSUE: IT doesn;t know its size yet!
			'Local container:TContainer = TContainer( children[index] )
			'If container; container.resize()
		Next
	
	End Method

	' Distribute space vertically
	Method distributeVertically( rect:SRectangle )
		
		' Calculate surplus space inside container
		Local surplus:Int = rect.height - sumsize.height
		
		' If we dont have space, turn on scrollbars or something!
'		If surplus < 0; Return
' TODO: Auto Scrollbars?
'		End If		

		'If surplus <= 0 ; Return
		
		'# Get the allocation for each bid
		Local bidsize:Float
		If surplus>0 And expansion.y>0; bidsize = surplus / expansion.y
			
		'# Calculate child size by splitting surplus between bidders
		Local xpos:Int = container.inner.x
		Local ypos:Int = container.inner.y
		For Local index:Int = 0 Until children.count()
			
			' Check if this child expands
			If childExpands[index].y > 0 And bidsize > 0
			
				' Add allocation to widget
				Local allocation:Float = bidsize * childExpands[index].y
					
				' Expand child
				childRect[index].height :+ allocation
				'available :- allocation
				
			End If
			
			' Position child
			childRect[index].x = xpos
			childRect[index].y = ypos
			
			' Update position
			ypos :+ childRect[index].height
			
			' Fill space
			childRect[index].width = minsize.width
		
			' If child is a container; ask it to layout
			'ISSUE: IT doesn;t know its size yet!
			'Local container:TContainer = TContainer( children[index] )
			'If container; container.resize()
		Next
			
	End Method

	' Reposition children into precalculated locations
	Method reposition()
		For Local index:Int = 0 Until children.count()
			Local child:TWidget = TWidget( children[index] )
			child._setBounds( ChildRect[index] )
			' If child is a container; ask it to layout
			'Local container:TContainer = TContainer( children[index] )
			'If container; container.runLayout()
		Next
	End Method

	Method setparent( container:TContainer )
		If Self.container <> container
			Self.container = container
			invalidate()
		End If
	End Method
	
End Type

Type TGridLayout Implements ILayout
	
	Field container:TContainer
	Field direction:Int
	Field rowcount:Int, colcount:Int
	
	Field children:TWidgetArray
	Field childRect:SRectangle[]	' Calculated size and position of children
	Field minsize:TDimension		' Minimum size required for this container
	'Field sumsize:TDimension		' Sum of sizes (Compound)
	'Field childExpands:SPoint[]		' Expansion bids for children
	'Field rowexpansion:Int[]		' Total expansion bids for rows
	'Field colexpansion:Int[]		' Total expansion bids for cols

	Field cols:sLayoutMeasure[]
	Field rows:sLayoutMeasure[]
	'Field colminsize:TDimension[]		' Minimum size required for this container
	'Field colsumsize:TDimension[]		' Sum of sizes (Compound)
	'Field rowminsize:TDimension[]		' Minimum size required for this container
	'Field rowsumsize:TDimension[]		' Sum of sizes (Compound)

	Method New()
		Assert False, "TGridLayout arguments are not optional" 
	End Method

	Method New( direction:Int, size:Int )
		Self.direction = direction
		If direction = LAYOUT_HORIZONTAL
			rowcount = size
		Else ' LAYOUT_VERTICAL
			colcount = size
		End If
	End Method

	' This calculates the containers size if not already calculated.
	Method getMinimumSize:TDimension()
		Assert container<>Null, "setParent() has not been called"

		' Do not recalculate if we already have the information
		If minsize; Return minsize
		
		' Allocate fields
		children     = container.getChildren()
Print( "CHILDREN: "+children.count() )
		childRect    = New SRectangle[ children.count() ]
		'childExpands = New SPoint[ children.count() ]
		'minsize      = New TDimension()
		'sumsize      = New TDimension()
		'rowexpansion  = New Int[ rowcount ]
		'colexpansion  = New Int[ colcount ]
		
		' Calculate size of grid
		If direction = LAYOUT_HORIZONTAL
			colcount = children.count()/rowcount
		Else ' LAYOUT_VERTICAL
			rowcount = children.count()/colcount
		End If
		
		cols = New sLayoutMeasure[ colcount ]
		rows = New sLayoutMeasure[ rowcount ]

		'colminsize = New TDimension[ columns ]
		'rowminsize = New TDimension[ rows ]
		'colsumsize = New TDimension[ columns ]
		'rowsumsize = New TDimension[ rows ]
		
		' calculate minimum size
		For Local index:Int = 0 Until children.count()
			Local row:Int = index/colcount
			Local col:Int = index Mod colcount
			'If Not colminsize[col]; colminsize[col] = New TDimension()
			'If Not colsumsize[col]; colsumsize[col] = New TDimension()
			'If Not rowminsize[col]; rowminsize[col] = New TDimension()
			'If Not rowsumsize[col]; rowsumsize[col] = New TDimension()

			' Save the minimum size of the child
'Print children[index].name
			'DebugStop
			
			Local size:TDimension = children[index].getMinimumSize()
			'childRect[index].setSize( children[index].getMinimumSize() )
			'childRect[index].setSize( size )
			childRect[Index].width = size.width
			childRect[Index].height = size.height
			
			' Calculate minimum and compound sizes
			cols[col].minwidth = Max( cols[col].minwidth, childRect[index].width )
			'cols[col].sumwidth :+ childRect[index].width
			rows[row].minheight = Max( rows[row].minheight, childRect[index].height )
			'rows[row].compound :+ childRect[index].height
			
			' Calculate compound size
			'colsumsize[col].height :+ childRect[index].height
			'colsumsize[col].width  :+ childRect[index].width
			'rowsumsize[row].height :+ childRect[index].height
			'rowsumsize[row].width  :+ childRect[index].width
			
			' Get expansion bids and total
			'childExpands[ index ] = children[index].getExpand()
			'rowexpansion[row] :+ childExpands[index].x
			'colexpansion[col] :+ childExpands[index].y
		Next

		' Calculate size
		'DebugStop
		minsize = New TDimension(container.whitespaceX(),container.whitespaceY())
		Local total:Int = 0
		For Local col:Int = 0 Until colcount
			total :+ cols[col].minwidth
			cols[col].sumwidth = total
			minsize.width :+ cols[col].minwidth
		Next
		total = 0
		For Local row:Int = 0 Until rowcount
			total :+ rows[row].minheight
			rows[row].sumheight = total
			minsize.height :+ rows[row].minheight
		Next

		Return minsize
	End Method

	Method invalidate()
		' Remove old data
		If children; children.clear()
		childRect = Null
		'childExpands = Null
		minsize = Null
		'sumsize = Null
	End Method
		
	' Layout children within the container area
	Method run()
		Assert container<>Null, "setParent() has not been called"

		' ALL CHILDREN GET SAME SPACE AT THE MOMENT
		' LATER WE WILL ADD EXPAND / MAXIMUMSIZE
		
		' A Box layout is a 1 column/row grid, so we can use this
		' for a multi column/row grid at a later time

		Local rect:SRectangle = container.getInner()
	
		If direction = LAYOUT_HORIZONTAL
			distributeHorizontally( rect )
		Else	' VERTICAL
			distributeVertically( rect )
		End If
		
		reposition()
	
	End Method

	' Distribute space horizontally
	Method distributeHorizontally( rect:SRectangle )
		Local surplus:Int = rect.height-minsize.height

		' Distribute evenly
		Local rowheight:Int = rect.height/rowcount
		For Local row:Int = 0 Until rowcount
			rows[row].height = rowheight
		Next
	End Method
	
	' Distribute space vertically
	Method distributeVertically( rect:SRectangle )
	
		' Calculate surplus space inside container
		'Local surplus:SPoint = New SPoint( rect.width-minsize.width, rect.height-minsize.height )
		
		' If we dont have space, turn on scrollbars or something!
'		If surplus < 0; Return
' TODO: Auto Scrollbars?
'		End If

		' Allocate space to each row and column
		'If expand>0, they will expand
		'If New size>component maximum, that wil be their maximum
		'If New size<minimum, they will get zero
		
		'For VERITICAL, ONLY WIDTHS SHOULD GROW
		'For HORIZONTAL, ONLY HEIGHTS SHOULD GROW
		
' TODO: Add support for row/column minimum and maximum sizes
' because you may have a column you dont want to expand.
'DebugStop
		Local surplus:Int = rect.width-minsize.width

'minsize And rect are different. This should Not happen. the difference is the whitespace.
		
		' Distribute evenly
		Local colwidth:Int = rect.width/colcount
		For Local col:Int = 0 Until colcount
			cols[col].width = colwidth
		Next
		
		Local xpos:Int = container.inner.x
		Local ypos:Int = container.inner.y

		'Print "Parent @ ("+xpos+","+ypos+")"
		
		For Local index:Int = 0 Until children.count()
			Local row:Int = index/colcount
			Local col:Int = index Mod colcount

			' Expand child
			childRect[index].width = cols[col].minwidth
			childRect[index].height = rows[row].minheight
			
			' Position child
			'DebugStop
			Local x:Int = cols[col].sumwidth - cols[col].minwidth
			Local y:Int = rows[row].sumheight - rows[row].minheight
			childRect[index].x = xpos + x
			childRect[index].y = ypos + y
			'Print children[index].GetName()+" @ ("+childRect[index].x+","+childRect[index].y+")"
			
			' Update position
			'ypos :+ childRect[index].height
			
			' Fill space
			'childRect[index].width = minsize.width
		
		Next
			
	End Method

	' Reposition children into precalculated locations
	Method reposition()
		For Local index:Int = 0 Until children.count()
			Local child:TWidget = TWidget( children[index] )
			child.setBounds( ChildRect[index] )
			' If child is a container; ask it to layout
			Local container:TContainer = TContainer( children[index] )
			If container; container.runLayout()
		Next
	End Method

	Method setparent( container:TContainer )
		If Self.container <> container
			Self.container = container
			invalidate()
		End If
	End Method
	
End Type

Interface IStyleable
	Method GetName:String()
	Method GetClassList:String[]()
	Method flagset:Int( flag:Int )
	Method setAlignSelf( horz:Float, vert:Float )
	Method setAlignContent( horz:Float, vert:Float )
	Method setMargin( edges:SEdges )
	Method setPadding( edges:SEdges )
	Method _setPalette( id:Int, color:SColor8 )
End Interface

' TLookup<V> is an Array-backed map that keeps your data in
' the order you insert it and doesn't sort it by key or hash 
' like TMap, TStringMap or TTreeMap do.

Type TLookup<V>

	Field list:String[]
	'Field index:String[]	' Hashed index
	Field data:V[]
	Field total:Int
	Field size:Int = 0		' Number of records

	Field stepsize:Int = 50
	
	Method New()
	End Method

	Method add( key:String, value:V )
'DebugStop
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
		Local id:Int = find( key, False )
		If id <0 Or id > total; Return Null
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
	Field width:Int = AUTO
	Field height:Int = AUTO
	
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
'DebugStop
		stylesheet = New TLookup<TMap>()
		parse( raw )
	End Method
	
	Method apply( widget:IStyleable )
		Local debugger:Int = False	' Stylesheet debugger

		' Get widget details
		Local typeid:TTypeId   = TTypeId.forObject( widget )
		Local typename:String  = Lower( typeid.name() )
		Local name:String      = Lower( widget.GetName() )

'If widget.GetName() = "btnok"; debugger = True
'If typeid.name() = "TGroup"; debugger = True
'If debugger; DebugStop

		' Style is an index into stylesheet
		Local styleindex:Int[] = New Int[ stylesheet.count() ]
		If debugger; Print( "STYLESHEET.APPLY( " + name + " ): " + typeid.name() )
		
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

		' Create a local style that will be applied
		Local style:SStyle = New SStyle()

		' Loop through style index
		For Local index:Int = 0 Until styleIndex.length

			If Not styleIndex[index]; Continue
			' Get the sheet for this index
			Local sheet:TMap = TMap( stylesheet[index] )

			' Apply styles
			For Local property:String = EachIn sheet.keys()
			
				Local value:String = String( MapValueForKey( sheet, property ) )
				If debugger; Print( "- "+property+"="+value )
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
					style.palette[ COLOR.CURSOR ] = value
					'SetColour( widget, COLOR.CURSOR, value )
				Case "height"
					style.height = Int( value )
				Case "margin"
					'DebugStop
					style.margin = ExtractEdges( Lower(value) )
					'widget.setMargin( ExtractEdges( Lower(value) ) )
				Case "padding"
					'DebugStop
					style.padding = ExtractEdges( Lower(value) )
					'widget.setPadding( ExtractEdges( Lower(value) ) )
				Case "text-align"
					'DebugStop
					Local temp:Float[] = ExtractAlignment( Lower(value) )
					style.alignContent = ExtractAlignment( Lower(value) )
					'Local align:Float[] = ExtractAlignment( Lower(value) )
					'widget.setAlignContent( align[0], align[1] )
					'DebugStop
				Case "variant", "variant"
					style.palette[ COLOR.VARIANT ] = value
					'SetColour( widget, COLOR.VARIANT, value )
				Case "width"
					style.width = Int( value )
				End Select

				' STYLESHEET DEBUGGER
				If debugger
					Print "  STYLE:"
					Print "  align-content:"+style.alignSelf[0]+","+style.alignSelf[1]
					Print "  align-self:   "+style.alignContent[0]+","+style.alignContent[1]
					Print "  margin:       "+style.margin.T+","+style.margin.R+","+style.margin.B+","+style.margin.L
					Print "  padding:      "+style.padding.T+","+style.padding.R+","+style.padding.B+","+style.padding.L
					Print "  size:         "+style.width+","+style.height
					Print "  colour:"
					For Local palette:Int = 0 Until style.palette.length
						Print( "  "+palette+". "+style.palette[palette] )
					Next
					DebugStop
				End If
			Next
		Next

		If debugger; DebugStop
		
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
			'Local ss:Object = style.stylesheet[ key ]
			'DebugStop
			stylesheet.add( key, style.stylesheet[ key ] )
		Next
	End Method
	
	Private
	
	Method extractAlignment:Float[]( text:String )
		Local items:String[] = text.split( "," )
		If items.length=1; items = text.split( " " )
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
		If edges.length=1; edges = text.split( " " )
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
'Print( ": "+selector )
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
'Print( "PARSING STYLESHEET" )
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
							DebugLog( "[STYLE ERROR] Invalid selector '"+key+"' in '"+selector+"'" )
						End If
					Next

				End If
				p=pos2+1
			End If
		Until pos1=0 Or pos2=0
		'DebugStop
		' Split out root variables
		root = TMap( stylesheet[":root"] )
'If root
'	For Local key:String = EachIn root.keys()
'		Print key+"="+String(root.valueforkey( key ))
'	Next
'End If
		'DebugStop
	End Method

	Method SetColour( widget:IStyleable, index:Int, value:String )
		value = Lower(value)
		If value="none"
			widget._setPalette( index, New SColor8( 0,0,0,0 ) )	' Invisible
		Else
			widget._setPalette( index, ExtractColour( value ) )
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

' DUE TO A BUG SOMEWHERE, LINE NUMBERS ARE MISREPORTED BELOW A MULTILINE STRING

Global STYLE_DEFAULT:String = """
// Default Stylesheet

// Define colour scheme
// Material Design Colours
// https://m2.material.io/design/color/the-color-system.html#tools-For-picking-colors

:root {
  --Blue50: #E3F2FD;
  --Blue100: #BBDEFB;
  --Blue200: #90CAF9;
  --Blue300: #64B5F6;
  --Blue400: #42A5F5;
  --Blue500: #2196F3;
  --Blue600: #1E88E5;
  --Blue700: #1976D2;
  --Blue800: #1565C0;
  --Blue900: #0D47A1;

  --Background: #E5E5E5;
  --Surface:    #FFFFFF;
  --Error:      #B00020;
  --OnError:    #FFFFFF;
}
* {
  margin: 1;
  padding: 2;
  color: --Blue900;
  surface: white;
  margin-color: none;
  cursor-color: --Blue900;
  variant: --Blue200;
}
TButton {
  surface: --Blue500;
  padding: 1,5;
  color: black;
  text-align: center middle;
}
TButton:hover {
  surface: --Blue300;
}
TButton:focus {
  surface: --Blue700;
}

TCheckbox {
  surface: None;
}
TForm {
  surface: --Background;
  margin: 2;
  margin-color: black;
}
TGroup {
  margin-color: --Blue100;
  surface: none;
  margin: 10;
  padding: 3;
}
TLabel {
  surface: None;
  text-align: Left,middle;
  padding:5;
}
TPanel {
  surface: #cccccc;
  margin: 0;
  padding: 3;
}
TProgressBar {
  surface: --Blue100;
  color: --Blue900;
  variant: --Blue700;
  text-align:center;
}
TRadioButton {
  surface: None;
}
TSlider {
  surface: --Blue100;
  color: --Blue900;
  variant: --Blue700;
}
TSlider:drag {
  variant: red;
}
TTextBox {
  surface: --surface;
  variant: --Blue500;	// Secondary is used For the hint
  color: --Blue700;
  text-align: Left,center;
}
TTextBox:hover {
  margin-color: --Blue900;
}
TTextBox:focus {
  margin-color: #666;
}

// Used For form headings
.title {
	surface: --Blue900;
	color: white;
	text-align: center;
}
// Used For button box
.buttonbox {
	margin: 10 0 0 0;
	padding: 3;
	surface: --blue100;
}

:disabled {
  surface: #cccccc;
  variant: #888888;
  color: #333333;
}

"""

Global STYLE_INSPECTOR:String = """
// Stylesheet used For the inspector

:root {
  --Blue50: #E3F2FD;
  --Blue100: #BBDEFB;
  --Blue200: #90CAF9;
  --Blue300: #64B5F6;
  --Blue400: #42A5F5;
  --Blue500: #2196F3;
  --Blue600: #1E88E5;
  --Blue700: #1976D2;
  --Blue800: #1565C0;
  --Blue900: #0D47A1;

  --Background: #E5E5E5;
  --Surface:    #FFFFFF;
  --Error:      #B00020;
  --OnError:    #FFFFFF;
}

* {
  margin: 1;
  padding: 2;
  color: --Blue900;
  surface: white;
  margin-color: --Background;
  cursor-color: black;
  variant: #444;
}
TButton {
  surface: --Blue500;
  padding: 1,5;
  color: black;
}
TForm {
  surface: --Background;
  margin: 2;
  margin-color: black;
  width: 250;
  height: 200;
}
TLabel:hover {
	margin-color: --Background;
}

// Used For form headings
.title {
	surface: #0D47A1;
	color: white;
	text-align: center;
	margin: 1 1 10 1;
}

:hover {
  margin-color: red;
}
:focus {
  margin-color: #2196F3;
}

"""