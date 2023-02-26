
'	Prototyping User Interface
'	Written by Si Dunford, Feb 2023

'	Released into the public domain without warranty
'	Please feel free to do what you want with it

'	Yes; I know its inefficient to create lots of objects. This is for prototyping!

'Import bmx.json

Struct SDimensions
	Field x:Int
	Field Y:Int
	Field w:Int
	Field h:Int
	Method New(x:Int,y:Int,w:Int,h:Int)
		Self.x=x
		Self.y=y
		Self.w=w
		Self.h=h
	End Method
End Struct

Function Setup()
End Function

Type TProtoUX

	Const GRID:Int = 0
		
	' Colours
	Const COL_PRIMARY:Int 				= 0
	Const COL_PRIMARY_VARIANT:Int 		= 1
	Const COL_SECONDARY:Int 			= 2
	Const COL_SECONDARY_VARIANT:Int 	= 3

	Const COL_BACKGROUND:Int			= 4
	Const COL_SURFACE:Int				= 5
	Const COL_ERROR:Int 				= 6

	Const COL_ONPRIMARY:Int				= 7
	Const COL_ONPRIMARY_VARIANT:Int 	= 8
	Const COL_ONSECONDARY:Int 			= 9
	Const COL_ONSECONDARY_VARIANT:Int	= 10

	Const COL_ONBACKGROUND:Int 			= 11
	Const COL_ONSURFACE:Int 			= 12
	Const COL_ONERROR:Int				= 13

	Global BLACK:SColor8 = New SColor8( $000000 )
	Global WHITE:SColor8 = New SColor8( $FFFFFF )

	Field _palette:SColor8[]
	'Field list:SWidget
	'Field cursor:Int
	Field _stack:TList = New TList()	'FIFO stack
	Field _frame:UXContainer			' Current Frame
	'Field _layout:Int = GRID
	
	Method New()
		_palette = [ ..
			New SColor8( $2196F3 ),		' PRIMARY
			New SColor8( $0D47A1 ),		' PRIMARY VARIANT
			New SColor8( $FF9800 ),		' SECONDARY
			New SColor8( $E65100 ),		' SECONDARY VARIANT
			New SColor8( $FFFFFF ),		' BACKGROUND
			New SColor8( $EFE5FD ),		' SURFACE
			New SColor8( $B00020 ),		' ERROR
			WHITE,						' ON PRIMARY
			WHITE,						' ON PRIMARY VARIANT
			BLACK,						' ON SECONDARY
			WHITE,						' ON SECONDARY VARIANT
			BLACK,						' ON BACKGROUND
			BLACK,						' ON SURFACE
			WHITE ..					' ON ERROR
			]
	End Method 
	'Method New( maximum:Int = 10 )
	'	list = New SWidget[maximum]
	'	cursor = 0
	'End Method
	
	' Push current frame to stack
	Method push()
		_stack.addLast( _frame )
	End Method
	
	' Pop last frame from stack
	Method pop()
		_frame = UXContainer( _stack.removelast() )
	End Method
	
	Method setBackgroundColor()
		SetColor( _palette[ COL_BACKGROUND ] )
	End Method
	
	Method SetColor( color:Int )
		If color<_palette.length; SetColor( _palette[ color ] )
	End Method
	
	' Create a frame to add components
	Method frame( x:Int, y:Int, w:Int, h:Int )
		_frame = New UXFrame( Self,x,y,w,h )	'.clear()
	End Method
	
	' Create a layout in the current frame
	Method layout( _layout:Int, rows:Int=-1, cols:Int=-1 )
		Local box:SDimensions = _frame.box
		push()	' Push current frame
		_frame = New UXLayout( Self, box, rows, cols )
	End Method
	
	Method Button:Int( caption:String )
		' Get size and position of widget
		Local box:SDimensions = _frame.add()
		
		SetColor( COL_PRIMARY )
		DrawRect( box.x, box.y, box.w, box.h )
		SetColor( COL_ONPRIMARY )
		Local th:Int = TextHeight( caption )
		Local tw:Int = TextWidth( caption )
		DrawText( caption, box.x+(box.w-tw)/2, box.y+(box.h-th)/2 )
	End Method
	
	'Method find:Int( name:String )
End Type

Interface IWidget
End Interface

Interface IContainer
	Method add( control:IWidget )
End Interface

Type UXWidget
	Field parent:IWidget
	Field box:SDimensions
End Type

Type UXContainer Extends UXWidget
	Field ux:TProtoUX
	
	'Method getBox:SDimensions()
	'	Return box
	'End Method
	
	Method add:SDimensions()
		Return box
	End Method
	
End Type

Type UXFrame Extends UXContainer	'Extends TWidget Implements IWidget,IContainer
	'Field list:TList = New TList()
	
	Method New( ux:TProtoUX, x:Int, y:Int, w:Int, h:Int )
		Self.ux = ux
		box.x = x
		box.y = y
		box.w = w
		box.h = h
		ux.SetColor( ux.COL_SURFACE )
		DrawRect( box.x, box.y, box.w, box.h )
	End Method
	
	'Method clear:UXFrame()
	'	ux.SetColor( ux.COL_SURFACE )
	'	DrawRect( x, y, w, h )
	'	Return Self
	'End Method
	
End Type

Type UXLayout Extends UXContainer
	Field grid:UXFrame[]
	Field rows:Int, cols:Int
	Field cursor:Int = 0	' Current cell

	Method New( ux:TProtoUX, box:SDimensions, rows:Int, cols:Int )
		Self.ux = ux
		Self.box = box
		Self.rows = rows
		Self.cols = cols
		grid = New UXFrame[ rows*cols ]	' Allocate an array
		fillgrid()
		ux.SetColor( ux.COL_SURFACE )
		DrawRect( box.x, box.y, box.w, box.h )
	End Method
	
	Method get:UXFrame( row:Int, col:Int )
		Local cell:Int = ((row-1)*cols+col ) Mod grid.length
		'If cell>grid.length; Throw "out of bounds"
		Return grid[cell]
	End Method

	Method get:SDimensions()
		Local cell:Int = cursor
		cursor = ( cursor + 1 ) Mod grid.length
		Return grid[cell].box
	End Method
	
	Method fillgrid()
		DebugStop
		Local w:Int = box.w/cols
		Local h:Int = box.h/rows
		For Local col:Int = 0 Until cols
			For Local row:Int = 0 Until rows
				Local cell:Int = row*cols+col
				Local x:Int = (col)*w
				Local y:Int = (row)*h
				grid[cell] = New UXFrame( ux, box.x, box.y, w, h )
			Next
		Next
	End Method
End Type

'End Type

'Type TWidgets

'	Method location:TWidget( x:Int, y:Int )
		'Self.x = x
		'Self.y = y
		'Return Self
'	End Method
	
'	Method size:TWidget( w:Int, h:Int )
		'elf.w = w
		'Self.h = h
'	End Method
	
'End Type
	
'Type TButton Extends TWidget
'End Type
DebugStop
Local ux:TProtoUX = New TProtoUX()

'ux.layout( UX.GRID, 3, 3 )

Graphics 800,600
Repeat
	ux.setBackgroundColor()
	Cls
	'DebugStop
	ux.frame( 100,100,GraphicsWidth()-200,GraphicsHeight()-200 )
	ux.layout( ux.GRID, 3, 3 )
	ux.button( "Hello" )
	ux.pop()					' Exit grid back to frame
	
Rem	ux.layoutStart( GRID, 3, 3 )		' Screen 
		ux.text( "Example.1" )
		ux.text( "Example.2" )
		ux.text( "Example.3" )
		ux.push( ux.layout( GRID, 2,1 ) )
			ux.button( "OK" )
			ux.button( "Cancel" )
			ux.pop()
		ux.text( "Example.4" )
End Rem		
	
	Flip
	Delay( 1 )
Until KeyHit( KEY_ESCAPE ) Or AppTerminate()
