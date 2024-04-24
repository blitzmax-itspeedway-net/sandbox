

' MATCHUNTIL == @e
' Matches until Pattern; Identical to <- (!E .)* E
' V1.0, 11 NOV 2023
Type TMatchUntil Extends TPattern

	Method New( pattern:TPattern )	', name:String="" )
		'Self.kind    = kind
		'Self.name     = name
		Self.patterns = [pattern]
	End Method

	Method match:TParseNode( doc:TTextDocument, caller:IPatternCallback=Null, start:Int=0, depth:Int=0, traceback:String="" )
'TODO: UNTESTED
DebugLog "@E / TMatchUntil.match() is UNTESTED"
DebugStop
		traceback :+ "/MATCHUNTIL"
		
		'Debug( depth, doc, start, Self, patterns[0] )
		Local children:TParseNode[]
		Local pos:Int = start
		
		' ZERO OR MORE
		Repeat
			' MATCH NOT PATTERN (LOOKAHEAD)
			Local result:TParseNode = patterns[0].match( doc, caller, pos, depth+1, traceback )
			If Not result
				'Debug( depth, doc, Self, "SUCCESS/NO MATCH" )
				'print( "TNegate(@"+pos+") - NO MATCH, Return Empty SUCCESS" )
				Exit
			End If

			' MATCH ANY
			If pos < doc.content.length
				pos :+ 1
			Else	' EOI
				Exit
			End If
		Forever
		
		' MATCH PATTERN
		Local result:TParseNode = patterns[0].match( doc, caller, pos, depth+1 )
		If Not result; Return Null
		doc.set_farthest( pos )
		Return Success( start, pos, [] )
		
	End Method

	Method PEG:String()
		If Not patterns Or patterns.length=0; Return "#ERR#"
		Return "@"+patterns[0].PEG()
	End Method

	Method generate:String( tab:String )
		Local str:String = tab + "MATCHUNTIL( "
		'If name; str :+ "~q"+name+"~q, "
		str :+ ".."+patterns[0].generate( tab+"~t" )
		str :+ tab+")"
		Return str
	End Method
	
EndType







