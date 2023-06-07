SuperStrict

'	TYPEGUI
'	Author: Si Dunford [Scaremonger], June 2023
'	Contributions from:
'		@GW		(Discord)
'		@mingw	(Discord)
'
'	Version 0.5

Global SUPPORTED_TYPES:String[] = ["button","checkbox","password","radio","textbox","separator"]
' Others: color,slider,icon,dropdown,textarea,intbox
Global SUPPORTED_METADATA:String[] = ["disable","label","options","Type"]

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
Const ALIGN_TOP:Int = $01
Const ALIGN_MIDDLE:Int = $02
Const ALIGN_BOTTOM:Int = $04
Const ALIGN_LEFT:Int = $10
Const ALIGN_CENTER:Int = $20
Const ALIGN_CENTRE:Int = $20
Const ALIGN_RIGHT:Int = $40
Const ALIGN_MIDCENTER:Int = $22

Interface IForm
	Method onGUI( form:TForm, fld:TFormField )
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

' TCOLOR allows the use of Alpha Channels.
Type TCOLOR

	Const A:Int = 3, R:Int = 2, G:Int = 1, B:Int = 0

	Field color:Int = 0
	Field argb:Byte Ptr = Varptr color
	
	Method New( color:Int )
		Self.color = color
	End Method

	Method New( red:Byte, Green:Byte, Blue:Byte )
		argb[A]=$FF
		argb[R]=red
		argb[G]=green
		argb[B]=blue
	End Method
	
	Method New( alpha:Byte, red:Byte, Green:Byte, Blue:Byte )
		argb[A]=alpha
		argb[R]=red
		argb[G]=green
		argb[B]=blue
	End Method
		
	Method getByte:Byte( mask:Byte )
		Assert mask>=0 And mask<4, "Invalid Colour Mask"
		Return argb[mask]
	End Method

	Method setByte( mask:Byte, value:Byte )
		Assert mask>=0 And mask<4, "Invalid Colour Mask"
		argb[mask] =  value
	End Method
	
	Method toString:String()
		Return Hex( color )
	End Method
	
	Method set()
		SetAlpha( Float( argb[A]/255.0 ) )
		SetColor( argb[r], argb[g], argb[b] )
	End Method

	Function set( red:Byte, green:Byte, blue:Byte, alpha:Byte )
		SetAlpha( Float( alpha/255.0 ) )
		SetColor( red, green, blue )
	End Function

	Function set( red:Byte, green:Byte, blue:Byte )
		SetAlpha( 1.0 )
		SetColor( red, green, blue )
	End Function

	Function set( color:Int )
		Local c:TCOLOR = New TCOLOR(color)
		c.set()
	End Function

End Type

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
	Field colors:TColor[5] 
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

	Method color( slot:Int, colour:TColor )
		colors[slot] = colour
	End Method

	Method setPos( x:Int, y:Int, w:Int, h:Int )
		shape.x = x
		shape.y = y
	End Method

	Method setSize( w:Int, h:Int )
		shape.w = w
		shape.h = h
	End Method
	
	Method setShape( x:Int, y:Int, w:Int, h:Int )
		shape.x = x
		shape.y = y
		shape.w = w
		shape.h = h
	End Method
	
End Type

Struct SRectangle

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
	
	Method minus:SRectangle( trbl:Int[] )
		Assert trbl.length = 4, "Invalid array detected"
		Return New SRectangle( x+trbl[NL], y+trbl[NT], w-trbl[NL]-trbl[NR], h-trbl[NT]-trbl[NB] )
	End Method
	
End Struct

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
	
End Struct

Type TForm Final

	Const BLINKSPEED:Int = 500

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

	Field palette:TColor[11]
	
	Field cursorstate:Int
	Field cursortimer:Int
	Field cursorpos:Int
	
	'V05
	Field layout:TLayout
	Field invalid:Int = True
	
	' Manual GUI
	Method New()
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
					'If Object( fld )
					'	fields.addlast( MakeLabel( "(object)" ) )
					'ElseIf IsArray( fld )
					'	fields.addlast( MakeLabel( "(array) TBC"  ) )
					'Else
					fields.addlast( MakeLabel( "NOT IMPLEMENTED" ) )
					'End If
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
		palette[ BACKGROUND ].set()
		DrawRect( xpos, ypos, width, height )
		' Border
		drawborder( PRIMARY, xpos, ypos, width, height )
		' Title
		If title
			palette[ PRIMARY ].set()
			DrawRect( col1-MARGIN, y-MARGIN, width, TextHeight(title) )
			palette[ ONPRIMARY ].set()
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
							palette[ PRIMARY ].set()
							DrawOval( px, y, fld.height, fld.height )
						ElseIf hasfocus( fld )
							palette[ SECONDARY ].set()
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
				palette[ ONBACKGROUND ].set()
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
			If layout; layout.doLayout( Self )
			Invalid = False
		End If
		
		Local col1:Int = xpos+MARGIN
		Local col2:Int = col1+widths[0]+PADDING
		Local y:Int = ypos+MARGIN
		Local column:Int = 0
		
		' Background
		palette[ BACKGROUND ].set()
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
			palette[ isTrue ].set()
		Else
			palette[ isFalse ].set()
		End If
	End Method
	
	Function iif:String( state:Int, isTrue:String, isFalse:String )
		If state Return isTrue Else Return isFalse
	End Function

	Function iif:TColor( state:Int, isTrue:TColor, isFalse:TColor )
		If state Return isTrue Else Return isFalse
	End Function
	
	Method stringRepeat:String( char:String, count:Int )
		Return " "[..count].Replace(" ",char)
	End Method

	Method SetPalette( element:Int, color:Int )
		Assert element >=0 And element < palette.length, "Invalid colour element"
		Self.palette[ element ] = New TColor( color )
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
		palette[ colour ].set()
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
	Local area:SRectangle
	' BORDER
	widget.colors[ ST_BORDER ].set()
	area = shape.minus( widget.margin )
	DrawRect( area.x, area.y, area.w, area.h )
	' BACKGROUND
	widget.colors[ ST_BACKGROUND ].set()
	area = area.minus( widget.border )
	DrawRect( area.x, area.y, area.w, area.h )
	' PADDING
	Return area.minus( widget.padding )
End Function

Function _DrawCaption:SRectangle( form:TForm, fld:TFormField, shape:SRectangle )
	fld.colors[ ST_FOREGROUND ].set()
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

	fld.colors[ ST_FOREGROUND ].set()
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
			fld.colors[ ST_FOREGROUND ].set()
			'colour( inside, ONPRIMARY, ONSURFACE )
		Else
			fld.colors[ ST_FOREGROUND ].set()
			'colour( fld.disable, DISABLED, SURFACE )
		End If
		Local offset:Int = TextWidth( fld.value[..cursorpos] )
		DrawLine( shape.x+offset, shape.y+2, shape.x+offset, shape.y+shape.h-2 )

	End If	
	
End Function


Type TLayout

	Method doLayout( form:TForm ) Abstract
	
End Type

' A Very simple layout
Type TInspectorLayout Extends TLayout

	Const COLUMNS:Int = 3
	
	
	Method doLayout( form:TForm )
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

