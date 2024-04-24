SuperStrict

Import "lexer.bmx"

Const FILENAME:String = "TESTFILE.bmx"
Const PADDING:Int = 5
Const REPEATSPEED:Int = 125

Function write( caption:String, reset:Int = False )
	Global y:Int = 5
	If reset; y=5
	DrawText( caption, 5, y )
	y:+TextHeight(caption)
End Function

Function loadSource:String[]( filename:String )
	Local lines:String[]

	Local file:TStream = OpenFile( filename )
	While Not file.Eof()
		lines :+ [ ReadLine( file ) ]
	Wend
	file.close()
	Return lines
End Function

Function keyrepeat:Int( key:Int )
	Global timer:Int[]
	If key >= timer.length; timer = timer[..key+1]
	cursor = True	' Always show cursor while repeating
	If MilliSecs()>timer[key]
		timer[key] = MilliSecs()+REPEATSPEED
		Return True
	End If
	Return False
End Function

Global GRY:Int, GRX:Int
Local TH:Int, TW:Int
Local doc:String[] = LoadSource( filename )
Local lexer:TLexer = New TLexer( "~n".join(doc) )

Local ofsX:Int = 0		' Hidden rows at top
Local ofsY:Int = 0		' Hidden rows to left!
Local linenum:Int = 0
Local linepos:Int = 0

Local quit:Int = False
Local editing:Int = True
Local showlinenum:Int = False
Local showCR:Int = False
Global cursor:Int = True
Local cursortime:Int = MilliSecs()

Graphics 320,200
TH  = TextHeight( "8y" )
TW  = TextWidth( "W" )
GRY = Floor(GraphicsHeight()/TH)-1
GRX = GraphicsWidth()/TextWidth("W")

Local iconCR:TImage = LoadImage( "iconCR.png" )
'Local iconTAB:TImage = LoadImage( "iconTAB.png" )

Repeat
	Cls
	
	If KeyHit( KEY_ESCAPE ); editing = Not editing
	If KeyHit( KEY_F5 ); showlinenum = Not showlinenum
	If KeyHit( KEY_F6 ); showCR = Not showCR
	
	If MilliSecs() > cursortime
		cursortime :+ 500
		cursor = Not cursor
	End If

	If editing

		'DebugStop
		For Local line:Int = 0 Until Min(GRY,doc.length)
			SetColor( $FF, $BF, $00 )
			Local text:String 
			If showlinenum; text :+ Right(" "[..4]+(line+ofsY+1),4)+"  "
			text :+ doc[line+ofsY]
			DrawText( text, PADDING,TH+line*TH )
			' CR
			If showCR And iconCR
				Local cRX:Int = PADDING+TextWidth( text)
				Local CRY:Int = TH+line*TH
				DrawImage( iconCR, CRX, CRY )
			End If
		Next

		SetColor( $FF, $BF, $00 )
		Write( "ESC:MENU  F1:-  F2:-  F2:-  F2:-  F5:LINES  F5:SHOW", True )
		DrawText( "#EOF", PADDING, TH+doc.length*TH )

		' Cursor
		If cursor
			SetColor( $FF, $BF, $00 )
			Local px:Int = PADDING+TextWidth(doc[linenum][..linepos])
			Local py:Int = TH+(linenum-ofsy)*TH
			If showlinenum; px :+ TextWidth( "9999  " )
			'SetLineWidth( 2 )
			DrawLine( px, py, px, py+TH )
		End If
		
		If KeyDown( KEY_LEFT ) And keyrepeat(KEY_LEFT)
			linepos :- 1
			If linepos<0
				If linenum>0
					linenum :- 1
					linepos = doc[linenum].length
				Else
					linepos = 0
				End If
			End If
			'
		End If
		If KeyDown( KEY_RIGHT ) And keyrepeat(KEY_RIGHT)
'			DebugStop
			linepos :+ 1
			If linepos>doc[linenum].length
				DebugStop
				BUG HERE
				If linenum<doc.length
					linenum :+ 1
					linepos = 0
				Else
					linepos = doc[linenum].length
				End If
			End If
		End If
		If KeyDown( KEY_UP ) And keyrepeat(KEY_UP)
			linenum = Max( linenum-1, 0 )
			If linepos > doc[linenum].length; linepos = doc[linenum].length
		End If
		If KeyDown( KEY_DOWN ) And keyrepeat(KEY_DOWN)
			linenum = Min( linenum+1, doc.length-1 )
			If linepos > doc[linenum].length; linepos = doc[linenum].length
		End If
		If KeyHit( KEY_HOME )
			If KeyDown( KEY_LCONTROL ) Or KeyDown( KEY_RCONTROL )
				linepos = 0
				linenum = 0
				ofsY = 0
			Else
				linepos = 0
			End If
		End If
		If KeyHit( KEY_END )
			If KeyDown( KEY_LCONTROL ) Or KeyDown( KEY_RCONTROL )
				linepos = 0
				linenum = Len(doc)-1
			Else
				linepos = Len(doc[linenum])
			End If
		End If
		If KeyHit( KEY_PAGEDOWN)
			linenum :+ (GraphicsHeight()/TH)-1
		End If
		If KeyHit( KEY_PAGEUP )
			linenum :- (GraphicsHeight()/TH)-1
		End If
		'
		If KeyDown( KEY_BACKSPACE ) And keyrepeat(KEY_BACKSPACE)
			If linepos = 0
				If linenum > 0
					Local saved:Int = doc[linenum-1].length
					doc[linenum-1] :+ doc[linenum]
					For Local line:Int = linenum Until doc.length -1
						doc[line] = doc[line+1]
					Next
					Print( "BEFORE: "+doc.length )
					doc = doc[..doc.length-1]
					Print( "AFTER: "+doc.length )
					linenum :- 1
					linepos = saved
				End If
			Else
				doc[linenum] = doc[linenum][..(linepos-1)]+doc[linenum][linepos..]
				linepos :- 1
			End If
		End If
		If KeyDown( KEY_DELETE ) And keyrepeat(KEY_DELETE)
			'DebugStop
			If linepos=doc[linenum].length
				If linenum < doc.length-1
				'DebugStop
					doc[linenum] :+ doc[linenum+1]
					For Local line:Int = linenum+1 Until doc.length -1
						doc[line] = doc[line+1]
					Next
					Print( "BEFORE: "+doc.length )
					doc = doc[..doc.length-1]
					Print( "AFTER: "+doc.length )
				End If
			Else
				doc[linenum] = doc[linenum][..linepos]+doc[linenum][(linepos+1)..]
			End If
		End If
		
		' Visible characters
		Local ch:Int = GetChar()
		Select True
		Case ch>=32 And ch<>127 And ch<255
			doc[linenum] = doc[linenum][..linepos]+Chr(ch)+doc[linenum][(linepos)..]
			linepos :+ 1			
		Case ch = 9		' TAB
			doc[linenum] = doc[linenum][..linepos]+"    "+doc[linenum][(linepos)..]
			linepos :+ 4
		Case ch = 13	' ENTER
			doc :+ ["BLANK"]
			Print Len(doc)
			For Local line:Int = doc.length-1 To linenum+1 Step -1
				doc[line] = doc[line-1]
			Next
			doc[linenum+1] = doc[linenum][(linepos)..]
			doc[linenum] = doc[linenum][..linepos]
			linepos = 0
			linenum :+ 1
		End Select

		' Screen and scrolling
		If linenum < ofsy
			'DebugStop
			ofsY = linenum
		End If
		If linenum-ofsy >= GRY
			'DebugStop
			ofsY = linenum-GRY+1
		End If

		
	Else
		Write( "ESC:EDITOR", True )
		Write( "L. Reveal Lexer" )
		Write( "R. Reload Source" )
		Write( "S. Show Source" )
		Write( "Q. Show Source" )
		Write( "" )
		Write( "F5. Show Line Numbers" )
		If KeyHit( KEY_L )
			lexer.reveal()
			editing = True
		End If
		If KeyHit( KEY_R )
			lexer = New TLexer( "~n".join(doc) )
			editing = True
		End If
		If KeyHit( KEY_S )
			Print lexer.source
			editing = True
		End If
		
	End If
	
	Flip
Until quit Or AppTerminate()
