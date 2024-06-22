SuperStrict

Include "../bmx-imgui.bmx"

Graphics 800,600

Local UX:IMGUI

Local buttongroup:Int = 1
'UX.init()

' Values for components
Local slider_value_H:Float = 12
Local slider_value_V:Float = 8
Local radio_value:Int = True	' Default to "ON"
Local check_value:Int = True	' Checked
Local textbox_value:String = ""
Local dropdown_value:Int
Local dropdown_list:String[] = ["","One","Two","Three","Four"]
Local image_button:TImage = LoadImage( "resources/imagebutton.png" )
Local push_button:String

Repeat
	Cls
	
	' Draw a simple GUI
	If UX.BeginDraw()
		'UX.modal()
		
		' V1.0 COMPONENTS
		UX.Frame1( "GENERATOR", 10, 10, 112, GraphicsHeight()-20 )

		If UX.OnOffButton( 1, "PICKUP/COIN", buttongroup, 5, 5, 102, 19 ) ; Print( "SFXR_COIN" )
		If UX.OnOffButton( 2, "LASER/SHOOT", buttongroup, 5, 30, 102, 19 ) ; Print( "SFXR_SHOOT" )
		If UX.OnOffButton( 3, "EXPLOSION", buttongroup, 5, 55, 102, 19 ) ; Print( "SFXR_EXPLOSION" )
		If UX.OnOffButton( 4, "POWERUP", buttongroup, 5, 80, 102, 19 ) ; Print( "SFXR_POWERUP" )
		If UX.OnOffButton( 5, "HIT/HURT", buttongroup, 5, 105, 102, 19 ) ; Print( "SFXR_HIT" )
		If UX.OnOffButton( 6, "JUMP", buttongroup, 5, 130, 102, 19 ) ; Print( "SFXR_JUMP" )
		If UX.OnOffButton( 7, "BLIP/SELECT", buttongroup, 5, 155, 102, 19 ) ; Print( "SFXR_BLIP" )

		' V3.0 COMPONENTS
DebugStop

		If( UX.Window( "EXAMPLE", New SRect( 130, 10, 200, 200 ) ))

			DebugStop
			
			If UX.Button( "Test" )
				Print( "Yay, V3 button pressed" )
			End If

			If UX.Button( image_button )
				Print( "Yay, image button pressed" )
			End If
			
			If UX.Button( push_button, IMGUI_BUTTON_LATCH )
				push_button = "ON"
			Else
				push_button = "OFF"
			End If
			
			UX.EndWindow()
		EndIf

		If UX.Frame( New SRect( 130, 220, 200, 200 ) )
				
			' Layout
			UX.Row( [25, 25, 25, 25] )
				UX.Slider( slider_value_h, 0, 100 )
				UX.Radio( radio_value, 0 )
				UX.Label( "Blah, Blah" )
			UX.EndRow()

			UX.Row( [25, 25, 25] )	' Generates 4 cells, the fourth being the remaining %
				UX.Label( "Size", IMGUI_ALIGN_MC )
				UX.Radio( radio_value, 1 )
				If( radio_value )
					UX.Label( "ON" )
				Else
					UX.Label( "OFF" )
				EndIf
				UX.Checkbox( check_value )
						
			UX.TextBox( textbox_value )
			
			UX.Row( [25,75] )
				UX.Checkbox( check_value )
				UX.Label( "Clickme!" )
			' Automatic EndLayout() because we have filled all cells

			UX.Row( 4 )	' 4 Equal with cells
				UX.Label( "One" )
				UX.Label( "Two" )
				UX.Label( "Three" )
				UX.Label( "Four" )

			UX.Row( 4 )	' 4 Equal with cells (Same as Layout(4))
				UX.Label( "One" )
				UX.Label( "Two" )
				UX.Label( "Three" )
				UX.Label( "Four" )
				
			UX.Row( [0,-30], True )	' AUTO and 20px fixed with repeat
				UX.Label("One")
				UX.Label("ONE")
				UX.Label("Two")
				UX.Label("TWO")
				UX.Label("Three")
				UX.Label("THREE")
			UX.EndRow()
			
			UX.Dropdown( dropdown_value, dropdown_list )
		
			UX.EndFrame()
		End If

		' Panel without a frame
		If UX.Panel( New SRect( 340, 10, 200, 200 ) )

			UX.Slider( slider_value_V, 0, 100, IMGUI_SLIDER_VERTICAL )
		
			UX.EndPanel()
		EndIf 

'UX.Graph()

		' Draw the icon sheet so we can see the icons
		SetColor( 255,255,255 )
		'DrawImage( UX.style.iconsheet, 250, 10 )

		UX.EndDraw()
	EndIf
	Flip
Until KeyHit( KEY_ESCAPE )