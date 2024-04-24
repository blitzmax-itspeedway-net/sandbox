'	SELFTEST
'	(c) Copyright Si Dunford [Scaremonger], 2023-date, All rights reserved.
'	VERSION 1.0
'
'	Self-test the Packrat Parser and generator
'	NOTE: Does not use all operators
'

'Import bmx.packrat
Import "../../bmx.packrat/packrat.bmx"

Type TParseTree2PEG Implements IVisitor

	Method New( parseTree:TParseTree )
	
		Local root:TParsenode = parsetree.getroot()
	
		For Local node:TParsenode = EachIn root.byname("RULE")
			Print "RULE: "+node.name
			
			DebugStop
		Next
	
		' Visit the parsetree
		'parsetree.accept( Self )
		
		For Local node:TParsenode = EachIn root.preorder()
			Local name:String = node.name
			If Not name; name = "<empty>"
			Print "# "+name+":"+TTypeId.forobject( node ).name() 
			'DebugStop
			node.accept( Self )
		Next
		
	End Method

	Function ParseTree2PEG( parseTree:TParseTree )
		Local PEG:String

		For Local rule:TParseNode = EachIn parseTree.ByName( "RULE" )
			DebugStop
			Print rule.tostring()
			DebugStop
		Next

	End Function

	'Method visit:Int( sequence:TParsenode )
	'	Print "TParsenode"
	'	DebugStop
	'End Method

	'Method visit:Int( sequence:TSequence )
	'	Print "SEQUENCE"
	'	DebugStop
	'End Method

	Method visit:Int( visitable:IVisitable )
		'DebugStop
		
		Local node:TParseNode = TParseNode( visitable )
		If Not node
			DebugLog "Invalid visitable detected"
			Return False
		End If
		
		Local name:String = node.name
		If Not name; name = "<empty>"
		Print "VISITING:  "+name+":"+TTypeId.forObject(node).name()
		Print "  ASSTRING:"+node.AsString().Replace("~n","")
		'Print "  TOPEG:   "+node.toPeg()
		
		'DebugStop
		'If children

	End Method


	Method getPEG:String()
	End Method
	
End Type

' ############################################################

DebugStop

' Load the (Manual) PEG Parser
Local parser1:TPackrat_Parser = New TPackrat_PEG_Parser()
Local grammar1:TGrammar = parser1.grammar

' Generate PEG from grammar
Local peg1:String = grammar1.toPEG()
Print "MANUAL PEG DEFINTION:"
Print "---------------------"
Print peg1
DebugStop

' Use the Manual PEG Parser to parse the generated definition
Local tree1:TParseTree = parser1.Parse( peg1 )

' ############################################################

Print "~n##"
Print "## SELF TEST 1"
Print "## There should be no Parse Errors!"
Print "##~n"

Local count:Int
For Local error:TParseNode = EachIn tree1.ByName( "ERROR" )
	'DebugStop
	Local position:TPosition = parser1.getPosition( error.start )
	Print error.captured + " at " + position.format() + " / "+ error.start + ".." + error.finish
	'Print "  LINE:"+position.line+", COLUMN:"+position.col
	count :+ 1
Next

If count>0
	Print "RESULT: Failed - Parse tree contains "+count+ " errors."
	End
End If
Print "RESULT: Success"

' ############################################################

Print "~n##"
Print "## SELF TEST 2"
Print "## Generated PEG should be the same as Original"
Print "##~n"

' Generate PEG from the Parse Tree
DebugStop
Local selftest2:TParseTree2PEG = New TParseTree2PEG( tree1 )
Local peg2:String = selftest2.getPeg()

If peg1 <> peg2
	Print "RESULT: Failed - Generated PEG is different than original"
	End
End If
Print "RESULT: Success"

DebugStop

' ############################################################

Print "~n##"
Print "## SELF TEST 3"
Print "## Match Manual and Generated grammar Trees"
Print "##~n"

' Build

DebugStop
Local tree2:TParseTree = parser1.Parse( peg2 )
Local grammar2:TGrammar = parser1.grammar

DebugStop
If Not grammar1.count() <> grammar2.count()
	Print "RESULT: Failed - Rule count mismatch"
	End
End If
Print "RESULT: Success"

'Local rules1:String[], rules2:String[]
'For Local key:String = EachIn grammar1.keys()
'	rules1 :+ [key]
'Next
'For Local key:String = EachIn grammar2.keys()
'	rules2 :+ [key]
'Next

'If Not rules1.length <> rules2.length
'	Print "FAIL: Rule count mismatch"
'	End
'End If

'Print "/".join(rules1)

DebugStop

For Local key:String = EachIn grammar1.keys()
	
	If Not grammar2.contains( key )
		Print "RESULT: Failed - Rule '"+key+"' mismatch"
		End
	End If
	
	' Walk two trees at once
	If Not walk2trees( TPattern(grammar1[key]), TPattern(grammar2[key]) )
		Print "FAIL: Grammar trees do not match"
		End
	End If
Next

Function walk2trees:Int( t1:TPattern, t2:TPattern )

	' Check patterns are the same
	If TTypeId.forobject( t1 ).Name() <> TTypeId.forobject( t2 ).Name(); Return die( t1, "Type name mismatch" )
	
	If Not( t1.patterns And t2.patterns And t1.patterns.length = t2.patterns.length )
		Return die( t1, "Children mismatch" )
	End If
	
	If t1.patterns And t2.patterns And t1.patterns.length > 0 And t2.patterns.length >0
		Return True
	End If
	
	Local count:Int = 0
	Repeat
		If Not walk2trees( t1.patterns[count], t2.patterns[count] ); Return False
		count :+ 1
	Until count > t1.patterns.length
	
	Return True

	Function die:Int( t:TPattern, message:String )
		Print "FAIL: "+ message
		Print "      "+ t.tostring() 
		Return False
	End Function
	
End Function

