SuperStrict

'Framework brl.Graphics
'Import brl.max2d

Type TWindow
' Graphics Resolution
Field gmode:TGraphics
Field grw:Int, grh:Int, grd:Int
' Virtual Graphics Resolution
Field width:Int, height:Int
' Other
Field scale:Float=1.00
'Field icon:String=""

	Method New( mode:TGraphicsMode, vwidth:Int=320, vheight:Int=200 )
		Self.width = vwidth
		Self.height = vheight
		resize( mode )
	End Method
	
	' Support for changing graphics mode at runtime
	Method resize( mode:TGraphicsMode )
		Self.grw = mode.width
		Self.grh = mode.height
		Self.grd = mode.depth
		If GMode ; Cls
		GMode = Graphics( grw, grh, grd )
		SetVirtualResolution( Self.width, Self.height )
		AutoMidHandle( True )
'?Win32
'		'# Set Application Icon (Windows only)
'		ccSetIcon( icon, GetActiveWindow())
'?
		Flip
		'#
		scale = 1
		SetScale( scale, scale )
	End Method

	'------------------------------------------------------------
	Method seticon( ico:String )
'		icon = ico
'?Win32
'		'# Set Application Icon (Windows only)
'		ccSetIcon( icon, GetActiveWindow())
'?
	End Method
	
	'------------------------------------------------------------
	' Set the virtual resolution
	Method setresolution( vwidth:Int, vheight:Int )
		Self.width = vwidth
		Self.height = vheight
		SetVirtualResolution( vwidth, vheight )
	End Method
End Type

' Get Graphics Modes
Local modes:TGraphicsMode[] = GraphicsModes()

DebugStop
Local screen:TWindow = New TWindow( modes[0] )
End

Local x:Int[2], d:Int[2]
d = [5,-5]
x[1] = screen.width
Repeat
	Cls
		' Update animation
		For Local i:Int = 0 Until 2
			x[i] :+ d[i]
			If x[i]>screen.width
				d[i] = -d[i]
				x[i] = screen.width
			ElseIf x[i] <= 0
				d[i] = -d[i]
			End If
		Next
		DrawLine( x[0],0, x[1],screen.height )
		
		' Draw menu
		


'		Local th:Int = TextHeight("8")
'		For Local i:Int = 0 Until Len( modes )
'			DrawText( i+") "+modes[i].name(), 5, i*th )
'		Next
		
		' Change modes
		Local ch:Int = GetChar()-48 	' CHR("0") = ASC(48)
		If ch>=0 And ch<Len(modes) ; screen.resize( modes[ch] )
	Flip
Until KeyHit( KEY_ESCAPE )


