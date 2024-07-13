SuperStrict

'	TYPEGUI EXAMPLE 2 - OBJECT INSPECTOR
'	Author: Si Dunford [Scaremonger], June 2023
'	Contributions from:
'		@GW		(Discord)
'		@mingw	(Discord)
'
'	Version 0.8, 13 JUL 2023
'
'	NOT FULLY IMPLEMENTED

Import "typegui-08.bmx"

AppTitle = "Example #2 - Object Inspector"

Global WHITE:TCOLOR = New TCOLOR( $ffffffff )
Global RED:TCOLOR = New TCOLOR( $ffff0000 )

Type TBlob
	Global autonumber:Int = 0
	
	Global list:TList = New TList
	Global counter:Int = 0
	Global mouseover:TBlob
	
	Field id:Int			{ ReadOnly }
	Field colour:TCOLOR	{ colorbox }
	'Field x:Float
	'Field y:Float
	Field pos:Vec2 = New Vec2()		
	Field radius:Int		{ range="5,15" }
	Field direction:Vec2 = New Vec2()
	Field Speed:Float
		
	Method New()
		autonumber :+ 1
		id = autonumber
		colour = New TCOLOR( Rand( 0,255), Rand( 0,255), Rand( 0,255) )
		radius = Rand( 5, 15 )
		pos.x = Rand( 0, GraphicsWidth() )
		pos.y = Rand( 0, GraphicsHeight() )
		While Abs(direction.x) < 0.01 And Abs(direction.y < 0.01)
			direction.x = RndFloat() * 2 - 1.0
			direction.y = RndFloat() * 2 - 1.0
		Wend
		speed = RndFloat() * 20 + 5
		list.addLast( Self )
	End Method
	
	Function updateall( delta:Float )
		TBlob.mouseover = Null
		For Local blob:TBlob = EachIn list
			blob.Update( delta )
		Next
	End Function
	
	Function renderall()
		For Local blob:TBlob = EachIn list
			blob.render()
		Next
	End Function
	
	Method Update( delta:Float )
		If TForm.boundsCheck( pos.x-radius, pos.y-radius, radius*2, radius*2 )
			TBlob.mouseover = Self
		End If
		
		pos :+ direction * speed * delta
		
		If pos.x < 0; pos.x :+ GraphicsWidth()
		If pos.x > GraphicsWidth(); pos.x :- GraphicsWidth()
		If pos.y < 0; pos.y :+ GraphicsHeight()
		If pos.y > GraphicsHeight(); pos.y :- GraphicsHeight()
	End Method
	
	Method render()
		TForm.iif( mouseover=Self, RED, WHITE ).set()
		DrawOval( pos.x-radius, pos.y-radius, radius*2, radius*2 )
		colour.set()
		DrawOval( pos.x-radius+1, pos.y-radius+1, radius*2-2, radius*2-2 )
	End Method
	
	' GUI FUNCTION
	Method onGUI( fld:TFormField ); End Method
	
End Type

' Custom Vector type because Struct cannot be read using reflection
Struct Vec2
	Field x:Float = 0 
	Field y:Float = 0
	Field threshold:Float = 0.000001
	
	Method New( x:Float, y:Float )
        Self.x = x
        Self.y = y
	End Method

	' local vec:Vec2 = VectorA + VectorB
	Method Operator +:Vec2( vec:Vec2 )
        Return New Vec2( x + vec.x, y + vec.y )
    End Method

	' local vec:Vec2 = VectorA - VectorB
	Method Operator -:Vec2( vec:Vec2 )
        Return New Vec2( x - vec.x, y - vec.y )
    End Method

	' local vec:Vec2 = Vector * number
	Method Operator *:Vec2( scalar:Float )
        Return New Vec2( x * scalar, y * scalar )
    End Method

	' VectorA :+ VectorB
	Method Operator :+ ( vec:Vec2 )
        x :+ vec.x
		y :+ vec.y
    End Method

	' Compares the vector values and not the object pointers
	Method Operator =:Int( vec:Vec2 )
		If Abs(x-vec.x)<threshold And Abs(y-vec.y)<threshold Return True
		Return False
	End Method

End Struct

Graphics 800,600
SetBlend( AlphaBlend )
SeedRnd MilliSecs()
HideMouse()

' Create some blobs
For Local n:Int = 1 Until 50
	Local blob:TBlob = New TBlob()
Next

Global inspector:TForm

Local lasttime:Float = MilliSecs()
Local thistime:Float
Local delta:Float
Repeat
	' Crude Deltatime
	thistime = MilliSecs()
	'delta = Max( 0.0, Min( thistime - lasttime, 0.25 ) )	' Clamp between 0.0 and 0.25
	delta = ( thistime - lasttime) / 1000
	lasttime = thistime
			
	Cls

	' Update
	TBlob.updateAll( delta )
	
	' Render
	TBlob.renderAll()

	' Inspector 
	If TBlob.mouseOver And MouseHit( 1 )
		inspector = New TForm( TBlob.mouseOver, MouseX(), MouseY() )
	End If
	If inspector And inspector.inspect(); inspector = Null

	' HUD
	WHITE.set()
	DrawText( "Click blob to edit", 5, GraphicsHeight()-10-TextHeight("8y") )

	DrawLine( MouseX()-5, MouseY(),   MouseX()-1, MouseY() )
	DrawLine( MouseX()+1, MouseY(),   MouseX()+5, MouseY() )
	DrawLine( MouseX(),   MouseY()-5, MouseX(),   MouseY()-1 )
	DrawLine( MouseX(),   MouseY()+1, MouseX(),   MouseY()+5 )
	
	Flip()
Until KeyHit( KEY_ESCAPE ) Or AppTerminate()
	


