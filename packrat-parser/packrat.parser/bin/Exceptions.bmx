
Type TParserException Extends TBlitzException

	Private Field trace:String
	
	Public Method message:String() Abstract
	
	' DEPRECIATED
	Public Method append( name:String )
	'	If Not rulename
	'		rulename = name
	'	Else
	'		rulename = name +"/"+rulename
	'	End If
	End Method
	
	'Method setTrace( trace:String )
	'	Self.trace = trace
	'End Method

	Public Method getTrace:String()
		Return trace
	End Method
		
	Public Method traceBack:String()
		Return trace
	End Method
	
End Type

Type TInfiniteLoop Extends TParserException
	
	Field ptype:String
	Field pattern:String
	
	Method New( ptype:String, pattern:String, trace:String )
		Self.ptype = ptype
		Self.pattern = pattern
		Self.trace = trace
	End Method

	Method message:String()
		Return "Infinite loop in pattern '"+ptype+"', "+pattern
	End Method
	
End Type

Type TMissingRule Extends TParserException

	Field rule:String

	Method New( rule:String )
		Self.rule = rule
	End Method

	Method message:String()
		Return "Rule '"+rule+"' is not defined"
	End Method

End Type

Type TMissingVisitor Extends TParserException

	Field methd:String

	Method New( methd:String )
		Self.methd = methd
	End Method

	Method message:String()
		Return "Visitor method '"+methd+"()' is not defined."
	End Method

End Type

' The reflection module only returns the string "ERROR" when something goes wrong
' This type wraps it so that we can handle it better

Type TReflectionException Extends TParserException

	Method New()
	End Method

	Method message:String()
		Return "Reflection error. No details provided by module."
	End Method

End Type

' This type wraps a string exception it so that we can handle it better

Type TStringException Extends TParserException

	Field msg:String

	Method New( msg:String )
		Self.msg = msg
	End Method

	Method message:String()
		Return msg
	End Method

End Type

' This is thrown when an ERROR operator is used and no
' Farthest point has been captured by EXPECT
' It results in a syntax error without a location and it therefore
' raised as an exception
Type TMissingExpectException Extends TParserException

	Method New( trace:String )
		Self.trace = trace
	End Method
	
	Method message:String()
		Return "Error handler without Expect"
	End Method

End Type