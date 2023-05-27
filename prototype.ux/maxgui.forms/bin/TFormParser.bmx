'#
Include "TFormParserBFD.bmx"	'# BlitzMax Form Definition
'Include "TFormParserBFD.bmx"	'# BlitzMax Form (Supports Sizers) = EXPERIMENTAL
'Include "TFormParserFRM.bmx"	'# VB6 FORM - EXPERIMENTAL
'Include "TFormParserLFM.bmx"	'# Lazarus Form - EXPERIMENTAL

'############################################################
Type TFormParser
Field ts:TStream
Field form:TForm		'# Form we are parsing
Field msgHandler( text:String, options:Int )
Field LineNum%=0

	Const TEXTFORMAT_RED% = $10

	'------------------------------------------------------------
	Method Load:Int( file:String, msghandler( text:String, options:Int )=Null)
	Local result%
		Self.msgHandler = msgHandler
		ts = OpenFile( file )
		If Not ts Then Return fail( ERR_FILEOPEN, "Unable to open file" )
		result = Parse()
		CloseStream ts
	Return result
	End Method

	'------------------------------------------------------------
	Method Writeln( text:String, options:Int = 0 )
		If msgHandler Then MsgHandler( text, options )
	End Method
	
	'------------------------------------------------------------
	Method Fail%( ErrCode:Int=ERR_EOF, ErrText:String="Unexpected end of file" )
		form.LastErrCode = ErrCode
		form.LastErrText = ErrText
		WriteLn( errText, TEXTFORMAT_RED )
		Return False
	End Method

	'------------------------------------------------------------
	Method Fail_EOF%()
	Return fail( ERR_EOF, "Unexpected end of file" )
	End Method
	
	'------------------------------------------------------------
	Method Fail_Invalid%()
	Return fail( ERR_INVALID, "File format is invalid" )
	End Method

	'------------------------------------------------------------
	Method Fail_Unsupported%()
	Return fail( ERR_UNSUPPORTED, "Unsupported file version" )
	End Method
	
	'------------------------------------------------------------
	Method Parse%() Abstract
	
	'------------------------------------------------------------
	'# The default version of this function does not use the IDENT variable
	Method readNextLine:Int( line:String Var, ident:String[] Var )
	Local list$[]
		If Eof( ts ) Then Return False
		line = Trim( ReadLine( ts ) )
		LineNum:+1
		form.LastErrLine :+ 1
	Return True
	End Method

	'------------------------------------------------------------
	'# Translate Form Defininition names to BlitzMAX names
	Method Translate$( gadname$ ) Abstract

End Type

