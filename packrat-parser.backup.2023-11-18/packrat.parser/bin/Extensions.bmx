' EXTENSIONS
Rem 

	TLiteral:	Matches a literal String
	
End Rem


Type TCapture Extends TPattern

	Method New( pattern:TPattern )
'		If kind>0; Self.kind = kind
		Self.patterns = [pattern]
	End Method
	
	Method match:TParseNode( doc:TTextDocument, pos:Int=0, depth:Int=0 )
		Debug( depth, doc, pos, Self, patterns[0] )
		Local result:TParseNode = patterns[0].match( doc, pos, depth+1 )
	
		If Not result; Return Null
		
		'Local match:TParseNode = Success( doc, start, pos, children )
		Local match:TParseNode = Success( doc, pos, result.finish, Null )	' Do we need the children?
		match.captured = doc.content[ pos..result.finish ]
		Return match
	
'		Debug( tab+pos+", TCapture() = "+pattern.AsString()+" {'"+cleanse(text[pos..pos+15])+"...'" )
'		Local result:TParseNode = pattern.match( text, pos, tab+"  " )
'		If result.found
'			Local match:TParseNode = New TParseNode( Self, kind, text, result.start, result.finish, [result] )
'			match.captured = text[pos..result.finish]
'			Debug( tab+"MATCH" )
'			Return match
'		End If
'		Debug( tab+"NO MATCH" )
'		Return result
	End Method

	Method PEG:String()
		Return "/capture "+patterns[0].PEG()
	End Method

	Method generate:String( tab:String )
		Local str:String = tab + "CAPTURE( "
		If name; str :+ "~q"+name+"~q, "
		str :+ ".."+patterns[0].generate( tab+"~t" )
		str :+ tab+")"
		Return str
	End Method
	
EndType

' Matches a string of characters agains an allowed set
' V1.0
Rem Type TCharset

	'Field id:String = "Char"
	'Field kind:Int
	'Field iffail:String				' Message to generate if match fails
	
	Method New( pattern:String )	', kind:Int=KIND_NONE, iffail:String="" )
		'If kind>0; Self.kind = kind
		Self.pattern = pattern
		'Self.iffail = iffail
	End Method
	
	Method match:TParseNode( text:String, pos:Int=0, tab:String="" )
		Local debug:TDebug = debugline( Self, text, pos )
		Local ch:Int = text[pos]
		For Local c:Int = EachIn pattern
			If ch=c
				debug.echo([ "MATCH", text[pos..pos+1] ])
				'Debug "- Matched '"+Chr(c)+"' in '"+pattern+"'"
				Return New TParseNode( Self, 0, text, pos, pos+1, Null )
			End If
		Next
		debug.echo("FAIL/NO MATCH")
		'Debug "- Not matched with '"+pattern+"'"
		Return New TParseNode()	' FAILURE
	End Method
	
	Method AsString:String()
		'DebugStop
		Return "'"+Cleanse(pattern)+"'"
	End Method

	Method getid:String(); Return TTypeId.forobject( Self ).name()+" {'"+pattern+"'}"; End Method
	'Method setid( id:String ); Self.id = id; End Method

	Method save:JSON()
		Local J:JSON = New JSON()
		'J["id"] = id
		J["typeid"] = TTypeId.forobject( Self ).name()
		'J["kind"] = kind
		'J["name"] = name
		J["pattern"] = pattern
		'J["iffail"] = iffail
		Return J
	End Method
		
EndType
EndRem

' A TError is a runtime error that can be inserted as a pattern
Type TError Extends TPattern

	Field errortext:String
	
	Method New( pattern:TPattern, errortext:String )
		Self.kind      = KIND_ERROR
		Self.errortext = errortext
		Self.patterns  = [pattern]
		Self.name      = "ERROR"
	End Method

	Method match:TParseNode( doc:TTextDocument, start:Int=0, depth:Int=0 )
	'Method match:TParseNode( text:String, pos:Int=0, tab:String="" )
		'DebugStop
		'Print( "TError() <- "+patterns[0].PEG() )
		Local result:TParseNode = patterns[0].match( doc, start, depth+1 )
		Local match:TParseNode 
		If Not result
			doc.error( "Error matcher returned NULL ("+errortext+") at {pos}", Self, start )
			'Print "An error matcher must return a success ("+errortext+") "+patterns[0].Peg()
			Return Null
		EndIf
		'Debug( tab+"MATCH '"+text[pos..result.finish]+"', "+errortext )
		doc.error( errortext+" at {pos}", Self, start )
		match = New TParseNode( Self, kind, doc, start, result.finish, [result] )
		match.name = "ERROR"
		match.captured = errortext
'DebugStop
		Return match
	End Method
		
	'Method AsString:String()
	'	'DebugStop
	'	Return TTypeId.forobject( Self ).name()+"{"+name+"}["+patterns[0].AsString()+"]"
	'End Method

	Method PEG:String()
		Return "#error{'"+errortext+"',"+patterns[0].PEG() + "}"
	End Method

	Method generate:String( tab:String )
		Local str:String = tab + "ERROR( .."
		str :+ patterns[0].generate( tab+"~t" )+", .."
		str :+ tab+"~t~q"+errortext+"~q .."
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
	Method New( pattern:String, name:String="", casesensitive:Int=false )
		'If kind>0; Self.kind = kind
		Self.name          = name	'cleanse( pattern )
		Self.pattern       = pattern
		Self.casesensitive = casesensitive
		'Self.iffail = iffail
	End Method
	
	Method match:TParseNode( doc:TTextDocument, start:Int=0, depth:Int=0 )
	'Method match:TParseNode( text:String, pos:Int=0, tab:String="" )
	'DebugStop
		If start+Len(pattern) > doc.content.length; Return Null	' EOI always fails
		'Local debug:TDebug = debugline( Self, text, pos )
		'debug.reset( pattern )
		'Debug( tab+pos+", TLiteral() {'"+cleanse(text[pos..pos+Len(pattern)])+"' == '"+cleanse(pattern)+"' } " )
		If ( casesensitive And doc.content[start..].startswith( pattern ) )..
		Or ( Not casesensitive And Upper(doc.content[start..start+Len(pattern)])=Upper(pattern) )
			'Debug( tab+"MATCH='"+text[pos..pos+Len(pattern)]+"'" )
			'debug.echo([ "MATCH", text[pos..pos+Len(pattern)] ])
			'Print "<- [TLiteral] Matched '"+pattern+"' at "+doc.getPosition(start).toString()
			Return Success( doc, start, start+Len(pattern) )
		End If
		'Debug( tab+"NO MATCH" )
		'debug.echo([ "FAIL/NO MATCH", text[pos..pos+Len(pattern)]+"<>"+pattern ])
		'If iffail; Debug "** "+iffail
		'Print "## [TLiteral] '"+pattern+"' expected at "+doc.getPosition(start).toString()
		'If Not quiet; doc.error( "Expected {identifier} at {pos}", Self, start )
		'Return Failure()
		Return Null
	End Method

	Method AsString:String()
		'DebugStop
		Return TTypeId.forobject( Self ).name()+"{"+name+"}["+pattern+"]"
	End Method

	Method PEG:String()
		Return Chr(34) + escape(pattern) + Chr(34)
	End Method

	Method generate:String( tab:String )
		Local str:String = tab+"LITERAL( "
		If name; str :+ "~q"+name+"~q, "
		str :+ "~q"+escape(pattern)+"~q"
		If casesensitive; str :+ ", True"
		str :+ " )"
		Return str
	End Method
	
EndType

' A NON-TERMINAL is a reference that is looked up at runtime
Type TNonTerminal Extends TPattern

	Field grammar:TDictionary	
	Field pattern:TPattern
	
	Method New( name:String, grammar:TDictionary )
		Self.name    = name
		Self.grammar = grammar
	End Method

	Method match:TParseNode( doc:TTextDocument, pos:Int=0, depth:Int=0 )
		'DebugStop
		If Not pattern; pattern = TPattern(grammar[name])
		Debug( depth, doc, pos, Self, pattern ) ')name, "TNonTerminal("+name+") == "+pattern.AsString() )
		Local result:TParseNode
		Try
			result = pattern.match( doc, pos, depth+1 )
		Catch e:String
			Print e+" in rule "+name
			DebugStop
		EndTry
		'
		If result
'			DebugStop
			Debug( depth, doc, pos, Self, "SUCCESS='"+doc.content[result.start..result.finish]+"'" )
		Else
			Debug( depth, doc, pos, Self, "NO MATCH" )
		End If
		Return result
	End Method
	
	Method AsString:String()
		'DebugStop
		If Not pattern; pattern = TPattern(grammar[name])
		If Not pattern; Return "TPlaceholder("+name+")==Null"
		Return TTypeId.forobject( pattern ).name()+"{"+name+"}"
	End Method
	
	Method getid:String()
		If Not pattern; pattern = TPattern(grammar[name])
		Return pattern.getid()
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

' Symbols are single static ASCII characters
Type TSymbol Extends TPattern

	Field pattern:String
	Field length:Int
	
	Method New( pattern:String, name:String="" )
		Self.name    = name
		Self.pattern = pattern
		Self.length  = Len( pattern )
	End Method

	Method New( pattern:Int, name:String="" )
		Self.name    = name
		Self.pattern = Chr(pattern)
		Self.length  = 1
	End Method
	
	Method set( pattern:String )
		Self.pattern = pattern
		Self.length  = Len( pattern )
	End Method
	
	Method match:TParseNode( doc:TTextDocument, start:Int=0, depth:Int=0 )
	'Method match:TParseNode( text:String, pos:Int=0, tab:String="" )
		'DebugStop
		If start>doc.content.length; Return Null	' EOI always fails
		Local ch:String = doc.content[start..(start+length)]
		If ( doc.content[start..(start+length)] = pattern )
			Return Success( doc, start, start+length )
		End If
		'DebugStop
		'If Not quiet
		'	'Print "## [TSymbol] '"+escape(pattern)+"' expected at "+doc.getPosition(start).toString()
		'	doc.error( "[TSymbol] Expected {identifier} at {pos}", Self, start )
		'End If
		Return Null	'Failure()
	End Method

	Method AsString:String()
		'DebugStop
		Return TTypeId.forobject( Self ).name()+"{"+name+"}["+pattern+"]"
	End Method

	Method PEG:String()
		If length=1; Return escape( pattern )
		Return " "+Chr(34)+escape(pattern)+Chr(34)
	End Method

Rem
	Method save:JSON()
		Local J:JSON       = Super.save()
'		J["typeid"]        = TTypeId.forobject( Self ).name()
'		J["kind"]          = kind
'		J["name"]          = name
		J["pattern"]       = pattern
		Return J
	End Method	
EndRem	

'	Method todata:String[][]()
'		Local rows:String[][] = Super.todata()
'		rows[0][7] = "~q"+escape(pattern)+"~q"			' PATTERN
'		Return rows
'	End Method

	Method generate:String( tab:String )
		Local str:String = tab+"SYMBOL( ~q"+escape(pattern)+"~q )"
		Return str
	End Method

EndType

