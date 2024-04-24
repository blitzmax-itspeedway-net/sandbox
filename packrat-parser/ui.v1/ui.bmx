' A UI for debugging
SuperStrict

Import "MaterialDesignColour.bmx"

Const CURSOR_POINTER:Int = 0
Const CURSOR_HAND:Int = 1

Type GUI

	Global SURFACE:SColor8 = New SColor8( $FFFFFF )
	Global ERRCOL:SColor8 = ErrorColor
	Global PRIMARY:SColor8 = Teal700
	Global PRIMARYLO:SColor8 = Teal200
	Global PRIMARYHI:SColor8 = Teal900
	Global SECONDARY:SColor8 = Amber400
	
	Global ONSURFACE:SColor8 = BLACK
	Global ONPRIMARY:SColor8 = WHITE
	Global ONPRIMARYLO:SColor8 = WHITE
	Global ONPRIMARYHI:SColor8 = WHITE
	Global ONSECONDARY:SColor8 = WHITE
	Global ONERROR:SColor8 = WHITE

	'Private
	
	Field thread:TThread
	Field mutex:TMutex
	Field width:Int, height:Int
	
	Field btn:Int 			' Current Button
	Field mouseclick:Int
	Field running:Int = False
	
	Field cursors:TImage[2]
	Field cursor_frame:Int
	Field cursor_state:Int = True
	
	Public
	
	Method New( width:Int, height:Int )
		Self.width = width
		Self.height = height
		running = True
		mutex = CreateMutex()
		
		'Print CurrentDir()
		loadCursors()
		thread = CreateThread( GUI_Thread, Self )
		
		'AddHook( EmitEventHook, ui_hook, Self )
	End Method
	
	Method wait()
		If Not running
			Print "THREAD NOT RUNNING"
			Return
		End If
		Print "WAITING ON THREAD"
		WaitThread( thread )
		Print "THREAD FINISHED"
	End Method
	
	' This is temporary; enable threads when stable
	'Method sh()
	'	show()
	'End Method
	
	Method quit()
		LockMutex( mutex )
		running = False
		UnlockMutex( mutex )
	End Method
	
	'Private
	
	Method contains:Int( px:Int, py:Int, bx:Int, by:Int, bw:Int, bh:Int )
		If px>bx And px<bx+bw And py>by And py<by+bh; Return True
		Return False
	End Method
	
	Method show()
		Local window:TGraphics = Graphics( width, height )
		HideMouse()
		Repeat
			SetClsColor( PRIMARY )
			Cls
			' GUI
			mouseclick = MouseHit(1)
			setcursor( CURSOR_POINTER )
		
			DrawText( CurrentTime(), 5, 5 )

			If TryLockMutex( mutex )
				paint()
				If Not running Or AppTerminate(); Exit
			End If
			
			DrawCursor()
			Flip
		Forever
		CloseGraphics( window )
	End Method

	Method paint()
	End Method

	Method loadcursors()
		RestoreData CursorData
		Local index:Int, line:String
		For Local cursor:Int = 0 Until cursors.length
			ReadData( index )
			Assert index=cursor, "Invalid index "+index+" in cursor data. Expected "+cursor 
			Local pixmap:TPixmap = CreatePixmap( 20, 20, PF_RGBA8888 )
			For Local y:Int = 0 Until 20
				ReadData( line )
				Assert line.length=20, "Invalid cursor definition in cursor "+cursor+" at line "+y
				For Local x:Int = 0 Until 20
					Select Chr(line[x])
					Case "."	; WritePixel( pixmap, x, y, $00000000 )		' . = TRANSPARENT
					Case "#"	; WritePixel( pixmap, x, y, $FF000000 )		' # = BLACK
					Case "*"	; WritePixel( pixmap, x, y, $FFFFFFFF )		' * = WHITE
					Default
						Print "Unknown character '"+Chr(line[x])+"' in cursor "+cursor+" at position "+x+","+y
						End
					EndSelect
				Next
			Next
			cursors[cursor] = LoadImage( pixmap )
		Next
	End Method

	Method hideCursor()
		cursor_state = False
	End Method

	Method showCursor()
		cursor_state = True
	End Method

	Method DrawCursor()
		If Not cursor_state; Return
		SetColor( $ff, $ff, $ff )
		DrawImage( cursors[cursor_frame], MouseX(), MouseY() )
	End Method
	
	Method setCursor( cursor:Int )
		cursor_frame = cursor
	End Method

	'Method button:Int( caption:String, x:Int, y:Int, w:Int, h:Int, state:Int=False )
	Method button:Int( btn:SWidget, state:Int=False )
		Local mx:Int = MouseX()
		Local my:Int = MouseY()
		Local inside:Int = False
		Local textcolor:SColor8
		
		' BORDER
		If contains( mx, my, btn.x, btn.y, btn.width, btn.height )
			inside = True
			'SetColor( $00,$00,$ff )
			SetColor( SECONDARY )
			'textcolor = ONSECONDARY
			setcursor( CURSOR_HAND )
		Else
			'SetColor( $00,$00,$7f )
			SetColor( PRIMARYLO )
			'textcolor = ONPRIMARY
		End If
		DrawRect( btn.x, btn.y, btn.width, btn.height )

		' SURFACE
		If state
			'SetColor( $00,$00,$7F )
			SetColor( PRIMARYLO )
			textcolor = ONPRIMARYLO
		Else
			'SetColor( $00,$00,$00 )
			SetColor( PRIMARY )
			textcolor = ONPRIMARY
		End If
		DrawRect( btn.x+1, btn.y+1, btn.width-2, btn.height-2 )
		
		' TEXT
		SetColor( textcolor )
		DrawText( btn.caption, btn.x+(btn.width-TextWidth(btn.caption))/2,btn.y+(btn.height-TextHeight(btn.caption))/2 )
		
		Return (inside And mouseclick)
	End Method
	
	' Dialog returns TRUE when closed
	Method dialog:Int( area:SWidget, content:String[] = [], autoclose:Int=False )
	
		Const PADDING:Int = 3
		Const MAXLINELEN:Int = 60

		Local mx:Int = MouseX()
		Local my:Int = MouseY()
		Local inside:Int = False
		Local textcolor:SColor8
		Local th:Int = TextHeight("8w" )
		
		'DebugStop
		If content.length = 0 Or ( content.length="1" And content[0]="" ); content = ["Null"]
		Local titlesize:Int = TextHeight( area.caption ) + PADDING * 2
		Local width:Int = Max( 200, TextWidth( area.caption ) + titlesize )
		'Local lines:String[] = content.split("~n")
		For Local line:String = EachIn content
			If line.length > MAXLINELEN; line = line[..MAXLINELEN-3]+"..."
			width = Max( TextWidth(line), width )
		Next
		width :+ PADDING * 2
		Local height:Int = Max( 100, content.length * th + titlesize + PADDING * 2 )
		Local dx:Int = area.x - width/2
		Local dy:Int = area.y
		
		' BORDER
		'DebugStop
		SetColor( SURFACE )
		DrawRect( dx-1, dy-1, width+2, height+2 )
		
		' TITLEBAR
		SetColor( PRIMARY )
		DrawRect( dx, dy, width, height )
		
		SetColor( ONPRIMARY )
		DrawText( area.caption, dx + PADDING, dy + PADDING )
				
		' SURFACE
		SetColor( SURFACE )
		DrawRect( dx+1, dy+titlesize, width-2, height-titlesize-2 )
		
		SetColor( ONSURFACE )
		Local y:Int = dy + titlesize + PADDING
		For Local line:String = EachIn content
			'width = Max( line.length, width )
			If line.length > MAXLINELEN; line = line[..MAXLINELEN-3]+"..."
			DrawText( line, dx + PADDING, y )
			y :+ TextHeight( line )
		Next
		
		If autoclose
			Return Not contains( mx, my, dx, dy, width, height )
		Else
			' CLOSE BUTTON
			Local bx:Int = dx + width - titlesize
			Local by:Int = dy
			
			If contains( mx, my, bx, by, titlesize, titlesize )
				inside = True
				SetColor( SECONDARY )
				textcolor = ONSECONDARY
				setcursor( CURSOR_HAND )
			Else
				SetColor( PRIMARYLO )
				textcolor = ONPRIMARY
			End If
			DrawRect( bx, by, titlesize, titlesize )
			SetColor( textcolor )
			Local tx:Int = (titlesize-TextWidth("x"))/2
			Local ty:Int = (titlesize-TextHeight("x"))/2
			DrawText( "X", bx+tx,by+ty )
		
			Return (inside And mouseclick) Or KeyHit( KEY_ESCAPE )
		End If
	End Method
	
	Function GUI_Thread:Object( data:Object )
		Local ui:GUI = GUI( data )
		If ui
			ui.show()
		Else
			Print "GUI NOT INITIALISED"
		End If
	End Function
	
	'Function ui_hook:Object( id:Int,data:Object,context:Object )
	'	Local event:TEvent = TEvent( data )
	'	Local ui:GUI = GUI( context )
	'	If Not event Or Not ui; Return data
	'	
	'	Select event.id
	'	Case EVENT_MOUSEMOVE	' Ignore this
	'	Default
	'		Print event.toString()
	'	End Select
	'	
	'End Function
	
End Type

Struct SWidget
	'Field name:String
	Field caption:String
	Field tooltip:String
	Field x:Int
	Field y:Int
	Field width:Int
	Field height:Int

	Method New( caption:String, x:Float, y:Float, w:Float, h:Float )
		Self.caption = caption
		Self.x = x
		Self.y = y
		Self.width = w
		Self.height = h
	End Method

	Method New( x:Float, y:Float, w:Float, h:Float )
		Self.x = x
		Self.y = y
		Self.width = w
		Self.height = h
	End Method

	Method drawbox( x:Int, y:Int, w:Int, h:Int )
		DrawLine( x,   y,   x+w, y )
		DrawLine( x+w, y,   x+w, y+h )
		DrawLine( x+w, y+h, x,   y+h )
		DrawLine( x,   y+h, x,   y )
	End Method
	
End Struct

' Cursor Definitions
#CursorData
DefData 0                     ' CURSOR_POINTER
DefData "#..................."
DefData "##.................."
DefData "#*#................."
DefData "#**#................"
DefData "#***#..............."
DefData "#****#.............."
DefData "#*****#............."
DefData "#******#............"
DefData "#*******#..........."
DefData "#********#.........."
DefData "#*********#........."
DefData "#**********#........"
DefData "#******#####........"
DefData "#***#**#............"
DefData "#**#.#**#..........."
DefData "#*#..#**#..........."
DefData "##....#**#.........."
DefData "......#**#.........."
DefData ".......##..........."
DefData "...................."
DefData 1                     ' CURSOR_HAND
DefData "....##.............."
DefData "...#**#............."
DefData "...#**#............."
DefData "...#**#............."
DefData "...#**#............."
DefData "...#**#............."
DefData "...#**###.##........"
DefData ".###**#**#**###....."
DefData "#**#********#**#...."
DefData "#**************#...."
DefData "#******#**#****#...."
DefData "#******#**#****#...."
DefData ".#*****#**#***#....."
DefData "..#***********#....."
DefData "...#**********#....."
DefData "...#**********#....."
DefData "....#********#......"
DefData "....#********#......"
DefData "....##########......"
DefData "...................."





