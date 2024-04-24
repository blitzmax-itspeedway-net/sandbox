

' Extracts Grammar from a Parsetree
Function ExtractGrammar:TGrammar( tree:TParseTree )
	DebugStop
	
	For Local rule:TParseNode = EachIn tree.byName("RULE")
		DebugStop
	Next

End Function
