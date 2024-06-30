SuperStrict

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

End Rem

Global SUPPORTED_TYPES:String[] = ["button","checkbox","password","radio","textbox","separator"]
' Others: color,slider,icon,dropdown,textarea,intbox
Global SUPPORTED_METADATA:String[] = ["disable","label","options","Type"]

' LAYOUT DIRECTIONS
'Const LAYOUT_NONE:Int = 0
Const LAYOUT_HORIZONTAL:Int = 1
Const LAYOUT_VERTICAL:Int = 2

' Constant used in TRBL arrays
Const NT:Int = 0
Const NR:Int = 1
Const NB:Int = 2
Const NL:Int = 3

' Constants used in Style array		LABEL	BUTTON   TEXTBOX
Const ST_BACKGROUND:Int = 0		'	n/a		SURFACE  SURFACE
Const ST_FOREGROUND:Int = 1		'	CAPTION	CAPTION  VALUE
Const ST_BORDER:Int = 2			'	n/a		n/a      BORDER
Const ST_SHADOW:Int = 3			'	n/a		n/a      n/a
Const ST_ALT:Int = 4			'	n/a		n/a      CURSOR

' Constants used in properties array
Const PR_ALIGNMENT:Int = 0

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
Const PALETTE_SIZE:Int = 10

' OTHER
Const AUTO:Int = -1

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

' EVENTS
Global EVENT_WIDGETCLICK:Int = AllocUserEventId( "Widget Clicked" )
Global EVENT_WIDGETCHANGED:Int = AllocUserEventId( "Widget Changed" )

' WIDGET ATTRIBUTE FLAGS
Global FLAG_HIDDEN:Int = $01
Global FLAG_DISABLED:Int = $02
Global FLAG_HOVER:Int = $04
Global FLAG_FOCUS:Int = $08
Global FLAG_PRESSED:Int = $10
Global FLAG_DRAG:Int = $20		' TODO:

Interface IForm
	Method onGui( event:Int, form:TForm, widget:TWidget )
End Interface

Interface IGUI
	Method onClick( id:Int, event:TEvent )
End Interface

Global PALETTE_BLUE:Int[] = [..
	$00FFFFFF,..	' NONE
	$ffc8c8c8,..	' BACKGROUND
	$ffffffff,..	' SURFACE
	$ff0D47A1,..	' PRIMARY		- BLUE 900
	$ffFF9800,..	' SECONDARY		- ORANGE 500
	$ff8a8a8a,..	' DISABLED
	$ff000000,..	' ON BACKGROUND
	$ff0D47A1,..	' ON SURFACE	- BLUE 900
	$ffffffff,..	' ON PRIMARY
	$ffffffff,..	' ON SECONDARY
	$ffffffff]		' ON DISABLED

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
	
End Struct

Struct SPoint
	Field x:Int
	Field y:Int
	
	Method New( x:Int, y:Int )
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

'DEPRECIATED
Struct SVector

	Field x:Int
	Field y:Int
	
	Method New( x:Int, y:Int )
		Self.x = x
		Self.y = y
	End Method
	
	Method add:SVector( addition:SVector )
		x :+ addition.x
		y :+ addition.y
		Return Self
	End Method

	Method add:SVector( w:Int, h:Int )
		x :+ w
		y :+ h
		Return Self
	End Method
	
End Struct

' FLAG functions
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

' A list that returns unsorted iterators
' TMap, TString and TTreeMap return sorted iterators
' See testing folder for comparison

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
		Local id:Int = find( key )
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
	
	Method find:Int( key:String )
		For Local id:Int = 0 Until size
			If list[id]=key; Return id
		Next
		' Not found
		Return size
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
		Local id:Int = find( key )
		If id > total; Return Null
		Return data[id]
	End Method
End Type

' An array-backed object to replace TWidget[]
Type TWidgetArray Extends TObjectList
	Method operator[]:TWidget( index:Int )
		Return TWidget( valueAtIndex( index ) )
	End Method
End Type

Type TGUISys
	Global cursortimer:TTimer	' System cursor timer
	Global cursorState:Int		' System cursor state
	Global handlers:TList		' Event handlers
	
	Function initialise()
		If Not cursortimer; cursortimer = CreateTimer( 2 )
		handlers = New TList()
	End Function
	
	Function register( handler:IForm )
		handlers.addlast( handler )
	End Function
	
	Function emit( event:Int, form:TForm, widget:TWidget )
		For Local handler:IForm = EachIn handlers
			handler.onGUI( event, form, widget )
		Next
		'For Local handler( event:Int, form:TForm ) = EachIn handlers
		'	handler( event, Null )
		'Next
		
	End Function
	
	
End Type
TGUISys.initialise()

Type TWidget
	Global autoincrement:Int = 0

	Private
	
	Field name:String
	Field invalid:Int = True	' Needs to be recalculated
	Field parent:TContainer
	Field runstyle:Int = True	' Style needs to be applied
	Field stylesheet:TStylesheet

	Field classlist:TSet<String>				' A bit like "class" in CSS

	Field bounds:SRectangle = New SRectangle()	' OUTSIDE SIZE
	Field outer:SRectangle
	Field inner:SRectangle
	Field cliparea:SRectangle					' See ClipArea()
	
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

	Method addClass( class:String )
		If Not classlist; classlist = New TSet<String>
		'If classlist.contains( class ); Return
		classlist.add( Lower(class) )
	End Method

	Method addClass( classes:String[] )
		If Not classlist; classlist = New TSet<String>
		'If classlist.contains( class ); Return
		For Local class:String = EachIn classes
			classlist.add( Lower(class) )
		Next
	End Method
	
	Method addStyle( style:String )
		If Not style; Return
		Local sheet:TStylesheet = New TStylesheet( style )
		stylesheet.merge( sheet )
	End Method
	' 
	Method BIT1:Int( flag:Int )
		Return flags.isset( flag )
	End Method

	Method BIT0:Int( flag:Int )
		Return Not flags.isset( flag )
	End Method
		
	' Confirm if location without bounds
	Method contains:Int( x:Int, y:Int )
		If x>bounds.x And x<bounds.x+bounds.width And y>bounds.y And y<bounds.y+bounds.height; Return True
		Return False
	End Method

	Method GetClass:String()
		Return name
	End Method
	
	' Get the client (inner) space
	Method GetInner:SRectangle()
		Return inner
	End Method

	Method getMinimumSize:TDimension()
		' User provided minimum size
		If minsize; Return minsize
		' Actual boundary size
		Return New TDimension( bounds.width, bounds.height )
	End Method

	Method GetName:String()
		Return name
	End Method
	
	' Get widget at a specific location
	Method getWidgetAt:TWidget( x:Int, y:Int )
		If contains( x, y ); Return Self
		Return Null
	End Method
	
	Method getWidgetByName:TWidget( criteria:String )
		If criteria = name; Return Self
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
		runstyle = True
	End Method

	Method onKey( code:Int, key:Int )
'		Print( "WIDGET.onKey: "+name )
	End Method

	Method onLoseFocus( x:Int, y:Int )
'		Print( "WIDGET.onLoseFocus: "+name )
		flags.unset( FLAG_FOCUS )
		runstyle = True
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
		runstyle = True
	End Method
	
	Method onMouseLeave( x:Int, y:Int )
'		Print( "WIDGET.onMouseLeave: "+name )
		flags.unset( FLAG_HOVER )
		runstyle = True
	End Method

	Method onMouseUp( x:Int, y:Int )
'		Print( "WIDGET.onMouseUp: "+name )
		flags.unset( FLAG_PRESSED )
	End Method
	
	Method removeClass( class:String )
		If Not classlist; Return
		classlist.remove( Lower(class) )
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

	' Set Attribute Flag
	Method setAttr( flag:Int, state:Int = True )
		If state
			flags.set( flag )
		Else
			flags.unset( flag )
		End If
		runstyle = True		' Force re-styling
		invalidate()
	End Method

	' Save and restore the clip area to prevent overflow
	Method setClipArea( save:Int = True )
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
	
	Method setMinSize( w:Int, h:Int )
		If minsize
			minsize.width = w
			minsize.height = h
		Else
			minsize = New TDimension( w, h )
		End If
	End Method

	' Sets a stylesheet
	Method setStyle( style:TStylesheet = Null )
		If Not style; style = New TStylesheet()
		If Not stylesheet Or style<>stylesheet
			stylesheet = style
			runstyle = True
		End If
		stylesheet.apply( Self )
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
	End Method
			
	'------------------------------------------------------------
	Protected Method __PROTECTED__() ; End Method

	Method getExpand:Spoint()
		Return expand
	End Method

	' Invalidates the widget layout
	Method invalidate()
		invalid = True
		If parent; parent.invalidate()
	End Method
		
	Method render()
		bounds.fill( New SColor8( $ffff0000 ) )
	End Method

	' Called by parent to achieve two things
	' 1. Distribute a stylesheet if child doesn't have one
	' 2. Inform child it needs to apply the stylesheet
	Method restyle( style:TStylesheet )
		If Not stylesheet Or stylesheet<> style; stylesheet = style
		stylesheet.apply( Self )
		runstyle = False	' Dont need to re-run until something changes
	End Method
	
	' Set bounds and optionally set outer and inner
	Method setBounds( rect:SRectangle, update:Int = False )
		bounds = rect
		If Not update; Return
		'DebugStop
		rect.shrink( margin )
		setOuter( rect )
		rect.shrink( padding )
		setInner( rect )
	End Method

	' Set inner size and optionally set outer and bounds
	Method setInner( rect:SRectangle, update:Int = False )
		inner = rect
		If Not update; Return
		'DebugStop
		rect.expand( padding )
		setOuter( rect )
		rect.expand( margin )
		setBounds( rect )
	End Method

	Method setMargin( all:Int ) ;        setMargin( all, all, all, all ) ; End Method
	Method setMargin( TB:Int, LR:Int ) ; setMargin( TB, LR, TB, LR ) ;     End Method
	Method setMargin( T:Int, R:Int, B:Int, L:Int )
		If margin.T=T And margin.R=R And margin.B=B And margin.L=L; Return
		margin.T = T
		margin.R = R
		margin.B = B
		margin.L = L
		invalidate()
	End Method
	Method setMargin( edges:SEdges )
		If margin.T=edges.T And margin.R=edges.R And margin.B=edges.B And margin.L=edges.L; Return
		margin = edges
		invalidate()
	End Method
	
	Method setOuter( rect:SRectangle )
		outer = rect
	End Method

	Method setPadding( all:Int ) ;        setPadding( all, all, all, all ) ; End Method
	Method setPadding( TB:Int, LR:Int ) ; setPadding( TB, LR, TB, LR ) ;     End Method
	Method setPadding( T:Int, R:Int, B:Int, L:Int )
		If padding.T=T And padding.R=R And padding.B=B And padding.L=L; Return
		padding.T = T
		padding.R = R
		padding.B = B
		padding.L = L
		invalidate()
	End Method
	Method setPadding( edges:SEdges )
		If padding.T=edges.T And padding.R=edges.R And padding.B=edges.B And padding.L=edges.L; Return
		padding = edges 
		invalidate()
	End Method
	
	' Get the widget whitespace total
	Method WhitespaceX:Int()
		Return margin.L+margin.R+padding.L+padding.R
	End Method
	
	Method WhitespaceY:Int()
		Return margin.T+margin.B+padding.T+padding.B
	End Method
		
End Type

Type TButton Extends TWidget Implements IComponent

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
		bounds.outline( palette[ TForm.BORDER ] )
		' Draw surface
		Local surface:SRectangle = outer
		If BIT1( FLAG_PRESSED )
			surface.x :+ 1
			surface.y :+ 1
		End If
		surface.fill( palette[ TForm.SURFACE ] )
		' Draw content
		Local pos:SPoint = getTextPos( caption, surface )
		SetAlpha( palette[TForm.FOREGROUND].a/256.0 )
		SetColor( palette[TForm.FOREGROUND] )
		DrawText( caption, pos.x, pos.y )
	End Method
	
End Type

Type TCheckbox Extends TToggle Implements IComponent

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
		End If
		' Draw border (Only visible if margin>0)
		bounds.outline( palette[ TForm.BORDER ] )
		' Background
		outer.fill( palette[ TForm.SURFACE ] )
		' Toggle box
		toggle.fill( palette[ TForm.VARIANT ] )
		' handle
		If state
			handle.fill( palette[ TForm.FOREGROUND ] )
		End If
		'
		Local pos:SPoint = getTextPos( caption, label )
		SetAlpha( palette[TForm.FOREGROUND].a/256.0 )
		SetColor( palette[TForm.FOREGROUND] )
		DrawText( caption, pos.x, pos.y )
	End Method
	
End Type

Type TFormField Extends TWidget
	
	' TYPE DEFINITION
	'Field owner:IForm
	Field fld:TField			' Original field (TypeGui)
	Field fldName:String		' Field name
	Field fldType:String		' Field data type (Blitzmax datatype)
	
	' METADATA
	Field datatype:String		' label, input, checkbox, etc...
	Field value:String			' state of the variable
	Field length:Int
	Field options:String[]
	Field disable:Int = False
	'
	'Field xpos:Int, ypos:Int
	Field width:Int, height:Int					' INSIDE SIZE
	
	' Composites
	Field properties:Int[] = [ ALIGN_LEFT|ALIGN_MIDDLE ]
	Field children:TList
	'Field border:Int[]  = [1,1,1,1]		'TRBL
	'Field margin:Int[]  = [1,1,1,1]		'TRBL
	'Field padding:Int[] = [1,1,1,1]		'TRBL
	'Field shadow:Int[]  = [0,0,0,0]		'TRBL
	Field shape:SRectangle = New SRectangle()	' OUTSIDE SIZE
	Field colors:SColor8[5] 
	Field _draw:SRectangle( form:TForm, fld:TFormField, shape:SRectangle )
	Field _client:SRectangle( form:TForm, fld:TFormField, shape:SRectangle )

	Method New( fieldtype:String, name:String="", value:String="" )
		autoincrement :+ 1
		Self.name = autoincrement
		If name = ""; name=fieldtype+name
		fldName  = name
		datatype = fieldtype
		Self.value = value
	End Method
	
	Method set( property:Int, value:Int )
		If properties.length < property; properties = properties[..property]
		properties[property] = value
	End Method
	
	Method getwidth:Int()
		Return width + margin.L + margin.R + padding.L + padding.R
	End Method
	
	Method getHeight:Int()
		Return height + margin.T + margin.B + padding.T + padding.B
	End Method

	Method color( slot:Int, colour:SColor8 )
		colors[slot] = colour
	End Method

	Method setPos( x:Int, y:Int, w:Int, h:Int )
		shape.x = x
		shape.y = y
	End Method

	Method setSize( w:Int, h:Int )
		shape.width = w
		shape.height = h
	End Method
	
	Method setShape( x:Int, y:Int, w:Int, h:Int )
		shape.x = x
		shape.y = y
		shape.width = w
		shape.height = h
	End Method
	
End Type

Type TContainer Extends TFormField

	Field children:TList = New TList()
	Field layout:ILayout

	' V0.6
	Method add:TWidget( widget:TWidget )
		If widget.parent; widget.invalidate()
		widget.parent = Self
		' Add to list
		children.addlast( widget )
		Return widget
	End Method
	
	Method add:TWidget( name:String, widget:TWidget )
		widget.name = name
		Return add( widget )
	End Method
		
	' A container should use a layout manager to calculate its minimum size
	Method getMinimumSize:TDimension()
		' User provided minimum size
		If minsize; Return minsize
		If Not layout; layout = New TBoxLayout( Self )
		Return layout.getMinimumSize()
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
		If criteria = name; Return Self
		For Local child:TWidget = EachIn children
			found = child.getWidgetByName( criteria )
			If found; Return found
		Next
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

	' Sets a layout
	Method setLayout( layout:Int )
		Select layout
		Case LAYOUT_HORIZONTAL, LAYOUT_VERTICAL
			setLayout( New TBoxLayout( Self, layout ) )
		End Select
	End Method
	
	Method setLayout( layout:ILayout )
		Self.layout = layout
		invalidate()
	End Method

	' Sets a stylesheet
	Method setStyle( style:TStylesheet = Null )
		Super.setStyle( style )
		For Local child:TWidget = EachIn children
			child.setstyle( stylesheet )
		Next
	End Method
	
	Method render()
		' Container is invisible. If you want style, use a panel!
		For Local child:TWidget = EachIn children
			If child.flags.isSet( FLAG_HIDDEN); Continue
			If child.runstyle; child.restyle( stylesheet )
			child.render()
		Next		
	End Method
	
	'------------------------------------------------------------
	Protected Method __PROTECTED__() ; End Method

	' Invalidates the widget layout
	Method invalidate()
		If layout; layout.invalidate()
		Super.invalidate()
	End Method
	
	Method runLayout()
		If layout; layout.run()
	End Method
	
	' Validate the tree
	'Method recalculate()
	'	For Local child:TWidget = EachIn children
	'		If child.invalid; child.recalculate()
	'	Next
	'	'
	'	Local size:Int =... layout.getMinimumSize() Or calc!
	'	
	'	invalid = False
	'End Method
	
End Type

Type TForm Extends TContainer

	Const BLINKSPEED:Int = 500

	Const NONE:Int = 0
	'Const BACKGROUND:Int = 1	' epreciated, use BORDER
	Const BORDER:Int = 1		' Colour of bounds
	Const SURFACE:Int = 2		' Colour of outer (Inside margin, includes padding)
	'Const PRIMARY:Int = 3		' Depreciated, use FOREGROUND
	Const FOREGROUND:Int = 3	' Forground colour
	'Const SECONDARY:Int = 4		' Depreciated, use VARIANT
	Const VARIANT:Int = 4		' Variant Color
	Const CURSOR:Int = 5		' Cursor Color (Textbox mostly)
	'Const DISABLED:Int = 5		' Depreciated use stylesheet
	'Const ONBACKGROUND:Int = 6	' Depreciated 
	'Const ONSURFACE:Int = 7		' Depreciated 
	'Const ONPRIMARY:Int = 8		' Depreciated 
	'Const ONSECONDARY:Int = 9	' Depreciated 
	'Const ONDISABLED:Int = 10	' Depreciated
		
	Const _CENTRE_:Int = $0001	' For the Brits
	Const _CENTER_:Int = $0001	' For the Americans
	
	'Field MARGIN:Int = 5
	'Field PADDING:Int = 4
	
	Field parent:Object 'IForm
	Field title:String
	Field fields:TList			' Widgets in the form
	Field xpos:Int = AUTO
	Field ypos:Int = AUTO
	Field width:Int, height:Int
	Field widths:Int[2]
	Field flags:Int = _CENTRE_
	
	' Depreciated
	Field focus:TFormfield		' Field with focus
	
	Field cursorstate:Int		' Current cursor state
	Field cursortimer:Int		' Depreciated in 0.6
	Field cursorpos:Int		' Depreciated in 0.6
	
	'V05
	Field invalid:Int = True
	
	'V06
	'Field root:TContainer

	Field dragged:TWidget		' widget being dragged
	Field hovered:TWidget		' widget under mouse
	Field focused:TWidget		' widget with keyboard focus
	Field mousefocus:TWidget	' widget with mouse focus
	Field pressed:TWidget		' currently pressed widget
	
	Field handler( event:Int, widget:TWidget, data:Object )
	
	' Manual GUI
	Method New()
		'DebugStop
		'setPalette( PALETTE_BLUE )
		setStyle()				' Set default stylesheet
		
		fields = New TList()
		xpos = -1
		ypos = -1
		AddHook( EmitEventHook, EventHook, Self )
	End Method
	
	' TypeGUI - View a Type as a GUI
	Method New( form:IForm, fx:Int=AUTO, fy:Int=AUTO )
		parent = form
		fields = New TList()
		' Default colour scheme
		'setPalette( PALETTE_BLUE )
		setStyle()				' Set default stylesheet

		Local t:TTypeId = TTypeId.ForObject( form )
		title = t.metadata("title")
		Local value:Int = Int( t.metadata("margin") )
		If value=0; value=5
		setMargin( value )
		value = Int( t.metadata("padding") )
		If value=0; value=4
		setPadding( value )
		
		height = 5
		Local x:String = title
		Local n:Int = TextHeight( x )
		If title; height :+ TextHeight( title ) + 5
		
		' Position Form
		'Print( Hex(flags) )
		If fx>=0 And fy>=0
			xpos = fx
			ypos = fy
			flags = flags & (Not _CENTRE_)	' Turn off center flag
		ElseIf t.hasMetadata("pos")
			'Local sPos:String = t.metadata("pos")
			Local Pos:String[] = t.metadata("pos").split(",")
			If pos.length = 2
				xpos = Int( pos[0] )
				ypos = Int( pos[1] )
				flags = flags & (Not _CENTRE_)	' Turn off center flag
			End If
		End If
		
		'In a related issue, The tForm.New Method needs To keep track of all the gadgets created And update 
		'Method-wide 'width' parameter, so that the border rect will size to the largest gadget.  
		'In the loop, I added something like this 
		'`tempW=Max(tempW ,MARGIN*2 + Max( widths[0] + widths[1], TextWidth(title))+ PADDING)
		'`  Then assign 'width' to that value after the loop.

		For Local fld:TField = EachIn t.EnumFields()
			'Only include fields with metadata
			'Local meta:String = fld.metadata()
			'If Not meta; Continue
			If Not fld.metadata(); Continue
			
'DebugStop
			Local row:TFormField = New TFormField()
			row.fld      = fld
			row.fldName  = fld.name()
			row.fldType  = fld.typeid().name()
			'row.datatype = Lower(fld.metadata("type"))
			row.caption  = fld.metadata("label")
			row.length   = Int( fld.metadata("length") )
			row.value    = fld.getString( parent )
			row.disable = fld.hasmetadata( "disabled" ) = True

			' Read datatype from metadata
			For Local fieldtype:String = EachIn SUPPORTED_TYPES
				If fld.hasmetadata( fieldtype )
					row.datatype = Lower(fieldtype)
					Local opt:String = fld.metadata(fieldtype)
					If opt<>"1"; row.options = opt.split(",")
				End If
			Next

			' Validation
			If Not row.caption; row.caption = row.fldname
			If row.length = 0; row.length = 10 
			row.height = Max( TextHeight( row.caption ), TextHeight("8y") )
			row.width  = TextWidth( stringRepeat( "W", row.length ) )
			
			' Adjust width for multiple fields
			If row.datatype="radio"
				row.width = row.height*row.options.length + 4*(row.options.length)
				For Local text:String = EachIn row.options
					row.width :+ TextWidth( text )
				Next
			End If
			
			' Calculate column widths
			widths[0] = Max( widths[0], TextWidth( row.caption ) )
			widths[1] = Max( widths[1], row.width )
			height :+ row.height + 4
			
			'DebugStop
			fields.addlast( row )

		Next

		' Give focus to first field
		If Not focus; focus = TFormField( fields.first() )
	
		' Calculate size of the form
		width = 5*2 + Max( widths[0] + widths[1], TextWidth(title) ) + 4 
		height :+ 5
		
		' Centralise form (if Required )
		'Print( Hex(flags) )
		If ( flags & _CENTRE_ )
			xpos = (GraphicsWidth()-width)/2
			ypos = (GraphicsHeight()-height)/2		
		End If
		
	End Method

	' Object Inspector
	Method New( form:Object, fx:Int, fy:Int )
		fields = New TList()
		Local component:TFormField
		'setPalette( PALETTE_BLUE )
		setStyle()					' Set default stylesheet
		stylesheet.merge( New TStylesheet( STYLE_INSPECTOR ) )	' Add inspector stylesheet
		
		parent = form
		layout = New TInspectorLayout()
		invalid = True
		
		' Add title
		'DebugStop
		Local t:TTypeId = TTypeId.ForObject( form )
		Local title:String = t.metadata("title")
		If Not title; title = t.name()
		fields.addlast( MakeLabel( title ) )
		' Fill next two cells with NULL labels
		fields.addlast( MakeLabel( "" ) )
		fields.addlast( MakeLabel( "" ) )
		
		'DebugStop
		
		' Add table of fields
		For Local fld:TField = EachIn t.EnumFields()
			Print( fld.name() )
			Local temp:String
		
			' Add field name to column 1
			fields.addlast( MakeLabel( fld.name() ))
			
			' Add field type to Column 2
			Local fldType:String = fld.typeid().name()
			fields.addlast( MakeLabel( fldType ))
			
			' Add field data to Column 3
			'Local value:String = 
			'If Not value; label = fld.name()
			Select fldType
				Case "Byte"
					fields.addlast( MakeLabel( fld.getByte( form ) ) )
				Case "Short"
					fields.addlast( MakeLabel( fld.getShort( form ) ) )
				Case "Double"
					fields.addlast( MakeLabel( fld.getDouble( form ) ) )
				Case "Float"
					fields.addlast( MakeLabel( fld.getFloat( form ) ) )
				Case "Int"
					If fld.hasmetadata( "boolean" )
						'Local fld:TFormField = fields.addlast( New TFormField( "checkbox", label ) )
						'fld.value = ( fld.getInt( parent ) = True )
						
						Local value:Int = ( fld.getInt( form ) = True )						
						fields.addlast( MakeLabel( ["FALSE","TRUE"][value] ) )
					Else
						Local widget:TFormField = MakeTextBox( fld.name() )
						widget.fld = fld
						fields.addlast( widget )
					End If
				Case "Long"
					fields.addlast( MakeLabel( fld.getLong( form ) ) )
				Case "String"
					fields.addlast( MakeLabel( Chr(34)+fld.getString( form )+Chr(34) ) )
				Default
				DebugStop
					If fld.typeid().extendsType( ArrayTypeId )
						fields.addlast( MakeLabel( "(array)"  ) )
					ElseIf fld.typeid().extendsType( ObjectTypeId )					
						fields.addlast( MakeLabel( "(object)" ) )
					Else
						fields.addlast( MakeLabel( "NOT IMPLEMENTED" ) )
					End If
			End Select
		
		Next

		' Add Buttons
		'row = root.add( New TContainer() )
		'row.setLayout( New TBoxLayout( LAYOUT_HORIZONTAL ) )
		'row.add( New TButton( "Ok" ) )
		'row.add( New TButton( "Appy" ) )
		'row.add( New TButton( "Cancel" ) )
		
	End Method 

	Function EventHook:Object( id:Int, data:Object, context:Object )
		Local form:TForm = TForm(context)
		Local event:TEvent = TEvent( data )
		If Not form Or Not event; Return data
		'
		'If form.onEvent( id, event ); Return Null
		Select event.id
		'Case EVENT_APPSUSPEND
		'Case EVENT_APPRESUME
		'Case EVENT_APPTERMINATE
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
		'Case EVENT_MOUSEWHEEL
		'Case EVENT_MOUSEENTER
		'Case EVENT_MOUSELEAVE
		Case EVENT_TIMERTICK
			Local c:TTimer = TTimer(event.source)
			If c = TGUISys.cursortimer; TGUISys.cursorState = Not TGUISys.cursorState
		'Case EVENT_HOTKEYHIT
		'Case EVENT_MENUACTION
		'Case EVENT_WINDOWMOVE
		'Case EVENT_WINDOWSIZE
		'Case EVENT_WINDOWCLOSE
		'Case EVENT_WINDOWACTIVATE
		'Case EVENT_WINDOWACCEPT
		Default
			DebugLog( "TForm::Event=>"+event.toString() )
		End Select
		Return data
	End Function

	' V05
	Method add( fld:TFormField )
		fields.addlast( fld )
		' V0.6
		If Not children; children = New TList()
		children.addlast( fld )
	End Method

	Method add( fieldtype:String, name:String )
		fields.addlast( make( fieldtype, name ) )
		' V0.6
		If Not children; children = New TList()
		children.addlast( fld )
	End Method
		
	' Emit an event to the form handler
	Method emit( event:Int, widget:TWidget )
		Local target:IForm = IForm(parent)
		If target; target.onGUI( event, Self, TFormField(widget) )
		If handler; handler( event, TWidget( widget ), Null )
	End Method

	Method onKeyChar:TEvent( event:TEvent )
		Print( "FORM.onKeyChar: "+event.toString() )
		If focused; focused.onKey( 0, event.data )
	End Method

	Method onKeyRepeat:TEvent( event:TEvent )
		Print( "FORM.onKeyRepeat: "+event.toString() )
		If focused; focused.onKey( event.data, 0 )
	End Method

	Method onKeyDown:TEvent( event:TEvent )
		Print( "FORM.onKeyDown: "+event.toString() )
		If focused; focused.onKey( event.data, 0 )
	End Method

	Method onKeyUp:TEvent( event:TEvent )
		Print( "FORM.onKeyUp: "+event.toString() )
	End Method

	Method onMouseDown:TEvent( event:TEvent )
		' Only interested in button 1
		If event.data <> 1; Return event
		' Get widget under button
		pressed = getWidgetAt( event.x, event.y )
		If Not pressed; Return event
		'
		pressed.onMouseDown(event.x, event.y)
		'
		' Deal with Focus
		If focused; focused.onLoseFocus( event.x, event.y )
		focused = pressed
		focused.onGetFocus( event.x, event.y )
	End Method
	
	Method onMouseMove:TEvent( event:TEvent )
		If dragged; dragged.onDrag( event.x, event.y )

		Local widget:TWidget

		' Mouseover / Hover!
		If hovered; widget = hovered.getWidgetAt( event.x, event.y )
		If Not widget; widget = getWidgetAt( event.x, event.y )
		If (widget And widget <> hovered) Or (Not widget And hovered)
			If hovered
				hovered.onMouseLeave(event.x, event.y)
				emit( EVENT_MOUSELEAVE, hovered )
			End If
			If widget
				widget.onMouseEnter(event.x, event.y)
				emit( EVENT_MOUSEENTER, widget )
			End If
			hovered = widget
		End If
		If hovered; hovered.onMouseMove(event.x, event.y)
	
	End Method

	Method onMouseUp:TEvent( event:TEvent )
		' Only interested in button 1
		If event.data <> 1; Return event
		If Not pressed; Return event
		' Get widget under button
		Local widget:TWidget = getWidgetAt( event.x, event.y )
		If pressed; pressed.onMouseUp( event.x, event.y )
		If Not widget; Return Null
		If widget = pressed
			' Mouse CLick event
			emit( EVENT_WIDGETCLICK, pressed )
			pressed.onMouseClick(event.x, event.y)
		End If
		pressed = Null
	End Method

	' calculates size of form
	Method pack()
'		DebugStop
		If Not layout; layout = New TBoxLayout( Self )
		
		Local size:TDimension = layout.getMinimumSize()
		Local pos:SPoint = New SPoint( xpos, ypos )
		
		' A Form aligns to given position, or centre
		If xpos = AUTO; pos.x = ( GraphicsWidth() - size.width ) * alignSelf.x
		If ypos = AUTO; pos.y = ( GraphicsHeight() - size.height ) * alignSelf.y
		
'		DebugStop
		Local rect:SRectangle = New SRectangle( pos, size )
		
		'Print "SIZE BEFORE: ("+bounds.toString()+"), ("+outer.toString()+"), ("+inner.toString()+")"
		setInner( rect, True )
		'rect.expand( padding )
		'setOuter( rect )
		'rect.expand( margin )
		'setBounds( rect )
		'Print "SIZE AFTER: ("+bounds.toString()+"), ("+outer.toString()+"), ("+inner.toString()+")"		
		
'		DebugStop
		
	End Method
	
	Method resize()
		pack()
		layout.run()
		invalid = False
	End Method
	
	' Forms render differently than containers
	'
	Method render()
		'DebugStop
		bounds.fill( palette[ BORDER ] )
		outer.fill( palette[ SURFACE ] )
		'inner.fill( palette[ BACKGROUND ] )
		Super.render()
	End Method
	
	' Depreciated, Please use TLabel
	Method MakeLabel:TFormField( caption:String="" )
		Local widget:TFormField = New TFormfield( "label" )
		' Set Properties
		'DebugStop
		widget.caption = caption
		widget.color( ST_BACKGROUND, Palette[ NONE ] )
		widget.color( ST_FOREGROUND, Palette[ FOREGROUND ] )
		widget.color( ST_BORDER, Palette[ NONE ] )
		widget.color( ST_SHADOW, Palette[ NONE ] )
		widget.color( ST_ALT, Palette[ NONE ] )
		'DebugStop
		widget.set( PR_ALIGNMENT, ALIGN_LEFT | ALIGN_MIDDLE )
		' Set inner size of widget
		widget.height = TextHeight( caption )
		widget.width =  TextWidth( caption )
		' Attach behaviour
		widget._draw   = _DrawWidget
		widget._client = _DrawCaption
		Return widget
	End Method
	
	Method MakeTextbox:TFormField( name:String, value:String="" )
		Local widget:TFormField = New TFormfield( "textbox" )
		' Set Properties
		'DebugStop
		'widget.caption = caption
		widget.color( ST_BACKGROUND, Palette[ SURFACE ] )
		widget.color( ST_FOREGROUND, Palette[ FOREGROUND ] )
		widget.color( ST_BORDER, Palette[ BORDER ] )
		widget.color( ST_SHADOW, Palette[ NONE ] )
		widget.color( ST_ALT, Palette[ VARIANT ] )
		'DebugStop
		widget.set( PR_ALIGNMENT, ALIGN_LEFT | ALIGN_MIDDLE )
		' Set inner size of widget
		widget.height = TextHeight( "8q" )
		widget.width =  TextWidth( "w" )
		' Attach behaviour
		widget._draw   = _DrawWidget
		widget._client = _DrawEditbox
		Return widget
	End Method
	
	' Set a function handler to receive events
	Method setHandler( handler( event:Int, widget:TWidget, data:Object ) )
		Self.handler = handler
	End Method
	
	Method show( modal:Int = False )

		' Draw modal background
		If modal
			SetAlpha( 0.7 )
			SetColor( 0, 0, 0 )
			DrawRect( 0, 0, GraphicsWidth(), GraphicsHeight() )
			SetAlpha( 1.0 )
		EndIf 
	
		' Version 0.5 is testing a widget type
		'If root; root.Render(); Return

		Local col1:Int = xpos+5
		Local col2:Int = col1+widths[0]+4
		Local y:Int = ypos+5		
		
		' Validate tree
		If invalid; resize()
		
		' Draw tree
		'DebugStop
		render()
		Return
Rem
		' Background
		bounds.fill( palette[ ONBACKGROUND ] )
		outer.fill( palette[ BACKGROUND ] )
		inner.fill( palette[ SURFACE ] )
		'SetColor( palette[ BACKGROUND ] )
		'DrawRect( xpos, ypos, width, height )
		' Border
		'drawborder( PRIMARY, xpos, ypos, width, height )
		' Title
		DebugStop
		If title
			SetColor( palette[ PRIMARY ] )
			DrawRect( col1-5, y-5, width, TextHeight(title) )
			SetColor( palette[ ONPRIMARY ] )
			DrawText( title, col1, y-5+2 )
			y :+ TextHeight( title ) + 5
		End If
		' Cursor
		If MilliSecs() > cursortimer
			cursorstate = Not cursorstate
			cursortimer = MilliSecs() + BLINKSPEED
		End If
		
		' Fields
		'DebugStop
		For Local fld:TFormField = EachIn fields
			
			Local xpos:Int = col2
			Local ypos:Int = y
			
			' Turn off focus for disabled widgets
			If fld.disable And focus = fld; focus = Null
			
			Select Lower(fld.datatype)
			Case "textbox", "password"
				Local value:String = fld.fld.getString(parent)
				Local inside:Int
				' ACTION
				If Not fld.disable
					inside = boundscheck( col2, y, widths[1], fld.height )
					If inside And MouseHit(1); setfocus( fld )
				End If
				' LABEL
				colour( fld.disable, ONDISABLED, PRIMARY )
				'SetColor( palette[ PRIMARY ] )
				DrawText( fld.caption, col1, y )
				' BACKGROUND
				colour( fld.disable, DISABLED, SURFACE )
				'SetColor( palette[ SURFACE ] )
				'DrawRect( col2, y, fld.width, fld.height )
				DrawRect( col2, y, widths[1], fld.height )
				' BORDER
				If Not fld.disable
					If inside
						'drawBorder( PRIMARY, col2, y, fld.width, fld.height )
						'drawBorder( PRIMARY, col2, y, widths[1], fld.height )
						outer.outline( palette[ PRIMARY ] )
					ElseIf hasfocus( fld )
						'drawBorder( SECONDARY, col2, y, fld.width, fld.height )
						'drawBorder( SECONDARY, col2, y, widths[1], fld.height )
						outer.outline( palette[ SECONDARY ] )
					End If
				End If
				' FOREGROUND
				colour( fld.disable, ONDISABLED, PRIMARY )
				'SetColor( Palette[ PRIMARY ] )
				Local text:String = iif( fld.datatype="password", stringRepeat( "*", value.length ), value )
				DrawText( text, col2, y+2 )
				' CURSOR
				If hasfocus( fld )
					If KeyHit( KEY_HOME ); cursorpos = 0
					If KeyHit( KEY_END ); cursorpos = value.length
					If KeyHit( KEY_LEFT ); cursorpos :- 1
					If KeyHit( KEY_RIGHT ); cursorpos :+ 1
					cursorpos = Max( 0, Min( cursorpos, value.length ))	' Bounds validation
					If KeyHit( KEY_DELETE ); value = value[..cursorpos]+value[cursorpos+1..]
					If KeyHit( KEY_BACKSPACE )
						value = value[..cursorpos-1]+value[cursorpos..]
						cursorpos = Max(cursorpos-1,0)
					End If
					Local key:Int = GetChar()
					If key>31 And key<127
						'DebugStop
						value = value[..cursorpos]+Chr(key)+value[cursorpos..]
						cursorpos :+ 1
					End If
					' Draw cursor
					If cursorstate
						colour( inside, ONPRIMARY, ONSURFACE )
					Else
						colour( fld.disable, DISABLED, SURFACE )
					End If
					Local offset:Int = TextWidth( value[..cursorpos] )
					DrawLine( col2+offset, y+2, col2+offset, y+fld.height-2 )

				End If
				' UPDATE TYPE
				fld.fld.setString( parent, value )
			Case "button"; Render_Button( fld, col1, col2, y )

			Case "checkbox"
				Local value:Int = fld.fld.getInt( parent )
				Local inside:Int
				' ACTION
				If Not fld.disable
					inside = boundscheck( col2, y, fld.height, fld.height )
					If inside And MouseHit( 1 )
						value = Not value
						setfocus( fld )
					End If
				End If
				' LABEL
				colour( fld.disable, ONDISABLED, PRIMARY )
				'SetColor( palette[ PRIMARY ] )
				DrawText( fld.caption, col2+fld.height+4, y+2 )	' We use height here to make a square!
				' BACKGROUND
				colour( fld.disable, DISABLED,SURFACE )
				'SetColor( Palette[ SURFACE ] )
				DrawRect( col2, y, fld.height, fld.height )		' We use height here to make a square!
				' BORDER
				If Not fld.disable
					If inside
						'drawBorder( PRIMARY, col2, y, fld.height, fld.height )
						outer.outline( palette[PRIMARY] )
					ElseIf hasfocus( fld )
						'drawBorder( SECONDARY, col2, y, fld.height, fld.height )
						outer.outline( palette[SECONDARY] )
					End If
				End If
				' FOREGROUND
				If value
					colour( fld.disable, ONDISABLED, PRIMARY )
					'SetColor( Palette[ PRIMARY ] )
					DrawRect( col2+3, y+3, fld.height-6, fld.height-6 )
				EndIf
				' SET FIELD VALUE
				fld.fld.setInt( parent, value )
			Case "radio"
				Local value:Int = fld.fld.getInt( parent )
				
				' LABEL
				colour( fld.disable, ONDISABLED, PRIMARY )
				'SetColor( palette[ PRIMARY ] )
				DrawText( fld.caption, col1, y+2 )
				'
				' Create button for each option
				Local px:Int = col2
				For Local id:Int = 1 To fld.options.length
					Local inside:Int
					If Not fld.disable
						inside = boundscheck( px, y, fld.height, fld.height )
						If inside And MouseHit( 1 )
							'parent.onGui( "select", fld )
							value = id
							setfocus( fld )
						End If
						' BORDER
						If inside
							SetColor( palette[ PRIMARY ] )
							DrawOval( px, y, fld.height, fld.height )
						ElseIf hasfocus( fld )
							SetColor( palette[ SECONDARY ] )
							DrawOval( px, y, fld.height, fld.height )
						End If
					End If
					' BACKGROUND
					colour( fld.disable, DISABLED, SURFACE )
					'SetColor( Palette[ SURFACE ] )
					DrawOval( px+1, y+1, fld.height-2,fld.height-2 )
					' FOREGROUND
					colour( fld.disable, ONDISABLED, PRIMARY )
					'SetColor( palette[ PRIMARY ] )
					If id = value
						DrawOval( px+3, y+3, fld.height-6,fld.height-6 )
					EndIf
					' Option text
					Local text:String = fld.options[id-1]
					DrawText( text, px+fld.height, y+2 )
					' NEXT
					px :+ fld.height + 4*2 + TextWidth( text )
				Next				
				' SET FIELD VALUE
				fld.fld.setInt( parent, value )
			Default
				SetColor( palette[ ONBACKGROUND ] )
				'DrawText( fld.caption, col1, y )
				DrawRect( col1-5, y+fld.height*0.5, width, 1 )
			End Select
			y:+fld.height+4			
		Next
	
		' Throw away mouseclicks within the form
		' Without this, clicking in the form and moving to a button clicks it.
		If boundscheck( xpos, ypos, width, height ); FlushMouse()
End Rem
	End Method
	
	' Object Inspector
	Method inspect:Int()
		' Do we need to perform a layout?
		'DebugStop
		
		If Invalid
			If layout; layout.run( Self )
			Invalid = False
		End If
		
		Local col1:Int = xpos+5
		Local col2:Int = col1+widths[0]+4
		Local y:Int = ypos+5
		Local column:Int = 0
		
		' Background
		outer.fill( palette[BORDER] )
		'SetColor( palette[ BACKGROUND ] )
		'DrawRect( xpos, ypos, width, height )
		' Border
		'drawborder( PRIMARY, xpos, ypos, width, height )
		outer.outline( palette[FOREGROUND] )
		
		' Cursor
		If MilliSecs() > cursortimer
			cursorstate = Not cursorstate
			cursortimer = MilliSecs() + BLINKSPEED
		End If
		
		' Fields
		'DebugStop
		Local dimensions:SRectangle = New SRectangle( xpos, ypos, height, width )
		For Local fld:TFormField = EachIn fields
			
			' Turn off focus for disabled widgets
			If fld.disable And focus = fld; focus = Null
			
			' Dynamic field Update
			If fld.fld; fld.value = fld.fld.getString( parent )
			
			Local clientarea:SRectangle
			If fld._draw
				clientarea = fld._draw( Self, fld, fld.shape )
			Else
				clientarea = fld.shape
			End If
			If fld._client; fld._client( Self, fld, clientarea )
			
		Next
		
		If boundscheck( xpos, ypos, width, height )
			' Throw away unused mouseclicks inside the inspector
			'Print( "FLUSHING" )
			FlushMouse()
			Return False
		ElseIf MouseHit(1)
			Print( "CLICKED OUTSIDE" )
			Return True
		End If
				
	End Method
	

	
	Method make:TFormField( fieldtype:String, name:String )
		Local fld:TFormField = New TFormField( fieldtype:String, name:String )
		
		Select fieldtype
		Case "label"
			'fld.border = [0,0,0,0]
			fld.margin = New SEdges(1)	'[1,1,1,1]
			'fld.shadow = [0,0,0,0]
		End Select
	End Method
		
	Method setPos( x:Int, y:Int )
		xpos = x
		ypos = y
	End Method
	
	Method Render_Button( fld:TFormField, col1:Int, col2:Int, y:Int )
		'DebugStop
		
		'If fld.fld.typeid().ExtendsType( ArrayTypeId ); Print "YES"
		
		Local value:String = fld.fld.getString(parent)
		' ACTION
		Local inside:Int
		Local pressed:Int
		If Not fld.disable
			inside = boundscheck( col1, y, widths[0], fld.height )
			If inside And MouseHit( 1 )
				setfocus( fld )
				Local form:IForm = IForm(parent)
				If form; form.onGUI( EVENT_WIDGETCLICK, Self, fld )
			End If
			pressed = MouseDown(1) And inside
		End If
		' BACKGROUND
		colour( fld.disable, BORDER, FOREGROUND )
		'SetColor( palette[ PRIMARY ] )
		DrawRect( col1+pressed, y+pressed, fld.width, fld.height )
		If Not pressed And Not fld.disable
			SetColor( $22,$22,$22 )
			DrawLine( col1+fld.width, y,            col1+fld.width, y+fld.height )
			DrawLine( col1,           y+fld.height, col1+fld.width, y+fld.height )
		End If
		' BORDER
		If inside And Not fld.disable
			outer.outline( palette[VARIANT] )
			'drawBorder( SECONDARY, col1+pressed, y+pressed, fld.width, fld.height )
		'ElseIf hasfocus( fld )
		'	drawBorder( SECONDARY, col1+pressed, y+pressed, fld.width, fld.height )
		End If
		' FOREGROUND
		colour( fld.disable, FOREGROUND, VARIANT )
		'SetColor( palette[ ONPRIMARY ] )
		DrawText( value, col1+(col2-col1-4-TextWidth(value))/2+pressed, y+pressed+1 )
	End Method

	Method colour( state:Int, isTrue:Int, isFalse:Int )
		If state
			SetColor( palette[ isTrue ] )
		Else
			SetColor( palette[ isFalse ] )
		End If
	End Method
	
	Function iif:String( state:Int, isTrue:String, isFalse:String )
		If state Return isTrue Else Return isFalse
	End Function

	Function iif:SColor8( state:Int, isTrue:SColor8, isFalse:SColor8 )
		If state Return isTrue Else Return isFalse
	End Function
	
	Method stringRepeat:String( char:String, count:Int )
		Return " "[..count].Replace(" ",char)
	End Method

	' Depreciated in version 0.6 in favour of stylesheet
	'Method SetPalette( element:Int, color:Int )
	'	Assert element >=0 And element < palette.length, "Invalid colour element"
	'	Self.palette[ element ] = New SColor8( color )
	'End Method

	' Depreciated in version 0.6 in favour of stylesheet
	'Method setPalette( palette:Int[] )
	'	Assert palette.length = Self.palette.length, "Invalid palette"
	'	For Local element:Int = 0 Until palette.length
	'		SetPalette( element, palette[element] )
	'	Next
	'End Method
	
	Function boundscheck:Int( x:Int, y:Int, w:Int, h:Int )
		If MouseX()>x And MouseY()>y And MouseX()<x+w And MouseY()<y+h; Return True
		Return False
	End Function
	
	'Method drawborder( colour:Int, x:Int, y:Int, w:Int, h:Int )
	'	SetColor( palette[ colour ] )
	'	DrawLine( x,     y,     x+w-1, y )
	'	DrawLine( x+w-1, y,     x+w-1, y+h-1 )
	'	DrawLine( x+w-1, y+h-1, x,     y+h-1 )
	'	DrawLine( x,     y+h-1, x,     y )
	'End Method
	
	Method hasfocus:Int( fld:TFormField )
		Return (focus = fld)
	End Method
	
	Method setfocus( fld:TFormField )
		focus = fld
		
		
	End Method
	
	Method Disable( caption:String )
        For Local r:TFormField = EachIn fields
            If r.caption=caption Then r.disable=True
        Next
    End Method

    Method Enable( caption:String )
        For Local r:TFormField=EachIn fields
            If r.caption=caption Then r.disable=False
        Next
    End Method
	
End Type

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

Type TLabel Extends TWidget Implements IComponent

	Method New( caption:String="" )
		Self.caption = caption
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
		outer.fill( palette[ TForm.SURFACE ] )
		Local pos:SPoint = getTextPos( caption )
		SetAlpha( palette[TForm.FOREGROUND].a/256.0 )
		SetColor( palette[TForm.FOREGROUND] )
		DrawText( caption, pos.x, pos.y )
	End Method
	
End Type

Type TPanel Extends TContainer Implements IComponent

	Method getMinimumSize:TDimension()
		'DebugStop
		Return Super.getMinimumSize()
	End Method

	Method render()
		bounds.fill( palette[ TForm.BORDER ] )
		outer.fill( palette[ TForm.SURFACE ] )
		Super.render()
	End Method
	
End Type

Type TProgressBar Extends TWidget Implements IComponent

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
		Self.value = value
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
		bounds.outline( palette[ TForm.BORDER ] )
		' Draw surface
		outer.fill( palette[ TForm.SURFACE ] )
		' Draw handle
		handle.fill( palette[ TForm.VARIANT ] )	
		' Draw Text
		Local pos:SPoint = getTextPos( value )
		SetAlpha( palette[TForm.FOREGROUND].a/256.0 )
		SetColor( palette[TForm.FOREGROUND] )
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

Type TRadioButton Extends TToggle Implements IComponent

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
		bounds.outline( palette[ TForm.BORDER ] )
		' Background
		outer.fill( palette[ TForm.SURFACE ] )
		' Toggle box
		SetAlpha( palette[ TForm.VARIANT].a/256.0 )
		SetColor( palette[ TForm.VARIANT ] )
		DrawOval( toggle.x, toggle.y, toggle.width, toggle.height )
		' handle
		If parent.valueint = value
			SetAlpha( palette[ TForm.FOREGROUND ].a/256.0 )
			SetColor( palette[ TForm.FOREGROUND ] )
			DrawOval( handle.x, handle.y, handle.width, handle.height )
		End If
		'
		Local pos:SPoint = getTextPos( caption, label )
		SetAlpha( palette[TForm.FOREGROUND].a/256.0 )
		SetColor( palette[TForm.FOREGROUND] )
		DrawText( caption, pos.x, pos.y )
	End Method
		
End Type

Type TSlider Extends TWidget Implements IComponent

	Const MINIMUM_WIDTH:Int = 100

	' Value and range
	Field lo:Int = 0	' Minimum value
	Field hi:Int		' Maximum value
	Field value:Int			' Current value
	
	'Field size:SPoint		' Size of slider
	
	Field dragging:Int = False
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
		If BIT1( FLAG_PRESSED ); snapTomouse( x, y )
	End Method
	
	Method render()
		If value <> valueint
			value = valueint
			'TForm.emit( EVENT_TEXTCHANGED, Self )	'TODO
		End If
		' Draw border (Only visible if margin>0)
		bounds.outline( palette[ TForm.BORDER ] )
		' Draw surface
		outer.fill( palette[ TForm.SURFACE ] )
		' Draw handle
		calcHandle()
		handle.fill( palette[ TForm.VARIANT ] )
		' Draw Text
		Local pos:SPoint = getTextPos( valueint )
		SetAlpha( palette[TForm.FOREGROUND].a/256.0 )
		SetColor( palette[TForm.FOREGROUND] )
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

Type TTextBox Extends TWidget Implements IComponent

	Field value:String			' Saved value (used for TEXTCHANGE event)
	Field length:Int = 20		' Default size of a textbox

	Field cursor:Int			' Cursor position
	Field offset:Int			' Cursor offset
	
	Method New( value:String="" )
		Self.value = value
	End Method

	Method New( value:String, caption:String )
		Self.caption = caption
		Self.value = value
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
		End If
		' Draw border (Only visible if margin>0)
		bounds.outline( palette[ TForm.BORDER ] )
		' Draw surface
		outer.fill( palette[ TForm.SURFACE ] )
		
		' Draw content
		setClipArea()
		Local pos:SPoint
		If value = ""
			pos = getTextPos( caption )
			SetAlpha( palette[TForm.VARIANT].a/256.0 )
			SetColor( palette[TForm.VARIANT] )
			'DebugStop
			DrawText( caption, pos.x, pos.y )
		Else
			pos = getTextPos( value )
			SetAlpha( palette[TForm.FOREGROUND].a/256.0 )
			SetColor( palette[TForm.FOREGROUND] )
			DrawText( valuestr[offset..], pos.x, pos.y )
		End If
		setClipArea( False )
		
		If BIT1( FLAG_FOCUS ) And TGUISys.cursorState
			Local pos:Int = TextWidth( value[offset..cursor] )
			'If insertmode
			SetAlpha( palette[ TForm.CURSOR ].a/256.0 )
			SetColor( palette[ TForm.CURSOR ] )
			DrawLine( inner.x+pos, inner.y, inner.x+pos, inner.y+inner.height-1)
		End If
		
		'If focus
		'	If TForm.cursorstate
		'		Local offset:Int = TextWidth( valuestr[..cursorpos] )
		'		If insertmode
		'	'	colour( inside, ONPRIMARY, ONSURFACE )
		'			SetAlpha( palette[ TForm.CURSOR ].a/256.0 )
		'			SetColor( palette[ TForm.CURSOR ] )
		'			DrawLine( pos.x+offset, inner.y, pos.x+offset, inner.y+inner.height)			
		'		Else
		'			Local cursor:SRectangle = New SRectangle()
		'			cursor.x = pos.x+offset
		'			cursor.y = inner.y
		'			cursor.width = TextWidth( valuestr[ cursorpos..cursorpos+1] )
		'			cursor.height = inner.height
		'			cursor.outline( palette[ TForm.CURSOR ] )
		'		End If
		'	'Else
		'	'	colour( fld.disable, DISABLED, SURFACE )
		'	End If
		'End If
		
	End Method
	
	' A widget must set it's size when asked to do so.
	'Method recalculate()
	'	setClientSize( TextWidth( caption ), TextHeight( caption ) )
	'End Method
End Type

Type TToggle Extends TWidget Implements IComponent

	Field size:Int	
	Field label:SRectangle
	Field toggle:SRectangle
	Field handle:SRectangle

	' Resize self
	Method setInner( rect:SRectangle, update:Int = False )
	'DebugStop
		Super.setInner( rect, update )
		label = rect
		label.x :+ size + whitespaceX()
		label.width :- size + whitespaceX()
		'
		toggle = rect
		toggle.width = toggle.height
		handle = toggle
		handle.shrink( 4 )
		
	End Method
	
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


Type TLayout

	Method run( form:TForm ); End Method
'	Method run( form:TContainer, resize:Int = False ); End Method
	
End Type

Interface ILayout
	Method run()
	Method run( form:TForm )		' DEPRECAITED
	Method invalidate()
	Method getMinimumSize:TDimension()
End Interface

' A Very simple layout
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
		'Print( Hex(flags) )
		If ( form.flags & form._CENTRE_ )
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

Type TBoxLayout Implements ILayout
	
	Field container:TContainer
	Field direction:Int = LAYOUT_VERTICAL
	
	Field children:TWidgetArray
	Field childRect:SRectangle[]	' Calculated size and position of children
	Field minsize:TDimension		' Minimum size required for this container
	Field sumsize:TDimension		' Sum of sizes (Compound)
	Field childExpands:SPoint[]		' Expansion bids for children
	Field expansion:Spoint			' Total expansion bids
	
	Method New( form:TContainer, direction:Int = LAYOUT_VERTICAL )
		container = form
		Self.direction = direction
		'children = New TWidgetArray()
	End Method
	
	' This calculates the containers size if not already calculated.
	Method getMinimumSize:TDimension()

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
			Print children[index].name
			'DebugStop
			Local size:TDimension = children[index].getMinimumSize()
			'childRect[index].setSize( children[index].getMinimumSize() )
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
	
		' ALL CHILDREN GET SAME SPACE AT THE MOMENT
		' LATER WE WILL ADD EXPAND / MAXIMUMSIZE
		
		' A Box layout is a 1 column/row grid, so we can use this
		' for a multi column/row grid at a later time

		Local rect:SRectangle = container.getInner()

		If direction = LAYOUT_HORIZONTAL
			distributeHorizontally( rect )
		Else	' VERTICAL
			distributeVertical( rect )
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
	Method distributeVertical( rect:SRectangle )
		
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

	Method run( form:TForm )		' DEPRECAITED
	End Method
	
	' Reposition children into precalculated locations
	Method reposition()
		For Local index:Int = 0 Until children.count()
			Local child:TWidget = TWidget( children[index] )
			child.setBounds( ChildRect[index], True )
			' If child is a container; ask it to layout
			Local container:TContainer = TContainer( children[index] )
			If container; container.runLayout()
		Next
	End Method
	
End Type

Interface IComponent
	Method getMinimumSize:TDimension()
	'Method recalculate()
	Method render()
End Interface

Rem
Type TStylesheet

	Global INVISIBLE:SColor8 = New SColor8( $00000000 )
	Global BLACK:SColor8 = New SColor8( $ff000000 )
	Global WHITE:SColor8 = New SColor8( $ffffffff )
	Global LTGREY:SColor8 = New SColor8( $ffE5E5E5 )
	Global BLUE500:SColor8 = New SColor8( $ff2196F3 )
	Global BLUE700:SColor8 = New SColor8( $ff1976D2 )

	Field BACKGROUND:SColor8 = INVISIBLE
	Field SURFACE:SColor8 = WHITE
	Field PRIMARY:SColor8 = BLUE500
	Field VARIANT:SColor8 = BLUE700

	Method New()
		' Create a default style
	End Method
	
	Method merge( style:TStylesheet )
	End Method
	
	Method apply( widget:TWidget )
		widget.palette[ TForm.FOREGROUND ] = PRIMARY
		widget.palette[ TForm.BACKGROUND ] = BACKGROUND
		widget.palette[ TForm.SURFACE ]    = SURFACE
		widget.palette[ TForm.VARIANT ]    = VARIANT
	End Method
	
End Type
End Rem

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
		
	' Match a selector
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

Function debugPalette( palette:SColor8[] )
	DebugLog( "PALETTE:" )
	For Local c:Int = 0 Until palette.length
		DebugLog( c+") #"+Hex(palette[c].toARGB()) )
	Next
End Function

AppTitle = "TypeGUI 0.6 Testing"
Graphics 400,300
DebugStop

Global form:TForm = New TForm()
form.addStyle( "#lbltitle { surface-color: #ff222222; color:white; text-align:center; }" )
form.add( "lbltitle", New TLabel( "Label-1" ) )
form.add( "lblName", New TLabel( "Name:" ) )
form.add( "fldName", New TTextBox( "", "What is your name?" ) )
form.add( "chkEnable", New TCheckbox( "Enable", True ) )
form.add( "chkVisible", New TCheckbox( "Visible", True ) )
'xyz.setEnabled( False )
form.add( "lblSlider", New TLabel( "Amount:" ) )
form.add( "fldamount", New TSlider( 0, 15, 6 ) )
' RADIO BUTTONS SAVE THEIR VALUE IN THE PARENT
form.setValue( 1 )
form.add( "radOne", New TRadioButton( "One", 1 ) )
form.add( "radTwo", New TRadioButton( "Two", 2 ) )

Local progress:TWidget 
progress = form.add( "prgSeconds", New TProgressBar( 0,59,MilliSecs()/1000 ) )

' Button Panel
Local panel:TPanel = New TPanel()
'DebugStop
panel.setLayout( LAYOUT_HORIZONTAL )
panel.add( "btnOK", New TButton( "OK" ) )
panel.add( "btnCancel", New TButton( "CANCEL" ) )
'DebugStop
form.add( panel )
form.setHandler( onGUI )

Function onGUI( event:Int, widget:TWidget, data:Object )
	'Local widget:TWidget = TWidget( event.source )
	Select event
	'Case EVENT_WIDGET_CLICK; Print( "-> Clicked, "+ widget.GetName() )
	Case EVENT_MOUSEENTER
	Case EVENT_MOUSELEAVE
	Case EVENT_WIDGETCLICK
		Select Lower(widget.name)
		Case "chkenable"
			DebugStop
			Local state:Int = widget.GetInt()
			Local fld:TWidget = form.getWidgetByName( "fldamount" )
			If fld; fld.setAttr( FLAG_DISABLED, Not state )
		Case "chkvisible"
			'DebugStop
			Local state:Int = widget.GetInt()
			Local fld:TWidget = form.getWidgetByName( "fldamount" )
			If fld; fld.setAttr( FLAG_HIDDEN, Not state )
		End Select
	'Case EVENT_WIDGETCHANGE	
	Default
		If widget
			Print( "ONGUI: "+TEvent.DescriptionForId( event )+" ("+widget.name+")" )
		Else
			Print( "ONGUI: "+TEvent.DescriptionForId( event )+" (NULL)" )
		End If
	End Select
End Function

Repeat
	SetClsColor( $33,$7a,$ff )
	Cls
'DebugStop
	Local seconds:Int = MilliSecs()/1000
	Local minutes:Float = Float( seconds ) /60.0
	progress.setValue( seconds-Int(minutes)*60)

	'DebugStop
	form.show()	'True )

	Flip
Until KeyHit( KEY_ESCAPE ) Or AppTerminate()

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
  surface-color: white;
  border-color: none;
  variant-color: --Blue200;
  cursor-color: --Blue900;
}
TButton {
  surface-color: --Blue500;
  padding: 1,5;
  color: black;
}
TCheckbox {
  surface-color: None;
}
TForm {
  surface-color: --Background;
  margin: 2;
  border-color: black;
}
TLabel {
  surface-color: None;
  text-align: Left,middle;
  padding:5;
}
TLabel:hover {
  border-color:none;
}
TPanel {
  surface-color: #ffcccccc;
  margin: 0;
  padding: 3;
}
TProgressBar {
  surface-color: --Blue100;
  color: --Blue900;
  variant-color: --Blue700;
  text-align:center;
}
TRadioButton {
  surface-color: None;
}
TSlider {
  surface-color: --Blue100;
  color: --Blue900;
  variant-color: --Blue700;
}
TSlider:drag {
  variant-color: red;
}
TTextBox {
  surface-color: --surface;
  variant-color: --Blue500;	// Secondary is used For the hint
  color: --Blue700;
  text-align: Left,center;
}
// THese should appear after other styles
:hover {
  border-color: --Blue900;
}
:focus {
  border-color: #ff666666;
}
:disabled {
  surface-color: #ffcccccc;
  color: #ffcccccc;
}
"""

Global STYLE_INSPECTOR:String = """
.title {
	surface-color: --Blue900;
	color: white;
}
"""