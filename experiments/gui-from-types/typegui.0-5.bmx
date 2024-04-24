SuperStrict


'	TYPEGUI
'	Author: Si Dunford [Scaremonger], June 2023
'	Contributions from:
'		@GW		(Discord)
'		@mingw	(Discord)
'
'	Version 0.6

Rem
FORM.add()
	- This should invalidate the layout causing a re-layout
	- New widgets have an invalid style by Default

WIDGET.setMargin, padding etc
	- This should invalidate the layout Not THE STYLE

TSTYLESHEET.Apply
	- Calls setBounds, setMargin, etc. - Invalidate layout, Not STYLE
	
setStyle()
	- Invalidates the style, forcing forward( EVENT_WIDGET_STYLE, stylesheet )
	
FORM.show() Or FORM.inspect()
	- layout.run() should also call layout.run() of children with layouts!
	

widget.render should be a message, Not a direct call.
	Forward( EVENT_WIDGET_RENDER, stylesheet, x, y )
	Each Object intercepts it, calling render() And forwarding it To children with their offset.
	- I need To remove the TEvent so that childen dont change the event position
	
	rendering containers should invoke layout.run()
End Rem

Rem TYPE TREE
TWidget
  TContainer
    TComponent
      TToggleBox
        TRadioButton
        TCheckbox
      TButtonBase
        TButton
        ?? DOES MENU ITEM GO HERE?
      TLabel
      TPanel
      TTextComponent
        TTextArea
        TTextField
      TSlider
End Rem

Global SUPPORTED_TYPES:String[] = ["button","checkbox","password","radio","textbox","separator"]
' Others: color,slider,icon,dropdown,textarea,intbox
Global SUPPORTED_METADATA:String[] = ["disable","label","options","Type"]

' LAYOUT DIRECTIONS
'Const LAYOUT_NONE:Int = 0
Const AUTO:Int = -1
Const LAYOUT_HORIZONTAL:Int = 1
Const LAYOUT_VERTICAL:Int = 2

Const _STYLE_:Int = $01
Const _LAYOUT_:Int = $02

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

' Valid Stylesheet Selectors
Const VALID_SELECTOR$ = ..
	"background-color,background-colour,"+..
	"border-color,border-colour,"+..			' Used by mouseover & TForm
	"cursor-color,cursor-colour,"+..
	"secondary-color,secondary-colour"+..		' Handle within a gadget
	"color,colour,"+..							' Foreground/Text
	"margin,padding,"+..
	"text-align"
'	"background-image,border,bottom,enabled,font-family,font-style,"+..
'	"font-size,font-weight,halign,hpos,height,left,opacity,position,
'	"right,text-decoration,top,valign,vpos,visibility,width"

' Events
Global EVENT_WIDGET_ADDED:Int     = AllocUserEventId( "Widget Added" )
Global EVENT_WIDGET_CLICK:Int     = AllocUserEventId( "Widget Clicked" )
Global EVENT_WIDGET_GETFOCUS:Int  = AllocUserEventId( "Widget Got Focus" )
Global EVENT_WIDGET_LOSEFOCUS:Int = AllocUserEventId( "Widget Lost FOcus" )
Global EVENT_WIDGET_SELECT:Int    = AllocUserEventId( "Widget Selector" )
'Global EVENT_WIDGET_STYLE:Int     = AllocUserEventId( "Widget Style" )
Global EVENT_SETSTYLE:Int         = AllocUserEventId( "Stylesheet changed" )
Global EVENT_RESTYLE:Int          = AllocUserEventId( "Widget restyle" )


' Cursors
'Global CURSOR_ARROW:Int = 0

Interface IForm
	Method onGui( form:TForm, fld:TFormField )
End Interface

Interface IForm2
	Method OnGUI( form:TForm2, event:TEvent )
End Interface

' DEPRECIATED

' SIZE OF A DEFAULT PALETTE
Const PALETTE_SIZE:Int = 11
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

' DEPRECIATED
Type TFormField
	Global autoincrement:Int = 0
	
	' TYPE DEFINITION
	'Field owner:IForm
	Field fld:TField			' Original field (TypeGui)
	Field fldName:String		' Field name
	Field fldType:String		' Field data type (Blitzmax datatype)
	
	' METADATA
	Field uid:Int
	Field datatype:String		' label, input, checkbox, etc...
	Field caption:String		' text displayed inside clientarea
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
	Field border:Int[]  = [1,1,1,1]		'TRBL
	Field margin:Int[]  = [1,1,1,1]		'TRBL
	Field padding:Int[] = [1,1,1,1]		'TRBL
	Field shadow:Int[]  = [0,0,0,0]		'TRBL
	Field shape:SRectangle = New SRectangle()	' OUTSIDE SIZE
	Field colors:SColor8[5] 
	Field _draw:SRectangle( form:TForm, fld:TFormField, shape:SRectangle )
	Field _client:SRectangle( form:TForm, fld:TFormField, shape:SRectangle )
	
	Method New()
		autoincrement :+ 1
		uid = autoincrement
	End Method
	
	Method New( fieldtype:String, name:String="" )
		autoincrement :+ 1
		uid = autoincrement
		If name = ""; name=fieldtype+uid
		fldName  = name
		datatype = fieldtype
	End Method
	
	Method set( property:Int, value:Int )
		If properties.length < property; properties = properties[..property]
		properties[property] = value
	End Method
	
	Method getwidth:Int()
		Return width + margin[1] + margin[3] + border[1] + border[3] + padding[1] + padding[3]
	End Method
	
	Method getHeight:Int()
		Return height + margin[0] + margin[2] + border[0] + border[2] + padding[0] + padding[2]
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

' NOTE:
' We use a Type here instead of a Struct because we check for NULL
Type TDimension
	Field height:Int
	Field width:Int
	
	Method New( w:Int, h:Int )
		width = w
		height = h
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

'	Method New()
'	End Method
	
	Method New( x:Float, y:Float )
		Self.x = x
		Self.y = x
	End Method
	
End Struct

Struct SRectangle

	Field x:Int
	Field y:Int
	
	Field width:Int
	Field height:Int
	
	Method New( x:Int, y:Int, width:Int, height:Int )
		Self.x = x
		Self.y = y
		Self.width = width
		Self.height = height
	End Method

	Method contains:Int( px:Int, py:Int )
		If px>x And py>y And px<x+width And py<y+height; Return True
		Return False
	End Method
		
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
	
	Method grow( edges:SEdges )
		x :- edges.L
		y :- edges.T
		width :+ (edges.L + edges.R)
		height :+ (edges.T + edges.B)
	End Method
	
	Method grow( T:Int, R:Int, B:Int, L:Int )
		x :- L
		y :- T
		width :+ (L + R)
		height :+ (T + B)
	End Method
		
	'DEPRECIATED
	Method minus:SRectangle( trbl:Int[] )
		Assert trbl.length = 4, "Invalid array detected"
		Return New SRectangle( x+trbl[NL], y+trbl[NT], width-trbl[NL]-trbl[NR], height-trbl[NT]-trbl[NB] )
	End Method

	'DEPRECIATED
	'Method minus:SRectangle( size:SVector )
	'	Self.width :- size.x
	'	Self.height :- size.y
	'	Return Self
	'End Method
	
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

'DEPRECIATED - Use SPoint
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

' An array-backed object to replace TWidget[]
Type TWidgetArray Extends TObjectList

	Method operator[]:TWidget( index:Int )
		Return TWidget( valueAtIndex( index ) )
	End Method

End Type

Type TForm 'Final

	Const BLINKSPEED:Int = 500

	Const NONE:Int = 0
	Const BACKGROUND:Int = 1
	Const SURFACE:Int = 2		' DEPRECIATED
	Const PRIMARY:Int = 3		' DEPRECIATED (USE FOREGROUND)
	Const FOREGROUND:Int = 3	
	Const SECONDARY:Int = 4
	Const DISABLED:Int = 5		' DEPRECIATED
	Const ONBACKGROUND:Int = 6	' DEPRECIATED - Used for border (Margin color)
	Const BORDER:Int = 6
	Const ONSURFACE:Int = 7		' DEPRECIATED
	Const ONPRIMARY:Int = 8		' DEPRECIATED
	Const ONSECONDARY:Int = 9	' DEPRECIATED
	Const ONDISABLED:Int = 10	' DEPRECIATED
	Const CURSOR:Int = 10
		
	Const _CENTRE_:Int = $0001	' For the Brits
	Const _CENTER_:Int = $0001	' For the Americans

	Field MARGIN:Int = 5
	Field PADDING:Int = 4
	
	Field parent:Object 'IForm
	Field title:String
	Field fields:TList			' Widgets in the form
	Field xpos:Int, ypos:Int
	Field width:Int, height:Int
	Field widths:Int[2]
	Field flags:Int = _CENTRE_
	
	Field focus:TFormfield		' Field with focus

	Field palette:SColor8[11]
	
	Field cursorstate:Int
	Field cursortimer:Int
	Field cursorpos:Int
	
	'V05
	Field layout:TLayout
	Field invalid:Int = True
	
	' Manual GUI
	Method New()
	DebugStop
		setPalette( PALETTE_BLUE )
		fields = New TList()
		xpos = -1
		ypos = -1
	End Method
	
	' TypeGUI - View a Type as a GUI
	Method New( form:IForm, fx:Int=-1, fy:Int=-1 )
		parent = form
		fields = New TList()
		' Default colour scheme
		setPalette( PALETTE_BLUE )

		Local t:TTypeId = TTypeId.ForObject( form )
		title = t.metadata("title")
		margin = Int( t.metadata("margin") )
		If margin=0; margin = 5
		padding = Int( t.metadata("padding") )
		If padding=0; padding = 4
		
		height = MARGIN
		Local x:String = title
		Local n:Int = TextHeight( x )
		If title; height :+ TextHeight( title ) + MARGIN
		
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
				row.width = row.height*row.options.length + PADDING*(row.options.length)
				For Local text:String = EachIn row.options
					row.width :+ TextWidth( text )
				Next
			End If
			
			' Calculate column widths
			widths[0] = Max( widths[0], TextWidth( row.caption ) )
			widths[1] = Max( widths[1], row.width )
			height :+ row.height + PADDING
			
			'DebugStop
			fields.addlast( row )

		Next

		' Give focus to first field
		If Not focus; focus = TFormField( fields.first() )
	
		' Calculate size of the form
		width = MARGIN*2 + Max( widths[0] + widths[1], TextWidth(title) ) + PADDING 
		height :+ MARGIN
		
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
		setPalette( PALETTE_BLUE )
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
	
	Method MakeLabel:TFormField( caption:String="" )
		Local widget:TFormField = New TFormfield( "label" )
		' Set Properties
		'DebugStop
		widget.caption = caption
		widget.color( ST_BACKGROUND, Palette[ NONE ] )
		widget.color( ST_FOREGROUND, Palette[ PRIMARY ] )
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
		widget.color( ST_FOREGROUND, Palette[ PRIMARY ] )
		widget.color( ST_BORDER, Palette[ PRIMARY ] )
		widget.color( ST_SHADOW, Palette[ NONE ] )
		widget.color( ST_ALT, Palette[ PRIMARY ] )
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
	
	'Method metadata2map:TMap( fld:TField )
	'	Local map:TMap = New TMap
	'	For Local prop:String = EachIn SUPPORTED_METADATA
	'	Next 		
	'	Return map
	'End Method
	
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

		Local col1:Int = xpos+MARGIN
		Local col2:Int = col1+widths[0]+PADDING
		Local y:Int = ypos+MARGIN		
		
		' Background
		SetColor( palette[ BACKGROUND ] )
		DrawRect( xpos, ypos, width, height )
		' Border
		drawborder( PRIMARY, xpos, ypos, width, height )
		' Title
		If title
			SetColor( palette[ PRIMARY ] )
			DrawRect( col1-MARGIN, y-MARGIN, width, TextHeight(title) )
			SetColor( palette[ ONPRIMARY ] )
			DrawText( title, col1, y-MARGIN+2 )
			y :+ TextHeight( title ) + MARGIN
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
						drawBorder( PRIMARY, col2, y, widths[1], fld.height )
					ElseIf hasfocus( fld )
						'drawBorder( SECONDARY, col2, y, fld.width, fld.height )
						drawBorder( SECONDARY, col2, y, widths[1], fld.height )
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
				DrawText( fld.caption, col2+fld.height+PADDING, y+2 )	' We use height here to make a square!
				' BACKGROUND
				colour( fld.disable, DISABLED,SURFACE )
				'SetColor( Palette[ SURFACE ] )
				DrawRect( col2, y, fld.height, fld.height )		' We use height here to make a square!
				' BORDER
				If Not fld.disable
					If inside
						drawBorder( PRIMARY, col2, y, fld.height, fld.height )
					ElseIf hasfocus( fld )
						drawBorder( SECONDARY, col2, y, fld.height, fld.height )
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
				Local value:Int = fld.fld.geatInt( parent )
				
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
					px :+ fld.height + PADDING*2 + TextWidth( text )
				Next				
				' SET FIELD VALUE
				fld.fld.setInt( parent, value )
			Default
				SetColor( palette[ ONBACKGROUND ] )
				'DrawText( fld.caption, col1, y )
				DrawRect( col1-MARGIN, y+fld.height*0.5, width, 1 )
			End Select
			y:+fld.height+PADDING			
		Next
	
		' Throw away mouseclicks within the form
		' Without this, clicking in the form and moving to a button clicks it.
		If boundscheck( xpos, ypos, width, height ); FlushMouse()

	End Method
	
	' Object Inspector
	Method inspect:Int()
		' Do we need to perform a layout?
		'DebugStop
		
		If Invalid
			If layout; layout.run( Self )
			Invalid = False
		End If
		
		Local col1:Int = xpos+MARGIN
		Local col2:Int = col1+widths[0]+PADDING
		Local y:Int = ypos+MARGIN
		Local column:Int = 0
		
		' Background
		SetColor( palette[ BACKGROUND ] )
		DrawRect( xpos, ypos, width, height )
		' Border
		drawborder( PRIMARY, xpos, ypos, width, height )
		
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
	
	' V05
	Method add( fld:TFormField )
		fields.addlast( fld )
	End Method

	Method add( fieldtype:String, name:String )
		fields.addlast( make( fieldtype, name ) )
	End Method
	
	Method make:TFormField( fieldtype:String, name:String )
		Local fld:TFormField = New TFormField( fieldtype:String, name:String )
		
		Select fieldtype
		Case "label"
			fld.border = [0,0,0,0]
			fld.margin = [1,1,1,1]
			fld.shadow = [0,0,0,0]
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
				If form; form.onGUI( Self, fld )
			End If
			pressed = MouseDown(1) And inside
		End If
		' BACKGROUND
		colour( fld.disable, DISABLED, PRIMARY )
		'SetColor( palette[ PRIMARY ] )
		DrawRect( col1+pressed, y+pressed, fld.width, fld.height )
		If Not pressed And Not fld.disable
			SetColor( $22,$22,$22 )
			DrawLine( col1+fld.width, y,            col1+fld.width, y+fld.height )
			DrawLine( col1,           y+fld.height, col1+fld.width, y+fld.height )
		End If
		' BORDER
		If inside And Not fld.disable
			drawBorder( SECONDARY, col1+pressed, y+pressed, fld.width, fld.height )
		'ElseIf hasfocus( fld )
		'	drawBorder( SECONDARY, col1+pressed, y+pressed, fld.width, fld.height )
		End If
		' FOREGROUND
		colour( fld.disable, ONDISABLED, ONPRIMARY )
		'SetColor( palette[ ONPRIMARY ] )
		DrawText( value, col1+(col2-col1-PADDING-TextWidth(value))/2+pressed, y+pressed+1 )
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

	Method SetPalette( element:Int, color:Int )
		Assert element >=0 And element < palette.length, "Invalid colour element"
		Self.palette[ element ] = New SColor8( color )
	End Method

	Method setPalette( palette:Int[] )
		Assert palette.length = Self.palette.length, "Invalid palette"
		For Local element:Int = 0 Until palette.length
			SetPalette( element, palette[element] )
		Next
	End Method
	
	Function boundscheck:Int( x:Int, y:Int, w:Int, h:Int )
		If MouseX()>x And MouseY()>y And MouseX()<x+w And MouseY()<y+h; Return True
		Return False
	End Function
	
	Method drawborder( colour:Int, x:Int, y:Int, w:Int, h:Int )
		SetColor( palette[ colour ] )
		DrawLine( x,     y,     x+w-1, y )
		DrawLine( x+w-1, y,     x+w-1, y+h-1 )
		DrawLine( x+w-1, y+h-1, x,     y+h-1 )
		DrawLine( x,     y+h-1, x,     y )
	End Method
	
	Method hasfocus:Int( fld:TFormField )
		Return (focus = fld)
	End Method
	
	Method setfocus( fld:TFormField )
		focus = fld 
	End Method
	
	Method Disable( caption:String )
        For Local r:TFormField = EachIn fields
            If r.caption=caption; r.disable=True
        Next
    End Method

    Method Enable( caption:String )
        For Local r:TFormField=EachIn fields
            If r.caption=caption; r.disable=False
        Next
    End Method
	
End Type

' Draw a default widget - Must return client area
Function _DrawWidget:SRectangle( form:TForm, widget:TFormField, shape:SRectangle )
	'DebugStop
	Local area:SRectangle
	' BORDER
	SetColor( widget.colors[ ST_BORDER ] )
	area = shape.minus( widget.margin )
	DrawRect( area.x, area.y, area.width, area.height )
	' BACKGROUND
	SetColor( widget.colors[ ST_BACKGROUND ] )
	area = area.minus( widget.border )
	DrawRect( area.x, area.y, area.width, area.height )
	' PADDING
	Return area.minus( widget.padding )
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

' Global system cursor
Rem
Type TCursor

	Global style:Int = CURSOR_ARROW

	Function set( style:Int )
		Self.style = style
	End Function
	
	Function reset()
		style = CURSOR_ARROW
	End Function
	
	Function draw( x:Int, Y:Int )
		SetColor( $ff, $ff, $ff )
		DrawLine( x-8, y-8, x+8, y+8 )
		DrawLine( x-8, y+8, x+8, y-8 )
			
	End Function
	
End Type
EndRem

Type TLayout

	Method run( form:TForm ); End Method
	Method run( form:TContainer, resize:Int = False ); End Method
	
End Type

Interface ILayout
	Method run()
	Method invalidate()
	Method getMinimumSize:TDimension()
	Method repositionChildren()
End Interface

' A Very simple layout
Type TInspectorLayout Extends TLayout

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
		form.height = minheight + form.MARGIN*2 + form.PADDING*(heights.length-1)
		form.width = minwidth + form.MARGIN*2 + form.PADDING*(COLUMNS-1)
		
		' Centralise form (if Required )
		'Print( Hex(flags) )
		If ( form.flags & form._CENTRE_ )
			form.xpos = (GraphicsWidth()-form.width)/2
			form.ypos = (GraphicsHeight()-form.height)/2		
		End If
		
		' Loop through gadgets, setting their positions
		Local y:Int = form.ypos + form.margin
		Local x:Int = form.xpos + form.margin
		id = 0
		For Local widget:TFormField = EachIn form.fields
			col = id Mod COLUMNS 
			row = id / COLUMNS
			widget.setShape( x+xsum[col], y+ysum[row], widths[col], heights[row] )
			id :+ 1
		Next
	
	End Method

End Type


' Box Layout
' also known as Vertical/Horizontal or Row/Column.
Type TBoxLayout Implements ILayout

	Private
	
	Field container:TContainer					' Object we are attached to
	Field direction:Int = LAYOUT_VERTICAL		' 0=Horizontal, 1=Vertical
	Field valid:Int = False
		
	' We use these to hold children properties
	Field children:TWidgetArray					' Children (excluding invisible ones)
	Field minSizes:TDimension[]					' Minimum sizes of all children
	Field maxSizes:TDimension[]					' Maximum sizes of all children
	Field bids:Int[]							' Child expansion bids
	Field sizes:SRectangle[]				    ' Calculated children position & size
	
	' These are used in the calculations for the space used
	Field minSize:TDimension = New TDimension()		' Minimum size of a row/column
	Field minSizeSum:TDimension = New TDimension()	' Total size of a row/column
	Field maxSize:TDimension = New TDimension()		' Maximum size of all children
	Field maxSizeSum:TDimension = New TDimension()	' Maximum size of row/column
	Field totalBids:Int
	
	Public
	
	Method New( container:TContainer )
		container.layout = Self
		Self.container = container
		Self.direction = LAYOUT_VERTICAL
	End Method

	Method New( container:TContainer, direction:Int )
		container.layout = Self
		Self.container = container
		Self.direction = direction
	End Method

	' Invalidates the layout forcing it to recalculate
	Method invalidate()
		children = Null
		valid = False
	End Method

	' Gets the minimum size required for a layout
	' This will be used to resize the parent
	Method getMinimumSize:TDimension()
		If Not valid; calculateSizes()
		
		If direction = LAYOUT_HORIZONTAL
			Return New TDimension( minSizeSum.width, minSize.height )
		Else
			Return New TDimension( minSize.width, minsizeSum.height )
		End If
		
	End Method
	
	' Begin the layout process
	Method run()
		If valid; Return
		
		' Calculate sizes of all children
		calculateSizes()

		' Distribute space
		If direction = LAYOUT_HORIZONTAL
			distributeHorizontal()
		Else
			distributeVertical()
		End If

		' Reposition children
		repositionChildren()

		valid = True		
	End Method
	
	' Reposition children
	' Should also be called after form is moved
	Method repositionChildren()
		Local area:SRectangle = container.getInner()
		'DebugStop
		For Local index:Int = 0 Until children.count()
			Local child:TContainer = TContainer( children[index] )
			child.setBounds( ..
				area.x+sizes[index].x, ..
				area.y+sizes[index].y, ..
				sizes[index].width, ..
				sizes[index].height )
			'child.bounds.x = area.x+sizes[index].x
			'child.bounds.y = area.y+sizes[index].y
			'child.bounds.width = sizes[index].width
			'child.bounds.height = sizes[index].height
			' Copy bounds and shrink it
			'child.outer = child.bounds
			'child.outer.shrink( child.margin )
			' Copy outer and shrink it
			'child.inner = child.outer
			'child.inner.shrink( child.padding )
		Next		
	End Method
	
	Private

	Method calculateSizes()
		'DebugStop
		' Get array of Children to work from
		' This excludes any that are invisible
		children = container.getWidgets()
		
		' Get sizes of children, calculating MIN and MAX
		minSizes   = New TDimension[ children.count() ]
		maxSizes   = New TDimension[ children.count() ]
		sizes      = New SRectangle[ children.count() ]
		bids       = New Int[ children.count() ]
		
		minSize    = New TDimension()
		minSizeSum = New TDimension()
		maxSize    = New TDimension()
		maxSizeSum = New TDimension()
		totalbids  = 0
		
		' Request Information from children
		For Local index:Int = 0 Until children.count()
			Local child:TContainer = TContainer(children[index])
			' Minimum sizes
			minSizes[index] = child.getMinimumSize()
			minSize.width  = Max( minSize.width, minSizes[index].width )
			minSize.height = Max( minSize.height, minSizes[index].height )
			minSizeSum.width  :+ minSizes[index].width
			minSizeSum.height :+ minSizes[index].height
			' Maximum sizes
			maxSizes[index] = child.getMaximumSize()
			maxSize.width  = Max( maxSize.width, maxSizes[index].width )
			maxSize.height = Max( maxSize.height, maxSizes[index].height )
			maxSizeSum.width  :+ maxSizes[index].width
			maxSizeSum.height :+ maxSizes[index].height
			' Get child expansion bid
			If direction = LAYOUT_HORIZONTAL
				bids[index] = child.getBids().x
			Else
				bids[index] = child.getBids().y
			End If
			totalBids :+ bids[index]
			' Set child initial size to minimum
			sizes[index].width = minSizes[index].width
			sizes[index].height = minSizes[index].height
			'Print child.name+ ", w="+sizes[index].width+", h="+sizes[index].height 
		Next
		
		'DebugStop
	End Method
	
	Method distributeHorizontal()
		' Get Container size (this is the space we have to work inside)
		Local area:SRectangle = container.getBounds()
		Local edges:SEdges    = container.getEdges()

		' Calculate surplus space
'		DebugStop
		Local surplus:Int = area.width - minSizesum.width

		' If we dont have space, turn on scrollbars or something!
'		If surplus < 0; Return
' TODO: Auto Scrollbars?
'		End If		

		Local available:Float = surplus
		While available>children.count() And totalBids>0
			
			'# Get the allocation for each bid
			Local alloc:Float = available / totalbids
			
			'# Calculate new size by splitting surplus between bidders
			For Local index:Int = 0 Until children.count()
				If bids[index] = 0; Continue
				
				' Add allocation to widget
				Local allocation:Float = alloc * bids[index]
				
				' Check that child will not expand past maximum
				If sizes[index].width + allocation > maxSizes[index].width
					bids[index] = 0 ' Remove from future bidding
					sizes[index].width = maxsizes[index].width
					allocation :- ( maxSizes[index].width - sizes[index].width )
					available :- allocation
				Else
					sizes[index].width :+ allocation
					available :- allocation
				End If
				
			Next
			
		Wend
		
		' Calculate new position
		Local xpos:Int = edges.L
		For Local index:Int = 0 Until children.count()
			sizes[index].x = xpos
			sizes[index].y = edges.T
			xpos :+ sizes[index].width
			sizes[index].height = minSize.height
		Next
	
	End Method
	
	Method distributeVertical()
		' Get Container size (this is the space we have to work inside)
		Local area:SRectangle = container.getBounds()
		Local edges:SEdges    = container.getEdges()

		' Calculate surplus space
		Local surplus:Int = area.height - minSizesum.height

		' If we dont have space, turn on scrollbars or something!
'		If surplus < 0; Return
' TODO: Auto Scrollbars?
'		End If

		' Loop through children allocating available space

		Local available:Float = surplus
		While available>children.count() And totalBids>0
			
			'# Get the allocation for each bid
			Local alloc:Float = available / totalbids
			
			'# Calculate new size by splitting surplus between bidders
			For Local index:Int = 0 Until children.count()
				If bids[index] = 0; Continue
				
				' Add allocation to widget
				Local allocation:Float = alloc * bids[index]
				
				' Check that child will not expand past maximum
				If sizes[index].height + allocation > maxSizes[index].height
					bids[index] = 0 ' Remove from future bidding
					sizes[index].height = maxsizes[index].height
					allocation :- ( maxSizes[index].height - sizes[index].height )
					available :- allocation
				Else
					sizes[index].height :+ allocation
					available :- allocation
				End If
				
			Next
			
		Wend
		
		' Calculate new position
		'DebugStop
		Local ypos:Int = edges.T
		For Local index:Int = 0 Until children.count()
			sizes[index].x = edges.L
			sizes[index].y = ypos
			ypos :+ sizes[index].height
			sizes[index].width = minSize.width
		Next

	End Method
		
End Type

' A Layout Node is used by a layout to calculate grid sizes
'Type SLayoutNode
'	Field minsize:SPoint
'End Type

Type TGridLayout Implements ILayout

	Private
	
	Field container:TContainer					' Object we are attached to
	'Field direction:Int = LAYOUT_VERTICAL		' 0=Horizontal, 1=Vertical
	Field columns:Int = 2						' Default size, 2 Columns
	Field rows:Int = AUTO						' Expands in "ROW" direction
	Field valid:Int = False

	Field minSize:TDimension					' Minimum size of layout
		
	' We use these to hold children properties
	Field children:TWidgetArray					' Children (excluding invisible ones)
	'Field minSizes:TDimension[]					' Minimum sizes of all children
	'Field maxSizes:TDimension[]					' Maximum sizes of all children
	Field sizes:SRectangle[]				    ' Calculated grid position & size
	
	' These are used in the calculations for the space used
	'Field calc:TLayoutNode[]					' Calculations for each child cell

	' We use these to hold grid properties
	Field gridw:Int, gridh:Int						' Calculated grid dimensions
	
	'Field row_bids:Int[]							' Expansion bids per row
	Field minHeight:Int[]							' Minumum height is max of children minimums
	Field maxHeight:Int[]							' Maximum height of rows
	
	'Field col_bids:Int[]							' Expansion bids per column
	Field minWidth:Int[]							' Minumum width is max of children minimums
	Field maxWidth:Int[]							' Maximum width of a column
	
	Field compoundHeight:Int[]
	Field compoundWidth:Int[]

	'Field minRowHeights:Int[]						' Minimum height of rows
	'Field minRowHeightSum:Int[]						' Total minimum height size of row
	'Field minColWidths:Int[]						' Minimum size of columns
	'Field minColWidthSum:Int[]						' Total minimum size of a columns
	'Field maxRowHeights:Int[]						' Maximum size of rows
	'Field maxRowHeightSum:Int[]						' Total maximum size of row
	'Field maxColWidths:Int[]						' Maximum size of columns
	'Field maxColWidthSum:Int[]						' Total maximum size of a columns

	'Field HeightBids:Int[]							
	'Field WidthBids:Int[]							

	'Field totalBids:SPoint
	
	Public

	Method New( container:TContainer )
		container.layout = Self
		Self.container = container
		Self.columns = 2
		Self.rows = AUTO
	End Method

	Method New( container:TContainer, cols:Int, rows:Int=AUTO )
		container.layout = Self
		Self.container = container
		Self.columns = cols
		Self.rows = rows
	End Method

	' Gets the minimum size required for a layout
	' This will be used to resize the parent
	Method getMinimumSize:TDimension()
'DebugStop
		If Not valid; calculateSizes()
		Return New TDimension( minSize.width, minsize.height )
	End Method
	
	' Invalidates the layout forcing it to recalculate
	Method invalidate()
DebugStop
		children = Null
		valid = False
	End Method
	
	Method setColumns( value:Int )
		columns = value
	End Method

	Method setRows( value:Int )
		rows = value
	End Method
	
	Method setSize( horz:Int, vert:Int )
		columns = horz
		rows = vert
	End Method

	' Reposition children into grid
	' Should also be called after form is moved
	Method repositionChildren()
		Local area:SRectangle = container.getInner()
				
		'DebugStop
		For Local index:Int = 0 Until children.count()
			Local RowID:Int = index / gridw
			Local ColID:Int = index Mod gridw
			
			' Calculate position of the cell within the grid
			Local cell:SRectangle = New SRectangle()
			cell.x = compoundWidth[ ColID ] + area.x
			cell.y = compoundHeight[ RowID ] + area.y 
			cell.width = minWidth[ ColID ] 
			cell.height = minHeight[ RowID ] 

			' Calculate new position
'		Local xpos:Int = edges.L
'		For Local index:Int = 0 Until children.count()
'			sizes[index].x = xpos
'			sizes[index].y = edges.T
'			xpos :+ sizes[index].width
'			sizes[index].height = minSize.height
		
		
				
			' Position the child
			Local child:TContainer = TContainer( children[index] )
			child.setBounds( cell.x, cell.y, cell.width, cell.height )
				'cell.x+sizes[index].x, ..
				'cell.y+sizes[index].y, ..
				'sizes[index].width, ..
				'sizes[index].height )
			'child.bounds.x = area.x+sizes[index].x
			'child.bounds.y = area.y+sizes[index].y
			'child.bounds.width = sizes[index].width
			'child.bounds.height = sizes[index].height
			' Copy bounds and shrink it
			'child.outer = child.bounds
			'child.outer.shrink( child.margin )
			' Copy outer and shrink it
			'child.inner = child.outer
			'child.inner.shrink( child.padding )
		Next		
	End Method
		
	Method run()
		DebugStop
		If valid; Return
		
		' Calculate sizes
		calculateSizes()

		' Distribute space
		distributeSpace()
		
		' Reposition children
		repositionChildren()		
		
		valid = True
	End Method

	Private

	Method calculateSizes()
DebugStop
DebugLog( "#TGridLayout - calculateSizes()" )
		' Get array of Children to work from
		' This excludes any that are invisible
		children = container.getWidgets()
				
		' Identify size of grid
		If columns = AUTO And rows = AUTO
			' Make it a square if both are AUTO
			gridw = Sqr( children.count() )
			gridh = gridw
		ElseIf columns = AUTO
			gridw = Ceil( children.count() / rows )
			gridh = rows
		ElseIf rows = AUTO
			gridw = columns
			gridh = Ceil( children.count() / columns )
		Else
			gridw = columns
			gridh = rows
		End If
		
		' Get sizes of grid, calculating MIN and MAX

		'row_bids   = New Int[ gridh ]		
		'col_bids   = New Int[ gridw ]

		minHeight = New Int[ gridh ]
		maxHeight = New Int[ gridh ]

		minWidth = New Int[ gridw ]
		maxWidth = New Int[ gridw ]
		
		compoundHeight = New Int[ gridh ]
		compoundWidth  = New Int[ gridw ]
		
		'minSizes   = New TDimension[ children.count() ]
		'maxSizes   = New TDimension[ children.count() ]
		'sizes      = New SRectangle[ children.count() ]
				
		'minColWidths = New Int[ gridw ]
		'minRowHeights = New Int[ gridh ]
		'minColWidthSum = New Int[ gridw ]
		'minRowHeightSum = New Int[ gridh ]

		'HeightBids = New Int[ gridh ]
		'WidthBids = New Int[ gridw ]
		
		'maxSize    = New TDimension()
		'maxSizeSum = New TDimension()
		'totalbids  = 0
'DebugStop
		' Request Information from children
		For Local index:Int = 0 Until children.count()
			Local size:TDimension
			Local RowID:Int = index / gridw
			Local ColID:Int = index Mod gridw
			
			'If Not grid[ gridw, gridh ]; grid[ gridw, gridh ] = New TLayoutNode()
			'Local node:TLayoutnode = grid[ gridw, gridh ]
			'
			Local child:TContainer = TContainer(children[index])
			
			' Minimum sizes
			size             = child.getMinimumSize()
			minWidth[ColID]  = Max( minWidth[ColID], size.width )
			minHeight[RowID] = Max( minHeight[RowID], size.height )
			
			'minSizes[index] = child.getMinimumSize()
			'minColWidths[rowid] = Max( minColWidths[rowid], minSizes[index].width )
			'minRowHeights[colid] = Max( minRowHeights[colid], minSizes[index].height )
			'minColWidthSum[rowid] :+ minSizes[index].width
			'minRowHeightSum[colid] :+ minSizes[index].height
			' Maximum sizes
			size             = child.getMaximumSize()
			maxWidth[ColID]  = Max( maxWidth[ColID], size.width )
			maxHeight[RowID] = Max( maxHeight[RowID], size.height )
			'maxSizes[index] = child.getMaximumSize()
			'maxColWidths[rowid] = Max( maxColWidths[rowid], maxSizes[index].width )
			'maxRowHeights[colid] = Max( maxRowHeights[colid], maxSizes[index].height )
			'maxColWidthSum[rowid] :+ maxSizes[index].width
			'maxRowHeightSum[colid] :+ maxSizes[index].height
			' Get expansion bids
			'Local bids:SPoint = child.getBids()
			'WidthBids[ColID]  = Max( bids.x, WidthBids[ColID] )
			'HeightBids[RowID] = Max( bids.y, HeightBids[RowID] )
			'totalBids.x :+ bids.x
			'totalColBids[colid] :+ bids.y
		Next
		
		' Calculate grid positions
		
		' Set child initial size to minimum
		'For Local index:Int = 0 Until children.count()
			'Local rowid:Int = index Mod gridw
			'Local colid:Int = index / gridw
			'sizes[index].width = minColWidths[rowid]
			'sizes[index].height = minRowHeights[colid]
			'Print child.name+ ", w="+sizes[index].width+", h="+sizes[index].height 
		'Next

		' Calculate minimum size of the grid
'DebugStop
		minsize = New TDimension( 0,0 )
		Local sum:Int
		'totalbids = New SPoint()
		For Local rowid:Int = 0 Until gridh
			'minsize.height :+ minHeight[RowID]
			'totalbids.y :+ HeightBids[RowID]
			compoundHeight[RowID] = sum
			sum :+ minHeight[RowID]
		Next
		minsize.height = sum
		sum = 0
		For Local colid:Int = 0 Until gridw
			'minsize.width :+ minWidth[ColID]
			'totalbids.x :+ WidthBids[ColID]
			compoundWidth[ColID] = sum
			sum :+ minWidth[ColID]
		Next
		minsize.width = sum
		
	End Method

	' In a grid layout, this is only used to turn on automatic Scrollbars
	Method distributeSpace()
	
'DebugStop

		' Get Container size (this is the space we have to work inside)
		Local area:SRectangle = container.getInner()
		'Local edges:SEdges    = container.getEdges()

		' Calculate surplus space
'		DebugStop
		Local surplus:SPoint = New SPoint( area.width - minSize.width, area.height - minSize.height )
		
		' If we dont have space, turn on scrollbars or something!
'		If surplus.x < 0 or surplus.y < 0; Return
' TODO: Auto Scrollbars?
'		End If

		' Grids do not expand like other layouts, so bidding is not relevant here

	End Method
	
Rem	Method distributeSpace()
		' Get Container size (this is the space we have to work inside)
		Local area:SRectangle = container.getBounds()
		Local edges:SEdges    = container.getEdges()

		' Calculate surplus space
'		DebugStop
		Local surplus:SPoint = New SPoint( area.width - minSize.width, area.height - minSize.height )

		' If we dont have space, turn on scrollbars or something!
'		If surplus.x < 0 or surplus.y < 0; Return
' TODO: Auto Scrollbars?
'		End If

		' Allocate space to grid (Children will then use that space)

		Local available:SPoint = surplus
		
		' Rows First!
		While available.y>children.count() And totalBids.y>0
			
			'# Get the allocation for each bid
			Local alloc:Float = available.y / totalbids.y
			
			'# Calculate new size by splitting surplus between bidders
			For Local rowid:Int = 0 Until gridh
				If heightBids[rowid] = 0; Continue
				
				' Add allocation to grid
				Local allocation:Float = alloc * heightBids[rowid]
				
				' Check that grid will not expand past maximum
				If sizes[index].height + allocation > maxRowHeight[rowid]
					heightBids[rowid].y = 0 ' Remove from future bidding
					sizes[rowid].height = maxRowHeight[rowid]
					allocation :- ( maxRowHeight[rowid] - sizes[rowid].width )
					available :- allocation
				Else
					sizes[index].height :+ allocation
					available :- allocation
				End If
				
			Next
			
		Wend
		
		' Columns Next
		While available.x>children.count() And totalBids.x>0
			
			'# Get the allocation for each bid
			Local alloc:Float = available.x / totalbids.x
			
			'# Calculate new size by splitting surplus between bidders
			For Local colID:Int = 0 Until gridw
				If WidthBids[colID] = 0; Continue
				
				' Add allocation to grid
				Local allocation:Float = alloc * WidthBids[colID]
				
				' Check that grid will not expand past maximum
				If sizes[index].height + allocation > maxColWidth[colID]
					WidthBids[colID].y = 0 ' Remove from future bidding
					sizes[colID].height = maxRowHeight[colID]
					allocation :- ( maxRowHeight[colID] - sizes[colID].height )
					available :- allocation
				Else
					sizes[index].width :+ allocation
					available :- allocation
				End If
				
			Next
			
		Wend		
		
		
		' Calculate new position
		Local xpos:Int = edges.L
		For Local index:Int = 0 Until children.count()
			sizes[index].x = xpos
			sizes[index].y = edges.T
			xpos :+ sizes[index].width
			sizes[index].height = minSize.height
		Next
	
	End Method
EndRem		
End Type


' UI MANAGER
' TODO: NOT CURRENTLY IMPLEMENTED

' Will be used to allow you to stack gui's

Type UI
	
	Field stack:TList = New TList
	
	' Manual
	Method New()
		stack = New TList
	End Method
	
	' Draw ALL GUIS on the stack, but only give focus to the top one
	Method show()
		Local top:TContainer = TContainer( stack.last() )
		For Local child:TContainer = EachIn stack
'			If child.invalid; child.update()
'			child.render( top=child )
		Next
	End Method
	
	Method push( panel:TContainer )
		stack.addlast( panel )
	End Method
	
	Method pop:TContainer()
		Return TPanel( stack.removeLast() )
	End Method
	
	Method popall()
		stack.clear()
	End Method
	
End Type

' Extends TFormfield until we manage to merge them
Type TWidget ' Extends TFormField

	Global autonumber:UInt=0	' Used by GenerateName() to create unique field names
	
	Private
	
	'Field classid:String=""		' Used by GenerateName() to create unique field names
	Field link:TLink			' Link to parents Tlist
	'
	Field name:String
	Field nameset:Int=False		' True if set by user, False if generated
	Field parent:TContainer
	'Field x:Int, y:Int, width:Int, height:Int	' Outside size of component
	
	' ATTRIBUTES
'TODO: Move into bitmask
'Enum ATTR
'	VISIBLE=0
'	ENABLED,
'	VALID,
'	CANFOCUS
'	HASFOCUS
'	MOUSEOVER
'	PACKED
'End Enum
'setAttribute( attrib:ATTR )
'clearAttribute( attrib:ATTR )
'getAttribute:int( attrib:ATTR )
	Field visible:Int = True
	Field enabled:Int = True
	'Field valid:Int = False
	Field restyle:Int = True			' Is a re-styling required?
	Field relayout:Int = True			' Is a re-layout required?
	
	'Field dropTarget:Int
	'Field popups:Tlist
	Field canfocus:Int		' Can widget receive focus
	Field focus:Int			' Does widget have focus
	Field mouseover:Int		' Is mouse over me?
	Field packed:Int = False		' True when layed out

	' Minimum and Maximum sizes.
	Field minSize:TDimension
	Field minSizeset:Int = False
	Field maxSize:TDimension
	Field maxSizeset:Int = False

	' Component Alignment
'TODO: Move into SAlignment struct
	Field align:SAlign = New SAlign( ALIGN_CENTRE, ALIGN_MIDDLE )
	'Field alignX:Float = ALIGN_CENTRE
	'Field alignY:Float = ALIGN_CENTRE
	
	' Theme, Palette and Style
	Field palette:SColor8[PALETTE_SIZE]
	Field stylesheet:TStylesheet
	Field classlist:TSet<String>
	'Field font:TFont
	'Field cursor:TCursor
	Field textAlign:SAlign = New SAlign()

	Public Function __PUBLIC__()
	End Function
	
	Method New()
		name = generateName()
	End Method

'	Method getAttribute:int( attrib:int )
'		return ( attribute | ($0001 shl atrib )) = 0
'	End Method

'	Method setAttribute:int( attrib:int )
'		attribute = ( attribute | ($0001 shl atrib ))
'	End Method

'	Method unsetAttribute:int( attrib:int )
'		return ( attribute  not ($0001 shl atrib ))
'	End Method

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
	
	Method getAlign:SAlign()
		Return align
	End Method

	Method getMaximumSize:TDimension() Abstract
	Method getMinimumSize:TDimension() Abstract

	Method GetName:String()
		If name="" And Not nameset; GenerateName()
		Return name
	End Method

	Method getPalette:SColor8( index:Int )
		Assert index >=0 And index < palette.length, "Invalid colour element"
		Return palette[ index ]
	End Method
	
	Method getParent:TWidget()
		Return parent
	End Method
	
	Method invalidateLayout()
		valid_layout = False
		If parent; parent.invalidateLayout()
	End Method

	Method invalidateStyle()
		restyle = True
	End Method
	
	Method isEnabled:Int()
		Return enabled
	End Method

	Method isVisible:Int()
		Return visible
	End Method

	'
	Method onKey:Object( event:TEvent ); End Method
	Method onKeyDown:Object( event:TEvent ); End Method
	Method onKeyUp:Object( event:TEvent ); End Method
	'
	Method onMouseClick:Object( event:TEvent ); End Method
	Method onMouseDown:Object( event:TEvent ); End Method
	Method onMouseEnter:Object( event:TEvent )
		mouseOver = True
		restyle()
		Return Null
	End Method
	Method onMouseLeave:Object( event:TEvent )
		mouseOver = False
		restyle()
		Return Null
	End Method
	Method onMouseMove:Object( event:TEvent ); End Method
	Method onMouseUp:Object( event:TEvent ); End Method
	'
	Method onGetFocus:Object( event:TEvent ) ; End Method
	Method onLoseFocus:Object( event:TEvent ) ; End Method
	
	Method removeClass( class:String )
		If Not classlist; Return
		classlist.remove( Lower(class) )
	End Method
	
	Method setAlign( x:Float, y:Float )
		align = New SAlign( x, y )
		'alignX = x
		'alignY = y
	End Method
		
	Method setEnabled( state:Int = True )
		enabled = state
	End Method

	Method setFocus( state:Int = True )
		If canfocus; focus = state
	End Method

	' Set maximum Size (Null clears)
	Method setMaxSize( size:TDimension )
		maxSize = size
		maxSizeSet = ( size <> Null )
	End Method

	' Set minimum Size (Null clears)
	Method setMinSize( size:TDimension )
		If Not minSize; minsize = New TDimension
		minSize = size
		minSizeSet = ( size <> Null )
	End Method

	Method setMinSize( w:Int, h:Int )
		minSize = New TDimension( w, h )
		minSizeSet = True
	End Method
	
	Method setName( name:String )
		nameset = True
		Self.name = name		
	End Method

	Method SetPalette( element:Int, color:Int )
		Assert element >=0 And element < palette.length, "Invalid colour element"
		Self.palette[ element ] = New SColor8( color )
	End Method

	Method setPalette( palette:Int[] )
	'Print palette.length
	'Print Self.palette.length
		Assert palette.length = Self.palette.length, "Invalid palette"
		For Local element:Int = 0 Until palette.length
			SetPalette( element, palette[element] )
		Next
	End Method

	Method setPalette( palette:SColor8[] )
		Assert palette.length = Self.palette.length, "Invalid palette"
		Self.palette = palette
	End Method

	Method setStyle( style:TStylesheet )
		Local same:Int = (style = stylesheet)
		If same; Return
		'
		If Not style; style = New TStylesheet()
		stylesheet = style
		'
		forward( EVENT_SETSTYLE, stylesheet )
		restyle = True
	End Method

	Method setTextAlign( x:Float, y:Float )
		textAlign = New SAlign( x, y )
	End Method

	Method setVisible( state:Int = True )
		visible = state
	End Method

	Method toggleClass( class:String )
		If Not classlist; classlist = New TSet<String>
		class = Lower(class)
		If classlist.contains( class )
			classlist.remove( class )
		Else
			classlist.add( class )
		End If
	End Method
	
	Method render() ; End Method

	Protected
	
	Function __PROTECTED__()
	End Function

	Method forward:Object( event:Int, data:Object )
		Select event
		Case EVENT_SETSTYLE
			stylesheet = TStylesheet( data )
			restyle = True
		Case EVENT_RESTYLE
			If Not stylesheet; stylesheet = TStylesheet( data )
			If restyle; stylesheet.apply( Self )
			restyle = False
		End Select
	End Method
	
	Method generateName:String()
		'If classid=""; classid = TTypeId.forObject( Self ).name()
		autonumber :+ 1
		'Return classid+":"+Hex(autonumber)
		Return Hex(autonumber)
	End Method
	
	Method validate()
		If Not restlye; Return
		If stylesheet; stylesheet.apply( Self )
		restyle = False
	End Method
	
End Type

Type TContainer Extends TWidget

	Private
	
	Field children:TList

	' Edges
	Field margin:SEdges = New SEdges(0)
	Field padding:SEdges = New SEdges(0)

	' Calculated positions
	Field bounds:SRectangle		' Screen space including margin
	Field outer:SRectangle		' Area including padding
	Field inner:SRectangle		' Client area inside padding

	' Bids are used in the calculation of expansion and indicate how many
	' Portions of the available space are allocated to the widget (X and Y)
	Field bids:SPoint = New SPoint(0,0)

	' MouseOver
	Field canMouseover:Int = True
	Field mouseinside:Int = False
	
	Public
	
	Field layout:ILayout

	Method add:TWidget( widget:TWidget )
		Return addWidget( widget, "" )
	End Method

	Method add:TWidget( widget:TWidget, name:String )
		Return addWidget( widget, name )
	End Method

	Method addStyle( style:TStylesheet )
		If Not style; Return
		If stylesheet And stylesheet<>style
			stylesheet.merge( style )		' Add to existing stylesheet
		Else
			stylesheet = style				' Use as stylesheet
		End If
		forward( EVENT_SETSTYLE, stylesheet )
		restyle = True
	End Method

	Method contains:Int( x:Int, y:Int )
		Return outer.contains( x, y )
	End Method

	' Widget event dispatcher bubbles an event up the tree
	'Method dispatch( event:Int, source:Int, data:Int, mods:Int, x:Int, y:Int, extra:Object )
	Method dispatch( event:Int, source:Object )
		bubble( CreateEvent( event, source ) )
	End Method

	Method getBids:SPoint()
		Return bids
	End Method
			
	' Get Bounding box
	Method getBounds:SRectangle()
		Return bounds
	End Method

	' Get client area
	Method getInner:SRectangle()
		Return inner
	End Method
		
	Method getMaximumSize:TDimension()
		If maxSize And maxSizeset; Return New TDimension( maxSize )
		Return New TDimension( outer.width, outer.height )
	End Method
	
	' Minimum size of a container is sum of children unless manually overridden
	Method getMinimumSize:TDimension()
		Assert layout, "Missing Layout Manager"
		Local size:TDimension
		Local edges:Sedges = getEdges()

		' Manual minimum size has been set
		If minsizeset
			size = New TDimension()
			size.width  = edges.L + edges.R + minsize.width
			size.height = edges.T + edges.B + minsize.height
			Return size
		End If
		
		Assert layout, "Missing Layout Manager"

		'Ensure children containers have calculated their minimum size!!!

		' Use Layout Manager
		size = layout.getMinimumSize()
		size.width  :+ edges.L+edges.R
		size.height :+ edges.T+edges.B
		Return size

	End Method

	' Return the space used by margin and padding
	Method getEdges:SEdges()
		Return New SEdges( margin.T+padding.T, margin.R+padding.R, margin.B+padding.B, margin.L+padding.L )
	End Method

	Method getWidgets:TWidgetArray()
		Local list:TWidgetArray = New TWidgetArray()
		For Local child:TWidget = EachIn children
			If child.visible; list.addlast( child )
		Next
		'If list.count=0; Return Null
		Return list
	End Method

	Method invalidate_layout()
		Super.invalidateLayout()
		If layout; layout.invalidate()
	End Method

	' Default MouseOver support
	Method onMouseEnter:Object( event:TEvent )
'Print "ENTER: "+name
		If canMouseover; mouseover =  True
	End Method
	Method onMouseLeave:Object( event:TEvent )
'Print "LEAVE: "+name
		mouseover=False
	End Method

	Method render()
		If Not children; Return
		For Local child:TWidget = EachIn children
			child.render()
		Next
	End Method

'	Method render( ofsX:Int, ofsY:Int )
'		If Not children; Return
'		'Local edges:SEdges = getEdges()
'		For Local child:TWidget = EachIn children
'			DebugStop
'			child.render( ofsX, ofsY)
'		Next
'	End Method

	Method remove( widget:TWidget )
		If widget.link; link.remove()
		widget.link = Null
	End Method

	Method removeAll()
		children.clear()
	End Method

	' Push the stylesheet
	'Method restyle()
	'	forward( CreateEvent( EVENT_WIDGET_STYLE, Self, 0,0,0,0, stylesheet ) )
	'	Super.restyle()
	'End Method

	' Bids are used in expansion
	Method setBids( bids:SPoint )
		Self.bids = bids
	End Method

	Method setBids( both:Int )
		Self.bids = New SPoint( both, both )
	End Method

	Method setBids( horizontal:Int, vertical:Int )
		Self.bids = New SPoint( horizontal, vertical )
	End Method

	Method setBounds( x:Int, y:Int, w:Int, h:Int )
		'DebugStop
		reshape( x,y,w,h )
	End Method

	Method setBounds( rect:SRectangle )
		reshape( rect.x, rect.y, rect.width, rect.height )
	End Method
		
	Method setLayout( layout:Int )
		Select layout
		Case LAYOUT_HORIZONTAL, LAYOUT_VERTICAL
			setLayout( New TBoxLayout( Self, layout ) )
		End Select
	End Method
		
	Method setLayout( layout:ILayout )
		Self.layout = layout
		invalidate_layout()
	End Method
	
	Method setLocation( x:Int, y:Int )
		reshape( x, y, bounds.width, bounds.height )
	End Method
	
	Method setPadding( all:Int ) ;        setPadding( all, all, all, all ) ; End Method
	Method setPadding( TB:Int, LR:Int ) ; setPadding( TB, LR, TB, LR ) ;     End Method
	Method setPadding( T:Int, R:Int, B:Int, L:Int )
		If padding.T=T And padding.R=R And padding.B=B And padding.L=L; Return
		padding.T = T
		padding.R = R
		padding.B = B
		padding.L = L
		invalidateLayout()
	End Method
	Method setPadding( edges:SEdges )
		If padding.T=edges.T And padding.R=edges.R And padding.B=edges.B And padding.L=edges.L; Return
		padding = edges 
		invalidateLayout()
	End Method
	
	Method setMargin( all:Int ) ;        setMargin( all, all, all, all ) ; End Method
	Method setMargin( TB:Int, LR:Int ) ; setMargin( TB, LR, TB, LR ) ;     End Method
	Method setMargin( T:Int, R:Int, B:Int, L:Int )
		If margin.T=T And margin.R=R And margin.B=B And margin.L=L; Return
		margin.T = T
		margin.R = R
		margin.B = B
		margin.L = L
		invalidateLayout()
	End Method
	Method setMargin( edges:SEdges )
		If margin.T=edges.T And margin.R=edges.R And margin.B=edges.B And margin.L=edges.L; Return
		margin = edges
		invalidateLayout()
	End Method
	
	Public
	
	' Debugging tool for component design to give you guides
	' Works best when margin and padding are non-zero
	Method showDebugBox()
		'DebugStop
		
		' DRAW MARGIN IN RED
		bounds.fill( New SColor8( $FFFF0000 ) )

		' DRAW PADDING IN GREEN
		outer.fill( New SColor8( $FF00FF00 ) )
		
		' DRAW CLIENT AREA IN BLUE
		inner.fill( New SColor8( $FF0000FF ) )
	
	End Method
	
	Method validate()

'NEED To STYLE EVERYTHING EACH LOOP

layout.invalidate shoudl invalidate children containers too.

LAYOUT NEEDS SIZE OF CONTAINER SET BEFORE IS POSITIONS CHILDREN
BUT CHILDREN SIZE NEEDS To BE CALCULATED BEFORE CONTAINER SIZE IS SET

	SO CALCULATE SIZES (OF CONTAINER And CHILDREN)
		SHOULD ALSO CALCULATE CHILDRENS CHILDREN BU CALLING CONTAINERS OWN LAYOUT
	
	Then CALL LAYOUT.LayoutChildren()
		Which calls containers layoutChildren()
	
	:YIKES, BAsically a PACK()

		getMinimumSize

		' Calculate sizes of children
		For Local child:TWidget = EachIn children
			child.reshape()
		Next
		
		resize Self
		
		after tree resized, Then repositionChildren()
			which iterates through tree
			A container just puts all objects below each other If no layout manager
			like a vertical box layout... maybe that should be Default!
	
'	DebugStop
'DebugLog( "#TContainer - validate()" )

		If validstyle And validlayout; Return
		
		'
		If Not validlayout And layout; layout.run()
		
		Super.validate()
	End Method
		
	Method PRIVATE_METHODS() Final; End Method
	Private
		
	Method addWidget:TWidget( widget:TWidget, name:String="" )
	
		' Move Parent
		' THIS MUST BE DONE FIRST
		If widget.parent; parent.remove( widget )
		widget.parent = Self
		
		' Add to list
		If name; widget.name = ""
		If Not children; children = New TList()
		widget.link = children.addlast( widget )
		
		' Invalidate layout and style
		invalidateLayout()
		invalidateStyle()
		
		' Notification of added object

		dispatch( EVENT_WIDGET_ADDED, widget )
		
		Return widget
	End Method

	' Bubble sends an event up the tree until something handles it.
	' The handler should simply override this method
	Method bubble( event:TEvent )
		If parent; parent.bubble( event )
	End Method

	' Forward sends an event down the tree until something handles it.
	' The handler should simply override this method
	' forward returns when a child returns a non null value
	' This allows it to be used for finding things 
	'Method forward:Object( event:TEvent )
	'	' Handle Global Events
	'	If event.id = EVENT_WIDGET_STYLE; setStyle( TStylesheet( event.extra ) )
	'	' Forward to Children
	'	If children
	'		For Local child:TContainer = EachIn children
	'			Local result:Object = child.forward( event )
	'			If result; Return result
	'		Next
	'	End If
	'End Method

	Method forward:Object( event:Int, data:Object )
		Super.forward( event, data )
		'
		If children
			For Local child:TWidget = EachIn children
				child.forward( event, data )
			Next
		End If
	End Method

	Method reshape( x:Int, y:Int, w:Int, h:Int )
	
		' When position is AUTO, centralise it
		If x = AUTO Or y = AUTO
			Local pw:Int, ph:Int
			If parent
				pw = parent.inner.width
				ph = parent.inner.height
			Else
				pw = GraphicsWidth()
				ph = GraphicsHeight()
			End If
			
			If x=AUTO; x= (pw-w)/2
			If y=AUTO; y= (ph-h)/2
		End If
	
		' Check for resize or move
		Local resized:Int = (bounds.width<>w Or bounds.height<>h)
		Local moved:Int = (bounds.x<>x Or bounds.y<>y)
'DebugStop
		If resized Or moved
			' Update the fields.
			'Self.x = x
			'Self.y = y
			'Self.width = w
			'Self.height = h
			
			bounds.x = x
			bounds.y = y
			bounds.width = w
			bounds.height = h
			' Copy bounds and shrink it
			outer = bounds
			outer.shrink( margin )
			' Copy outer and shrink it
			inner = outer
			inner.shrink( padding )
			'
			invalidateLayout()
		End If
		
	End Method


	Protected
	
	
	' Method to find a widget based on coordinates
	Method searchXY:TContainer( x:Int, y:Int )
		Local result:TContainer
		For Local child:TContainer = EachIn children
			result = child.searchXY( x, y )
			If result; Return result
		Next
		If outer.contains( x, y ); Return Self
	End Method
	
End Type

' Replacement for TForm (Once working)
'
Type TForm2 Extends TContainer Implements IEventHook, IForm2

	Private
	
	Field focused:TContainer		' Widget with focus
	Field mouseinside:TContainer	' Widget containing mouse

	' GUI Event Handler
	Field handler( form:TForm2, event:TEvent )
	
	' (Optional) type that will receive GUI events
	Field iType:IForm2
	
	Public
	
'	' Manual GUI
	Method New()
		layout = New TBoxlayout( Self, LAYOUT_VERTICAL )
		setStyle( New TStylesheet() )
		
		setLocation( AUTO, AUTO )
		
		' Listen for events
		EventHook.attach( Self )
		
		'.on( EVENT_WIDGET_ADDED, Self )
		
	End Method

	' Object inspector
	Method New( form:Object, fx:Int=AUTO, fy:Int=AUTO )
		layout = New TBoxlayout( Self, LAYOUT_VERTICAL )
		setStyle( New TStylesheet() )
'DebugStop
		addStyle( New TStylesheet( INSPECTOR_STYLESHEET ) )

		Local widget:TWidget

		' Position
		setLocation( fx, fy )

		'fields = New TList()
		'Local component:TFormField
		'setPalette( PALETTE_BLUE )
		'parent = form
		
		'invalid = True
		
		' ADD TITLE
'DebugStop
		Local t:TTypeId = TTypeId.ForObject( form )
		Local title:String = t.metadata("title")
		If Not title; title = t.name()
		widget = Self.add( New TLabel( title ) )
		widget.setTextAlign( ALIGN_CENTRE, ALIGN_MIDDLE )
		widget.addClass( "title" )
		
		' ADD INSPECTOR TABLE
		Local table:TContainer = New TContainer()
		Self.add( table )

		' TABLE LAYOUT
		Local grid:TGridLayout = New TGridLayout( table )
		grid.setColumns( 3 )
		grid.setRows( AUTO )

		' ADD BUTTONS IN A PANEL
		Local buttons:TPanel = New TPanel()
		buttons.setLayout( LAYOUT_HORIZONTAL )
		buttons.add( New TButton( "OK" ) )
		Self.add( buttons )
		
		' Add fields to inspector table
		For Local fld:TField = EachIn t.EnumFields()
			Print( fld.name() )
			
			'Local temp:String
		
			' Add field name to column 1
			Local fldname:String = fld.name()
			table.add( New TLabel( fldname ) )
			
			' Add field type to Column 2
			Local fldType:String = fld.typeid().name()
			table.add( New TLabel( fldType ) ) 
			'fields.addlast( MakeLabel( fldType ))
			
			' Add field data to Column 3
			'Local value:String = 
			'If Not value; label = fld.name()
			Select fldType
			Case "Byte"
				'fields.addlast( MakeLabel( fld.getByte( form ) ) )
				table.add( New TTextBox( fldname, fld.getByte( form ) ) ) 
			Case "Short"
				'fields.addlast( MakeLabel( fld.getShort( form ) ) )
				table.add( New TTextBox( fldname, fld.getShort( form ) ) ) 
			Case "Double"
				'fields.addlast( MakeLabel( fld.getDouble( form ) ) )
				table.add( New TTextBox( fldname, fld.getDouble( form ) ) ) 
			Case "Float"
				'fields.addlast( MakeLabel( fld.getFloat( form ) ) )
				table.add( New TTextBox( fldname, fld.getFloat( form ) ) ) 
			Case "Int"
				If fld.hasmetadata( "boolean" )					
					Local value:Int = ( fld.getInt( form ) = True )						
					Local bool:TComponent = TComponent( table.add( New TCheckbox( "Enable?" ) ))
					bool.setValue( value )
				Else
					'Local widget:TFormField = MakeTextBox( fld.name() )
					'widget.fld = fld
					'fields.addlast( widget )
					table.add( New TTextBox( fldname, fld.getString( form ) ) ) 
				End If
			Case "Long"
				'fields.addlast( MakeLabel( fld.getLong( form ) ) )
				table.add( New TTextBox( fldname, fld.getLong( form ) ) ) 
			Case "String"
				'fields.addlast( MakeLabel( Chr(34)+fld.getString( form )+Chr(34) ) )
				table.add( New TTextBox( fldname, fld.getString( form ) ) ) 
			Default
			'DebugStop
				If fld.typeid().extendsType( ArrayTypeId )
					'fields.addlast( MakeLabel( "(array)"  ) )
					table.add( New TTextBox( "(array)" ) ) 
				ElseIf fld.typeid().extendsType( ObjectTypeId )					
					'fields.addlast( MakeLabel( "(object)" ) )
					table.add( New TTextBox( "(object)" ) ) 
				Else
					table.add( New TTextBox( "NOT IMPLEMENTED" ) ) 
				End If
			End Select
		
		Next
		
		' Set event handler
		setHandler( InspectorEventHandler )
		
		' Run initial layout
		pack()
		
	End Method 
	
	' Typegui
	Method New( form:IForm )
		'TODO: Replace this with a column/grid layout
		layout = New TGridlayout( Self, 2, AUTO )
		setStyle( New TStylesheet() )
	'	root = New TPanel()
	'	root.setLayout( New TInspectorLayout() )
	'	current = root
		setMargin( 1 )	' Shown as a border on a Form
	End Method

	' Handle system events
	' If not overridden by client, we sent to iType
	' and to optional handler
	Method onGUI( form:TForm2, event:TEvent )
		If iType; iType.onGUI( form, event )
		If handler; handler( form, event )
	End Method

	Function InspectorEventHandler( form:TForm2, event:TEvent )
		Local widget:TWidget = TWidget( event.source )
		Select event.id
		'Case EVENT_WIDGET_CLICK; Print( "-> Clicked, "+ widget.GetName() )
		Default
			Print( "INSPECTOR: "+event.tostring() )
			DebugStop
		End Select
	End Function

	' Entry method to display whole GUI
	' Should be called on root object only
	Method inspect:Int()
DebugLog( "#TForm2 - Inspect()" )

		' Save State
		Local blend:Int = GetBlend()
		Local alpha:Float = GetAlpha()
		'
		SetBlend( ALPHABLEND )
		'
		DebugStop
		
		' Forward a restyle event to component tree
		forward( EVENT_RESTYLE, stylesheet )
			
		If Not validlayout
			layout.run()
			validlayout = True
		End If
		
		If visible; render()

		' Restore State
		SetBlend( blend )
		SetAlpha( alpha)		
		Return Not visible			' Forces close when invisible
	End Method

	' Handle system events
	Method onEvent:Object( id:Int, event:TEvent )
		If Not event; Return event
'Print "Received "+Hex(id)+", "+Hex(event.id)
		Select id
		'Case EVENT_APPSUSPEND
		'Case EVENT_APPRESUME
		'Case EVENT_APPTERMINATE
		Case EVENT_KEYDOWN
			If focused; Return focused.onKeyDown( event )
		Case EVENT_KEYUP
			If focused; Return focused.onKeyUp( event )
		Case EVENT_KEYCHAR
			If focused; Return focused.onKey( event )
		'Case EVENT_KEYREPEAT
		Case EVENT_MOUSEDOWN
			If mouseInside
				If mouseinside <> focused
					If focused; dispatch( EVENT_WIDGET_LOSEFOCUS, focused )
					dispatch( EVENT_WIDGET_GETFOCUS, mouseinside )
					focused = mouseinside
				End If
				mouseinside.onMouseDown( event )
				Return Null
			End If
		Case EVENT_MOUSEUP
			If mouseinside And mouseinside = focused; Return focused.onMouseUp( event )
		Case EVENT_MOUSEMOVE
			If mouseinside
				' Check mouse inside child
				Local inside:TContainer = mouseinside.searchXY( event.x, event.y )
				' Still in same component?
				If inside = mouseinside; Return mouseinside.onMousemove( event )
				mouseinside.onMouseLeave( event )
				
				If inside
					' Moved to child
					inside.onMouseEnter( event )
					mouseinside = inside
					Return Null
				End If
			EndIf
			
			mouseinside = searchxy( event.x, event.y )
			If mouseinside; Return mouseinside.onMouseEnter( event )

		'Case EVENT_MOUSEWHEEL
		Case EVENT_MOUSEENTER
			mouseinside = TContainer( event.source )
			Return mouseinside.onMouseEnter( event )
		Case EVENT_MOUSELEAVE
			Local result:Object = mouseinside.onMouseLeave( event )
			mouseinside = Null
			Return result
		'Case EVENT_TIMERTICK
		'Case EVENT_HOTKEYHIT
		'Case EVENT_WINDOWMOVE
		'Case EVENT_WINDOWSIZE
		'Case EVENT_WINDOWCLOSE
		'Case EVENT_WINDOWACTIVATE
		'Case EVENT_WINDOWACCEPT
		'Case EVENT_GADGETACTION
		'Case EVENT_GADGETPAINT
		'Case EVENT_GADGETSELECT
		'Case EVENT_GADGETMENU
		'Case EVENT_GADGETOPEN
		'Case EVENT_GADGETCLOSE
		'Case EVENT_GADGETDONE
		Default
			DebugLog( "TFORM: "+event.toString() )		
		End Select
		' Unprocessed events must return event
		Return event
	End Method

	' Entry method to display whole GUI
	' Should be called on root object only
	Method show( modal:Int=False)
		' Save State
		Local blend:Int = GetBlend()
		Local alpha:Float = GetAlpha()
		'
		SetBlend( ALPHABLEND )
		' Draw modal background
		If modal
			SetAlpha( 0.7 )
			SetColor( 0, 0, 0 )
			DrawRect( 0, 0, GraphicsWidth(), GraphicsHeight() )
			'SetAlpha( 1.0 )
		EndIf 
		
		' Forward a restyle event to component tree
		forward( EVENT_RESTYLE, stylesheet )
		
		If Not valid_layout; validate()
		If Not visible; Return
		'DebugStop
		'render( x, y )
		render()
		' Restore State
		SetBlend( blend )
		SetAlpha( alpha)
	End Method
	
'	Method setTitle( title:String )
'	End Method

	' Resize form to fit components
	Method pack()
DebugLog( "#TForm2 - calculateSizes()" )
		
		' Apply styles (Margin, Padding, etc)
		restyle()

		'DebugStop
		If Not layout; Return
		
		' Get client minimum size
		Local size:TDimension = layout.getMinimumSize()	

'DebugStop
		'Local edges:Sedges = getEdges()
		'size.width  :+ edges.L+edges.R
		'size.height :+ edges.T+edges.B
		'setSize( size.width, size.height )
		'
		'If alignself & ALIGN_CENTER
		'	x = ( GraphicsWidth() - width ) /2
		'	y = ( GraphicsHeight() - height ) /2
		'End If

		' Calculate position
		Local x:Int = ( GraphicsWidth() - size.width ) * align.X
		Local y:Int = ( GraphicsHeight() - size.height ) * align.Y
		'DebugStop

		' Create our client area
		inner = New SRectangle( x, y, size.width, size.height )
		
		' Update edges
		outer = inner			' COPY STRUC
		outer.grow( padding )	' Add padding
		bounds = outer			' COPY STRUCT
		bounds.grow( margin )	' Add margins

	End Method

	Method render()
		' Use Margin as a border for a form
		bounds.fill( Palette[ TForm.BORDER ] )
		' Fill Outer box
		outer.fill( Palette[ TForm.BACKGROUND ] )
		' Draw children
		Super.render()
		'TCursor.draw( MouseX(), MouseY() )
	End Method
	
	' Set the GUI Event handler
	Method setHandler( handler( form:TForm2, event:TEvent ) )
		Self.handler = handler
	End Method

	Private
	
	' Handle bubbled events by sending them to the handler
	Method bubble( event:TEvent )
	'Print( event.tostring() )
		'DebugStop
		Select event.id
		'Case EVENT_WIDGET_ADDED
		'	Local widget:TWIdget = TWidget( event.source )
		'	If widget; widget.setPalette( palette )
		'	DebugStop
		Case EVENT_WIDGET_GETFOCUS
			focused = TContainer( Event.Source )
			focused.setFocus()
		Case EVENT_WIDGET_LOSEFOCUS
			focused.setFocus( False )
			focused = Null
		Default
			' Send to the handler
			onGUI( Self, event )
		End Select
	End Method
	
End Type

'TODO: Decide if I really need this now that I have moved functionality
' UP or DOWN the hierarchy
Type TComponent Extends TContainer

	' Most components have these that is used in differnt ways
	Field caption:String
	Field valueStr:String
	Field valueInt:Int
	
	' Text alignment
	Field textAlignX:Float = ALIGN_CENTRE
	Field textAlignY:Float = ALIGN_CENTRE
	
	Method getTextPos:SPoint( client:SRectangle, text:String )
		Local point:SPoint = New SPoint()
		point.x = client.x+padding.L+(client.width-TextWidth( text )-padding.L-padding.R) * textAlignX
		point.y = client.y+padding.T+(client.height-TextHeight( text )-padding.T-padding.B) * textAlignY
		Return point
	End Method

	' Method to find a widget based on coordinates
	Method searchXY:TContainer( x:Int, y:Int )
		If outer.contains( x, y ); Return Self
	End Method
	
'	Method onEvent:Int( id:Int, event:TEvent )
'		Select id
'		Case EVENT_MOUSEMOVE
'			Local rect:SRectangle '=  getOuterRect( 
'		End Select
'	End Method

	Method setTextAlign( horizontal:Float, vertical:Float )
		textAlignX = horizontal
		textAlignY = vertical
	End Method

	Method setValue( value:Int )
		valueint = value
		valuestr = String( value )
	End Method

	Method setValue( value:String )
		valueint = Int( value )
		valuestr = value
	End Method

End Type

Type TPanel Extends TContainer

	Method New()
		setLayout( LAYOUT_VERTICAL )
	End Method
	
	Method render( ofsX:Int=0, ofsY:Int=0 )
		showDebugBox()
		'Local rect:SRectangle = getOuterRect( ofsX, ofsY )
		outer.fill( Palette[ TForm.SECONDARY ] )
		Super.render()
	End Method

	Private
	
	' Handle bubbled events for RADIO group support
	Method bubble( event:TEvent )
		If event.id = EVENT_WIDGET_CLICK And TRadioButton( event.source )
			forward( CreateEvent( EVENT_WIDGET_SELECT, event.source ) )
		EndIf
		'DebugStop
		If parent; parent.bubble( event )
		'DebugStop
	End Method
		
End Type

Type TButton Extends TComponent

	' Replaceable Renderer
	Global Renderer( this:TComponent ) = DRAW
	'Global Renderer( this:TComponent, ofsX:Int, ofsY:Int ) = DRAW
	
	Method New( text:String )
		caption = text
	End Method

	Method getMinimumSize:TDimension()
		Local size:TDimension = New TDimension()
		Local edges:SEdges = getEdges()	' Whitespace
		'
		size.width  = TextWidth(caption)+edges.L+edges.R
		size.height = TextHeight(caption)+edges.T+edges.B
		Return size
	End Method

	Method onMouseUp:Object( event:TEvent )
		'DebugStop
		dispatch( EVENT_WIDGET_CLICK, Self )
	End Method
	
	' Render using replaceable renderer
	Method render()
		Renderer( Self )
	End Method
	
	' Default Renderer
	Function DRAW( this:TComponent )
		'DebugStop
		If this.mouseover; this.bounds.outline( this.palette[ TForm.DISABLED ] )
		this.outer.fill( this.palette[ TForm.BACKGROUND ] )
		Local pos:SPoint = this.getTextPos( this.inner, this.caption )
		SetAlpha( this.palette[ TForm.FOREGROUND ].a/256.0 )
		SetColor( this.palette[ TForm.FOREGROUND ] )
		DrawText( this.caption, pos.x, pos.y )
	End Function

End Type

Type TLabel Extends TComponent

	Method New( text:String )
		caption = text
		' Default Style
		'textAlignX = ALIGN_LEFT
	End Method

	Method getMinimumSize:TDimension()
		Local size:TDimension = New TDimension()
		Local edges:SEdges = getEdges()	' Whitespace
		'
		size.width  = TextWidth(caption)+edges.L+edges.R
		size.height = TextHeight(caption)+edges.T+edges.B
		Return size
	End Method

	Method render()
		'DebugStop

'Print "BG.ALPHA: "+palette[ TForm.BACKGROUND ].a/256.0
'Print "BG.COLOR: "+Hex(palette[ TForm.BACKGROUND ].toargb())
'Print "FG.ALPHA: "+palette[ TForm.FOREGROUND ].a/256.0
'Print "FG.COLOR: "+Hex(palette[ TForm.FOREGROUND ].toargb())
'DebugStop
		'showDebugBox()
		outer.fill( palette[ TForm.BACKGROUND ] )
		Local pos:SPoint = getTextPos( inner, caption )
		SetAlpha( palette[ TForm.FOREGROUND ].a/256.0 )
		SetColor( palette[ TForm.FOREGROUND ] )
		DrawText( caption, pos.x, pos.y )
	End Method
	
End Type

' Toggle type is intended to be used by widgets not as a widget in itself
Type TToggle Extends TComponent Abstract

	Field state:Int = False
	
	Method getMinimumSize:TDimension()
		Local size:TDimension = New TDimension()
		Local edges:SEdges = getEdges()	' Whitespace
		Local length:Int = Max( TextWidth("W"), TextHeight("8y") )
		size.width  = length + edges.L + edges.R
		size.height = length + edges.T + edges.B
		Return size
	End Method		

	Method setState( state:Int = False )
		Self.state = state
	End Method

	Method toggle()
		state = Not state
	End Method

End Type

' The toggle component of a Checkbox
Type TToggleCheckbox Extends TToggle

	' Replaceable Renderer
	Global Renderer( this:TToggle )
	
	Method New( state:Int=False )
		Self.state = state
		Renderer = DRAW
		'setmargin(0)
		'setpadding(3)
	End Method

	' Render using replaceable renderer
	Method render()
		If Renderer; Renderer( Self )
	End Method
					
	Function DRAW( this:TToggle )
		' Draw outer edge
		this.outer.fill( this.palette[ TForm.BACKGROUND ] )
		' Draw Pressed state
		If this.state
			this.inner.fill( this.palette[ TForm.SECONDARY ] )
		End If
	End Function

End Type

Type TToggleRadio Extends TToggle

	' Replaceable Renderer
	Global Renderer( this:TToggle )
	
	Method New( state:Int=False )
		Self.state = state
		Renderer = DRAW
		'setmargin(0)
		'setpadding(3)
	End Method

	' Render using replaceable renderer
	Method render()
		If Renderer; Renderer( Self )
	End Method
			
	Function DRAW( this:TToggle )
		' Draw outer edge
		SetAlpha( this.palette[ TForm.BACKGROUND ].a/256.0 )
		SetColor( this.palette[ TForm.BACKGROUND ] )
		DrawOval( this.outer.x, this.outer.Y, this.outer.width, this.outer.height )
		' Draw Pressed state
		If this.state
			SetAlpha( this.palette[ TForm.SECONDARY ].a/256.0 )
			SetColor( this.palette[ TForm.SECONDARY ] )
			DrawOval( this.inner.x, this.inner.Y, this.inner.width, this.inner.height )
		End If
	End Function
	
End Type

' Radio stores its value in the parent, so make sure you 
' attach it To a widget that doesn't also use its own value.

Type TRadioButton Extends TContainer

	Field button:TToggle

	Method New( caption:String="TRadioButton", state:Int=False )
		setpadding(0)
		layout = New TBoxLayout( Self, LAYOUT_HORIZONTAL )
		button = New TToggleRadio( state )
		Local label:TLabel = New TLabel( caption )
		label.setBids(1)
		'
		add( button )
		add( label )
		'
	End Method

	Method onMouseUp:Object( event:TEvent )
		button.toggle()
		dispatch( EVENT_WIDGET_CLICK, Self )
	End Method

'	Method onMouseClick:Object( event:TEvent )
'		If event.data<>Self And event.data.parent=parent
'			button.toggle()
'		End If
'	End Method

	Method render()
		'showDebugBox()
		If mouseover; bounds.outline( palette[ TForm.BORDER ] )
		Super.render()
	End Method

	' Do not search children
	Method searchXY:TContainer( x:Int, y:Int )
		If outer.contains( x, y ); Return Self
	End Method

	Private
	
	Method forward:Object( event:TEvent )
	
		Select event.id
		Case EVENT_WIDGET_SELECT
			If event.source <> Self
				button.setState( False )
			End If
		Default
			Return Super.forward( event )
		End Select
		
	End Method

End Type

Type TCheckbox Extends TContainer

	'Field value:Int = 0
	Field button:TToggle

	Method New( caption:String = "TCheckbox", state:Int = False )
		setpadding(0)
		layout = New TBoxLayout( Self, LAYOUT_HORIZONTAL )
		button = New TToggleCheckbox( state )
		Local label:TLabel = New TLabel( caption )
		label.setBids( 1 )
		'
		add( button )
		add( label )
	End Method

	Method onMouseUp:Object( event:TEvent )
		button.toggle()
		dispatch( EVENT_WIDGET_CLICK, Self )
	End Method
	
	'Method onMouseClick:Object( event:TEvent )
	'	'parent.value = value
	'	dispatch( EVENT_MOUSECLICK, Self )
	'End Method
		
	Method render()
		'showDebugBox()
		If mouseover; bounds.outline( palette[ TForm.BORDER ] )
		Super.render()
	End Method

	' Do not search children
	Method searchXY:TContainer( x:Int, y:Int )
		If outer.contains( x, y ); Return Self
	End Method
	
End Type

Type TTextBox Extends TComponent

	' Cursor Blink speed
	Global BLINKSPEED:Int = 500

	Global cursorstate:Int = False
	Global cursortimer:Int = 0
		
	Field cursorPos:Int = 0
	Field cursorOfs:Int = 0
	Field insertmode:Int = True

	Method New( text:String, value:String="" )
		caption  = text
		valuestr = value
		' Default Style
		textAlignX = ALIGN_LEFT
	End Method

	Method getMinimumSize:TDimension()
		Local size:TDimension = New TDimension()
		Local edges:SEdges = getEdges()	' Whitespace
		'
		size.width  = TextWidth(caption)+edges.L+edges.R
		size.height = TextHeight(caption)+edges.T+edges.B
		Return size
	End Method

	Method onKey:Object( event:TEvent )
		Print( "KEYCHAR: "+event.toString() )
		If event.data>31 And event.data<127
			Print( "- CHAR "+Chr(event.data ) )
			valuestr = valuestr[..cursorpos]+Chr(event.data)+valuestr[cursorpos..]
			cursorpos :+ 1
			Return Null
		End If
		Return event
	End Method

	Method onKeyUp:Object( event:TEvent )
		Print( "KEY: "+event.toString() )
		Select event.data
		Case KEY_HOME
			cursorPos = 0
		Case KEY_END
			cursorpos = valuestr.length
		Case KEY_LEFT
			cursorpos :- 1
		Case KEY_RIGHT
			cursorpos :+ 1
		Case KEY_DELETE
			valuestr = valuestr[..cursorpos]+valuestr[cursorpos+1..]
		Case KEY_BACKSPACE
			valuestr = valuestr[..cursorpos-1]+valuestr[cursorpos..]
			cursorpos :- 1
		Case KEY_INSERT
			Print( "- INSERT" )
			insertmode = Not insertmode
		Default
			Print( "KEYUP: "+event.toString() )
			Return event
		End Select
		' Bounds limit the cursor
		cursorpos = Min( Max( cursorpos, 0 ), valuestr.length )
	End Method
		
	Method render()
		' Cursor
		If MilliSecs() > cursortimer
			cursorstate = Not cursorstate
			cursortimer = MilliSecs() + BLINKSPEED
		End If
		' Draw widget
		If mouseover; bounds.fill( palette[ TForm.BORDER ] )
		'Local rect:SRectangle = getOuterRect( ofsX, ofsY )
		outer.fill( palette[ TForm.BACKGROUND ] )
		'rect.shrink( padding )
		' Draw Text
		Local pos:SPoint = getTextPos( inner, caption )
		If valuestr=""
			SetAlpha( palette[ TForm.SECONDARY ].a/256.0 )
			SetColor( palette[ TForm.SECONDARY] )
			DrawText( caption, pos.x, pos.y )
		Else
			SetAlpha( palette[ TForm.FOREGROUND ].a/256.0 )
			SetColor( palette[ TForm.FOREGROUND ] )
			DrawText( valuestr, pos.x, pos.y )
		End If
		' Draw Cursor
		Rem
		If False
			If KeyHit( KEY_HOME ); cursorPos = 0
			If KeyHit( KEY_END ); cursorpos = valuestr.length
			If KeyHit( KEY_LEFT ); cursorpos :- 1
			If KeyHit( KEY_RIGHT ); cursorpos :+ 1
			cursorpos = Max( 0, Min( cursorpos, valuestr.length ))	' Bounds validation
			If KeyHit( KEY_DELETE ); valuestr = valuestr[..cursorpos]+valuestr[cursorpos+1..]
			If KeyHit( KEY_BACKSPACE )
				valuestr = valuestr[..cursorpos-1]+valuestr[cursorpos..]
				cursorpos = Max(cursorpos-1,0)
			End If
			Local key:Int = GetChar()
			If key>31 And key<127
				'DebugStop
				valuestr = valuestr[..cursorpos]+Chr(key)+valuestr[cursorpos..]
				cursorpos :+ 1
			End If
			' Draw cursor
		End If
		End Rem
		If focus
			If cursorstate
				Local offset:Int = TextWidth( valuestr[..cursorpos] )
				If insertmode
			'	colour( inside, ONPRIMARY, ONSURFACE )
					SetAlpha( palette[ TForm.CURSOR ].a/256.0 )
					SetColor( palette[ TForm.CURSOR ] )
					DrawLine( pos.x+offset, inner.y, pos.x+offset, inner.y+inner.height)			
				Else
					Local cursor:SRectangle = New SRectangle()
					cursor.x = pos.x+offset
					cursor.y = inner.y
					cursor.width = TextWidth( valuestr[ cursorpos..cursorpos+1] )
					cursor.height = inner.height
					cursor.outline( palette[ TForm.CURSOR ] )
				End If
			'Else
			'	colour( fld.disable, DISABLED, SURFACE )
			End If
		End If
		
	End Method

End Type

Type TSlider Extends TComponent

	Const MINIMUM_WIDTH:Int = 30

	Field minimum:Int = 0	' Minimum value
	Field maximum:Int		' Maximum value
	Field value:Int			' Current value
	
	Field minheight:Int		' Size of slider
	
	Field dragging:Int = False
	Field handle:SRectangle = New SRectangle()
	
	Field minhandlewidth:Int = 15
	'Field showvalue:Int = True
	
	Method New( maximum:Int, value:Int=0, minimum:Int=0 )
		Self.minimum = minimum
		Self.maximum = maximum
		Self.value = value
		Self.minheight = TextHeight( "8" )
		calcHandle()
	End Method
	
	Method getMinimumSize:TDimension()
		Local size:TDimension = New TDimension()
		Local edges:SEdges = getEdges()	' Whitespace
		'
		size.width  = MINIMUM_WIDTH+edges.L+edges.R
		size.height = TextHeight( "8p" )+edges.T+edges.B
		Return size
	End Method

	Method onMouseDown:Object( event:TEvent )
		'If handle.contains( event.x, event.y )
		dragging = True
		snapToMouse( event.x, event.y )
		'Else
			' Snap to mouse position
			'DebugStop
	'	SnapToMouse( event.x, event.y )
		'End If
	End Method

	Method onMouseMove:Object( event:TEvent )
		If dragging
			snapToMouse( event.x, event.y )
		End If
	End Method

	Method onMouseUp:Object( event:TEvent )
		dragging = False
	End Method

	Method onMouseEnter:Object( event:TEvent )
		If MouseDown(1); dragging = True
	End Method

	Method onMouseLeave:Object( event:TEvent )
		dragging = False
	End Method
	
	Method render()
		' DRAW BACKGROUND
		If mouseover; bounds.outline( palette[ TForm.BORDER ] )
		outer.fill( palette[ TForm.BACKGROUND ] )
		
		' CALCULATE HANDLE SIZE
		calcHandle()
				
		' DRAW HANDLE
		'If dragging
		handle.fill( palette[ TForm.SECONDARY ] )
		'Else
		'	handle.fill( palette[ TForm.SECONDARY ] )
		'End If
		
		' Draw value
		'If showvalue
		Local pos:SPoint = getTextPos( inner, value )
		SetAlpha( palette[ TForm.FOREGROUND ].a/256.0 )
		SetColor( palette[ TForm.FOREGROUND ] )
		DrawText( value, pos.x, pos.y )
		'End If
		
	End Method

'	Method showText( state:Int )
'		showvalue = state
'	End Method
	
	Private

	Method calcHandle()
		handle.x = inner.x + inner.width/(maximum-minimum)*(value-minimum) 
		handle.y = inner.y
		handle.width = Min( minhandlewidth, inner.width/(maximum-minimum) )
		handle.height = inner.height
	End Method

	Method snapToMouse( mx:Int, my:Int )
		Local pos:Int = Min( inner.width, Max(0, mx - inner.x ))
		value = minimum+(Float(pos)/Float(inner.width)*Float(maximum-minimum))
		calcHandle()
	End Method
	
End Type

Interface IEventHook
	Method OnEvent:Object( id:Int, event:TEvent )
End Interface

Type EventHook

'	Global handlers:TList
		
	' System Event Hook
	Function HookFunction:Object( id:Int, data:Object, context:Object )
		Local target:IEventHook = IEventHook( context )
		Local event:TEvent = TEvent( data )
'If event; Print( "HOOK: "+Hex(id)+","+Hex(event.id)+","+event.tostring() )
'If target; DebugStop
		If Not event Or Not target; Return data
		'
		' Dispatch
		Return target.onEvent( event.id, event )
	End Function	

	' Generic event handler
	Function attach( target:IEventHook )
		AddHook( EmitEventHook, HookFunction, target )
	End Function

	Function attach( target:IEventHook, hooktype:Int )
		AddHook( hooktype, HookFunction, target )
	End Function

	Function detach( target:IEventHook )
		RemoveHook( EmitEventHook, HookFunction, target )
	End Function

	Function detach( target:IEventHook, hooktype:Int )
		RemoveHook( hooktype, HookFunction, target )
	End Function

End Type

' FUTURE EXPANSION
Type TStylesheet

	Field root:TMap		' Root variables defined in stylesheet
	Field stylesheet:TMap

	' Create a new default Stylesheet
	Method New()
		stylesheet = New TMap()
		parse( DEFAULT_STYLESHEET )
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
		Local classes:String[] = []
		If widget.classlist; classes = widget.classlist.toArray()
		'DebugStop
		'Local value:String		
		'Local integer:Int
		'Local real:Float
		'Local item:String[]
		'Local items:Int
		'Local styles:Int[]
		Local style:TMap = CreateMap()
		Print( "STYLE: " + widget.name + ":" + typeid.name() )
		' Build list of selectors using a bitmask
		'	0000 = *
		'   0001 = Typename
		'	0010 = Name
		Local selector:String
		For Local bitmask:Int = 0 To 2
			If bitmask = 0
				match( "*", style )
				Continue
			End If
			'# Create match string
			selector=""
			
			If (bitmask & 1); selector = typename	
			If (bitmask & 2) And name; selector:+ "#" + name
			If Not selector; Continue
			match( selector, style )
			
			Local base:String = selector
			For Local class:String = EachIn classes
				selector = base
				If class
					selector :+ "."+class
					match( selector, style )
				End If
				' Check attribute-based styles
				For Local attr:Int = 0 To 2
					Select attr
					Case 0; If Not widget.enabled; match( selector+":disabled", style )
					Case 1; If widget.focus; match( selector+":active", style )
					Case 2; If widget.mouseover; match( selector+":hover", style )
					End Select
				Next
			Next
		Next
'DebugStop
'Print( "APPLYING:" )
		' Apply styles
		For Local property:String = EachIn MapKeys( style )
			Local value:String = String( MapValueForKey( style, property ) )
'Print( "  "+property+"="+value )
			Select property
			Case "background-color", "background-colour"
				SetColour( widget, TForm.BACKGROUND, value )
			Case "border-color", "border-colour"
				SetColour( widget, TForm.BORDER, value )
			Case "cursor-color", "cursor-colour"
				SetColour( widget, TForm.CURSOR, value )
			Case "color", "colour"
				SetColour( widget, TForm.FOREGROUND, value )
				'widget.palette[ TForm.FOREGROUND ] = ExtractColour( Lower(value) )
			Case "margin"
				TContainer(widget).setMargin( ExtractEdges( Lower(value) ) )
			Case "padding"
				TContainer(widget).setPadding( ExtractEdges( Lower(value) ) )
			Case "secondary-color", "secondary-colour"
				SetColour( widget, TForm.SECONDARY, value )
			Case "text-align"
				'DebugStop
				Local textalign:Float[] = ExtractAlignment( Lower(value) )
				TComponent(widget).setTextAlign( TextAlign[0], textalign[1] )
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
'Print( "  "+selector )
		Local properties:TMap = TMap( MapValueForKey( styleSheet, selector ))
		If Not properties; Return
		Local value:String
		For Local property:String = EachIn MapKeys( properties )
			value = String( MapValueForKey( properties, property ) )
			MapInsert( style, property, value )
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

Global DEFAULT_STYLESHEET:String = """
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
  color: black;
  background-color: white;
  border-color: --Blue700;
  secondary-color: -Blue200;
  cursor-color: --Blue900;
}
TForm2 {
  background-color: --Surface;
  margin: 2;
  border-color: black;
}
TPanel {
  background-color: --Background;
  color: black;
}
TButton {
  background-color: --Blue500;
  padding: 1,5;
  color: black;
}
TLabel {
  background-color: None;
  color: black;
  text-align: Left,center;
}
TToggleCheckBox {
  background-color: --Blue100;
  secondary-color: --Blue900;
  margin: 4;
  padding: 4;
}
TToggleRadio {
  background-color: --Blue100;
  secondary-color: --Blue900;
  margin: 4;
  padding: 4;
}
TRadio {
  background-color: None;
}
TCheckbox {
  background-color: --Background;
}
TTextBox {
  background-color: --Blue100;
  secondary-color: --Blue500;	// Secondary is used For the hint
  text-align: Left,center;
}
TSlider {
  background-color: --Blue100;
  secondary-color: --Blue900;
}
"""
Global INSPECTOR_STYLESHEET:String = """
.title {
	background-color: --Blue900;
	color: white;
}
"""

