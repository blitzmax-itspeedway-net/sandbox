' 	SFXR Toolkit Example
'   (c) Copyright Si Dunford, September 2022, All Rights Reserved. 
'   VERSION: 1.1

SuperStrict

Include "../bmx-imgui.bmx"

AppTitle = "SFXR Toolkit Example"
Graphics 800, 255

Print( "KEY_DELETE: "+ KEY_DELETE )
Print( "KEY_BACKSPACE: "+ KEY_BACKSPACE )
Print( "KEY_INSERT: "+ KEY_INSERT )
Print( "KEY_LEFT: "+ KEY_LEFT )
Print( "KEY_RIGHT: "+ KEY_RIGHT )
Print( "KEY_HOME: "+ KEY_HOME )
Print( "KEY_END: "+ KEY_END )

Const FLD_NUMBER:Int = 8
Const BTN_SFXR_COIN:Int = 1
'Const BTN_
Const BTN_PLAY:Int		= 13

Global seed:Int = 64518
Local buttongroup:Int = BTN_SFXR_COIN
Global soundID:int
Global soundName:String = "SFXR_COIN"
Global bmxcode:String[] = []
Global cliptext:String = ""
Global cliptimer:Int

' Plays a preset sound using SFXR

Function DoSound( Preset:Int=-1, Text:String="" )
	'Local ch:TChannel = AllocChannel()
	If Text<>"" soundName = Text
	If preset<>-1 soundID = preset
	'
	'PlaySound( New TSFXRSound.LoadPreset( soundID, Seed ) )
	bmxcode = []
	bmxcode :+ [ "Import retro.audio" ]
	bmxcode :+ [ "Local sound:TSound = New TSFXRSound.LoadPreset( "+soundName+", "+seed+" )" ]
	bmxcode :+ [ "Local channel:TChannel = AllocChannel()" ]
	bmxcode :+ [ "PlaySound( sound, channel )" ]
	bmxcode :+ [ "While ChannelPlaying( channel ); Wend" ]
	cliptext = ""	
End Function
	
' Plays a preset sound using SFXR
Function Sound( Preset:Int, Seed:Int, Text:String )
	'Local ch:TChannel = AllocChannel()
	'PlaySound( New TSFXRSound.LoadPreset( Preset, Seed ) )
	bmxcode = []
	bmxcode :+ [ "Import retro.audio" ]
	bmxcode :+ [ "Local sound:TSound = New TSFXRSound.LoadPreset( "+Text+", "+seed+" )" ]
	bmxcode :+ [ "Local channel:TChannel = AllocChannel()" ]
	bmxcode :+ [ "PlaySound( sound, channel )" ]
	bmxcode :+ [ "While ChannelPlaying( channel ); Wend" ]
	cliptext = ""
End Function

Function SetupUX()
	UX.Init()
	
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
	
' Setup the UX
SetupUX()

Local clipboard:TClipboard = CreateClipboard()

UX.setFocus( FLD_NUMBER )

Repeat
    SetClsColor( 0,0,0 )
	Cls
	' Draw a simple GUI
	UX.modal()
	
	UX.Frame( "GENERATOR", 10, 10, 112, GraphicsHeight()-20 )

	'UX.Label( "GENERATOR", 10, 10, 19 )
	
	If UX.OnOffButton( BTN_SFXR_COIN, "PICKUP/COIN", buttongroup, 5, 5, 102, 19 ) ; Print( "SFXR_COIN" )
	If UX.OnOffButton( 2, "LASER/SHOOT", buttongroup, 5, 30, 102, 19 ) ; Print( "SFXR_SHOOT" )
	If UX.OnOffButton( 3, "EXPLOSION", buttongroup, 5, 55, 102, 19 ) ; Print( "SFXR_EXPLOSION" )
	If UX.OnOffButton( 4, "POWERUP", buttongroup, 5, 80, 102, 19 ) ; Print( "SFXR_POWERUP" )
	If UX.OnOffButton( 5, "HIT/HURT", buttongroup, 5, 105, 102, 19 ) ; Print( "SFXR_HIT" )
	If UX.OnOffButton( 6, "JUMP", buttongroup, 5, 130, 102, 19 ) ; Print( "SFXR_JUMP" )
	If UX.OnOffButton( 7, "BLIP/SELECT", buttongroup, 5, 155, 102, 19 ) ; Print( "SFXR_BLIP" )
	
	' Draw Seperator
	'DrawRect( 110, 0, 2, GraphicsHeight() )
	
	UX.Frame( 132, 10, GraphicsWidth()-142, 55 )
	
	' Draw Minus Button
	If UX.Button( 11, "-", 5, 30, 19, 19 )
		seed = Max( 0, seed - 1 )
		DoSound()
	End If
	
	' Draw Number Field
	Seed = Min( 65535, Max( 0, seed ) )
	UX.Label( "SEED:", 5, 5, 19 )
	UX.IntField( FLD_NUMBER, Seed, 30, 30, 102, 19, 5 )

	' Draw Plus Button
	If UX.Button( 12, "+", 137, 30, 19, 19 )
		seed = Min( 65535, seed + 1 )
		DoSound()
	End If
	
	' Draw Random Number
	If UX.Button( 9, "RANDOMIZE", 161, 30, 102, 19 )
		seed = Rand( 0, 65535 )
		bmxcode = []
		DoSound()
	End If

	If UX.Button( BTN_PLAY, "PLAY", GraphicsWidth()-249, 30, 102, 19 ); DoSound()
	
	' Draw Blitzmax Source
	If Len(bmxcode) > 0
		UX.Frame( 132, 75, GraphicsWidth()-142, 130 )
		UX.label( "BLITZMAX CODE:", 5, 5, 19 )
		Local code:String =""
		For Local line:Int = 0 Until Len(bmxcode)
			UX.Label( bmxcode[line], 5, 30+(line*18) )
			code :+ bmxcode[line] + "~n"
		Next
		If UX.Button( 10, "CLIPBOARD", GraphicsWidth()-249, 5, 102, 19 )
			If ClipboardSetText( clipboard, code )
				cliptext = "Copied to clipboard"
			Else
				cliptext = "Failed to copy to clipboard"
			End If
			cliptimer = MilliSecs() + 2000
		End If
	End If
	
	If cliptext And cliptimer > MilliSecs()
		UX.Frame( 132, 215, GraphicsWidth()-142, 30 )
		UX.label( cliptext, 5, 5, 19 )
	End If
	
    Flip
	Delay( 1 )
Until KeyHit( KEY_ESCAPE ) Or AppTerminate()

