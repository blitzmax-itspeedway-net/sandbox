' EXTENSIONS
Rem 

	TLiteral:	Matches a literal String
	
End Rem



Rem Type TCapture

	'Field id:String = "Capture"
	Field kind:Int = KIND_CAPTURE
	Field pattern:TPattern
	
	Method New( pattern:TPattern, kind:Int=KIND_NONE )
		If kind>0; Self.kind = kind
		Self.pattern = pattern
	End Method
	
	Method match:TParseNode( text:String, pos:Int=0, tab:String="" )
		Debug( tab+pos+", TCapture() = "+pattern.AsString()+" {'"+cleanse(text[pos..pos+15])+"...'" )
		Local result:TParseNode = pattern.match( text, pos, tab+"  " )
		If result.found
			Local match:TParseNode = New TParseNode( Self, kind, text, result.start, result.finish, [result] )
			match.captured = text[pos..result.finish]
			Debug( tab+"MATCH" )
			Return match
		End If
		Debug( tab+"NO MATCH" )
		Return result
	End Method

	Method AsString:String()
		DebugStop
		Return pattern.AsString()
	End Method

	Method getid:String(); Return TTypeId.forobject( Self ).name(); End Method
	'Method SetId( id:String ); Self.id = id; End Method

	Method save:JSON()
		Local J:JSON = New JSON()
		'J["id"] = id
		J["typeid"] = TTypeId.forobject( Self ).name()
		J["kind"] = kind
		J["pattern"] = pattern.save()
		Return J
	End Method

EndType
EndRem

' Matches a string of characters agains an allowed set
' V1.0
Rem Type TCharset

	'Field id:String = "Char"
	'Field kind:Int
	Field pattern:String
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
	'Field pattern:TPattern
	
	Method New( pattern:TPattern, errortext:String )
		Self.kind      = KIND_ERROR
		Self.errortext = errortext
		Self.patterns  = [pattern]
		Self.name      = "ERROR"
	End Method

	Method match:TParseNode( text:String, pos:Int=0, tab:String="" )
		'DebugStop
		Print( "TError() = "+patterns[0].AsString() )
		Local result:TParseNode = patterns[0].match( text, pos, tab+"  " )
		Local match:TParseNode 
		If Not result.found
			Print "An error matcher must return a success ("+errortext+") "+patterns[0].Peg()
			End
		EndIf
		'Debug( tab+"MATCH '"+text[pos..result.finish]+"', "+errortext )
		match = New TParseNode( Self, kind, "", pos, result.finish, [result] )
		match.name = "ERROR"
		match.captured = errortext
'DebugStop
		Return match
	End Method
		
	Method AsString:String()
		'DebugStop
		Return TTypeId.forobject( Self ).name()+"{"+name+"}["+patterns[0].AsString()+"]"
	End Method

	Method PEG:String()
		Return "ERROR_("+patterns[0].PEG() + "'"+name+"')"
	End Method
		
	Method save:JSON()
		Local J:JSON   = New JSON()
		J["typeid"]    = TTypeId.forobject( Self ).name()
		J["kind"]      = kind
		J["name"]      = kind
		J["errortext"] = errortext
		J["pattern"]   = patterns[0].save()
		Return J
	End Method	
	
EndType

' A TExpect is a pattern match that returns an error if not matched
Rem Type TExpect

	Field errortext:String

	Field pattern:TPattern
	
	'Field id:String
	Field kind:Int = KIND_ERROR
	
	Method New( pattern:TPattern, errortext:String="Unexpected symbol" )
		Self.errortext = errortext
		Self.pattern = pattern 
	End Method

	Method match:TParseNode( text:String, pos:Int=0, tab:String="" )
		Debug( tab+pos+", TExpect() = "+pattern.AsString() )
	'DebugStop
		Local result:TParseNode = pattern.match( text, pos, tab+"  " )
		Local match:TParseNode 
		If result.found
			Debug( tab+"MATCH '"+text[pos..result.finish]+"'" )
			match = New TParseNode( Self, KIND_NONE, "", pos, result.finish, [result] )
		Else
			' An error is always successful and returns a match error
			Debug( tab+"NO MATCH: "+errortext+" at "+pos )
			match = New TParseNode( Self, kind, "", pos, pos, [] )
		End If
		' Save the error and return
		match.name = "ERROR"
		match.captured = errortext
'DebugStop
		Return match
	End Method
		
	Method AsString:String()
		Return "{"+errortext+"}"
	End Method
	
	Method getid:String(); Return TTypeId.forobject( Self ).name(); End Method	
	'Method SetId( id:String ); Self.id = id; End Method	

	Method save:JSON()
		Local J:JSON = New JSON()
		'J["id"] = id
		J["typeid"] = TTypeId.forobject( Self ).name()
		J["kind"] = kind
		J["errortext"] = errortext
		J["pattern"] = pattern.save()
		Return J
	End Method	
	
EndType
EndRem

' Literals are keywords that are static
Type TLiteral Extends TPattern

	Field casesensitive:Int = True
	Field pattern:String
	'Field iffail:String				' Message to generate if match fails
	
	'Method New( pattern:String, kind:Int=KIND_NONE, iffail:String="" )
	Method New( pattern:String, name:String="", casesensitive:Int=True )
		'If kind>0; Self.kind = kind
		Self.name          = name	'cleanse( pattern )
		Self.pattern       = pattern
		Self.casesensitive = casesensitive
		'Self.iffail = iffail
	End Method
	
	Method match:TParseNode( text:String, pos:Int=0, tab:String="" )
	'DebugStop
		'Local debug:TDebug = debugline( Self, text, pos )
		'debug.reset( pattern )
		'Debug( tab+pos+", TLiteral() {'"+cleanse(text[pos..pos+Len(pattern)])+"' == '"+cleanse(pattern)+"' } " )
		If ( casesensitive And text[pos..].startswith( pattern ) )..
		Or ( Not casesensitive And Upper(text[pos..pos+Len(pattern)])=Upper(pattern) )
			'Debug( tab+"MATCH='"+text[pos..pos+Len(pattern)]+"'" )
			'debug.echo([ "MATCH", text[pos..pos+Len(pattern)] ])
			Return Success( text, pos, pos+Len(pattern) )
		End If
		'Debug( tab+"NO MATCH" )
		'debug.echo([ "FAIL/NO MATCH", text[pos..pos+Len(pattern)]+"<>"+pattern ])
		'If iffail; Debug "** "+iffail
		Return Failure()
	End Method

	Method AsString:String()
		'DebugStop
		Return TTypeId.forobject( Self ).name()+"{"+name+"}["+pattern+"]"
	End Method

	Method PEG:String()
		Return " "+Chr(34)+cleanse(pattern)+Chr(34)
	End Method
	
	Method save:JSON()
		Local J:JSON       = New JSON()
		J["typeid"]        = TTypeId.forobject( Self ).name()
		J["kind"]          = kind
		J["name"]          = name
		J["casesensitive"] = casesensitive
		J["pattern"]       = pattern
		Return J
	End Method	
	
EndType

Rem Type TNamed

	'Field id:String = "Named"
	Field kind:Int = KIND_NAMED
	Field pattern:TPattern
	Field name:String
	
	Method New( pattern:TPattern, name:String, kind:Int=KIND_NONE )
		If kind>0; Self.kind = kind
		Self.pattern = pattern
		Self.name = name
	End Method
	
	Method match:TParseNode( text:String, pos:Int=0, tab:String="" )
		Debug( tab+pos+", TNamed( "+name+" ) = "+pattern.AsString() )
		Local result:TParseNode = pattern.match( text, pos, tab+"  " )
		If result.found
			Debug( tab+"MATCH="+text[pos..result.finish]+"'" )
			Local match:TParseNode = New TParseNode( Self, kind, text, pos, result.finish, [result] )
			match.name = name
			Return match
		End If
		Debug( tab+"NO MATCH" )
		Return result
	End Method

	Method AsString:String()
		'DebugStop
		Return "TNamed["+name+","+getid()+"]="+pattern.AsString()+","
	End Method

	Method getid:String(); Return TTypeId.forobject( Self ).name(); End Method
	'Method SetId( id:String ); Self.id = id; End Method

	Method save:JSON()
		Local J:JSON = New JSON()
		'J["id"] = id
		J["typeid"] = TTypeId.forobject( Self ).name()
		J["kind"] = kind
		J["name"] = name
		J["pattern"] = pattern.save()
		Return J
	End Method

EndType
EndRem

' A NON-TERMINAL is a reference that is looked up at runtime
Type TNonTerminal Extends TPattern

	Field grammar:TDictionary
	Field name:String
	
	Field pattern:TPattern
	
	Method New( name:String, grammar:TDictionary )
		Self.name    = name
		Self.grammar = grammar
	End Method

	Method match:TParseNode( text:String, pos:Int=0, tab:String="" )
		If Not pattern; pattern = TPattern(grammar[name])
		Debug( "TNonTerminal("+name+") == "+pattern.AsString() )
		Return pattern.match( text, pos, tab+"  " )
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
		Return " "+cleanse(name)
	End Method

	Method save:JSON()
		Local J:JSON = New JSON()
		'J["id"] = id
		J["typeid"] = TTypeId.forobject( Self ).name()
		J["name"] = name
		If pattern; J["pattern"] = pattern.save()
		Return J
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
	
	Method match:TParseNode( text:String, pos:Int=0, tab:String="" )
		'DebugStop
		Local ch:String = text[pos..(pos+length)]
		If ( text[pos..(pos+length)] = pattern )
			Return Success( text, pos, pos+length )
		End If
		Return Failure()
	End Method

	Method AsString:String()
		'DebugStop
		Return TTypeId.forobject( Self ).name()+"{"+name+"}["+pattern+"]"
	End Method

	Method PEG:String()
		If length=1; Return " %d"+Asc(pattern)
		Return " "+Chr(34)+cleanse(pattern)+Chr(34)
	End Method
	
	Method save:JSON()
		Local J:JSON       = New JSON()
		J["typeid"]        = TTypeId.forobject( Self ).name()
		J["kind"]          = kind
		J["name"]          = name
		J["pattern"]       = pattern
		Return J
	End Method	
	
EndType




