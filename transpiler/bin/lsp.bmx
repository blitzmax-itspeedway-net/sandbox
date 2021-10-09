'
'	LANGUAGE SERVER PROTOCOL TYPES
'	(c) Copyright Si Dunford, July 2021, All Rights Reserved
'
'	Based on Language server protocol 3.16 at:
'	https://microsoft.github.io/language-server-protocol/specifications/specification-current/

Enum DiagnosticSeverity ; Error = 1 ; Warning ; Information ; Hint ; EndEnum
Enum DiagnosticTag ; Unnecessary = 1 ; Depreciated ; EndEnum

' https://microsoft.github.io/language-server-protocol/specifications/specification-3-17/#codeDescription
'Type TCodeDescription
'	Field href: URI
'End Type

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
		range = New TRange()
		range.start = New TPosition()
		range.ends = New TPosition()
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
End Type

' https://microsoft.github.io/language-server-protocol/specifications/specification-3-17/#range
Type TRange
	Field start: TPosition
	Field ends: TPosition
End Type


' https://microsoft.github.io/language-server-protocol/specifications/specification-3-17/#uri

'TODO: add function "file:URI( path:string )" to deal with files that contain characters that are
' interpreted as regex (Like # for example)

' BASED ON:
'	https://github.com/microsoft/vscode-uri/blob/6fc6458aba65ea67458897d3331a37784c08e590/src/uri.ts#L589

Type URI
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
	
	Function file:URI( value:String )
'TODO: Complete this
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