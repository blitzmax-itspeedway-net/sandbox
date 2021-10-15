
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

	Method Event_FileOpen:TTextDocument( uri:String )
DebugStop		
		Return getFile( uri )
	End Method

	Method Event_FileClose( uri:String )
		documents.remove( uri )
	End Method	

	' Get list of all documents
	Method all:TMap()
		Return documents
	End Method
	
	' Get a file. 
	' If the file is not in the library then we attempt to open it.
	Method getFile:TTextDocument( file_uri:String )
Print( "LOADING DOCUMENT "+file_uri )
		Local document:TTextDocument = TTextDocument( documents.valueforkey( file_uri ) )
		' Check if document is already loaded
'DebugStop
		If document ; Return document
		' Check file extension is supported
		Local ext:String = ExtractExt( file_uri )
		If ext<>"bmx" And ext<>"c" And ext<>"cpp" Return Null
		' Check file exists
		If FileType( file_uri ) <> 1 Return Null	' Does not exist or it is a folder!
		' Check if symbol table already created
		Local symfile:String = StripExt( file_uri )+".sym"
		If FileType( symfile ) = 1
			' Symbol table exists
			' Check if file has chnaged since symbol table created
			' if not "changed"
			'	load symbol table
			'	return new TTextDocument containing symbol table
			' end if
		End If
		' We need to create a new symbol table
		'Parse()
		
		' Load the Source code
		Local content:String = loadFileContent( file_uri )
		' Create a TFullTextDocument
		Local doc:TFullTextDocument = New TFullTextDocument( file_uri, content )
		
		' Tokenise and Parse into AST
		doc.parse()
		
		' Generate a symbol table
		' Save the symbol table to disk (for later)
		
		'Return a TTextDocument containing the symbol table
		'Local document:TFullTextDocument = New TFullTextDocument( uri, source )
		documents.insert( uri, doc )
		Return doc

	End Method

	Method loadFileContent:String( file_uri:String )
		Local content:String = ""
		Local file:TStream = OpenFile( file_uri )
		If file 
			While Not Eof(file)
				Local line:String = ReadLine(file)
				content :+ line + "~n"
			Wend
			CloseStream file
		EndIf
		Return content
	End Method
	
End Type


