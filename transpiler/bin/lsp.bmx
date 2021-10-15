'
'	LANGUAGE SERVER PROTOCOL TYPES
'	(c) Copyright Si Dunford, July 2021, All Rights Reserved
'
'	Based on Language server protocol 3.16 at:
'	https://microsoft.github.io/language-server-protocol/specifications/specification-current/

Enum DiagnosticSeverity ; Error = 1 ; Warning ; Information ; Hint ; EndEnum
Enum DiagnosticTag ; Unnecessary = 1 ; Depreciated ; EndEnum

Enum CompletionItemKind 
	_Text = 1
    _Method = 2
    _Function = 3
    _Constructor = 4
    _Field = 5
    _Variable = 6
    _Class = 7
    _Interface = 8
    _Module = 9
    _Property = 10
    _Unit = 11
    _Value = 12
    _Enum = 13
    _Keyword = 14
    _Snippet = 15
    _Color = 16
    _File = 17
    _Reference = 18
    _Folder = 19
    _EnumMember = 20
    _Constant = 21
    _Struct = 22
    _Event = 23
    _Operator = 24
    _TypeParameter = 25
EndEnum

Enum DocumentHighlightKind	;	Text = 1 ; Read ; Write ; EndEnum
Enum InsertTextFormat ; PlainText = 1 ; Snippet ; EndEnum

Enum MessageType ; Error = 1 ; Warning ; Info ; Log ; EndEnum

Enum SymbolKind
    _File = 1
    _Module = 2
    _Namespace = 3
    _Package = 4
    _Class = 5
    _Method = 6
    _Property = 7
    _Field = 8
    _Constructor = 9
    _Enum = 10
    _Interface = 11
    _Function = 12
    _Variable = 13
    _Constant = 14
    _String = 15
    _Number = 16
    _Boolean = 17
    _Array = 18
EndEnum

Enum TextDocumentSyncKind ; NONE = 0 ; FULL = 1 ; INCREMENTAL = 2 ; EndEnum

' https://microsoft.github.io/language-server-protocol/specifications/specification-3-17/#diagnostic
Type TDiagnostic
	Field range: TRange
	Field severity: DiagnosticSeverity	' The diagnostic's severity.
	'Field code: String					' The diagnostic's code, which might appear in the user interface.
	'Field codeDescription:TCodeDescription		' An optional property to describe the error code.
	Field source: String				' The source of this diagnostic
	Field message : String				' The diagnostic's message
	'Field tags: TDiagnostTag[]			' Additional metadata
	'Field relatedInformation:TDiagnosticRelatedInformation[]	' Related diagnostic information
	Field data:Int						' Data entry field that is preserved between Notification and request
	
	Method New()
		range = New TRange()
		range.start = New TPosition()
		range.ends = New TPosition()
	End Method
	
	Method New( error:String, severity:DiagnosticSeverity )
		Self.message = error
		Self.severity = severity
		Self.range = New TRange()
		Self.range.start = New TPosition()
		Self.range.ends = New TPosition()
	End Method

	Method New( error:String, severity:DiagnosticSeverity, range:TRange )
		Self.range = range
		Self.message = error
		Self.severity = severity
	End Method
	
	Method reveal:String()
		Local result:String
		result :+ Upper( severity.tostring() )
		result :+ " ["+range.start.line+","+range.start.character+"] - "
		result :+ "["+range.ends.line+","+range.ends.character+"] " 
		result :+ source + " "
		result :+ message
		Return result
	End Method
End Type

Type TDiagnosticRelatedInformation
	Field location: TLocation
	Field message: String
End Type

' https://microsoft.github.io/language-server-protocol/specifications/specification-3-17/#location
Type TLocation
	Field uri:String
	Field range:TRange
End Type

' https://microsoft.github.io/language-server-protocol/specifications/specification-3-17/#position
Type TPosition
	Field line: UInt
	Field character: UInt
	
	Method New( line:UInt, character:UInt )
		Self.line = line
		Self.character = character
	End Method
	
	Method New( token:TToken )
		If Not token return
		Self.line = token.line
		Self.character = token.pos
	End Method
	
End Type

' https://microsoft.github.io/language-server-protocol/specifications/specification-3-17/#range
Type TRange
	Field start: TPosition
	Field ends: TPosition

	Method New( starting:TPosition, ending:TPosition )
		Self.start = starting
		Self.ends = ending
	End Method

	Method New( start_line:UInt, start_char:Int, end_line:UInt, end_char:Int )
		Self.start = New TPosition( start_line, start_char )
		Self.ends = New TPosition( end_line, end_char )
	End Method
	
End Type


' https://microsoft.github.io/language-server-protocol/specifications/specification-3-17/#uri

'TODO: add function "file:URI( path:string )" to deal with files that contain characters that are
' interpreted as regex (Like # for example)

' BASED ON:
'	https://github.com/microsoft/vscode-uri/blob/6fc6458aba65ea67458897d3331a37784c08e590/src/uri.ts#L589


Type URI
	'	  foo://example.com:8042/over/there?name=ferret#nose
	'	  \_/   \______________/\_________/ \_________/ \__/
	'	   |           |            |            |        |
	'	scheme     authority       path        query   fragment
	'	   |   _____________________|__
	'	  / \ /                        \
	'	  urn:example:animal:ferret:nose
	
	Const REGEX:String = "^(([^:/?#]+?):)?(\/\/([^/?#]*))?([^?#]*)(\?([^#]*))?(#(.*))?"
	Field scheme:String, authority:String, path:String, query:String, fragment:String
	
	Method New( value:String )
		parse( value )
	End Method
	
	Method New( scheme:String, authority:String, path:String, query:String, fragment:String )
		Self.scheme = scheme
		Self.authority = authority
		Self.path = path
		Self.query = query
		Self.fragment = fragment
	End Method
	
	Function parse:URI( value:String )
		Local regex:TRegEx = TRegEx.Create( REGEX )
		Local match:TRegExMatch = regex.Find( value )
		If Not match Return New URI()	' Or should this return NULL?
		'
'DebugStop
		'Local count:Int = match.subcount()
        'For Local i:Int = 0 Until match.SubCount()	;	Print i + ": " + match.SubExp(i)	;	Next
		'Local result:URI = New URI()
		'result.scheme = match.SubExp(2)
		'result.authority = match.subexp(4)
		'result.path = match.subexp(5)
		'result.query = match.subexp(7)
		'result.fragment = match.subexp(9)
		'Return result
		Return New URI( match.SubExp(2), match.SubExp(4), match.SubExp(5), match.SubExp(7), match.SubExp(9) )
	End Function
	
	Function file:URI( path:String )
		Local authority:String = ""
		
		' Normalise slashes
		path = Replace( path, "\", "/" )

		' UNC paths
		If path[0..2]="//"
			Local idx:Int = Instr( path, "/", 2 )
			If idx = 0
				authority = path[2..]
				path = "/"
			Else
				authority = path[2..idx]
				path = path[idx..]
				If path="" ; path = "/"
			End If
		End If

		Return New URI( "file", authority, path, "", "" )
	End Function
	
End Type

'DebugStop
'Local test:URI
'test = URI.Parse( "http://example.com:222/in/this/path?param=22#fragment" )
''test = URI.Parse( "http://example.com/" )
'Print test.scheme
'Print test.authority
'Print test.path
'End 