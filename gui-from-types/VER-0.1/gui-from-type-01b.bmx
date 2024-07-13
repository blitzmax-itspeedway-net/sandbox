SuperStrict

' GUI FROM TYPE
' VERSION 0.1b - Scaremonger, 3 JUN 2023

'	EXAMPLE SHOWING BASIC FORM FROM TYPE
'	Author: Si Dunford [Scaremonger], June 2023
'	Contributions from:
'		@GW		(Discord)
'		@mingw	(Discord)

Interface IForm
	Method onClick( fld:TFormField )
End Interface

Global PALETTE_BLUE:Int[] = [..
	$c8c8c8,..	' BACKGROUND
	$ffffff,..	' SURFACE
	$0071dc,..	' PRIMARY
	$002c5c,..	' SECONDARY
	$8a8a8a,..	' DISABLED
	$000000,..	' ON BACKGROUND
	$000000,..	' ON SURFACE
	$ffffff,..	' ON PRIMARY
	$ffffff,..	' ON SECONDARY
	$ffffff]	' ON DISABLED

Type TFormField
	Field fld:TField
	Field fldName:String
	Field fldType:String
	Field caption:String
	Field datatype:String
	Field value:String
	Field Length:Int
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
			Local meta:String = fld.metadata()

			'Only include fields with metadata
			If Not meta; Continue
			
			Local row:TFormField = New TFormField()
			row.fld      = fld
			row.fldName  = fld.name()
			row.fldType  = fld.typeid().name()
			row.datatype = Lower(fld.metadata("type"))
			row.caption  = fld.metadata("text")
			row.Length   = Int( fld.metadata("length") )
			row.value    = fld.getString( parent )

			' Validation
			If Not row.caption; row.caption = row.fldname
			If row.Length = 0; row.Length = 10 
			row.height = Max( TextHeight( row.caption ), TextHeight("8y") )
			row.width  = TextWidth( stringRepeat( "W", row.Length ) )
			
			' Calculate column widths
			widths[0] = Max( widths[0], TextWidth( row.caption ) )
			widths[1] = row.width
			height :+ row.height + PADDING
			
			'DebugStop
			fields.addlast( row )

		Next
	
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
			DrawText( title, col1, y )
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
				Local inside:Int = boundscheck( col2, y, widths[0], fld.height )
				If inside And MouseHit(1); setfocus( fld )
				' LABEL
				SetColor( palette[ ONBACKGROUND ] )
				DrawText( fld.caption, col1, y )
				' BACKGROUND
				colour( inside, PRIMARY, SURFACE )
				DrawRect( col2, y, fld.width, fld.height )
				' BORDER
				If hasfocus( fld ); drawBorder( PRIMARY, col2, y, fld.width, fld.height )
				' FOREGROUND
				colour( inside, ONPRIMARY, ONSURFACE )
				Local text:String = iif( fld.datatype="password", stringRepeat( "*", fld.value.Length ), fld.value )
				DrawText( text, col2, y )
				' CURSOR
				If hasfocus( fld )
					If KeyHit( KEY_HOME ); cursorpos = 0
					If KeyHit( KEY_END ); cursorpos = Fld.value.Length
					If KeyHit( KEY_LEFT ); cursorpos :- 1
					If KeyHit( KEY_RIGHT ); cursorpos :+ 1
					cursorpos = Max( 0, Min( cursorpos, fld.value.Length ))	' Bounds validation
					If KeyHit( KEY_DELETE )
						'DebugStop
						fld.value = fld.value[..cursorpos]+fld.value[cursorpos+1..]
					End If
					If KeyHit( KEY_BACKSPACE )
						'DebugStop
						fld.value = fld.value[..cursorpos-1]+fld.value[cursorpos..]
					End If
					Local key:Int = GetChar()
					If key>31 And key<127
						'DebugStop
						fld.value = fld.value[..cursorpos]+Chr(key)+fld.value[cursorpos..]
						cursorpos :+ 1
					End If
					' Draw cursor
					If cursorstate
						Local offset:Int = TextWidth( fld.value[..cursorpos] )
						colour( inside, ONPRIMARY, ONSURFACE )
						DrawLine( col2+offset, y+2, col2+offset, y+fld.height-2 )
					End If
				End If
			Case "button"
				Local inside:Int = boundscheck( col1, y, widths[0], fld.height )
				' BACKGROUND
				If inside And MouseHit( 1 ); parent.onclick( fld )
				colour( inside, PRIMARY, SECONDARY )
				DrawRect( col1, y, fld.width, fld.height )
				' FOREGROUND
				colour( inside, ONPRIMARY, ONSECONDARY )
				DrawText( fld.value, col1+(col2-col1-PADDING-TextWidth(fld.value))/2, y )
			Case "radio"
				Local rsize% = 14
				Local inside:Int = boundscheck( col2, y, rsize,rsize) 'widths[0], fld.height )
				If inside And MouseHit( 1 ); parent.onclick( fld )
				SetColor( palette[ ONBACKGROUND ] )
				DrawText( fld.caption, col1, y )
				colour( inside, PRIMARY, SECONDARY )
				DrawOval(col2, y, rsize,rsize)
				colour( inside, ONPRIMARY, ONSECONDARY )
				DrawOval(col2+1, y+1, rsize,rsize)
				SetColor( palette[ ONBACKGROUND ] )
				If fld.value<>"" Then
					DrawOval(col2+4, y+4, rsize-6,rsize-6)
				Else    
				EndIf
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
		DrawLine( x, y, x+w, y )
		DrawLine( x+w, y, x+w, y+h )
		DrawLine( x+w, y+h, x, y+h )
		DrawLine( x, y+h, x, y )
	End Method
	
	Method hasfocus:Int( fld:TFormField )
		Return (focus = fld)
	End Method
	
	Method setfocus( fld:TFormField )
		focus = fld 
	End Method
	
End Type

' This is going to be our GUI Form:

Type TExample Implements IForm {title="Example"}

	Field Username:String	{Type="textbox" label="User Name" Length=10}
	Field Password:String	{Type="password"}
	Field test:String
	Field Gender:Int =0		{Type="radio" options="male,female"}
	
	Field ok:String = "OK" 	{Type="button"}
	
	Method New()
	End Method
	
	Method onclick( fld:TFormField )
		Print( "onclick() -> "+fld.fldName )
		If fld.fldName = "Gender" Then fld.value = TForm.iif(fld.value<>"","","X")
	End Method
	
End Type

Graphics 800,600

Local myform:TExample = New TExample()

Local form:TForm = New TForm( myform )
form.setPalette( PALETTE_BLUE )

Repeat
	SetClsColor( $cc,$cc,$cc )
	Cls

	form.show()

	Flip
Until KeyHit( KEY_ESCAPE ) Or AppTerminate()
