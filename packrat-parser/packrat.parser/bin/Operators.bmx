Rem 
STANDARD OPERATORS

	AndPredicate:  &e                  TAndPredicate
	Choice:        e1 / e2 / e3 / ...  TChoice
	Group:         (e)                 TGroup
	NotPredicate:  !e                  TNotPredicate
	OneOrMore:     e+                  TOneOrMore
	Optional:      e?                  TOptional
	Range:         []                  TRange (Allowed ranges of characters)
	Sequence:      e1 e2 e3 ...        TSequence
	ZeroOrMore:    e*                  TZeroOrMore

EXTENDED OPERATORS

	CharSet:       []                  TCharSet (Allowed selection of characters)

End Rem

TRange.initialise()

' ANDPREDICATE == &e 
' Matches expression but does not consume
' Returns FALSE if expression does not match
Type TAndPredicate Extends TPattern
	
	Method New( pattern:TPattern )	' name:String="" )
		'Self.name     = name
		Self.patterns = [pattern]
	End Method

	Method match:TParseNode( doc:TTextDocument, caller:IPatternCallback=Null, start:Int=0, depth:Int=0, traceback:String="" )
		traceback :+ "/ANDPRED"

		Local result:TParseNode = patterns[0].match( doc, caller, start, depth+1, traceback )
		If Not result; Return Null
		doc.set_farthest( start )
		Return success( start, start )
	End Method
	
	Method PEG:String()
		Return "&" + patterns[0].PEG()
	End Method

	Method generate:String( tab:String )
		Local str:String = tab + "ANDPRED( "
		'If name; str :+ "~q"+name+"~q, "
		str :+ ".."+patterns[0].generate( tab+"~t" )+".."
		str :+ tab+")"
		Return str
	End Method

EndType

' Any Character (.)
' Returns success unless at end of input
Type TAny Extends TPattern

	Method New()
	End Method

	Method match:TParseNode( doc:TTextDocument, caller:IPatternCallback=Null, start:Int=0, depth:Int=0, traceback:String="" )
		'traceback :+ "/ANY"
		If start >= doc.content.length; Return Null
'		doc.set_farthest( start+1 )
		Return Success( start, start+1 )
	End Method
	
	Method AsString:String()
		'DebugStop
		Return TTypeId.forobject( Self ).name()
	End Method

	Method PEG:String()
		Return "."
	End Method

	Method generate:String( tab:String )
		Return tab+"ANY()"
	End Method

EndType

Type TCapture Extends TPattern

	Field name:String
	
	Method New( pattern:TPattern, name:String = "" )
'		If kind>0; Self.kind = kind
		Self.patterns = [pattern]
		Self.name = name
	End Method
	
	Method match:TParseNode( doc:TTextDocument, caller:IPatternCallback=Null, start:Int=0, depth:Int=0, traceback:String="" )
		traceback :+ "/CAPTURE("+name+")"
		Local node:TParseNode = patterns[0].match( doc, caller, start, depth+1, traceback )
	
		If Not node; Return Null
		
		Local result:TParseNode = Success( start, node.finish, [node] )
		If Not result; Return Null
		result.captured = doc.content[ start..node.finish ]
		result.named = name
		doc.set_farthest( node.finish )
		Return result
	End Method

	Method PEG:String()
		Return "/capture{"+patterns[0].PEG()+"}"
	End Method

	Method generate:String( tab:String )
		Local str:String = tab + "CAPTURE( "
		'If name; str :+ "~q"+name+"~q, "
		str :+ ".."+patterns[0].generate( tab+"~t" )
		str :+ tab+")"
		Return str
	End Method
	
EndType

' A Charset scans a set of allowed characters
Type TCharSet Extends TPattern
	Field allowed:String

	Method New( charset:String )	' name:String="" )
		'Self.name    = name
		Self.allowed = charset
	End Method

	Method New( charset:String[], name:String="" )
		'Self.name    = name
		Self.allowed = "".join( charset )
	End Method

	Method match:TParseNode( doc:TTextDocument, caller:IPatternCallback=Null, start:Int=0, depth:Int=0, traceback:String="" )
'		traceback :+ "/CHARSET"
		'Local debug:TDebug = debugline( Self, text, pos )
		If start>doc.content.length; Return Null	' EOI always fails
		Local ch:Int = doc.content[start]
		For Local c:Int = EachIn allowed
			If ch=c
'				doc.set_farthest( start+1 )
				Return Success( start, start+1, Null )
			End If
		Next
		Return Null
	End Method
	
	Method AsString:String()
'		DebugStop
		Return TTypeId.forobject( Self ).name()+" ["+escape(allowed)+"]"
	End Method

	Method PEG:String()
		Local str:String = escape(allowed)
		If str.length = 1; Return str
		Return "["+str+"]"
	End Method

	Method generate:String( tab:String )
		Local str:String = tab+"CHARSET( ~q"+escape(allowed)+"~q )"
		Return str
	End Method

End Type

' CHOICE == e1 / e2 
' Choice is successful when any one of its children is successful, fails when ALL children fail.
' V1.0
Type TChoice Extends TPattern

	Method New( patterns:TPattern[] )	' name:String="" )
		'Self.kind     = KIND_CHOICE
		'Self.name     = name
		Self.patterns = patterns
	End Method
	
	'Method New( patterns:TPattern[], kind:Int=0 )
	'	Self.kind = kind
	'	Self.patterns = patterns
	'End Method

	Method match:TParseNode( doc:TTextDocument, caller:IPatternCallback=Null, start:Int=0, depth:Int=0, traceback:String="" )
		traceback :+ "/CHOICE"
		Local pos:Int = start
		Local count:Int = 1
		For Local pattern:TPattern = EachIn patterns
			Local result:TParseNode = pattern.match( doc, caller, pos, depth+1, traceback )
			If result
				'DebugStop
Rem
				' Treat as a failure if the result start & finish are equal
				' This occurs when a ZeroOrMore() (or Negate) is placed in a choice forcing it to
				' be successful in not finding something. The choice is then successful causing a loop!
End Rem
				'If result.start <> result.finish
				doc.set_farthest( result.finish )
				Return result
				'End If
				'DebugLog( "** TChoice pattern "+count+" returned empty result" )
			EndIf
			count :+ 1
		Next
		Return Null	'Failure()
	End Method
	
	Method AsString:String()
		'DebugStop
		Local str:String
		For Local pattern:TPattern = EachIn patterns
			str :+ ","+pattern.AsString()
		Next
		
		Return TTypeId.forobject( Self ).name()+" ["+str[1..]+"]}"
	End Method

	Method PEG:String()
		Local list:String[] = New String[ patterns.length ]
		'For Local pattern:TPattern = EachIn patterns
		For Local n:Int = 0 Until patterns.length
			If Not patterns[n]; Continue			' Shouldn't ever have NULL patterns!
			'str :+ " / "+pattern.PEG()
			
			list[n] = patterns[n].PEG()
		Next
		Local str:String = " / ".join( list )
		Return "( "+str+" )"
		'Return "( "+str[3..]+" )"
	End Method
	
	' Write expression using parser functions
	Method generate:String( tab:String )
		Local str:String = tab + "CHOICE([.."
		'If name; str :+ "~q"+name+"~q, "
		'str :+ "[.."
		If patterns
			For Local pattern:TPattern = EachIn patterns
				str :+ pattern.generate( tab+"~t" ) + ", .."
			Next
		End If
		' Strip trailing ", .."
		str = str[..(str.length-4)] + " .."+tab+"])"
		Return str
	End Method
	
EndType

' A TError is a runtime error that can be inserted as a pattern
Type TError Extends TPattern

'	Field errortext:String
	
	Method New( pattern:TPattern )	', errortext:String )
		Self.kind      = KIND_ERROR
'		Self.errortext = errortext
		Self.patterns  = [pattern]
		'Self.name      = "ERROR"
	End Method

	Method match:TParseNode( doc:TTextDocument, caller:IPatternCallback=Null, start:Int=0, depth:Int=0, traceback:String="" )
		traceback :+ "/ERROR"

'DebugStop
		' Position of error
		Local err_pos:Int = doc.farthest_point
		Local err_token:String = doc.expected_token
DebugStop
Print "ERROR"
Local data:String

If doc.farthest_point=0
	Print "  FP IS ZERO"
Else
	data = sanitize( doc.content[doc.farthest_point..doc.farthest_point+20] )
	Print "  FP:    ("+doc.farthest_point+") "+data
EndIf

		' Capture the error matcher
		Local result:TParseNode = patterns[0].match( doc, caller, start, depth+1, traceback )
		'An error matcher must return a success for it to be an error!
		If Not result; Return Null

data = sanitize( doc.content[start..result.finish] )
Print "  "+data
Print "  "+(" "[..(err_pos-start)])+"^"


'If data.length > 20; data = data[..18]+".."
Print "  RESULT: ("+start+"-"+result.finish+") "+data
DebugStop
		' Throw an exception if there is no expect block
		If doc.farthest_point = 0
			Throw New TMissingExpectException( traceback )
'Print "  - FARTHEST POINT IS ZERO, USING RESULT"
'			error = New TParseNode( Self, kind, doc, result.start, result.start+1, [] )
'			error.captured = "Unexpected Symbol"
'			error.start = start
		End If

		' Create an error
'DebugStop
		Local error:TParsenode = New TParseNode( Self, kind, err_pos, err_pos+1, [] )
'Local err_data:String = doc.content[err_start..err_finish]
		' Ensure 1 char is shown
		'Local size:Int = Max( 1, err_finish-err_start )
		Local err_data:String 
		If doc.expected_token
			Local size:Int = Max( 1, doc.expected_token.length )
			err_data = sanitize(doc.content[err_pos..err_pos+size])			
			error.captured = "'"+doc.expected_token + "' expected, found '"+err_data+"'"
		Else
			err_data = sanitize(doc.content[err_pos..err_pos+1])
			error.captured = "Token expected, found '"+err_data+"'"
		End If
		error.named = "ERROR"
Print "  "+error.captured
		' Clear the last saved "furthest point"
		doc.reset_farthest()
		
		' The match covers the size of the text captured by the error pattern
		' but only contains a child that contains the error and not the skipped text
		Local matcher:TParseNode
		matcher = New TParseNode( Self, kind, start, result.finish, [error] )
		Return matcher
	End Method
		
	Method PEG:String()
		Return "{"+patterns[0].PEG()+"}"
	End Method

	Method generate:String( tab:String )
		Local str:String = tab + "ERROR( .."
		str :+ patterns[0].generate( tab+"~t" )+", .."
'		str :+ tab+"~t~q"+errortext+"~q .."
		str :+ tab+")"
		Return str
	End Method

	Method sanitize:String( this:String )
		this = this.Replace("~n","\n")
		this = this.Replace("~r","\r")
		this = this.Replace("~t","\t")
		Return this
	End Method
EndType

' Expect simply saves the "Furthest Point" which is used
' when the next ERROR is processed
Type TExpect Extends TPattern

	'Field errortext:String
	
	Method New( pattern:TPattern )	', errortext:String )
		Self.patterns  = [pattern]
	End Method

	Method match:TParseNode( doc:TTextDocument, caller:IPatternCallback=Null, start:Int=0, depth:Int=0, traceback:String="" )
		traceback :+ "/EXPECT"
		Local result:TParseNode = patterns[0].match( doc, caller, start, depth+1, traceback )
		If Not result; Return Null
		doc.set_farthest( result.start, patterns[0].getToken() )
		Return result
	End Method

	Method PEG:String()
		Return "<"+patterns[0].PEG()+">"
	End Method

	Method generate:String( tab:String )
		Local str:String = tab + "EXPECT( .."
		str :+ patterns[0].generate( tab+"~t" )+", .."
		str :+ tab+")"
		Return str
	End Method

EndType

' GROUP == ( e )
' A Group simply returns the status of its "only" child.
Type TGroup	Extends TPattern

	Method New( pattern:TPattern )	', name:String="" )
		'Self.name     = name
		Self.patterns = [pattern]
	End Method

	Method match:TParseNode( doc:TTextDocument, caller:IPatternCallback=Null, start:Int=0, depth:Int=0, traceback:String="" )
		traceback :+ "/GROUP"
		Local result:TParseNode = patterns[0].match( doc, caller, start, depth+1, traceback )
		If Not result; Return Null
		doc.set_farthest( result.finish )
		Return result
	End Method
	
'	Method AsString:String()
'		Return TTypeId.forobject( Self ).name()+"{'"+name+"'}["+patterns[0].AsString()+"]"
'	End Method

	Method PEG:String()
		Return "( "+ patterns[0].peg() + " )"
	End Method
	
	Method generate:String( tab:String )
		Local str:String = tab + "GROUP( "
		'If name; str :+ "~q"+name+"~q, "
		str :+ ".."+patterns[0].generate( tab+"~t" )
		str :+ tab+")"
		Return str
	End Method
	
EndType

' Literals are keywords that are static
Type TLiteral Extends TPattern

	Field casesensitive:Int = True
	Field pattern:String
	'Field iffail:String				' Message to generate if match fails
	
	'Method New( pattern:String, kind:Int=KIND_NONE, iffail:String="" )
	Method New( pattern:String, ignorecase:Int=False )
		'If kind>0; Self.kind = kind
		'Self.name          = name	'cleanse( pattern )
		Self.pattern       = pattern
		Self.casesensitive = Not ignorecase
		'Self.iffail = iffail
	End Method

	' getToken is used by EXPECT / ERROR to identify the token that caused an error
	Method getToken:String()
		Return "'"+pattern+"'"
	End Method
		
	Method match:TParseNode( doc:TTextDocument, caller:IPatternCallback=Null, start:Int=0, depth:Int=0, traceback:String="" )
		'traceback :+ "/LITERAL"
		doc.expected_token = pattern
'DebugStop
		If start+Len(pattern) > doc.content.length; Return Null	' EOI always fails		
		If ( casesensitive And doc.content[start..].startswith( pattern ) )..
			Or ( Not casesensitive And Upper(doc.content[start..start+Len(pattern)])=Upper(pattern) )
				doc.set_farthest( start+Len(pattern) )', pattern )
				Return Success( start, start+Len(pattern) )
		End If
		Return Null
	End Method

'	Method AsString:String()
'		'DebugStop
'		Return TTypeId.forobject( Self ).name()+"{"+name+"}["+pattern+"]"
'	End Method

	Method PEG:String()
		Local str:String
		If Not casesensitive; str = "~~"
		Return str+Chr(34) + escape(pattern) + Chr(34)
	End Method

	Method generate:String( tab:String )
		Local str:String = tab+"LITERAL( "
		'If name; str :+ "~q"+name+"~q, "
		str :+ "~q"+escape(pattern)+"~q"
		If Not casesensitive; str :+ ", True"
		str :+ " )"
		Return str
	End Method
	
EndType

' A Pattern matcher that names a pattern group
Type TNamed Extends TPattern

	Field name:String

	Method New( pattern:TPattern, name:String = "" )
'		If kind>0; Self.kind = kind
		Self.patterns = [pattern]
		Self.name = name
	End Method
	
	Method match:TParseNode( doc:TTextDocument, caller:IPatternCallback=Null, start:Int=0, depth:Int=0, traceback:String="" )
		traceback :+ "/NAMED("+name+")"
		'doc.expected_token = name
		Local node:TParseNode = patterns[0].match( doc, caller, start, depth+1, traceback )
	
		If Not node; Return Null
		
		Local result:TParseNode = Success( start, node.finish, [node] )
		'Local match:TParseNode = Success( start, node.finish, Null )	' Do we need the children? YES (or nested doesn't work)
		If Not result; Return Null
		' SUCCESS
		result.named = name
		doc.set_farthest( node.finish )
		Return result
	End Method

	Method PEG:String()
		Return "/name{'"+name+"',"+patterns[0].PEG()+"}"
	End Method

	Method generate:String( tab:String )
		Local str:String = tab + "NAME( "
		If name; str :+ "~q"+name+"~q, "
		str :+ ".."+patterns[0].generate( tab+"~t" )
		str :+ tab+")"
		Return str
	End Method
	
EndType

' A NON-TERMINAL is a reference that is looked up at runtime
Type TNonTerminal Extends TPattern

	Field name:String
	Field grammar:TDictionary	
	Field pattern:TPattern
	
	Method New( name:String, grammar:TDictionary )
		Self.name    = name
		Self.grammar = grammar
	End Method

	' getToken is used by EXPECT / ERROR to identify the token that caused an error
	Method getToken:String()
		Return "Nonterminal '"+name+"'"
	End Method

	Method match:TParseNode( doc:TTextDocument, caller:IPatternCallback=Null, start:Int=0, depth:Int=0, traceback:String="" )
		traceback :+ "/NONTERMINAL("+name+")"
		doc.expected_token = name
'If name="LINE"; DebugStop
'If name="RULE"; DebugStop
'If name="PEXPR"; DebugStop
'DebugStop
		If Not pattern; pattern = TPattern(grammar[name])
		Local result:TParseNode
		result = pattern.match( doc, caller, start, depth+1, traceback )
		'set_farthest( start, name )	' This does not work here
		If Not result; Return Null
		' SUCCESS
		doc.set_farthest( result.finish )
		If Not result.named; result.named = name
		Return result	
	End Method
	
	Method AsString:String()
		'DebugStop
		If Not pattern; pattern = TPattern(grammar[name])
		If Not pattern; Return "TNonTerminal("+name+")==Null"
		Return TTypeId.forobject( pattern ).name()+"{"+name+"}"
	End Method
	
	Method PEG:String()
		Return name
		'Return " "+cleanse(name)
	End Method

	Method generate:String( tab:String )
		Local str:String = tab + "__( ~q"+name+"~q )"
		Return str
	End Method

EndType

' NOTPREDICATE == !e
' Success if pattern not found, Failure if pattern found
' Does not consume anything
Type TNotPredicate Extends TPattern

	Method New( pattern:TPattern )	', name:String="" )
		'Self.kind    = kind
		'Self.name     = name
		Self.patterns = [pattern]
	End Method

	Method match:TParseNode( doc:TTextDocument, caller:IPatternCallback=Null, start:Int=0, depth:Int=0, traceback:String="" )
		traceback :+ "/NOTPRED"
		Local result:TParseNode = patterns[0].match( doc, caller, start, depth+1, traceback )
		If result; Return Null	'Fail on Match found
		' Success on Match NOT found (result=null)
		result = Success( start, start ) 
		doc.set_farthest( start )
		Return result
	End Method

	Method PEG:String()
		'DebugStop
		Return "!" + Trim( patterns[0].PEG() )
	End Method
	
	Method generate:String( tab:String )
		Local str:String = tab + "NOTPRED( "
		'If name; str :+ "~q"+name+"~q, "
		str :+ ".."+patterns[0].generate( tab+"~t" )+".."
		str :+ tab+")"
		Return str
	End Method
	
EndType

' ONEORMORE == e+
' Matches One or More patterns
' Success when one or more matches. Fail when no match.
' V1.0
Type TOneOrMore Extends TPattern
	
	Method New( pattern:TPattern )	', name:String="" )
		'Self.kind    = 0
		'Self.name     = name
		Self.patterns = [pattern]
	End Method

	Method match:TParseNode( doc:TTextDocument, caller:IPatternCallback=Null, start:Int=0, depth:Int=0, traceback:String="" )
		traceback :+ "/ONEORMORE"

		Local children:TParseNode[]
		Local pos:Int = start
		Repeat
			Local result:TParseNode = patterns[0].match( doc, caller, pos, depth+1, traceback )
			If Not result
				If pos = start; Return Null
				doc.set_farthest( pos )
				Return New TParseNode( Self, 0, start, pos, children )
			End If
			' Continue matching
			children :+ [ result ]
			pos = result.finish
		Forever

	End Method

	Method PEG:String()
		Return patterns[0].PEG() + "+"
	End Method
	
	Method generate:String( tab:String )
		Local str:String = tab + "ONEORMORE( "
		'If name; str :+ "~q"+name+"~q, "
		str :+ ".."+patterns[0].generate( tab+"~t" )+".."
		str :+ tab+")"
		Return str
	End Method

EndType

' Optional - Always returns TRUE!
' OPTIONAL == e?
' V1.0
' Sometimes referred to as the ZEROORONE rule
Type TOptional Extends TPattern
	
	Method New( pattern:TPattern )	', name:String="" )
		Self.kind     = kind
		'Self.name     = name
		Self.patterns = [pattern]
	End Method

	Method match:TParseNode( doc:TTextDocument, caller:IPatternCallback=Null, start:Int=0, depth:Int=0, traceback:String="" )
		traceback :+ "/OPTIONAL"
		Local result:TParseNode = patterns[0].match( doc, caller, start, depth+1, traceback )
		If result
			doc.set_farthest( result.finish )
			Return New TParseNode( Self, kind, start, result.finish, [result] )
		Else
			doc.set_farthest( start )
			Return New TParseNode( Self, kind, start, start, [] )
		End If
	End Method

	Method PEG:String()
		Return patterns[0].PEG() + "?"
	End Method
	
	Method generate:String( tab:String )
		Local str:String = tab + "OPTIONAL( "
		'If name; str :+ "~q"+name+"~q, "
		str :+ ".."+patterns[0].generate( tab+"~t" )
		str :+ tab+")"
		Return str
	End Method

EndType

' A Range takes one or more ranges and builds a list of characters
' Note: "-" has special meaning; if you need to include it place it
' at the start or end otherwise it is treated as a range indicator.
Type TRange Extends TCharSet
	Global ascii8:String	' Lookup table
	
	Field init:String		

	Function initialise()
		If ascii8; Return
		ascii8 = " "[..256]
		For Local n:Int=0 To 255
			ascii8[n] = n
		Next
	End Function

	Method New( range:String )	', name:String="" )
		Self.init = range
		'Self.name = name
		Local p:Int = 0
		Local length:Int = Len(range)
		Local start:Int, finish:Int
		Repeat
			Select True
			Case p=length
				Exit
			Case p=0 And range[p]=45
				allowed :+ "-"
				p :+ 1
			Case p+3<=length And range[p+1]=45
				start = range[p]
				finish = range[p+2]+1
				If start<=finish; allowed :+ ascii8[ start..finish ]
				'For Local n:Int = range[p] To range[p+2]
				'	str :+ Chr( n )
				'Next
				p :+ 3
			Default
				allowed :+ range[p..p+1]
				p :+ 1
			End Select
		Forever
'Print range + " == "+ allowed
	End Method

'	Method New( ranges:String[], name:String="", identifier:String="" )
'		Self.name = name
'		'Self.expected = identifier
'		Self.init = ",".join( ranges )
'		For Local range:String = EachIn ranges
'			make( range )
'		Next
'	End Method
	
'	Method New( range:String, name:String="", identifier:String="" )
'		Self.name = name
'		'Self.expected = identifier
'		make( range )
'		init = range
'	End Method

	'Method New( start:String, finish:String, name:String="" )
	'	Self.name = name
	'	make( start+finish )
	'End Method
	
'	Method make( range:String )
'		Select range.length
'		Case 1					' Single character
'			allowed :+ range
'		Case 2					' Start and Finish characters
'			build( range[0], range[1] )
'		Case 3					' Regular expression type range using "-"
'			' Enforce "-" symbol in 3 digit ranges
'			If range[1]=45; build( range[0], range[2] )		
'		Case 4					' double dot notation
'			' Enforce ".." symbol in range
'			If range[1..3]=".."; build( range[0], range[3] )		
'		End Select
'	End Method
	
'	Method build( start:Int, finish:Int )
'		If finish <= start; Return
'		allowed :+ ascii8[ start..finish+1 ]
'	End Method

	Method PEG:String()
		Return "["+init+"]"
	End Method
	
	Method generate:String( tab:String )
		Local str:String = tab+"RANGE( ~q"+escape(init)+"~q )"
		Return str
	End Method
		
End Type

' SEQUENCE == [ e1, e2, e3 ... ]
' A Sequence is successfull if all its children are successfull.
' Fails If any one of its children fail.
Type TSequence Extends TPattern

	Method New( patterns:TPattern[] )	', name:String="" )
		'Self.kind     = KIND_SEQUENCE
		'Self.name     = name
		Self.patterns = patterns
	End Method
	
	Method match:TParseNode( doc:TTextDocument, caller:IPatternCallback=Null, start:Int=0, depth:Int=0, traceback:String="" )
		traceback :+ "/SEQUENCE"
	
		Local children:TParseNode[]
		Local pos:Int = start
		Local count:Int = 1
		For Local pattern:TPattern = EachIn patterns
			Local result:TParseNode = pattern.match( doc, caller, pos, depth+1, traceback )
			If Not result; Return Null	'result

			' Only add children that have content
			If result.finish > result.start
				'Print "=> '"+escape(doc.content[start..result.finish])+"'"
				children :+ [ result ]
				pos = result.finish
			End If
			count :+1
		Next
		doc.set_farthest( pos )
		Return New TParseNode( Self, 0, start, pos, children )
	End Method
	
	Method AsString:String()
		'DebugStop
		Local str:String
		For Local pattern:TPattern = EachIn patterns
			str :+ ","+pattern.AsString()
		Next
		Return TTypeId.forobject( Self ).name()+" ["+str[1..]+"]"
	End Method

	Method PEG:String()
'If name="BLOCKCOMMENT"; DebugStop
		Local str:String
		If Not patterns; Return "()"
		For Local pattern:TPattern = EachIn patterns
			str :+ " "+pattern.PEG()
		Next
		Return "("+str+" )"
	End Method
	
	' Write expression using parser functions
	Method generate:String( tab:String )
		Local str:String = tab + "SEQUENCE([.."
		'If name; str :+ "~q"+name+"~q, "
		'str :+ "[.."
		If patterns
			For Local pattern:TPattern = EachIn patterns
				str :+ pattern.generate( tab+"~t" ) + ", .."
			Next
		End If
		' Strip trailing ", .."
		str = str[..(str.length-4)] + " .."+tab+"])"
		Return str		
	End Method
		
EndType

' Symbols are single static ASCII characters
Type TSymbol Extends TPattern

	Field pattern:String
	Field length:Int
	
	Method New( pattern:String, name:String="" )
		'Self.name    = name
		Self.pattern = pattern
		Self.length  = Len( pattern )
	End Method

	Method New( pattern:Int, name:String="" )
		'Self.name    = name
		Self.pattern = Chr(pattern)
		Self.length  = 1
	End Method
	
	Method set( pattern:String )
		Self.pattern = pattern
		Self.length  = Len( pattern )
	End Method
	
	Method match:TParseNode( doc:TTextDocument, caller:IPatternCallback=Null, start:Int=0, depth:Int=0, traceback:String="" )
		'traceback :+ "/SYMBOL"

		'DebugStop
		If start>doc.content.length; Return Null	' EOI always fails
		Local ch:String = doc.content[start..(start+length)]
		If ( doc.content[start..(start+length)] = pattern )
			doc.set_farthest( start+length )
			Return Success( start, start+length )
		End If
		'DebugStop
		'If Not quiet
		'	'Print "## [TSymbol] '"+escape(pattern)+"' expected at "+doc.getPosition(start).toString()
		'	doc.error( "[TSymbol] Expected {identifier} at {pos}", Self, start )
		'End If
		Return Null	'Failure()
	End Method

	Method PEG:String()
		If length=1; Return escape( pattern )
		Return " "+Chr(34)+escape(pattern)+Chr(34)
	End Method

	Method generate:String( tab:String )
		Local str:String = tab+"SYMBOL( ~q"+escape(pattern)+"~q )"
		Return str
	End Method

EndType

' ZEROORMORE == e*		(Kleene Operator)
' Matches Zero or More patterns
' V1.0
Type TZeroOrMore Extends TPattern

	Method New( pattern:TPattern )	', name:String="" )
		'Self.kind    = kind
		'Self.name     = name
		Self.patterns = [pattern]
	End Method

	Method match:TParseNode( doc:TTextDocument, caller:IPatternCallback=Null, start:Int=0, depth:Int=0, traceback:String="" )
		traceback :+ "/ZEROORMORE"
'If traceback="/NONTERMINAL(PEG)/CHOICE/ZEROORMORE";DebugStop

		Local children:TParseNode[]
		Local pos:Int = start
		Local detector:Int = start

		Repeat
			Local result:TParseNode = patterns[0].match( doc, caller, pos, depth+1, traceback )
			
			' A "null" result is also considered a success otherwiseit leads to
			' an infinite loop
			If Not result 'Or ( result.start = result.finish )
				'If result.start = result.finish
				'	print( tab+"MATCH='"+text[start..pos]+"'" )
				'Else
				'	print( tab+"ZERO MATCH" )
				'End If
				doc.set_farthest( pos )
				Return Success( start, pos, children )
			End If
			children :+ [ result ]
			pos = result.finish
						
			'DebugStop
			' INFINATE LOOP DETECTION
			'Print " "[..depth]+"ZEROORMORE.detector="+detector
			If pos = detector
				'Print "## INFINITE LOOP DETECTED"
				DebugStop
				'Throw( "INFINITE LOOP" )
				'Local list:String
				If children And children.length > 0
					traceback :+ "~n"
					For Local n:Int = 0 Until children.length
						Local child:TParseNode = children[n]
						'DebugStop
						traceback :+ " "+(n+1)+": @("+child.start+".."+child.finish+"), NAME='"+child.named+"', VALUE='"+child.captured+"', {"+child.describe()+"}~n"
						' ".AsString()+"~n"
					Next
				End If
				Throw New TInfiniteLoop( "ZEROORMORE", patterns[0].AsString(), traceback )
			End If
			detector = pos
		Forever
	End Method

	Method PEG:String()
		If Not patterns Or patterns.length=0; Return "#ERR#"
		Return patterns[0].PEG() + "*"
	End Method
	
	Method generate:String( tab:String )
		Local str:String = tab + "ZEROORMORE( "
		'If name; str :+ "~q"+name+"~q, "
		str :+ ".."+patterns[0].generate( tab+"~t" )+".."
		str :+ tab+")"
		Return str
	End Method

EndType

