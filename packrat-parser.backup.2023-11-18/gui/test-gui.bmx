SuperStrict

' MAXGUI

'Import maxgui.proxygadgets
'Import brl.eventqueue
'Import brl.max2d
'Import brl.retro
'Import brl.timer
'Import brl.timerdefault

' REQUIRED FOR THE LANGUAGE SERVER
'Import brl.objectlist
'Import brl.reflection
'Import Text.RegEx

'	TYPES AND FUNCTIONS

' ADMIN GUI
Import "gui.bmx"

Type TNode Implements IViewable
	Field name:String
	Field children:TList
	Field content:String
	
	Method New( name:String, content:String = "" )
		Self.name = name
		Self.content = content
	End Method
	
	Method add:TNode( child:String, content:String = "" )
		Return add( New TNode( child, content ) )
	End Method
	
	Method add:TNode( child:TNode )
		If Not children; children = New TList()
		children.addlast( child )
		Return child
	End Method
	
	' IViewable
	Method getCaption:String()
		Return name
	End Method
	
	' IViewable
	Method getText:String[]()
		Return content.split( "~n" )
	End Method
	
	' IViewable
	Method getChildren:IViewable[]()
		Local list:IViewable[] = []
		If children
			For Local item:IViewable = EachIn children
				list :+ [ item ]
			Next
		End If
		Return list
	End Method
End Type

' Create a dummy, example tree
Local root:TNode = New TNode( "O" )
Local grandfather:TNode, father:TNode, son:TNode

Local poem:String 
	poem :+ "There was a ragged robin.~n"
	poem :+ "That flew To sunny spain.~n"
	poem :+ "And when he'd warmed his wings and feathers,~n"
	poem :+ "He turned and flew back again!~n"
	poem :+ "~n"
	poem :+ "But on his homeward journey~n"
	poem :+ "He met a mighty hawk.~n"
	poem :+ "Who plucked out all his feathers,~n"
	poem :+ "And said 'Walk you little begger! Walk'."

grandfather = root.add( "E" )
father = grandfather.add( "A" ) 
father = grandfather.add( "D" ) 
son = father.add( "B" )
son = father.add( "C" )

grandfather = root.add( "F" )

grandfather = root.add( "N" )
father = grandfather.add( "G", poem ) 
father = grandfather.add( "M" ) 
son = father.add( "H" )
son = father.add( "I" )
son = father.add( "J" )
son = father.add( "K" )
son = father.add( "L" )

AppTitle = "ADMIN TREE VIEWER"

' Create administration interface
'Local ui:Admin = New Admin( 800, 600 )

'ui.treeviewer.Create( root )
'ui.wait()

'Print "FINISHED"
DebugStop

Const CONFIG_FILE:String = "admin.config"
config.Load( CONFIG_FILE )

' Create Visualiser
Global app:TVisualiser = New TVisualiser()

Local viewer:TTreeView = New TTreeView()
app.add( "TREE", Viewer )
viewer.setTree( root )

app.Run()



