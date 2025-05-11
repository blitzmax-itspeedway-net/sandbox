'#
Include "TForm.bmx"
Include "TElement.bmx"
'Include "TFormParserBFD.bmx"	'# BlitzMax Form Definition
'Include "TFormParserBFD.bmx"	'# BlitzMax Form (Supports Sizers) = EXPERIMENTAL
Include "TFormParserFRM.bmx"	'# VB6 FORM - EXPERIMENTAL
'Include "TFormParserLFM.bmx"	'# Lazarus Form - EXPERIMENTAL

Const ERR_EOF:Int         = 1
Const ERR_INVALID:Int     = 2
Const ERR_UNSUPPORTED:Int = 3
Const ERR_FILEOPEN:Int = 4
' COMPONENT

Const WIDGET_FRAME:Int    = 1	' Frame, Window, Dialog


'############################################################
Type TFormParser
Field ts:TStream
Field form:TForm		'# Form we are parsing
Field msgHandler( text:String, options:Int )
Field LineNum:Int=0

	Field cursor:Int = 0
	Field lines:String[]
	Const TEXTFORMAT_RED:Int = 10

	Field filename:String

	'------------------------------------------------------------
	Method New( filename:String )
		Self.filename = filename
	End Method
	
	'------------------------------------------------------------
	Method Writeln( text:String, options:Int = 0 )
		If msgHandler Then MsgHandler( text, options )
	End Method
	
	'------------------------------------------------------------
	Method Fail:Int( ErrCode:Int=ERR_EOF, ErrText:String="Unexpected end of file" )
		form.LastErrCode = ErrCode
		form.LastErrText = ErrText
		WriteLn( errText, TEXTFORMAT_RED )
		Return False
	End Method

	'------------------------------------------------------------
	Method Fail_EOF:Int()
	Return fail( ERR_EOF, "Unexpected end of file" )
	End Method
	
	'------------------------------------------------------------
	Method Fail_Invalid:Int()
	Return fail( ERR_INVALID, "File format is invalid" )
	End Method

	'------------------------------------------------------------
	Method Fail_Unsupported:Int()
	Return fail( ERR_UNSUPPORTED, "Unsupported file version" )
	End Method
	
	'------------------------------------------------------------
	Method Parse:Int() Final
		ts = OpenFile( filename )
		If Not ts Then Return fail( ERR_FILEOPEN, "Unable to open file" )
		Local result:int = ParseFile()
		CloseStream ts
		Return result
	End Method
	
	Method ParseFile:Int() Abstract
	
	'------------------------------------------------------------
	'# The default version of this function does not use the IDENT variable
	Method readNextLine:Int( line:String Var, ident:String[] Var )
	Local list:String[]
		If Eof( ts ) Then Return False
		line = Trim( ReadLine( ts ) )
		LineNum:+1
		form.LastErrLine :+ 1
	Return True
	End Method

	'------------------------------------------------------------
	'# Translate Form Defininition names to BlitzMAX names
	Method Translate:String( gadname:String ) Abstract

End Type

