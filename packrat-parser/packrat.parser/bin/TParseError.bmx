'   NAME
'   (c) Copyright Si Dunford, MMM 2022, All Rights Reserved. 
'   VERSION: 1.0

'   CHANGES:
'   DD MMM YYYY  Initial Creation
'

Type TParseError

	Field start:Int, finish:Int
	Field severity:Int
	Field code:Int
	Field message:String
	
	Method New( message:String, start:Int, finish:Int, code:Int=0, severity:Int=0 )
		Self.message  = message
		Self.start    = start
		Self.finish   = finish
		Self.code     = code
		Self.severity = severity
	End Method
	
End type