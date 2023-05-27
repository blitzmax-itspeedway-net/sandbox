
'   TEST
'   (c) Copyright Si Dunford, MMM 2022, All Rights Reserved. 

'	This application tests the indirection list
'	The biggest issue here is "How the hell do I test it"!

'	

SuperStrict

Import "indirection-list-2.bmx"
Import "../../../prototype.ux/ux.bmx"	

AppTitle = "Test Indirection List"

Function SetupUX()
	UX.Init()
	'UX.SetColor( UX.COL_SURFACE, New SColor8( $C0B090 ) )
	'UX.SetColor( UX.COL_ONSURFACE, New SColor8( $504030 ) )
	Return
	
	' Define the colours 
	UX.SetColor( UX.COL_BACKGROUND, New SColor8( $404040 ) )	'# Charcoal
	'UX.SetColor( UX.COL_ONBACKGROUND, WHITE )
	'UX.SetModal( 0.5 )
	
	UX.SetColor( UX.COL_SURFACE, New SColor8( $C0B090 ) )
	UX.SetColor( UX.COL_ONSURFACE, New SColor8( $504030 ) )
	
	UX.SetColor( UX.COL_PRIMARY, New SColor8( $A09088 ) )
	UX.SetColor( UX.COL_ONPRIMARY, BLACK )

	UX.SetColor( UX.COL_PRIMARY_VARIANT, New SColor8( $FFF0E0 ) )
	UX.SetColor( UX.COL_ONPRIMARY_VARIANT, New SColor8( $A09088 ) )
	
	UX.SetColor( UX.COL_SECONDARY, New SColor8( $988070 ) )
	UX.SetColor( UX.COL_ONSECONDARY, New SColor8( $FFF0E0 ) )
	
	'UX.SetColor( UX.COL_SECONDARY_VARIANT, New SColor8( $988070 ) )
	'UX.SetColor( UX.COL_ONSECONDARY_VARIANT, BLACK )

	'UX.SetColor( UX.COL_ERROR, New SColor8( $B00020 ) )
	'UX.SetColor( UX.COL_ONERROR, WHITE )

	'UX.SetColor( UX.COL_DISABLE, New SColor8( $c0c0c0 ) )
	
	'UX.SetSize( 102, 19 )	' Set a fixed size for controls
	UX.setPadding( 2, 2 )

End Function

Graphics 800,600
'Local height:Int = TextHeight( "T_y" )
'Local MARGIN:Int = 2
'Local PADDING:Int = 2

' Create an Indirection List
'DebugStop
Global entities:TIndirectionList = New TIndirectionList( 10 )

' Initialise UX parameters
SetupUX()

Repeat
	SetClsColor( UX.GetColor( UX.COL_BACKGROUND ) )
	Cls

	Local ypos:Int
	Local xpos:Int
	Local txt:String

	' Draw a simple GUI
	UX.modal()
	
	
	'	DRAW CONTROLS
		
	UX.Frame( 10, 10, 120, GraphicsHeight()-20 )
	ypos = 10
	xpos = 10
	Local free:Int = entities.free()
	Local flags:Int =0
	If Not free; flags = UX.DISABLED
	
	If UX.Button( 200, "CAT++", xpos, ypos, 100, 19, flags )
		Local h:THandle = entities.add( "CAT" )
		If Not h ; Print "INVALID HANDLE"
	End If
	ypos :+ 25
	If UX.Button( 201, "DOG++", xpos, ypos, 100, 19, flags )
		Local h:THandle = entities.add( "DOG" )
		If Not h ; Print "INVALID HANDLE"
	End If
	ypos :+ 25
	If UX.Button( 202, "RABBIT++", xpos, ypos, 100, 19, flags )
		Local h:THandle = entities.add( "RABBIT" )
		If Not h ; Print "INVALID HANDLE"
	End If		
	ypos :+ 25
	txt = "SIZE:"+entities.size()
	SetColor( $A0, $90, $88 )
	DrawText( txt, xpos+10+(100-TextWidth(txt))/2, ypos+10+(19-TextHeight(txt))/2 )
	ypos :+ 25
	txt = "USED:"+entities.used()
	SetColor( $A0, $90, $88 )
	DrawText( txt, xpos+10+(100-TextWidth(txt))/2, ypos+10+(19-TextHeight(txt))/2 )
	ypos :+ 25
	txt = "FREE:"+entities.free()
	If free=0
		SetColor( Ux.GetColor( UX.COL_ERROR ) )
	Else
		SetColor( $A0, $90, $88 )
	End If
	DrawText( txt, xpos+10+(100-TextWidth(txt))/2, ypos+10+(19-TextHeight(txt))/2 )
	ypos :+ 25
	txt = "HEAD:"+entities.head
	SetColor( $A0, $90, $88 )
	DrawText( txt, xpos+10+(100-TextWidth(txt))/2, ypos+10+(19-TextHeight(txt))/2 )
	ypos :+ 25
	txt = "TAIL:"+entities.tail
	SetColor( $A0, $90, $88 )
	DrawText( txt, xpos+10+(100-TextWidth(txt))/2, ypos+10+(19-TextHeight(txt))/2 )

	'	Draw the ENTIRE ARRAY
	
	UX.Frame( 150, 10, 120, GraphicsHeight()-20 )
	ypos = 10
	xpos = 10
	
	txt = "ARRAY"
	SetColor( $A0, $90, $88 )
	DrawText( txt, xpos+150+(100-TextWidth(txt))/2, ypos+10+(19-TextHeight(txt))/2 )
	ypos:+20

	' Loop through entities list
	For Local index:UInt = 0 Until entities.list.length
		Local txt:String
		
		' Get the record at given index
		Local hnd:THandleRecord = entities.list[ index ]
		
		If hnd And hnd.enabled()
			txt = index+". "+hnd.name+" V"+hnd.version
			' Create a button
			If UX.Button( index+1, txt, xpos, ypos, 100, 19 )
				Print("pressed")
				entities.remove( New THandle( index, hnd.version ) )
			End If
		Else
			If hnd
				txt = index+". "+hnd.name+" V"+hnd.version
			Else
				txt = index+". Null"
			End If
			
			SetColor( $c0, $c0, $c0 )
			DrawRect( xpos+150, ypos+10, 100, 19 )
			SetColor( $00, $00, $00 )
			DrawText( txt, xpos+150+(100-TextWidth(txt))/2, ypos+10+(19-TextHeight(txt))/2 )
		End If
		
		ypos :+ 20
		
	Next
	
	'	Draw the Free Stack
	
	UX.Frame( 300, 10, 120, GraphicsHeight()-20 )
	ypos = 10
	xpos = 10
	Local node:Int = entities.head
	
	txt = "FREE LIST"
	SetColor( $A0, $90, $88 )
	DrawText( txt, xpos+300+(100-TextWidth(txt))/2, ypos+10+(19-TextHeight(txt))/2 )
	ypos:+20
	
	While node<>0
		' Create a label for each record
		txt = "#"+node+" V"+entities.list[node].version
		txt :+ " <"+entities.list[node]._prev+"-"+entities.list[node]._next+">"
	
		SetColor( $c0, $c0, $c0 )
		DrawRect( xpos+300, ypos+10, 100, 19 )
		SetColor( $00, $00, $00 )
		DrawText( txt, xpos+300+(100-TextWidth(txt))/2, ypos+10+(19-TextHeight(txt))/2 )
		node = entities.list[node]._next
		ypos :+ 20
	Wend
	
	'	Draw the iterable list
	UX.Frame( 450, 10, 120, GraphicsHeight()-20 )
	ypos = 10
	xpos = 10

	Rem txt = "LIST ITERABLE"
	SetColor( $A0, $90, $88 )
	DrawText( txt, xpos+450+(100-TextWidth(txt))/2, ypos+10+(19-TextHeight(txt))/2 )
	ypos:+20
	
	For Local item:THandleRecord = EachIn entities
		' Create a label for each record
		txt = itementities.list[head]head+" V"+entities.list[head].version
	
		SetColor( $c0, $c0, $c0 )
		DrawRect( xpos+300, ypos+10, 100, 19 )
		SetColor( $00, $00, $00 )
		DrawText( txt, xpos+300+(100-TextWidth(txt))/2, ypos+10+(19-TextHeight(txt))/2 )
		head = entities.list[head].freeptr
		ypos :+ 20
	
	Next
	End Rem
Rem
	ECS.pre_update()
	
	Local clicked:Int = MouseHit(1)
		
	'Local count:Int = 0
	For Local index:Int = 0 Until entities.list.length
	'For Local h:THandleRecord = EachIn entities.list
		Local h:THandleRecord = entities.list[ index ]
		
		Local tp:Int = MARGIN + ( height + MARGIN ) * index 
		Local lt:Int = MARGIN
		Local wd:Int = 100
		Local rt:Int = lt + wd
		Local bt:Int = tp + height

'Next - Add version numbers To list And check they increment
'Attempt To access a removed handle
'	draw table (TList) of alien handles.???
		
		If h.enable
			SetColor( 0,0,$ff )
			DrawRect( lt, tp, wd, height )
			SetColor( $ff,$ff,$ff )
			Local data:String = String( h.name )
			DrawText( h.name+" V"+h.version, lt+PADDING, tp )
			
			If clicked And MouseX()>lt And MouseX()<rt And MouseY()>tp And MouseY()<bt
				clicked = False
				entities.remove( New THandle( index, h.version, 0 ) )
			End If
		Else
			If index = 0
				SetColor( $ff,$00,$00 )
				DrawRect( lt, tp, wd, height )
				SetColor( $ff,$ff,$ff )
				DrawText( "INDEX", lt+PADDING, tp )
			Else
				SetColor( $00,$ff,$00 )
				DrawRect( lt, tp, wd, height )
				SetColor( $ff,$ff,$ff )
				DrawText( "FREE", lt+PADDING, tp )
			End If
		End If

		'count :+1
		'If count >= 30 Exit

	Next

	' Create a new alien
	If clicked 
		Local h:THandle = entities.add( "ALIEN" )
		If Not h ; Print "INVALID HANDLE"
	End If
	ECS.update()
	ECS.post_update()
EndRem

    Flip
	Delay( 1 )
Until KeyHit( KEY_ESCAPE ) Or AppTerminate()



