'# BlitzMAX Form Definition BFD
'#
'# VERSION 1.0 
'# 
'# BFD Files do not support form sizers. These have been added in BMF.

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
'DebugStop
	Local line$, ident$[]
	Local complete% = False
	Local version$
	Local mode:Int = 0		'# N
'DebugStop
		If Not readnextLine( line, ident ) Then Return fail_EOF()
		While Lower(line) <> "End" And Not complete
			Select ident.length
			Case 1 '# INSTRUCTION
				ident = line.split( " " )
				If Upper(ident[0])<>"FORM" Then Return fail( ERR_INVALID, "Invalid Identifier '"+Trim(Upper(ident[0]))+"' on line "+LineNum )
				line = line[5..]	'# Drop "FORM" SP
				'#
				form.window = New TElement.Create( Null, "WINDOW", dequote(line) )
				'# Define default form values
				form.window.titlebar = 1			'# 0=None, 1=Titlebar, 2=Toolbar
				form.window.resize = False
				form.window.menu = False
				form.window.status = False
				form.window.center = False
				form.window.dragdrop = False
				form.window.width = 800
				form.window.height = 600
				'#
				If Not ParseGadget( form.window ) Then Return False '# ParseGadget failed, so drop out
'				mode = 1
			Case 2	'# KEY/VALUE
				Local attrib$=Lower(Trim(ident[0]))
				Select attrib
				Case "version"
					version = Trim(ident[1])
				Default
					Return fail( ERR_INVALID, "Invalid Attribute '"+attrib+"' on line "+LineNum )
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
	Local line$, ident$[], value$
'DebugStop	
		If Not readnextLine( line, ident ) Then Return fail_EOF()
		While Upper(line) <> "END"
			Select ident.length
			Case 1	'# COMPONENT
'DebugStop
				ident = ident[0].split( " " )
'				If ident.length<>3 Or Lower(ident[0])<>"begin" Then Return fail_invalid()
				If ident.length<2 Then Return fail_invalid()
				value = dequote(" ".join( ident[2..] ))
'DebugStop
				If Not ParseGadget( New TElement.Create( element, Upper(ident[0]), ident[1], value ) ) Then Return False
			Case 2	'# KEY/VALUE
				Local attrib$=Lower(Trim(ident[0]))
				Select attrib
				Case "caption"	;	element.caption		= Dequote(" ".join(ident[1..]))
				Case "center"	;	element.center		= Int( ident[1] )
				Case "command"	;	element.command		= Int( ident[1] )
				Case "dragdrop"	;	element.dragdrop	= Int( ident[1] )
				Case "height"	;	element.height		= Int( ident[1] ) 
				Case "left"		;	element.x			= Int( ident[1] )
				Case "menu"		;	element.menu		= Int( ident[1] )
				Case "resize"	;	element.resize		= Int( ident[1] )
				Case "status"	;	element.status		= Int( ident[1] )
				Case "text"		;	element.text		= dequote(" ".join(ident[1..]))
				Case "titlebar"	;	element.titlebar	= Int( ident[1] )
				Case "top"		;	element.y			= Int( ident[1] )
				Case "width"	;	element.width		= Int( ident[1] )
				Case "border"	;	element.border		= Int( ident[1] )
				Case "bottom"	; 	If element.parent Then element.y = element.parent.height - Int( ident[1] )
				Case "right"	;	If element.parent Then element.x = element.parent.width - Int( ident[1] )
				Default
					Return fail( ERR_INVALID, "Invalid Attribute '"+attrib+"' on line "+LineNum )
				End Select
			End Select
			If Not readNextLine( line, ident ) Then Return fail_eof()
		Wend

		Return True
	End Method

	'------------------------------------------------------------
	Method readNextLine:Int( line:String Var, ident:String[] Var )
	Local list$[], item:String, str:String
		ident = list
		'#	
		'# Skip comments and empty lines
		Repeat
			If Eof( ts ) Then Return False
			line = Trim( ReadLine( ts ) )
			LineNum:+1
			form.LastErrLine :+ 1
		Until Left(line,1)<>"!" And line<>""
		'#
		'# Split the line into identifiers
		list = line.split( "=" )
		'# Remove null array records and replace Escape codes
'DebugStop
		For item = EachIn list 
			If item Then
				'# Replace Escape codes
				For Local r$[] = EachIn [["~t"," "]]
					str = Replace( item, r[0], r[1] )
				Next
				ident :+ [str]
			End If
		Next
	Return True
	End Method

	'------------------------------------------------------------
	Method dequote:String( str:String )
'	DebugStop
		str = Trim(str)
		If Left(str,1)=Chr(34) And Right(str,1)=Chr(34) Then Return str[1..(Len(str)-1)]
		If Left(str,1)="'" And Right(str,1)="'" Then Return str[1..(Len(str)-1)]
		Return str
	End Method
	
	'------------------------------------------------------------
	'# Translate BFD components to BlitzMAX
	'# (In fact we don't need to, because the format is standard already)
	Method Translate$( gadname$ )
	Return gadname
	End Method		

End Type

