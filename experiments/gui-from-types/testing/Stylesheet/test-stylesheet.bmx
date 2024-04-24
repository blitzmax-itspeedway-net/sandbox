SuperStrict

' Comment out the colour of TLabel in the stylesheet and disable is applied correctly

Include "cut-down-gui.bmx"
Include "TStylesheet.v3.bmx"

AppTitle="Stylesheet issue"

Local widget:TLabel = New TLabel("hello")
Local stylesheet:TStylesheet = New TStylesheet()
widget.setStyle( stylesheet )

Graphics( 320, 200 )
Local lineheight:Int = TextHeight( "8p" )

Repeat
	Cls
	
	SetColor( widget.palette[ COLOR.SURFACE ] )
	DrawRect( 50,50, GraphicsWidth()-100, GraphicsHeight()-100 )
	
	If KeyHit( KEY_E )
		If widget.flagset( FLAG_DISABLED )
			widget.unsetFlag( FLAG_DISABLED )
		Else
			widget.setFlag( FLAG_DISABLED )
		End If
		widget.restyle( stylesheet )
	End If
	
	SetColor( $ff, $ff, $ff )
	Local state:String = ["ENABLED","DISABLED"][widget.flagset( FLAG_DISABLED )]
	DrawText( state, 5, 5 )
	
	Local y:Int = GraphicsHeight()
	DrawText( "E - Enable/Disable", 5, Y-Lineheight )
	Flip
Until KeyHit( KEY_ESCAPE ) Or AppTerminate()

Global STYLE_DEFAULT:String = """

* {
	surface: White;
}

TLabel {
	surface: green;
}

:disabled {
	surface: #ccc;
}

"""