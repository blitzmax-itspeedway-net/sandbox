
'	LANGUAGE SERVER / DOCUMENT MANAGER
'	(c) Copyright Si Dunford, July 2021, All Rights Reserved

' import languageserver.document

Const MAXIMUM_PROBLEMS:Int = 10		' This needs to go into settings!

Function validateTextDocument( textDocument:TTextDocument )
	Local diagnostics : TDiagnostic[] = []
	Local problems:Int = 0
	
	While diagnostics.length < MAXIMUM_PROBLEMS
		Local diagnostic:TDiagnostic = New TDiagnostic()
		diagnostics :+ [diagnostic]
	Wend
	
	'connection.sendDiagnostics( textdocument.uri, diagnostics )
	
End Function

' Text Document Manager
Type TDocuments

	Field uri:String
	Field documents:TMap = New TMap()

	Method Event_FileOpen:TFullTextDocument( uri:String )
					
		Local source:String = ""
		Local file:TStream = OpenFile( uri )
		If file 
			While Not Eof(file)
				Local line:String = ReadLine(file)
				source :+ line + "~n"
			Wend
			CloseStream file
		EndIf
	
		Local document:TFullTextDocument = New TFullTextDocument( uri, source )
		documents.insert( uri, document )
		Return document
	End Method

	Method Event_FileClose( uri:String )
		documents.remove( uri )
	End Method	

	' Get list of all documents
	Method all:TMap()
		Return documents
	End Method
	
End Type


