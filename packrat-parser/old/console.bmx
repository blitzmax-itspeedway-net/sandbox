
CONSOLE.init()

Type CONSOLE

	Const BTNW:Int = 80
	Const BTNH:Int = 33
	Const BTN_TREE:Int = 0
	Const BTN_LIST:Int = 1

	Global HEADER:Int = 4		' Offset at top
	Global FOOTER:Int = 1		' Offset at bottom

	Global tree:TMatch
	Global TW:Int
	Global TH:Int
	Global WH:Int ' Height (in lines) of console window
	
	Global name:String
	Global text:String
	Global pattern:String
	Global start:Int, cease:Int
	Global message:String
	'
	Global logs:String[]
	Global showlog:Int = True
	
	Global YPos:Int
	Global btn:Int = BTN_TREE
	Global mouseclick:Int
	Global MZoffset:Int = 0
	Global MZ:Int = 0
	
	Function init()
		Return
		Graphics 1024,600
		TW = TextWidth( "W" )
		TH = TextHeight( "8p" )
		logs = New String[ GraphicsHeight()/TH - 3 ]
		MZoffset = MouseZ()	' Save current mouseZ so we can calculate offset
		wh = (GraphicsHeight()/TH) - HEADER - FOOTER
	End Function
	
	Function set( name:String, text:String, pattern:String, start:Int, cease:Int=0, message:String="" )
		CONSOLE.name = name
		CONSOLE.text = text
		CONSOLE.pattern = pattern
		CONSOLE.start = start
		CONSOLE.cease = cease
		CONSOLE.message = message
	End Function
	
	Function Log( message:String )
	Return
		'DebugStop
		'Local n:Int = logs.length
		logs = logs[1..(Logs.length+1)]
		logs[logs.length-1] = message
		'n = logs.length
		'DebugStop
	End Function
	
	Function wait()
	Return
		Local timer:Int = MilliSecs() + 50 '0
		Repeat
			Cls
			render()
			Flip
		Until MilliSecs()> timer
	End Function
	
	Function show()
	Return
		Repeat
			Cls
			render()
			SetColor( $ff, $ff, $ff )
			DrawText( "<ESC> or <SPACE> to continue...", 5, GraphicsHeight()-TH-5 )
			Local temp:String = "Z:"+MZ
			DrawText( temp, GraphicsWidth()-TextWidth(temp)-5, GraphicsHeight()-TH-5 )
			Flip
		Until KeyHit( KEY_ESCAPE ) Or KeyHit( KEY_SPACE )
	End Function
	
	Function render()
	Return
		SetColor( $ff, $ff, $ff )
		DrawText( text, 5,5 )
		DrawText( "^"+message, 5+start*TW, 5+TH )
		
		DrawText( name+": "+pattern, 5, TH*3 )
		
		If cease>0
			SetColor( $ff, 0,0 )
			DrawLine( 5+start*TW, 5, 5+cease*TW, 5 )		' TOP
			DrawLine( 5+cease*TW, 5, 5+cease*TW, 5+TH )		' RIGHT
			DrawLine( 5+cease*TW, 5+TH, 5+start*TW, 5+TH )	' BOTTOM
			DrawLine( 5+start*TW, 5+TH, 5+start*TW, 5 )		' LEFT
		End If
						
		' GUI
		mouseclick = MouseHit(1)
		
		' Get current Scroll position
		MZ = MouseZ() - MZOffset
		If MZ<0
			MZ=0
			MZOffset = MouseZ()
		End If
		
		If button( "TREE", GraphicsWidth()-(BTNW+5)*2, 5, BTNW, BTNH, btn=BTN_TREE )
			btn=BTN_TREE
		End If
		If button( "LIST", GraphicsWidth()-(BTNW+5), 5, BTNW, BTNH, btn=BTN_LIST )
			btn=BTN_LIST
		End If

		If button( "LOG", GraphicsWidth()-(BTNW+5)*3-15, 5, BTNW, BTNH, showlog )
			showlog = Not showlog
		End If
		
		If tree
			YPos = 0
			Select btn
			Case BTN_TREE
				'SetColor( 0, 0, $ff )
				'DebugStop
				drawnode( tree, 5 )
			Case BTN_LIST
				drawResult( tree, 5 )
				DrawText( "YPOS:"+Ypos+", OFS:"+MZOffset+", MZ:"+MouseZ()+", WH:"+WH, 5, GraphicsHeight()-TH*2 )
				If ypos > MZ; MZ = YPos 	' Prevent overscroll
			End Select
		End If

		If showlog
			SetColor( $ff, $ff, $ff )
			For Local line:Int = 0 Until logs.length
				DrawText( logs[line], GraphicsWidth()/2, TH*(line+3) )
			Next
		End If
		
	End Function

	Function drawnode( node:TMatch, x:Int )
	Return
		SetColor( $ff,$ff,$ff)
		DrawText( node.reveal(), x, (HEADER+YPos-MZ)*TH )
		Ypos :+ 1
		Local y:Int = (HEADER+YPos-MZ)*TH
		For Local index:Int = 0 Until node.children.length
			Local child:TMatch = node.children[index]
			SetColor( $ff,$7f,0)
			If index+1<node.children.length
'				DrawLine( x, YPos, x, YPos+TH ) 
				DrawLine( x+2, (HEADER+YPos-MZ)*TH+TH/2, x+TW, (HEADER+YPos-MZ)*TH+TH/2 ) 
			ElseIf index+1=node.children.length
				DrawLine( x+2, (HEADER+YPos-MZ)*TH, x+2, (HEADER+YPos-MZ)*TH+TH/2 ) 
				DrawLine( x+2, (HEADER+YPos-MZ)*TH+TH/2, x+TW-3, (HEADER+YPos-MZ)*TH+TH/2 ) 
			End If
			drawnode( child, x+TW )
			SetColor( $ff,$7f,0)
			If index+1<node.children.length
				DrawLine( x+2,y,x+2,(HEADER+YPos-MZ)*TH+TH/2 )
			End If
		Next
	End Function
	
'	Global count:Int = 0
	Function drawresult( node:TMatch, x:Int)
	Return
		' Draw children
		If node.children
			For Local child:TMatch = EachIn node.children
				'DebugStop
				'Print( child.asString() )
				drawresult( child, x )
				'YPos :+ TH
			Next
		End If
		'If node.finish=node.start; DebugStop
		DrawText( Ypos-MZ+","+WH, 5, GraphicsHeight()-TH*3 )
		' Don't draw if before scroll position or 
		If YPos < MZ Or Ypos-MZ > WH
			YPos :+ 1
			Return
		End If
		
		' Original text
		SetColor( $cc,$cc,$cc )
'count :+ 1
'Print( count+") "+node.text+" - "+ypos )
'If count=7; DebugStop
		DrawText( node.text, x, (HEADER+YPos-MZ)*TH )
'DrawText( count, x, Ypos )
		' NULL/Whitespace doesn;t have a size!
		If node.finish>node.start
			' Matched string highlight
			'SetColor( $00,$ff,$00 )
			DrawRect( X+node.start*TW, (HEADER+YPos-MZ)*TH, (node.finish-node.start)*TW, TH-1 )
			' Matched string
			SetColor( $ff,$ff,$ff )
			DrawText( node.text[node.start..node.finish], x+node.start*TW, (HEADER+YPos-MZ)*TH )
		End If
		' Match details; kind, name etc...
		SetColor( $00,$00,$ff )
		Local str:String = KINDSTR[node.kind]
		If node.name; str :+ ", NM='"+node.name+"'"
		If node.captured; str :+ ", CP='"+node.captured+"'"
		DrawText( str, x+TextWidth(node.text)+TW, (HEADER+YPos-MZ)*TH )
		YPos :+ 1
		
	End Function
	
	Function button:Int( caption:String, x:Int, y:Int, w:Int, h:Int, state:Int=False )
		Local mx:Int = MouseX()
		Local my:Int = MouseY()
		Local inside:Int = False
		
		' BORDER
		If mx>x And mx<x+w And my>y And my<y+h
			inside = True
			SetColor( $00,$00,$ff )
		Else
			SetColor( $00,$00,$7f )
		End If
		DrawRect( x,y,w,h )

		' SURFACE
		If state
			SetColor( $00,$00,$7F )
		Else
			SetColor( $00,$00,$00 )
		End If
		DrawRect( x+1,y+1,w-2,h-2 )
		
		' TEXT
		SetColor( $FF,$FF,$FF )
		DrawText( caption, x+(w-TextWidth(caption))/2,y+(h-TextHeight(caption))/2 )
		
		Return (inside And mouseclick)
	End Function
	
End Type