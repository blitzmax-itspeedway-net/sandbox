'#
Include "TFormParserBFD.bmx"
'Include "TFormParserFRM.bmx"	'# Experimental VB6 parser


'############################################################
Type TFormParser
Field ts:TStream
Field form:TForm		'# Form we are parsing

	'------------------------------------------------------------
	Method Load:Int( file:String )
	Local result%
		ts = OpenFile( file )
		If Not ts Then Return fail( ERR_FILEOPEN, "Unable to open file" )
		result = Parse()
		CloseStream ts
	Return result
	End Method

	'------------------------------------------------------------
	Method Fail%( ErrCode:Int=ERR_EOF, ErrText:String="Unexpected end of file" )
		form.LastErrCode = ErrCode
		form.LastErrText = ErrText
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
		form.LastErrLine :+ 1
	Return True
	End Method

	'------------------------------------------------------------
	'# Translate Form Defininition names to BlitzMAX names
	Method Translate$( gadname$ ) Abstract

End Type

