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

	'Field pattern:TPattern
	
	Method New( pattern:TPattern, name:String="" )
		Self.name     = name
		Self.patterns = [pattern]
	End Method

	Method match:TParseNode( text:String, pos:Int=0, tab:String="" )
		Debug( tab+pos+", TAndPredicate() = "+patterns[0].AsString() )

		Local result:TParseNode = patterns[0].match( text, pos, tab+"  " )
		If result.found
			Debug( tab+"TAndPredicate.match( "+pos+" ) - MATCH" )
			Return success( text, pos, pos )
		Else
			Debug( tab+"TAndPredicate.match( "+pos+" ) - NO MATCH" )
			Return result
		End If
	End Method
	
	Method AsString:String()
		'DebugStop
		Return TTypeId.forobject( Self ).name()+"{"+name+"}["+patterns[0].AsString()+"]"
	End Method

	Method PEG:String()
		Return "&" + patterns[0].PEG()
	End Method

	Method save:JSON()
		Local J:JSON = New JSON()
		J["typeid"]  = TTypeId.forobject( Self ).name()
		J["kind"]    = kind
		J["pattern"] = patterns[0].save()
		Return J
	End Method

EndType

' Any Character (.)
' Matches any character
Type TAny Extends TPattern

	'Method New()
	'	name = "ANY"
	'End Method

	Method match:TParseNode( text:String, pos:Int=0, tab:String="" )
		Debug( tab+pos+", TAny()" )
		Debug( tab+pos+", TAny() {'"+cleanse(text[pos..pos+1])+"'==ANY}" )
		If pos < text.length
			Debug( tab+"MATCH '"+text[pos..pos+1]+"'" )
			Return Success( text, pos, pos+1 )
		End If
		Debug( tab+"NO MATCH" )
		Return Failure()
	End Method
	
	Method AsString:String()
		'DebugStop
		Return TTypeId.forobject( Self ).name()
	End Method

	Method PEG:String()
		Return "."
	End Method

	Method save:JSON()
		Local J:JSON = New JSON()
		J["typeid"]  = TTypeId.forobject( Self ).name()
		J["kind"]    = kind
		'J["name"]    = name
		'J["pattern"] = "."
		Return J
	End Method

EndType

' CHOICE == e1 / e2 
' Choice is successful when any one of its children is successful, fails when ALL children fail.
' V1.0
Type TChoice Extends TPattern

	'Field kind:Int = KIND_CHOICE
	'Field patterns:TPattern[]
	'Field iffail:String

	Method New( patterns:TPattern[], name:String="" )
		'Self.kind     = KIND_CHOICE
		Self.name     = name
		Self.patterns = patterns
	End Method
	
	'Method New( patterns:TPattern[], kind:Int=0 )
	'	Self.kind = kind
	'	Self.patterns = patterns
	'End Method

	Method match:TParseNode( text:String, start:Int=0, tab:String="" )
		'Local debug:TDebug = debugline( Self, text, start )
		Print( "TChoice() {'"+cleanse(text[start..start+15])+"...'}" )
		'DebugStop
		Local pos:Int = start
		Local count:Int = 1
		For Local pattern:TPattern = EachIn patterns
			'debug.reset([ count+"/"+Len(patterns), patterns[0].getid() ])
			'Print( "TChoice["+count+"/"+Len(patterns)+"] {'"+cleanse(text[start..start+15])+"...'} == "+patterns[0].AsString() )
			Print( "TChoice["+count+"/"+Len(patterns)+"] NAME:"+pattern.name )
			Local result:TParseNode = pattern.match( text, pos, tab+"  " )
			If result.found
				'DebugStop
				' Treat as a failure if the result start & finish are equal
				' This occurs when a ZeroOrMore() (or Negate) is placed in a choice forcing it to
				' be successful in not finding something. The choice is then successful causing a loop!
				If Not result.Empty
					'Debug( tab+"TChoice["+count+"] MATCH '"+text[pos..result.finish]+"'" )
					Print( "TChoice["+count+"/"+Len(patterns)+"] - MATCH '" + text[pos..result.finish] + "'")
					'debug.echo([ "MATCH", text[pos..result.finish] ])
					Return result
				End If
				DebugLog( "** TChoice pattern "+count+" returned empty result" )
				'debug.echo( "Empty Result" )
			EndIf
			'CONSOLE.set( "TChoice", text, patterns[0].AsString(), pos, pos, "NO MATCH" )
			'CONSOLE.wait()
			Print( "TChoice["+count+"/"+Len(patterns)+"] - NO MATCH" )
			'debug.echo( "NO MATCH" )
			'Debug( tab+"TChoice["+count+"] NO MATCH" )
			'pos = result.finish
			count :+ 1
		Next
		'CONSOLE.set( "TChoice", text, "", start, 0, "FAILED" )
		'CONSOLE.wait()
		Print( "TChoice[] - FAILED" )
		'If iffail; Debug "** "+iffail
		'debug.reset()
		'debug.echo( "FAIL" )
		Return Failure()
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
		Local str:String 
		For Local pattern:TPattern = EachIn patterns
			str :+ " / "+pattern.PEG()
		Next
		Return "( "+str[3..]+" )"
	End Method
	
	Method save:JSON()
		Local J:JSON = New JSON()
		J["typeid"]  = TTypeId.forobject( Self ).name()
		J["name"]    = name
		J["kind"]    = kind
		Local list:JSON = New JSON( JARRAY )
		For Local pattern:TPattern = EachIn patterns
			list.addlast( pattern.save() )
		Next
		J.set( "patterns", list )
		Return J
	End Method

EndType

' GROUP == [ e1, e2, e3 ... ]
' A Group simply returns the status of its child.
Type TGroup	Extends TPattern

	'Field pattern:TPattern
	'Field iffail:String				' Message to generate if match fails

	Method New( pattern:TPattern, name:String="" )
		'Self.kind     = KIND_GROUP
		Self.name     = name
		Self.patterns = [pattern]
	End Method

	Method match:TParseNode( text:String, start:Int=0, tab:String="" )
		'Local debug:TDebug = debugline( Self, text, start )
		Debug( "TGroup()" )
		Return patterns[0].match( text, start, tab+"  " )
	End Method
	
	Method AsString:String()
'		DebugStop
		Return TTypeId.forobject( Self ).name()+"{"+name+"}["+patterns[0].AsString()+"]"
	End Method


	Method PEG:String()
		Return "( "+ patterns[0].peg() + " )"
	End Method
	
	Method save:JSON()
		Local J:JSON = New JSON()
		J["typeid"]  = TTypeId.forobject( Self ).name()
		J["kind"]    = kind
		J["name"]    = name
		J["pattern"] = patterns[0].save()
		Return J
	End Method
	
EndType

' NOTPREDICATE == !e
' Success if pattern not found, Failure if pattern found
' Does not consume anything
Type TNotPredicate Extends TPattern

	'Field pattern:TPattern
	
	Method New( pattern:TPattern, name:String="" )
		'Self.kind    = kind
		Self.name     = name
		Self.patterns = [pattern]
	End Method

	Method match:TParseNode( text:String, pos:Int, tab:String="" )
		'DebugStop
		Debug( "TNegate(@"+pos+") match '" + text[pos..(pos+5)] + "' with {"+patterns[0].AsString()+"}" )
		Local result:TParseNode = patterns[0].match( text, pos, tab+"  " )
		If result.found
			Debug( "TNegate(@"+pos+") - MATCH FOUND, Return FAILURE" )
			Return failure()
		Else
			Debug( "TNegate(@"+pos+") - NO MATCH, Return Empty SUCCESS" )
			Return Success( text, pos, pos ) 
		End If
	End Method

	Method AsString:String()
'		DebugStop
		Return TTypeId.forobject( Self ).name()+"{"+name+"}["+patterns[0].AsString()+"]"
	End Method

	Method PEG:String()
		Return "!" + Trim( patterns[0].PEG() )
	End Method
	
	Method save:JSON()
		Local J:JSON = New JSON()
		J["typeid"]  = TTypeId.forobject( Self ).name()
		J["kind"]    = kind
		J["name"]    = name
		J["pattern"] = patterns[0].save()
		Return J
	End Method

EndType

' ONEORMORE == e+
' Matches One or More patterns
' Success when one or more matches. Fail when no match.
' V1.0
Type TOneOrMore Extends TPattern

	'Field pattern:TPattern
	
	Method New( pattern:TPattern, name:String="" )
		'Self.kind    = 0
		Self.name     = name
		Self.patterns = [pattern]
	End Method

	Method match:TParseNode( text:String, start:Int=0, tab:String="" )
		'Debug( tab+start+", TOneOrMore() = "+patterns[0].AsString() )
		'Local debug:TDebug = debugline( Self, text, start )
		Local children:TParseNode[]
		Local pos:Int = start
		Repeat
			Local result:TParseNode = patterns[0].match( text, pos, tab+"  " )
			If Not result.found
				If pos = start
					'debug.echo( "NO MATCH" )
					Return New TParseNode()		' FAILURE / No matches!
				End If
				'Debug( tab+"MATCH='"+text[start..pos]+"'" )
				'debug.echo([ "MATCH", "'"+text[start..pos]+"'" ])
				Return New TParseNode( Self, 0, text, start, pos, children )
			End If
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
	
	Method save:JSON()
		Local J:JSON = New JSON()
		J["typeid"]  = TTypeId.forobject( Self ).name()
		J["name"]    = name
		J["pattern"] = patterns[0].save()
		Return J
	End Method	

EndType

' Optional - Always returns TRUE!
' OPTIONAL == e?
' V1.0
Type TOptional Extends TPattern

	'Field pattern:TPattern
	
	Method New( pattern:TPattern, name:String="" )
		Self.kind     = kind
		Self.name     = name
		Self.patterns = [pattern]
	End Method

	Method match:TParseNode( text:String, start:Int=0, tab:String="" )
		Debug( tab+start+", TOptional() = "+patterns[0].AsString() )
		Local result:TParseNode = patterns[0].match( text, start, tab+"  " )
		If result.found
			Debug( tab+"MATCH='"+text[start..result.finish]+"'" )
			Return New TParseNode( Self, kind, text, start, result.finish, [result] )
		Else
			Debug( tab+"NO MATCH" )
			Return New TParseNode( Self, kind, text, start, start, [] )
		End If
	End Method

	Method AsString:String()
		'DebugStop
		Return TTypeId.forobject( Self ).name()+"{"+name+"}["+patterns[0].AsString()+"]"
	End Method

	Method PEG:String()
		Return patterns[0].PEG() + "?"
	End Method
	
	Method save:JSON()
		Local J:JSON = New JSON()
		'J["id"] = id
		J["typeid"] = TTypeId.forobject( Self ).name()
		J["kind"] = kind
		J["pattern"] = patterns[0].save()
		Return J
	End Method

EndType
 
' SEQUENCE == [ e1, e2, e3 ... ]
' A Sequence is successfull if all its children are successfull. Fails if any one of its children fail.
Type TSequence Extends TPattern

	'Field patterns:TPattern[]
	'Field iffail:String				' Message to generate if match fails

	Method New( patterns:TPattern[], name:String="" )
		'Self.kind     = KIND_SEQUENCE
		Self.name     = name
		Self.patterns = patterns
	End Method
	
	'Method New( patterns:TPattern[] )
	'	Self.kind = kind
	'	Self.patterns = patterns
	'	'Self.iffail = iffail
	'End Method

	Method match:TParseNode( text:String, start:Int=0, tab:String="" )
		'Local debug:TDebug = debugline( Self, text, start )
		Debug( "TSequence()" )
		Local children:TParseNode[]
		Local pos:Int = start
		Local count:Int = 1
		For Local pattern:TPattern = EachIn patterns
			'debug.reset([ count+"/"+Len(patterns), patterns[0].getid() ])
			'Print( "TSequence("+count+"/"+Len(patterns) + ") =" + pattern.AsString() )
			Print( "TSequence("+count+"/"+Len(patterns) + ") NAME:"+pattern.name )
			'CONSOLE.set( "TSequence", text, patterns[0].AsString(), pos )
			'CONSOLE.wait()
			'Debug( tab+"TSequence["+count+"] = "+patterns[0].AsString() )
			Local result:TParseNode = pattern.match( text, pos, tab+"  " )
			If Not result.found
				'CONSOLE.set( "TSequence", text, patterns[0].AsString(), pos,0,"Fail" )
				Debug( "TSequence("+count+"/"+Len(patterns) + ") =" + pattern.AsString() + "- NO MATCH" )
				'If iffail; Debug "** "+iffail
				
				'debug.echo( "FAIL/NO MATCH" )
				Return result
			End If
			Debug( "TSequence("+count+"/"+Len(patterns) + ") MATCH='"+text[pos..result.finish]+"' =" + pattern.getid()  )
			children :+ [ result ]
			pos = result.finish
			count :+1
			'debug.echo([ "MATCH", "'"+text[pos..result.finish]+"'" ])
		Next
		'Debug( tab+"MATCH @ ["+start+".."+pos+"] = '"+text[start..pos]+"'" )
		Debug( "TSequence() - SUCCESS" )
		'debug.reset()
		'debug.echo([ "SUCCESS", text[start..pos] ])
		Return New TParseNode( Self, 0, text, start, pos, children )
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
		Local str:String 
		For Local pattern:TPattern = EachIn patterns
			str :+ " "+pattern.PEG()
		Next
		Return "("+str+" )"
	End Method
	
	Method save:JSON()
		Local J:JSON = New JSON()
		J["typeid"]  = TTypeId.forobject( Self ).name()
		J["kind"]    = kind
		J["name"]    = name
		'J["iffail"] = iffail
		Local list:JSON = New JSON( JARRAY )
		For Local pattern:TPattern = EachIn patterns
			list.addlast( pattern.save() )
		Next
		J.set( "patterns", list )
		Return J
	End Method
	
EndType

' ZEROORMORE == e*		(Kleene Operator)
' Matches Zero or More patterns
' V1.0
Type TZeroOrMore Extends TPattern

	'Field pattern:TPattern
	
	'Method New( pattern:TPattern, kind:Int=KIND_NONE )
	Method New( pattern:TPattern, name:String="" )
		'Self.kind    = kind
		Self.name     = name
		Self.patterns = [pattern]
	End Method

	Method match:TParseNode( text:String, start:Int=0, tab:String="" )
		Debug( tab+start+", TZeroOrMore() = "+patterns[0].AsString() )
		'DebugStop
		'Debug( "TZeroOrMore.match( "+patterns[0].AsString()+", "+start+" )" )
		Local children:TParseNode[]
		Local pos:Int = start
		Repeat
			Local result:TParseNode = patterns[0].match( text, pos, tab+"  " )
			If Not result.found
				If start=pos
					Debug( tab+"MATCH='"+text[start..pos]+"'" )
				Else
					Debug( tab+"ZERO MATCH" )
				End If
				Return Success( text, start, pos, children )
			End If
			children :+ [ result ]
			pos = result.finish
		Forever

	End Method

	Method AsString:String()
		'DebugStop
		Return TTypeId.forobject( Self ).name()+"{"+name+"}["+patterns[0].AsString()+"]"
	End Method

	Method PEG:String()
		Return patterns[0].PEG() + "*"
	End Method
	
	Method save:JSON()
		Local J:JSON = New JSON()
		J["typeid"]  = TTypeId.forobject( Self ).name()
		J["kind"]    = kind
		J["name"]    = kind
		J["pattern"] = patterns[0].save()
		Return J
	End Method

EndType

' A Charset scans a set of allowed characters
Type TCharSet Extends TPattern

	Field pattern:String

	Method New( charset:String, name:String="" )
		Self.name    = name
		Self.pattern = charset
	End Method

	Method New( charset:String[], name:String="" )
		Self.name    = name
		Self.pattern = "".join( charset )
'Local debug:TCharset = Self
'DebugStop
	End Method

	Method match:TParseNode( text:String, pos:Int=0, tab:String="" )
		'Local debug:TDebug = debugline( Self, text, pos )
		Local ch:Int = text[pos]
		For Local c:Int = EachIn pattern
			If ch=c
				'debug.echo([ "MATCH", text[pos..pos+1] ])
				Return Success( text, pos, pos+1, Null )
			End If
		Next
		'debug.echo("FAIL/NO MATCH")
		'Debug "- Not matched with '"+pattern+"'"
		
		'raise( 
		Return Failure()
	End Method
	
	Method AsString:String()
'		DebugStop
		Return TTypeId.forobject( Self ).name()+"{"+name+"}["+cleanse(pattern)+"]"
	End Method

	Method PEG:String()
		Local str:String = cleanse(pattern)
		If str.length = 1; Return str
		Return "['"+str+"']"
	End Method
	
	Method save:JSON()
		Local J:JSON = New JSON()
		J["typeid"]  = TTypeId.forobject( Self ).name()
		J["kind"]    = kind
		J["name"]    = name
		J["pattern"] = pattern
		Return J
	End Method

End Type

' A Range takes one or more ranges and builds a list of characters
' These range types are supported:
'	Double-dot:				A..Z
'	Regular Expression:		A-Z
'	Shorthand:				AZ
'	Character:				A
Type TRange Extends TCharSet

	Global ascii8:String	' Lookup table

	Function initialise()
		If ascii8; Return
		ascii8 = " "[..256]
		For Local n:Int=0 To 255
			ascii8[n] = n
		Next
	End Function

	Method New( ranges:String[], name:String="" )
		Self.name = name
		For Local range:String = EachIn ranges
			make( range )
		Next
	End Method
	
	Method New( range:String, name:String="" )
		Self.name = name
		make( range )
	End Method

	Method New( start:String, finish:String, name:String="" )
		Self.name = name
		make( start+finish )
	End Method
	
	Method make( range:String )
		Select range.length
		Case 1					' Single character
			pattern :+ range
		Case 2					' Start and Finish characters
			build( range[0], range[1] )
		Case 3					' Regular expression type range using "-"
			' Enforce "-" symbol in 3 digit ranges
			If range[1]=45; build( range[0], range[2] )		
		Case 4					' double dot notation
			' Enforce ".." symbol in range
			If range[1..3]=".."; build( range[0], range[3] )		
		End Select
	End Method
	
	Method build( start:Int, finish:Int )
		If finish <= start; Return
		pattern :+ ascii8[ start..finish+1 ]
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

