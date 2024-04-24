
'	FUNCTIONS FOR MANUALLY CREATING PATTERNS

Const CASE_SENSITIVE:Int = True
Const CASE_INSENSITIVE:Int = False

' AND PREDICATE / AND LOOKAHEAD
Function ANDPRED:TPattern( pattern:TPattern, name:String="" )
	Return New TAndPredicate( pattern, name )
End Function

Function ANY:TPattern()
	Return New TAny()
End Function

'Function capture:TPattern( pattern:TPattern )
'	Return New TCapture( pattern )
'End Function

'Function chain:TPattern( pattern:TPattern[] )
'	DebugLog( "chain() is Depreciated; please use 'sequence()'" )
'	Return New TChain( pattern )
'End Function

'Function charmatch:TPattern( charset:String )', kind:Int=KIND_CHAR )
'	Assert False, "charmatch() is depreciated; please use CHARSET()"
'	Return New TCharset( charset )
'End Function

Function CHARSET:TPattern( charset:String )
	Return New TCharset( charset )
End Function
Function CHARSET:TPattern( name:String, charset:String )
	Return New TCharset( charset, name )
End Function
Function CHARSET:TPattern( charset:String[] )
	Return New TCharset( charset )
End Function
Function CHARSET:TPattern( name:String, charset:String[] )
	Return New TCharset( charset, name )
End Function

Function CHOICE:TPattern( name:String, pattern:TPattern[] )
	Return New TChoice( pattern, name )
End Function

Function CHOICE:TPattern( pattern:TPattern[] )
	Return New TChoice( pattern )
End Function

'Function choice:TPattern( kind:Int, pattern:TPattern[] )
'	Return New TChoice( pattern, kind )
'End Function

'Function choice:TPattern( pattern:TPattern[] )
'	Return New TChoice( pattern )
'End Function

Function ERROR:TPattern( pattern:TPattern, message:String )
	Return New TError( pattern, message )
End Function

' Match for an expected patten, or return an error
'Function expect:TPattern( pattern:TPattern, error:String )
'	Return New TExpect( pattern, error )
'End Function

Function GROUP:TPattern( pattern:TPattern = Null )
	Return New TGroup( pattern )
End Function
Function GROUP:TPattern( name:String, pattern:TPattern = Null )
	Return New TGroup( pattern, name )
End Function

' A Keyword is a case insensitive literal
Function KEYWORD:TPattern( text:String )
	'DebugStop
	Local words:String[] = text.split( " " )
	If Len(words)=1; Return New TLiteral( Upper(text), text, CASE_INSENSITIVE )
	'
	'DebugStop
	Local pattern:TPattern[]
	For Local index:Int = 0 Until words.length
		pattern :+ [ SP, New TLiteral( Upper(words[index]), words[index], CASE_INSENSITIVE ) ]
	Next
	Return sequence( pattern[1..] )
End Function

Function LITERAL:TPattern( pattern:String )
	Return New TLiteral( pattern, cleanse(pattern), CASE_SENSITIVE )	', iffail )
End Function

Function LITERAL:TPattern( pattern:String, casesensitive:Int )	', iffail:String="" )
	Return New TLiteral( pattern, cleanse(pattern), casesensitive )
End Function

Function LITERAL:TPattern( name:String, pattern:String, casesensitive:Int )	', iffail:String="" )
	Return New TLiteral( pattern, name, casesensitive )
End Function

'Function named:TPattern( name:String, pattern:TPattern )
'	Return New TNamed( pattern, name )
'End Function

' Negative lookahead
Function NOTPRED:TPattern( name:String, pattern:TPattern )
	Return New TNotPredicate( pattern, name )
End Function
Function NOTPRED:TPattern( pattern:TPattern )
	Return New TNotPredicate( pattern )
End Function

'Function oneof:TPattern( pattern:TPattern[] )
'	DebugLog( "oneof() is Depreciated; please use 'choice()'" )
'	Return New TChoice( pattern )
'End Function

'Function OneOrMore:TPattern( pattern:TPattern, kind:Int=0 )
'	Return New TOneOrMore( pattern, kind )
'End Function

Function ONEORMORE:TPattern( pattern:TPattern )
	Return New TOneOrMore( pattern )
End Function

Function ONEORMORE:TPattern( name:String, pattern:TPattern )
	Return New TOneOrMore( pattern, name )
End Function

' OPTIONAL PATTERN (Zero or One)
Function OPTIONAL:TPattern( pattern:TPattern )
	Return New TOptional( pattern )
End Function
Function OPTIONAL:TPattern( name:String, pattern:TPattern )
	Return New TOptional( pattern, name )
End Function

'Function pattern:TPattern( id:String, definiton:TPattern )
'	definiton.setID( id )
'	Return definiton
'End Function

' Create a range
Function RANGE:TPattern( range:String )
	Return New TRange( range )
End Function
Function RANGE:TPattern( name:String, range:String )
	Return New TRange( range, name )
End Function
Function RANGE:TPattern( range:String[] )
	Return New TRange( range )
End Function
Function RANGE:TPattern( name:String, range:String[] )
	Return New TRange( range, name )
End Function

' Read characters until pattern found
Function READUNTIL:TPattern( name:String, pattern:TPattern )
	Return New TSequence([ ZEROORMORE( SEQUENCE([ NOTPRED(pattern), ANY() ]) ), pattern ], name)
End Function
Function READUNTIL:TPattern( pattern:TPattern )
	Return New TSequence([ ZEROORMORE( SEQUENCE([ NOTPRED(pattern), ANY() ]) ), pattern ] )
End Function

' Read characters until pattern found and mark as error
'Function recover:TPattern( pattern:TPattern, error:String )
'	Return New TError( sequence([ zeroOrMore( sequence([ NEG(pattern), any() ]) ), pattern ]), error )
'End Function

'Function repeats:TPattern( pattern:TPattern )
'	DebugLog( "repeats() is Depreciated; please use 'ZeroOrMore()'" )
'	Return New TZeroOrMore( pattern )
'End Function

Function SEQUENCE:TPattern( name:String, pattern:TPattern[] )
	Return New TSequence( pattern, name )
End Function
Function SEQUENCE:TPattern( pattern:TPattern[] )
	Return New TSequence( pattern )
End Function

Function SYMBOL:TPattern( character:String )
	Return New TSymbol( character )
End Function
Function SYMBOL:TPattern( character:Int )
	Return New TSymbol( character )
End Function

'Function sequence:TPattern( pattern:TPattern[], kind:Int=KIND_SEQUENCE, iffail:String="" )
'	Return New TSequence( pattern, kind, iffail )
'End Function

Function ZEROORMORE:TPattern( pattern:TPattern )
	Return New TZeroOrMore( pattern )
End Function
Function ZEROORMORE:TPattern( name:String, pattern:TPattern )
	Return New TZeroOrMore( pattern, name )
End Function

' PRE-DEFINED CORE RULES

' Based on rfc5234 ABNF definitions
Global ALPHA:TPattern     = RANGE(   "ALPHA",    [ "AZ", "az" ])          ' Case insensitive     A..Z, a..z
Global CHAR:TPattern      = RANGE(   "CHAR",     Chr($20)+Chr($7E) )      ' 7 BIt ASCII except CTRL
Global CR:TPattern        = CHARSET( "CR",       Chr($0D) )               ' Carriage Return      \n
Global CRLF:TPattern      = CHARSET( "CRLF",     [ Chr($0D), Chr($0A) ])  ' Newline (Windows)    \n\r
Global DIGIT:TPattern     = RANGE(   "DIGIT",    "09" )                   ' Digit 0 to 9        0123456789
Global DQUOTE:TPattern    = CHARSET( "DQUOTE",   Chr($22) )               ' Double Quote         "
Global HEXDIGIT:TPattern  = RANGE(   "HEXDIGIT", [  "09", "AF", "af" ])   ' Hexadecimal digits
Global HTAB:TPattern      = CHARSET( "HTAB",     Chr($09) )               ' Horizontal Tab       \t
Global LF:TPattern        = CHARSET( "LF",       Chr($0A) )               ' Line Feed            \r
Global OCTET:TPattern     = RANGE(   "OCTET",    Chr($00)+Chr($FF) )      ' Any 8 bit character
Global SP:TPattern        = CHARSET( "SP",       Chr($20) )               ' Space
Global VCHAR:TPattern     = RANGE(   "VCHAR",    Chr($21)+Chr($7E) )      ' visible (printing) characters

'Global WSP:TPattern       = ONEORMORE( "WSP",    choice([SP,HTAB]) )      ' Whitespace

