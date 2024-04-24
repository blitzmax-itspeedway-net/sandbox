' Generate a Blitzmax Parser from a PEG definition
' (c) Copyright Si Dunford [Scaremonger], 2023, All rights reserved

SuperStrict

Import "packrat-parser/packrat-parser.bmx"
Import "gui/gui.bmx"

DebugStop
' Get the PEG parser
Local PEG:TPackratParser = New PEG_Parser()

' Display a list of rules
'Print "PEG RULES:"
'For Local rule:String = EachIn PEG.rules()
'	Print "->"+rule
'Next
'DebugStop

' Load the Blitzmax PEG Definition
Local BlitzmaxPEG:String = LoadString( "BlitzMaxNG.peg" )

' Use the PEG Parser to parse the BlitzMax definition
Local parseTree:TParseTree = PEG.Parse( BlitzMaxPEG )

Assert parsetree.hasError(), "Unab

' Display a list of rules
Print "BLITZMAX RULES:"
For Local rule:TParseNode = EachIn parseTree.ByName( "RULE" )
	DebugStop
	Print rule.tostring()
Next

' Create a Blitzmax Parser
'parsetree.createParser( "blitzmax_parser.bmx", 1, 0 )

' Create Visualiser
Global app:TVisualiser = New TVisualiser()
'app.setShape( config.getint("x"), config.getint("y"), config.getint("w"), config.getint("h") )

' Add a tree viewer component
Global viewer:TTreeView = New TTreeView()
app.add( "TREE", Viewer )

' Display parseTree in Treeviewer
viewer.setTree( parseTree )
app.Run()




