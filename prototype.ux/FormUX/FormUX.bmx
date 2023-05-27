SuperStrict

'Import "src/TForm.bmx"
Import "src/TFormParser.bmx"

Type FormUX

	Function load:TForm( filename:String )
	
		If FileType( filename ) <> FILETYPE_FILE; Return Null
		
		Select Lower( ExtractExt( filename ) )
		Case ".dfm"		' Deplhi Form Definition
		'	Return New TFormParserDFM( filename ).parse()
		Case ".frm"		' Visual Basic Form Definition
			Return New TFormParserFRM( filename ).parse()
		Case ".lfm"		' Lazerus Form Definition
		'	Return New TFormParserLFM( filename ).parse()
		Case ".mxf"		' BlitzMax Form Definition
		'	Return New TFormParserMXF( filename ).parse()
		EndSelect
	
	End Function
	
End Type




