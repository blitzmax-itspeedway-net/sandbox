SuperStrict

'	TYPEGUI
'	Author: Si Dunford [Scaremonger], June 2023
'	Contributions from:
'		@GW		(Discord)
'		@mingw	(Discord)
'	Version 0.2, 3 JUN 2023

Global SUPPORTED_TYPES:String[] = ["button","checkbox","password","radio","textbox"]
' Others: color,slider,icon,dropdown,textarea,intbox

Interface IForm
	Method onGUI( fld:TFormField )
End Interface

Global PALETTE_BLUE:Int[] = [..
	$c8c8c8,..	' BACKGROUND
	$ffffff,..	' SURFACE
	$0D47A1,..	' PRIMARY		- BLUE 900
	$FF9800,..	' SECONDARY		- ORANGE 500
	$8a8a8a,..	' DISABLED
	$000000,..	' ON BACKGROUND
	$0D47A1,..	' ON SURFACE	- BLUE 900
	$ffffff,..	' ON PRIMARY
	$ffffff,..	' ON SECONDARY
	$ffffff]	' ON DISABLED

Type TFormField
	'Field owner:IForm
	Field fld:TField
	Field fldName:String
	Field fldType:String
	Field caption:String
	Field datatype:String
	'Field value:String
	Field Length:Int
	Field options:String[]
	'
	'Field xpos:Int, ypos:Int
	Field width:Int, height:Int
	
End Type

Type TForm

	Const MARGIN:Int = 5
	Const PADDING:Int = 4
	Const BLINKSPEED:Int = 500
	
	Const BACKGROUND:Int = 0
	Const SURFACE:Int = 1
	Const PRIMARY:Int = 2
	Const SECONDARY:Int = 3
	Const DISABLED:Int = 4
	Const ONBACKGROUND:Int = 5
	Const ONSURFACE:Int = 6
	Const ONPRIMARY:Int = 7
	Const ONSECONDARY:Int = 8
	Const ONDISABLED:Int = 9
	
	Field parent:IForm
	Field title:String
	Field fields:TList
	Field xpos:Int, ypos:Int
	Field width:Int, height:Int
	Field widths:Int[2]
	
	Field focus:TFormfield		' Field with focus

	Field palette:SColor8[10]
	
	Field cursorstate:Int
	Field cursortimer:Int
	Field cursorpos:Int
	
	Method New( form:IForm )
		parent = form
		fields = New TList()
		
		height = MARGIN

		Local t:TTypeId = TTypeId.ForObject( form )
		title = t.metadata("title")
		Local x:String = title
		Local n:Int = TextHeight( x )
		If title; height :+ TextHeight( title ) + MARGIN
		
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
			
			Local row:TFormField = New TFormField()
			row.fld      = fld
			row.fldName  = fld.name()
			row.fldType  = fld.typeid().name()
			'row.datatype = Lower(fld.metadata("type"))
			row.caption  = fld.metadata("label")
			row.Length   = Int( fld.metadata("length") )
			'row.value    = fld.getString( parent )

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
			If row.Length = 0; row.Length = 10 
			row.height = Max( TextHeight( row.caption ), TextHeight("8y") )
			row.width  = TextWidth( stringRepeat( "W", row.Length ) )
			
			' Adjust width for multiple fields
			If row.datatype="radio"
				row.width = row.height*row.options.Length + PADDING*(row.options.Length)
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
		
		' Centralise form
		xpos = (GraphicsWidth()-width)/2
		ypos = (GraphicsHeight()-height)/2		
		
	End Method
	
	Method show()

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
			Select Lower(fld.datatype)
			Case "textbox", "password"
				Local value:String = fld.fld.getString(parent)
				' ACTION
				Local inside:Int = boundscheck( col2, y, widths[0], fld.height )
				If inside And MouseHit(1); setfocus( fld )
				' LABEL
				SetColor( palette[ PRIMARY ] )
				DrawText( fld.caption, col1, y )
				' BACKGROUND
				SetColor( palette[ SURFACE ] )
				'DrawRect( col2, y, fld.width, fld.height )
				DrawRect( col2, y, widths[1], fld.height )
				' BORDER
				If inside
					'drawBorder( PRIMARY, col2, y, fld.width, fld.height )
					drawBorder( PRIMARY, col2, y, widths[1], fld.height )
				ElseIf hasfocus( fld )
					'drawBorder( SECONDARY, col2, y, fld.width, fld.height )
					drawBorder( SECONDARY, col2, y, widths[1], fld.height )
				End If
				' FOREGROUND
				SetColor( Palette[ PRIMARY ] )
				Local text:String = iif( fld.datatype="password", stringRepeat( "*", value.Length ), value )
				DrawText( text, col2, y+2 )
				' CURSOR
				If hasfocus( fld )
					If KeyHit( KEY_HOME ); cursorpos = 0
					If KeyHit( KEY_END ); cursorpos = value.Length
					If KeyHit( KEY_LEFT ); cursorpos :- 1
					If KeyHit( KEY_RIGHT ); cursorpos :+ 1
					cursorpos = Max( 0, Min( cursorpos, value.Length ))	' Bounds validation
					If KeyHit( KEY_DELETE ); value = value[..cursorpos]+value[cursorpos+1..]
					If KeyHit( KEY_BACKSPACE ); value = value[..cursorpos-1]+value[cursorpos..]
					Local key:Int = GetChar()
					If key>31 And key<127
						'DebugStop
						value = value[..cursorpos]+Chr(key)+value[cursorpos..]
						cursorpos :+ 1
					End If
					' Draw cursor
					If cursorstate
						Local offset:Int = TextWidth( value[..cursorpos] )
						colour( inside, ONPRIMARY, ONSURFACE )
						DrawLine( col2+offset, y+2, col2+offset, y+fld.height-2 )
					End If
				End If
				' UPDATE TYPE
				fld.fld.setString( parent, value )
			Case "button"
				Local value:String = fld.fld.getString(parent)
				' ACTION
				Local inside:Int = boundscheck( col1, y, widths[0], fld.height )
				If inside And MouseHit( 1 )
					setfocus( fld )
					parent.onGUI( fld )
				End If
				Local pressed:Int = MouseDown(1) And inside
				' BACKGROUND
				SetColor( palette[ PRIMARY ] )
				DrawRect( col1+pressed, y+pressed, fld.width, fld.height )
				If Not pressed
					SetColor( $22,$22,$22 )
					DrawLine( col1+fld.width, y,            col1+fld.width, y+fld.height )
					DrawLine( col1,           y+fld.height, col1+fld.width, y+fld.height )
				End If
				' BORDER
				If inside
					drawBorder( SECONDARY, col1+pressed, y+pressed, fld.width, fld.height )
				'ElseIf hasfocus( fld )
				'	drawBorder( SECONDARY, col1+pressed, y+pressed, fld.width, fld.height )
				End If
				' FOREGROUND
				SetColor( palette[ ONPRIMARY ] )
				DrawText( value, col1+(col2-col1-PADDING-TextWidth(value))/2+pressed, y+pressed+1 )
			Case "checkbox"
				Local value:Int = fld.fld.getInt( parent )
				' ACTION
				Local inside:Int = boundscheck( col2, y, fld.height, fld.height )
				If inside And MouseHit( 1 )
					value = Not value
					setfocus( fld )
				End If
				' LABEL
				SetColor( palette[ PRIMARY ] )
				DrawText( fld.caption, col2+fld.height+PADDING, y+2 )	' We use height here to make a square!
				' BACKGROUND
				SetColor( Palette[ SURFACE ] )
				DrawRect( col2, y, fld.height, fld.height )		' We use height here to make a square!
				' BORDER
				If inside
					drawBorder( PRIMARY, col2, y, fld.height, fld.height )
				ElseIf hasfocus( fld )
					drawBorder( SECONDARY, col2, y, fld.height, fld.height )
				End If
				' FOREGROUND
				If value
					SetColor( Palette[ PRIMARY ] )
					DrawRect( col2+3, y+3, fld.height-6, fld.height-6 )
				EndIf
				' SET FIELD VALUE
				fld.fld.setInt( parent, value )
			Case "radio"
				Local value:Int = fld.fld.getInt( parent )
				' LABEL
				SetColor( palette[ PRIMARY ] )
				DrawText( fld.caption, col1, y+2 )
				'
				' Create button for each option
				Local px:Int = col2
				For Local id:Int = 1 To fld.options.Length
					Local inside:Int = boundscheck( px, y, fld.height, fld.height )
					If inside And MouseHit( 1 )
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
					' BACKGROUND
					SetColor( Palette[ SURFACE ] )
					DrawOval( px+1, y+1, fld.height-2,fld.height-2 )
					' FOREGROUND
					SetColor( palette[ PRIMARY ] )
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
				DrawText( fld.caption, col1, y )
			End Select
			y:+fld.height+PADDING			
		Next
	
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
	
	Method stringRepeat:String( char:String, count:Int )
		Return " "[..count].Replace(" ",char)
	End Method

	Method SetPalette( element:Int, color:Int )
		Assert element >=0 And element < palette.Length, "Invalid colour element"
		Self.palette[ element ] = New SColor8( color )
	End Method

	Method SetPalette( palette:Int[] )
		Assert palette.Length = Self.palette.Length, "Invalid palette"
		For Local element:Int = 0 Until palette.Length
			SetPalette( element, palette[element] )
		Next
	End Method

	Method boundscheck:Int( x:Int, y:Int, w:Int, h:Int )
		If MouseX()>x And MouseY()>y And MouseX()<x+w And MouseY()<y+h; Return True
		Return False
	End Method
	
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
	
End Type