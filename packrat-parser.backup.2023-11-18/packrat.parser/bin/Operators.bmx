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


' ANDPREDICATE == &e 
' Matches expression but does not consume
' Returns FALSE if expression does not match
Type TAndPredicate Extends TPattern
	
	Method New( pattern:TPattern, name:String="" )
		Self.name     = name
		Self.patterns = [pattern]
	End Method

	Method match:TParseNode( doc:TTextDocument, pos:Int=0, depth:Int=0 )
		'DebugStop
		Debug( depth, doc, pos, Self, patterns[0] )

		Local result:TParseNode = patterns[0].match( doc, pos, depth+1 )
		If result
			Debug( depth, doc, pos, Self, "SUCCESS/MATCH" )
			Return success( doc, pos, pos )
		Else
			Debug( depth, doc, pos, Self, "FAIL/NO MATCH" )
			'If Not quiet; doc.error( "Expected {identifier} at {pos}", Self, pos )
			Return Null
		End If
	End Method
	
	Method AsString:String()
		'DebugStop
		Return TTypeId.forobject( Self ).name()+"{"+name+"}["+patterns[0].AsString()+"]"
	End Method

	Method PEG:String()
		Return "&" + patterns[0].PEG()
	End Method

	Method generate:String( tab:String )
		Local str:String = tab + "ANDPRED( "
		If name; str :+ "~q"+name+"~q, "
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

	Method match:TParseNode( doc:TTextDocument, start:Int=0, depth:Int=0 )
		If start < doc.content.length; Return Success( doc, start, start+1 )
		Return Null
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

' CHOICE == e1 / e2 
' Choice is successful when any one of its children is successful, fails when ALL children fail.
' V1.0
Type TChoice Extends TPattern

	Method New( patterns:TPattern[], name:String="" )
		'Self.kind     = KIND_CHOICE
		Self.name     = name
		Self.patterns = patterns
	End Method
	
	'Method New( patterns:TPattern[], kind:Int=0 )
	'	Self.kind = kind
	'	Self.patterns = patterns
	'End Method

	Method match:TParseNode( doc:TTextDocument, start:Int=0, depth:Int=0 )
		'debug( depth, Self )
		'DebugStop
		debug( depth, doc, start, Self, PEG() )
		'DebugStop
'If start > doc.content.length; DebugStop
		Local pos:Int = start
		Local count:Int = 1
		For Local pattern:TPattern = EachIn patterns
			Debug( depth, doc, pos, Self, pattern, count, Len(patterns) )
			Local result:TParseNode = pattern.match( doc, pos, depth+1 )
			If result
				'DebugStop
Rem
				' Treat as a failure if the result start & finish are equal
				' This occurs when a ZeroOrMore() (or Negate) is placed in a choice forcing it to
				' be successful in not finding something. The choice is then successful causing a loop!
End Rem
				'If result.start <> result.finish
				Debug( depth, doc, pos, Self, "SUCCESS/MATCH", count, Len(patterns) )
				Return result
				'End If
				'DebugLog( "** TChoice pattern "+count+" returned empty result" )
			EndIf
			Debug( depth, doc, pos, Self, "NO MATCH", count, Len(patterns) )
			'Print( "TChoice["+count+"/"+Len(patterns)+"] - NO MATCH" )
			count :+ 1
		Next
		Debug( depth, doc, pos, Self, "FAIL" )
		'If Not quiet; doc.error( "[TChoice] Unexpected symbol at {pos}", Self, start )
		'Print "## [TChoice] Unexpected symbol at "+doc.getposition(start).tostring()
		Return Null	'Failure()
	End Method
	
	Method AsString:String()
		'DebugStop
		Local str:String
		For Local pattern:TPattern = EachIn patterns
			str :+ ","+pattern.AsString()
		Next
		Return TTypeId.forobject( Self ).name()+"{"+name+"}["+str[1..]+"]"
	End Method

	Method PEG:String()
		Local list:String[] = New String[ patterns.length ]
		'For Local pattern:TPattern = EachIn patterns
		For Local n:Int = 0 Until patterns.length
			'str :+ " / "+pattern.PEG()
			list[n] = patterns[n].PEG()
		Next
		Local str:String = " / ".join( list )
		Return "( "+str+" )"
		'Return "( "+str[3..]+" )"
	End Method
	
'	Method save:JSON()
'		Local J:JSON = New JSON()
'		J["typeid"]  = TTypeId.forobject( Self ).name()
'		J["name"]    = name
'		J["kind"]    = kind
'		Local list:JSON = New JSON( JARRAY )
'		For Local pattern:TPattern = EachIn patterns
'			list.addlast( pattern.save() )
'		Next
'		J.set( "patterns", list )
'		Return J
'	End Method

	' Write expression using parser functions
	Method generate:String( tab:String )
		Local str:String = tab + "CHOICE("
		If name; str :+ "~q"+name+"~q, "
		str :+ "[.."
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

' GROUP == ( e )
' A Group simply returns the status of its "only" child.
Type TGroup	Extends TPattern

	Method New( pattern:TPattern, name:String="" )
		Self.name     = name
		Self.patterns = [pattern]
	End Method

	Method match:TParseNode( doc:TTextDocument, start:Int=0, depth:Int=0 )
		Debug( depth, doc, start, Self )
		Return patterns[0].match( doc, start, depth+1 )
	End Method
	
	Method AsString:String()
		Return TTypeId.forobject( Self ).name()+"{"+name+"}["+patterns[0].AsString()+"]"
	End Method

	Method PEG:String()
		Return "( "+ patterns[0].peg() + " )"
	End Method
	
	Method generate:String( tab:String )
		Local str:String = tab + "GROUP( "
		If name; str :+ "~q"+name+"~q, "
		str :+ ".."+patterns[0].generate( tab+"~t" )
		str :+ tab+")"
		Return str
	End Method
	
EndType

' NOTPREDICATE == !e
' Success if pattern not found, Failure if pattern found
' Does not consume anything
Type TNotPredicate Extends TPattern

	Method New( pattern:TPattern, name:String="" )
		'Self.kind    = kind
		Self.name     = name
		Self.patterns = [pattern]
	End Method

	Method match:TParseNode( doc:TTextDocument, start:Int=0, depth:Int=0 )
		Debug( depth, doc, start, Self, patterns[0] )
		'Print "TNegate(@"+pos+") match '" + text[pos..(pos+5)] + "' with {"+patterns[0].AsString()+"}" )
		Local result:TParseNode = patterns[0].match( doc, start, depth+1 )
		If result
			Debug( depth, doc, start, Self, "FAIL/MATCHED" )
			'Print "TNegate(@"+pos+") - MATCH FOUND, Return FAILURE" )
			Return Null	'failure()
		Else
			Debug( depth, doc, start, Self, "SUCCESS/NO MATCH" )
			'print( "TNegate(@"+pos+") - NO MATCH, Return Empty SUCCESS" )
			Return Success( doc, start, start ) 
		End If
	End Method

	Method AsString:String()
'		DebugStop
		Return TTypeId.forobject( Self ).name()+"{"+name+"}["+patterns[0].AsString()+"]"
	End Method

	Method PEG:String()
		'DebugStop
		Return "!" + Trim( patterns[0].PEG() )
	End Method
	
	Method generate:String( tab:String )
		Local str:String = tab + "NOTPRED( "
		If name; str :+ "~q"+name+"~q, "
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
	
	Method New( pattern:TPattern, name:String="" )
		'Self.kind    = 0
		Self.name     = name
		Self.patterns = [pattern]
	End Method

	Method match:TParseNode( doc:TTextDocument, start:Int=0, depth:Int=0 )
		Debug( depth, doc, start, Self, patterns[0] )
		Local children:TParseNode[]
		Local pos:Int = start
		Repeat
			Local result:TParseNode = patterns[0].match( doc, pos, depth+1 )
			If Not result
				If pos = start
					Debug( depth, doc, pos, Self, "FAIL/NO MATCH" )
					'If Not quiet; doc.error( "Expected {identifier} at {pos}", Self, start )
					Return Null
				End If
				Debug( depth, doc, pos, Self, "SUCCESS/MATCH" )
				'print([ "MATCH", "'"+text[start..pos]+"'" ])
				Return New TParseNode( Self, 0, doc, start, pos, children )
			End If
			' Continue matching
			children :+ [ result ]
			pos = result.finish
		Forever

	End Method

	Method AsString:String()
		'DebugStop
		Return TTypeId.forobject( Self ).name()+"{"+name+"}["+patterns[0].AsString()+"]"
	End Method

	Method PEG:String()
		Return patterns[0].PEG() + "+"
	End Method
	
	Method generate:String( tab:String )
		Local str:String = tab + "ONEORMORE( "
		If name; str :+ "~q"+name+"~q, "
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
	
	Method New( pattern:TPattern, name:String="" )
		Self.kind     = kind
		Self.name     = name
		Self.patterns = [pattern]
	End Method

	Method match:TParseNode( doc:TTextDocument, start:Int=0, depth:Int=0 )
		Debug( depth, doc, start, Self, patterns[0] )
		Local result:TParseNode = patterns[0].match( doc, start, depth+1 )
		If result
			Debug( depth, doc, start, Self, "MATCH='"+doc.content[start..result.finish]+"'" )
			Return New TParseNode( Self, kind, doc, start, result.finish, [result] )
		Else
			Debug( depth, doc, start, Self, "NO MATCH" )
			Return New TParseNode( Self, kind, doc, start, start, [] )
		End If
	End Method

	Method AsString:String()
		'DebugStop
		Return TTypeId.forobject( Self ).name()+"{"+name+"}["+patterns[0].AsString()+"]"
	End Method

	Method PEG:String()
		Return patterns[0].PEG() + "?"
	End Method
	
	Method generate:String( tab:String )
		Local str:String = tab + "OPTIONAL( "
		If name; str :+ "~q"+name+"~q, "
		str :+ ".."+patterns[0].generate( tab+"~t" )
		str :+ tab+")"
		Return str
	End Method

EndType
 
' SEQUENCE == [ e1, e2, e3 ... ]
' A Sequence is successfull if all its children are successfull.
' Fails If any one of its children fail.
Type TSequence Extends TPattern

	Method New( patterns:TPattern[], name:String="" )
		'Self.kind     = KIND_SEQUENCE
		Self.name     = name
		Self.patterns = patterns
	End Method
	
	Method match:TParseNode( doc:TTextDocument, start:Int=0, depth:Int=0 )
	
'If name="RULE"; DebugStop
		'Debug( depth, Self )
		debug( depth, doc, start, Self, PEG() )
		'
		Local children:TParseNode[]
		Local pos:Int = start
		Local count:Int = 1
		For Local pattern:TPattern = EachIn patterns
			Debug( depth, doc, pos, Self, pattern, count, Len(patterns ) )
			Local result:TParseNode = pattern.match( doc, pos, depth+1 )
			If Not result
				Debug( depth, doc, pos, Self, "FAIL/NO MATCH", count, Len(patterns) )
				Return Null	'result
			End If
			Debug( depth, doc, pos, Self, "MATCH="+pattern.PEG(), count, Len(patterns) )
			'Print "=> '"+escape(doc.content[start..result.finish])+"'"
			children :+ [ result ]
			pos = result.finish
			count :+1
		Next
		Debug( depth, doc, pos, Self, "SUCCESS" )
		Return New TParseNode( Self, 0, doc, start, pos, children )
	End Method
	
	Method AsString:String()
		'DebugStop
		Local str:String
		For Local pattern:TPattern = EachIn patterns
			str :+ ","+pattern.AsString()
		Next
		Return TTypeId.forobject( Self ).name()+"{"+name+"}["+str[1..]+"]"
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
	
'	Method save:JSON()
'		Local J:JSON = New JSON()
'		J["typeid"]  = TTypeId.forobject( Self ).name()
'		J["kind"]    = kind
'		J["name"]    = name
'		'J["iffail"] = iffail
'		Local list:JSON = New JSON( JARRAY )
'		For Local pattern:TPattern = EachIn patterns
'			list.addlast( pattern.save() )
'		Next
'		J.set( "patterns", list )
'		Return J
'	End Method

	' Write expression using parser functions
	Method generate:String( tab:String )
		Local str:String = tab + "SEQUENCE("
		If name; str :+ "~q"+name+"~q, "
		str :+ "[.."
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

' ZEROORMORE == e*		(Kleene Operator)
' Matches Zero or More patterns
' V1.0
Type TZeroOrMore Extends TPattern

	Method New( pattern:TPattern, name:String="" )
		'Self.kind    = kind
		Self.name     = name
		Self.patterns = [pattern]
	End Method

	Method match:TParseNode( doc:TTextDocument, start:Int=0, depth:Int=0 )
		Debug( depth, doc, start, Self, patterns[0] )
		Local children:TParseNode[]
		Local pos:Int = start
		Local detector:Int = start
		Try
			Repeat
				Local result:TParseNode = patterns[0].match( doc, pos, depth+1 )
				
				' A "null" result is also considered a success otherwiseit leads to
				' an infinite loop
				If Not result 'Or ( result.start = result.finish )
					'If result.start = result.finish
					'	print( tab+"MATCH='"+text[start..pos]+"'" )
					'Else
					'	print( tab+"ZERO MATCH" )
					'End If
					Return Success( doc, start, pos, children )
				End If
				children :+ [ result ]
				pos = result.finish
				
				'DebugStop
				' INFINATE LOOP DETECTION
				'Print " "[..depth]+"ZEROORMORE.detector="+detector
				If pos = detector
					Print "## INFINITE LOOP DETECTED"
					DebugStop
					Throw( "INFINITE LOOP" )
				End If
				detector = pos
			Forever
		Catch e:String
			Throw e
		EndTry
	End Method

	Method AsString:String()
		'DebugStop
		Return TTypeId.forobject( Self ).name()+"{"+name+"}["+patterns[0].AsString()+"]"
	End Method

	Method PEG:String()
		If Not patterns Or patterns.length=0; Return "#ERR#"
		Return patterns[0].PEG() + "*"
	End Method
	
	Method generate:String( tab:String )
		Local str:String = tab + "ZEROORMORE( "
		If name; str :+ "~q"+name+"~q, "
		str :+ ".."+patterns[0].generate( tab+"~t" )+".."
		str :+ tab+")"
		Return str
	End Method

EndType

' A Charset scans a set of allowed characters
Type TCharSet Extends TPattern
	Field allowed:String

	Method New( charset:String, name:String="" )
		Self.name    = name
		Self.allowed = charset
	End Method

	Method New( charset:String[], name:String="" )
		Self.name    = name
		Self.allowed = "".join( charset )
	End Method

	Method match:TParseNode( doc:TTextDocument, start:Int=0, depth:Int=0 )
	'Method match:TParseNode( text:String, pos:Int=0, tab:String="" )
		'Local debug:TDebug = debugline( Self, text, pos )
		If start>doc.content.length; Return Null	' EOI always fails
		Local ch:Int = doc.content[start]
		For Local c:Int = EachIn allowed
			If ch=c
				'Debug( depth, doc, Self, "MATCH '"+Chr(ch)+"' at " + doc.getposition(start).tostring() )
				'Print "## [TCharSet] matched '"+Chr(ch)+"' at "+doc.getposition(start).tostring()
				Return Success( doc, start, start+1, Null )
			End If
		Next
		'Debug( depth, doc, Self, "NO MATCH '"+Chr(ch)+"' at "+doc.getposition(start).tostring() )
		'Print "## [TCharSet] Unexpected symbol '"+Chr(ch)+"' at "+doc.getposition(start).tostring()
		'If Not quiet; doc.error( "Expected {identifier} at {pos}{show}", Self, start )
		Return Null
	End Method
	
	Method AsString:String()
'		DebugStop
		Return TTypeId.forobject( Self ).name()+"{"+name+"}["+escape(allowed)+"]"
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

	Method New( range:String, name:String="" )
		Self.init = range
		Self.name = name
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
				finish = range[p+2]
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
	
'	Method todata:String[][]()
'		Local rows:String[][] = Super.todata()
'		rows[0][7] = "~q~q"								' PATTERN
'		rows[0][8] = "~q"+escape(init)+"~q"				' INIT STRING
'		Return rows
'	End Method

	Method generate:String( tab:String )
		Local str:String = tab+"RANGE( ~q"+escape(init)+"~q )"
		Return str
	End Method
		
End Type
TRange.initialise()

Rem
Function MakeRange:String( chars:String[] )
	Local str:String
	For Local ch:String = EachIn chars
		str :+ MakeRange( ch )
	Next
	Return str
End Function

Function MakeRange:String( chars:String )
	Local begin:Int, cease:Int
	Select chars.length
	Case 2
		'DebugStop
		'Debug chars[0]
		begin = chars[0]
		cease = chars[1]
	Case 3
		'DebugStop
		'Debug chars[1]
		If chars[1]<>45 Return ""	' Enforce "-" symbol in 3 digit ranges
		begin = chars[0]
		cease = chars[2]		
	Default
		Return Null
	End Select

	'Local pattern:TPattern[] = New TPattern[ cease-begin ]
	Local pattern:String = ""
	For Local n:Int = begin To cease
		pattern :+ Chr( n )
	Next
	Return pattern
End Function
End Rem

' MATCHUNTIL == @e
' Matches until Pattern; Identical to <- (!E .)* E
' V1.0, 11 NOV 2023
Type TMatchUntil Extends TPattern

	Method New( pattern:TPattern, name:String="" )
		'Self.kind    = kind
		Self.name     = name
		Self.patterns = [pattern]
	End Method

	Method match:TParseNode( doc:TTextDocument, start:Int=0, depth:Int=0 )
'TODO: UNTESTED
DebugLog "@E / TMatchUntil.match() is UNTESTED"
DebugStop
		Debug( depth, doc, start, Self, patterns[0] )
		Local children:TParseNode[]
		Local pos:Int = start
		
		' ZERO OR MORE
		Repeat

			' MATCH NOT PATTERN (LOOKAHEAD)
			Local result:TParseNode = patterns[0].match( doc, pos, depth+1 )
			If Not result
				'Debug( depth, doc, Self, "SUCCESS/NO MATCH" )
				'print( "TNegate(@"+pos+") - NO MATCH, Return Empty SUCCESS" )
				Exit
			End If

			' MATCH ANY
			If pos < doc.content.length
				pos :+ 1
			Else
				' EOI
				Exit
			End If
		Forever
		
		' MATCH PATTERN
		Local result:TParseNode = patterns[0].match( doc, pos, depth+1 )
		If result; Return Success( doc, start, pos, [] )
		Return Null
		
	End Method

	Method PEG:String()
		If Not patterns Or patterns.length=0; Return "#ERR#"
		Return "@"+patterns[0].PEG()
	End Method

	Method generate:String( tab:String )
		Local str:String = tab + "MATCHUNTIL( "
		If name; str :+ "~q"+name+"~q, "
		str :+ ".."+patterns[0].generate( tab+"~t" )
		str :+ tab+")"
		Return str
	End Method
	
EndType

