'# BlitzMAX Form Definition
'#
'# VERSION 1.0

'############################################################
Type TFormParserBFD Extends TFormParser
'#
Field scaleHeight%, ScaleWidth%		'# VB Specific scaling

	'------------------------------------------------------------
	Method Create:TFormParserBFD( frm:TForm )
		form = frm
	Return Self
	End Method

	'------------------------------------------------------------
	Method Parse%()
	Local line$, ident$[]
	Local complete% = False
	Local version$
'DebugStop
		If Not readnextLine( line, ident ) Then Return fail_EOF()
		While Lower(line) <> "End" And Not complete
			Select ident.length
			Case 1
				ident = line.split( " " )
				If ident.length<>3 Then Return fail_invalid()
				If Lower(ident[0])<>"begin" And Lower(ident[1])<>"form" Then Return fail_invalid()
				form.window = New TElement.Create( Null, "WINDOW", ident[2] )
				'# Define default form values
				form.window.titlebar = 1			'# 0=None, 1=Titlebar, 2=Toolbar
				form.window.resize = False
				form.window.menu = False
				form.window.status = False
				form.window.center = False
				form.window.dragdrop = False
				'#
				ParseGadget( form.window )
			Case 2	'# KEY/VALUE
				Select Lower(ident[0])
				Case "version"
					version = ident[1]
				End Select
			End Select
			If Not readNextLine( line, ident ) Then complete = True
		Wend
		'# Finally check that the file version is correct and that we actually created a form!
		'# NOTE: We check it here because parser ignores things it does not understand.
		If version<>"1.0" Then Return fail_Unsupported()
		If Not form.window Then Return fail_invalid()
		Return True
	End Method

	'------------------------------------------------------------
	Method ParseGadget%( element:TElement )
	Local line$, ident$[]
	
		If Not readnextLine( line, ident ) Then Return fail_EOF()
		While Lower(line) <> "end"
			Select ident.length
			Case 1
				ident = line.split( " " )
				If ident.length<>3 Or Lower(ident[0])<>"begin" Then Return fail_invalid()
				ParseGadget( New TElement.Create( element, Upper(ident[1]), ident[2] ) )
			Case 2	'# KEY/VALUE
				Select Lower(ident[0])
				Case "caption"	;	element.caption		= " ".join(ident[1..])
				Case "center"	;	element.center		= Int( ident[1] )
				Case "command"	;	element.command		= Int( ident[1] )
				Case "dragdrop"	;	element.dragdrop	= Int( ident[1] )
				Case "height"	;	element.height		= Int( ident[1] ) 
				Case "left"		;	element.x			= Int( ident[1] )
				Case "menu"		;	element.menu		= Int( ident[1] )
				Case "resize"	;	element.resize		= Int( ident[1] )
				Case "status"	;	element.status		= Int( ident[1] )
				Case "text"		;	element.text		= " ".join(ident[1..])
				Case "titlebar"	;	element.titlebar	= Int( ident[1] )
				Case "top"		;	element.y			= Int( ident[1] )
				Case "width"	;	element.width		= Int( ident[1] )
				End Select
			End Select
			If Not readNextLine( line, ident ) Then Return fail_eof()
		Wend

		Return True
	End Method

	'------------------------------------------------------------
	Method readNextLine:Int( line:String Var, ident:String[] Var )
	Local list$[]
		ident = list
		'#	
		'# Skip comments and empty lines
		Repeat
			If Eof( ts ) Then Return False
			line = Trim( ReadLine( ts ) )
			form.LastErrLine :+ 1
		Until Left(line,1)<>";" And line<>""
		'#
		'# Split the line into identifiers
		list = line.split( "=" )
		'# Remove null array records and replace Escape codes
		For Local item$ = EachIn list 
			If item Then
				'# Replace Escape codes
				For Local r$[] = EachIn [["^E","="],["^Q",Chr(34)]]
					item = Replace( item, r[0], r[1] )
				Next
				ident :+ [item]
			End If
		Next
	Return True
	End Method

	'------------------------------------------------------------
	'# Translate BFD components to BlitzMAX
	'# (In fact we don't need to, because the format is standard already)
	Method Translate$( gadname$ )
	Return gadname
	End Method		

End Type

