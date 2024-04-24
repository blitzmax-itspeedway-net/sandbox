SuperStrict

' REMEMBER - MATCH START POSITION ARE ZERO-BASED


'Import packrat.parser
Import "../../packrat.parser/parser.bmx"
Import "../../packrat.functions/functions.bmx"

Import "../../peg.parser/parser.bmx"

Local sourcecode:String = "This is text with a number 1234.8"
Local int_test:String = "There were 100 of them"

Function title( message:String )
	Global line:String = " "[..40].Replace(" ","==")
	Print "~n"+line+"~n#~t"+Upper(message)+":~n"+line+"~n"
End Function

Function show( title:String, item:TPattern )
	Print title+" <- "+item.PEG()
	Print title+" :: "+item.AsString()
End Function

' REMEMBER - MATCH START POSITION ARE ZERO-BASED
Function view( pattern:TPattern, text:String, pos:Int=0 )
	Local result:TParseNode = pattern.match( text,, pos )
	'
	' Show the definition:
	Print "PEG:   "+pattern.PEG()
	' Show the search criteria
	Print "TEXT:  "+text
	' Show the ruler:
	Print "START: "+(" "[..(pos)].Replace(" ","-"))+"^"
	' Show result
	If Not result
		Print "-> NULL returned from function"
	Else If result.found()
		Local before:String = " "[..(result.start)].Replace(" ","#")
		Local marker:String = text[result.start..result.finish]
		Local after:String  = " "[..(text.length-result.finish)].Replace(" ","#")
		Print "-> Match found at "+result.start+".."+result.finish
		Print "       "+before+marker+after
	Else
		Print "-> No match found"
	End If
End Function

' Toggle parser-debugger
TPackratParser.DEBUGGER = False

' Variables
Local result:TParseNode
Local pattern:TPattern

'--------------------------------------------------
title( "CHARACTER CLASSES" )

'# DIGIT <- "0"/"1"/"2"/"3"/"4"/"5"/"6"/"7"/"8"/"9"
'# DIGIT <- [0-9]
Local digit:TPattern = RANGE( "0-9" )
show( "DIGIT", digit )

'# ALPHA <- [A-Za-z]
Local alpha:TPattern = RANGE( "A-Za-z" )
show( "ALPHA", alpha )

'# ALPHANUMERIC <- [A-Za-z0-9]
Local alphanumeric:TPattern = RANGE( "A-Za-z0-9" )
show( "ALPHANUMERIC", alphanumeric )

'# HEXDIGIT <- [A-Fa-f0-9]
Local hexdigit:TPattern = RANGE( "A-Fa-f0-9" )
show( "HEXDIGIT", hexdigit )

'--------------------------------------------------
title( "PRIMITIVES" )

'# NUMBER  <- FLOAT | INTEGER
'# FLOAT   <- <DIGITDIGIT+ "." DIGIT+
'# INTEGER <- DIGIT+

Local number:TPattern = ..
  CHOICE([..
    SEQUENCE( "FLOAT", [..
      ONEORMORE( digit ), ..
      SYMBOL( "." ), .. 
      ONEORMORE( digit ) ..
      ]), ..
    ONEORMORE( "INTEGER", digit )..
    ])
show( "NUMBER", number )

'# HEXNUMBER <- HEXDIGIT*
Local hexadecimal:TPattern = ONEORMORE( hexdigit )
show( "HEXADECIMAL", hexadecimal )

'--------------------------------------------------
title( "COMPOUND CLASSES" )

' End of Input (Equivalent to REGEX $)
'# EOI <- !.
Local EOI:TPattern = NOTPRED( ANY() )
show( "EOI", EOI )

'--------------------------------------------------
title( "Digit Match" )
view( digit, sourcecode, 27 )	' REMEMBER - MATCH START POSITION ARE ZERO-BASED

title( "Float Match" )
view( number, sourcecode, 27 )	' REMEMBER - MATCH START POSITION ARE ZERO-BASED

title( "Int Match" )
view( number, int_test, 11 )	' REMEMBER - MATCH START POSITION ARE ZERO-BASED

'--------------------------------------------------
title( "Literal Case Sensitive Match" )

pattern = LITERAL( "Love" )
view( pattern, "We Love BlitzMax", 3 ) ' REMEMBER - MATCH START POSITION ARE ZERO-BASED

'--------------------------------------------------
title( "Literal Case Sensitive Mis-Match" )

pattern = LITERAL( "love" )
view( pattern, "We Love BlitzMax", 3 ) ' REMEMBER - MATCH START POSITION ARE ZERO-BASED

'--------------------------------------------------
title( "Literal Case Insensitive Match" )

pattern = LITERAL( "love", True )
view( pattern, "We Love BlitzMax", 3 ) ' REMEMBER - MATCH START POSITION ARE ZERO-BASED

'--------------------------------------------------
title( "SEQUENCE matching" )

pattern = SEQUENCE([ ..
	LITERAL("hello", True), ..
	SYMBOL(" "), ..
	LITERAL("world", True) ..
	])
view( pattern, "Hello world" )

Print
view( pattern, "Another world" )

