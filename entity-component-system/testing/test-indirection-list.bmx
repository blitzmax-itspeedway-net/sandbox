
'   TEST
'   (c) Copyright Si Dunford, MMM 2022, All Rights Reserved. 

'	This application tests the indirection list
'	The biggest issue here is "How the hell do I test it"!

'	

SuperStrict

Import "../bin/indirection_list.bmx"
Import "../../prototype.ux/ux.bmx"	

Print UX.COL_SURFACE

Function SetupUX()
	UX.Init()
	'UX.SetColor( UX.COL_SURFACE, New SColor8( $C0B090 ) )
	'UX.SetColor( UX.COL_ONSURFACE, New SColor8( $504030 ) )
	Return
	
	' Define the colours for SFXR
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
	
	'UX.SetSize( 102, 19 )	' Set a fixed size for controls
	UX.setPadding( 2, 2 )

End Function

Graphics 800,600
'Local height:Int = TextHeight( "T_y" )
'Local MARGIN:Int = 2
'Local PADDING:Int = 2

' Create an Indirection List
Global entities:THandleIndex = New THandleIndex( 4, 4, 4 )

' Initialise UX parameters
SetupUX()

Repeat
	SetClsColor( UX.GetColor( UX.COL_BACKGROUND ) )
	Cls
	
	' Draw a simple GUI
	UX.modal()
	UX.Frame( 10, 10, 112, GraphicsHeight()-20 )
	
	' Loop through entities list
	For Local index:UInt = 0 Until entities.list.length
	
		' Get the record at given index
		Local hnd:THandleRecord = entities.list[ index ]
		
		' Create a button for each record
		Local txt:String = hnd.name+" V"+hnd.version
		If hnd.enabled()
			If UX.Button( index+1, txt, 5, 5+index*20, 100, 19 )
				Print("pressed")
				entities.remove( New THandle( index, hnd.version, UINT(0) ) )
			End If
		Else
			SetColor( $c0, $c0, $c0 )
			DrawRect( 15, 15+index*20, 100, 19 )
			SetColor( $00, $00, $00 )
			DrawText( txt, 5+(100-textwidth(txt))/2, 15+index*20+(19-textheight(txt))/2 )
		End If
		
	Next
	
	UX.Frame( 132, 10, GraphicsWidth()-142, 55 )
	
	If UX.Button( 200, "CAT++", 5, 5, 100, 19 )
		Local h:THandle = entities.add( "CAT" )
		If Not h ; Print "INVALID HANDLE"
	End If
	If UX.Button( 201, "DOG++", 110, 5, 100, 19 )
		Local h:THandle = entities.add( "DOG" )
		If Not h ; Print "INVALID HANDLE"
	End If
	If UX.Button( 202, "RABBIT++", 215, 5, 100, 19 )
		Local h:THandle = entities.add( "RABBIT" )
		If Not h ; Print "INVALID HANDLE"
	End If
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



