'# VB FORM DEFINITION FILE LOADER
'#
'# Supports file version 5 definition only
'#
'# VERSION 0.1 - BETA

'############################################################
'# VB6 Form Parser
Type TFormParserFRM Extends TFormParser
'#
Field scaleHeight%, ScaleWidth%		'# VB Specific scaling

	'------------------------------------------------------------
	Method Create:TFormParserFRM( frm:TForm )
	form = frm
	Return Self
	End Method

	'------------------------------------------------------------
	Method GenerateElement:TElement()
	End Method

	'------------------------------------------------------------
	Method Parse%()
	Local line$, ident$[]
	Local complete% = False
	Local version$
		If Not readnextLine( line, ident ) Then Return fail_EOF()
		While Lower(line) <> "End" And Not complete
			Select ident.length
			Case 1
				ident = line.split( " " )
				If ident.length<>3 Then Return fail_invalid()
				If Lower(ident[0])<>"begin" And Lower(ident[1])<>"form" Then Return fail_invalid()
				form.window = New TElement.Create( Null, "WINDOW", ident[2] )
				ParseGadget( form.window )
			Case 2	'# KEY/VALUE
				Select Lower(ident[0])
				Case "version"
					version = ident[1]
				End Select
			End Select
			If Not readNextLine( line, ident ) Then complete = True
		Wend
	End Method
	
	'------------------------------------------------------------
	Method ParseForm%()
	Local line$, ident$[], gadname$
	Local failed% = False
	
		If Not readnextLine( line, ident ) Then Return fail_EOF()
		If line<>"VERSION 5.00" Then Return fail_Unsupported()
		'#
		If Not readNextLine( line, ident ) Then Return fail_eof()
		If ident.length <> 3 Or Left( line, 13 ) <> "Begin VB.Form" Then Return fail_invalid()
		form.component = "VB.Form"
		form.style = WINDOW_TITLEBAR
		'#
		'# Read Params
		If Not readNextLine( line, ident ) Then Return fail_eof()
'DebugStop
		While line <> "End" And Not failed
			If ident.length<3 Then Return fail_invalid()
			Select ident[0]
				'BackColor       =   &H0080C0FF&
				Case "Caption"			;	form.caption = " ".join(ident[2..])
				Case "ClientHeight"		;	form.height = TwipsToPixels( Int( ident[2] ) )
				Case "ClientLeft"		;	form.x = TwipsToPixels( Int( ident[2] ) )
				Case "ClientTop"		;	form.y = TwipsToPixels( Int( ident[2] ) )
				Case "ClientWidth"		;	form.width = TwipsToPixels( Int( ident[2] ) )
'				Case "LinkTopic" 	
'				Case "ScaleHeight"		
'				Case "ScaleWidth"
				Case "StartUpPosition"
					Local pos% = Int( ident[2] )
					If pos = 2 Then form.style :| WINDOW_CENTER
					'if pos = 3 then 'WIDNOWS_DEFAULT
				'
				Case "Begin"
					parseGadget( New TFormElement.Create( form, ident[1], ident[2] ) )
			End Select
			'#
			If Not readNextLine( line, ident ) Then Return fail_eof()
		Wend
		'#
		'# We don't care about anything after this point
		Print "FORM '" + form.name + ":" + form.component + " ("+form.x+","+form.y+") - W:"+form.width+", H:"+form.height
		Return True
	End Method

	'------------------------------------------------------------
	Method ParseGadget%( component:TElement )
	Local line$, ident$[]
	Local failed% = False
		'# Read Params
		If Not readNextLine( line, ident ) Then Return fail_EOF()
		While line <> "End" And Not failed
			If ident.length<3 Then Return fail_invalid()
			Select ident[0]
				'Case "Alignment"       =   1  'Right Justify	(label)
				'case "BackStyle"       =   0  'Transparent
				'case "Cancel"          =   -1  'True 'Used to create a cancel button that exits form
				Case "Caption"			; component.caption = " ".join(ident[2..])
				Case "Default"			; component.defValue = " ".join(ident[2..])	'-1 = true
				Case "Height"			; component.height = twipsToPixels( Int( ident[2] ))
				Case "Left"				; component.x = twipsToPixels( Int( ident[2] ))
'				Case "Style"
					'# Style = 2 = Dropdown List
'				Case "TabIndex"
				Case "Text"				; component.text = " ".join(ident[2..])
				Case "Top"				; component.y = twipsToPixels( Int( ident[2] ))
				Case "Width"			; component.width = twipsToPixels( Int( ident[2] ))
				'#
				Case "BeginProperty"
Rem
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   24
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
End Rem
				'# OTHER
				'Appearance      =   0  'Flat
				'ListField = "description"
				'BoundColumn = "id_type"
				'DataField = "id_type"
				'DataSource = "Data1"
				'DefaultCursorType= 0 'DefaultCursor
				'ReadOnly=0	'False (-1=True)
				 'Style           =   1  'Graphical

			End Select
			'#
			If Not readNextLine( line, ident ) Then Return fail_eof()
		Wend
		Print "FIELD '" + component.name + ":" + component.component + " ("+component.x+","+component.y+") - W:"+component.width+", H:"+component.height
	Return True
	End Method

	'------------------------------------------------------------
	Method readNextLine:Int( line:String Var, ident:String[] Var )
	Local list$[]
		If Eof( ts ) Then Return False
		ident = list
		line = Trim( ReadLine( ts ) )
		list = line.split( " " )
		'# Remove null array records
		For Local item$ = EachIn list 
			If item Then ident :+ [item]
		Next
		form.LastErrLine :+ 1
	Return True
	End Method

	'------------------------------------------------------------
	'# Translate VB6 components to BlitzMAX
	Method Translate$( gadname$ )
		Select Upper( gadname )
		Case "VB.FORM"			; Return "WINDOW"
		Case "VB.LABEL"			; Return "LABEL"
		Case "VB.TEXTBOX"		; Return "TEXTBOX"
		Case "VB.COMMANDBUTTON"	; Return "BUTTON"
		End Select
	End Method		

	'------------------------------------------------------------
	'# 1440 twips = 1 Inch
	'# Screen is 72 pixels / Inch 
	'# Need to check this...
	Method TwipsToPixels%( twips% )
		Return (Float(twips)/1440.0) * 72
	End Method
End Type

