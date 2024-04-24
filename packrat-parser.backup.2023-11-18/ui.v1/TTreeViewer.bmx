
' Based on dozens of resources but primarily on these three:
' https://www.drdobbs.com/positioning-nodes-for-general-trees/184402320?pgno=4
' https://rachel53461.wordpress.com/2014/04/20/algorithm-for-drawing-trees/
' https://github.com/d3/d3-hierarchy/blob/main/src/tree.js


' ISSUES
' Node F is not centralising between siblings E & N (Not coded- See example)
' Node O is not centralising between children E & N (Not coded- See example)

Interface IViewable
	Method getChildren:IViewable[]()
	Method getText:String[]()
	Method getCaption:String()
End Interface

Type TGNode
	Field caption:String
	Field source:IViewable		'_	' Original source object we are projecting
	Field parent:TGNode
	Field children:TGNode[] = []
	
	'Field widget:SWidget
	
	' Tree position
	Field x:Float, y:Float, width:Float, height:Float
	
	' Tree Layout
	Field defaultAncestor:TGNode	'A
	Field ancestor:TGNode			'a
	Field change:Float			'c
	Field depth:Float
	Field modifier:Float		'm
	Field prelim:Float			'z			' Preliminary X Position
	Field shift:Float			's
	Field thread:TGNode	't
	Field sibling:Int = 0		'i The position in parents children collection
	
	Method New( source:IViewable, depth:Int=0 )
		Self.source = source
		If source; Self.caption = source.getCaption()
		'Self.width = 2
		'Self.width = Min( 20, TextWidth( caption ) + TTreeViewer.HPADDING*2 )
		'Self.height = Min( 20, TextHeight( caption ) + TTreeViewer.VPADDING*2 )
		Self.sibling = 0
		Self.depth = depth
		'Self.y = 2 * depth * Self.height + TTreeViewer.SUBTREESEP
	End Method
	
	Method add( child:TGNode, sibling:Int )
'DebugStop
		children :+ [ child ]
		child.parent  = Self
		child.sibling = sibling		' Set the child number
'		child.depth   = depth + 1
'DebugStop
	End Method

	Method eachAfter:TGNode( callback( node:TGNode, index:Int, parent:TGNode ) )
		Local todo:TList = New TList()
		'Local list:TList = New TList()
		Local node:TGNode
		Local index:Int = -1
		' Add root node
		todo.addlast( Self )
		' Build list of nodes		
		While Not todo.isEmpty()
			node = TGNode( todo.removeFirst() )
			'list.addlast( node )
			For Local i:Int = 0 Until node.children.length
				todo.addlast( node.children[i] )
			Next
			index :+ 1
			callback( node, index, Self )
		Wend
		' Callback for each node
		'index = -1
		'For Local child:TGNode = EachIn list
		'	index :+ 1
	'		callback( Null, child, index, Self )
	'	Next
		
		Return Self
	End Method
	
	Method eachBefore:TGNode( callback( node:TGNode, index:Int, parent:TGNode ) )
		Local todo:TList = New TList()
		Local node:TGNode
		Local index:Int = -1
		' Add root node
		todo.addlast( Self )
		While Not todo.isEmpty()
			node = TGNode( todo.removeFirst() )
			index :+ 1
			callback( node, index, Self )
			For Local i:Int = 0 Until node.children.length
				todo.addlast( node.children[i] )
			Next
		Wend
		Return Self
	End Method

	Method inOrder:TInOrderEnumerator()
		Return New TInOrderEnumerator( Self )
	End Method

'TODO:
	'https://www.geeksforgeeks.org/tree-traversals-inorder-preorder-and-postorder/
	Method preorder:TPreOrderEnumerator()
		Return New TPreOrderEnumerator( Self )
	End Method

'TODO:
	Method postorder:TPostOrderEnumerator()
		Return New TPostOrderEnumerator( Self )
	End Method
		
	Method draw( ofsx:Float, ofsY:Float, callback( node:TGNode ) )
		'If Not text Or text = []; text = ["?"]
		
		' Draw box for the text
		'Local th:Int = text.length * TextHeight( "hy" )
		'Local tw:Int = 0
		'For Local t:String = EachIn text
		'	tw = Max( tw, TextWidth( text[t] ) )
		'Next
		
		' Mouse inside
		Local mouseinside:Int
		Local ox:Float, oy:Float
		GetOrigin( ox, oy )
		Local mx:Int = MouseX()-ox
		Local my:Int = MouseY()-oy
		If mx>ofsx+x And my>ofsy+y And mx<ofsx+x+width And my<ofsy+y+height
			mouseinside = True
			callback( Self )
		
			SetColor( GUI.SECONDARY )
			DrawRect( ofsX+x, ofsY+y, width, height )			
			SetColor( GUI.ONSECONDARY )
		Else
			SetColor( GUI.PRIMARY )
			DrawRect( ofsX+x, ofsY+y, width, height )
			SetColor( GUI.ONPRIMARY )
		End If

		Local tx:Int = ( width - TextWidth( caption ) ) /2
		Local ty:Int = ( height - TextHeight( caption ) ) /2
		DrawText( caption, ofsX+x+tx, ofsY+y+ty )


		'For Local t:Int=0 Until text.length
		'	DrawText( text[t], TTreeViewer.HPADDING+x, TTreeViewer.VPADDING+Y+t*TextHeight("hy") )
		'Next
		
'		SetColor( GUI.PRIMARYLO )
'		DrawRect( column * 30, 50 + row * 30, tw, th )
'		SetColor( GUI.ONPRIMARYLO )
'		For Local t:Int = 0 Until text.length
'			DrawText( text[t], column * 30, 50 + row * 30 + t*TextHeight("hy"))
'		Next		
		
		If Not children; Return
		SetColor( GUI.PRIMARY )
		Local first:TGNode = children[0]
		Local last:TGNode = children[children.length-1]
		Local line:Int = ofsy + y+height + (first.y - ( y + height ) ) / 2  		' height of vertical line
		DrawLine( ofsx + x+width/2, ofsy + y+height, ofsx + x+width/2, line )					' Vertical drop-line
		DrawLine( ofsx + first.x+first.width/2, line, ofsx + last.x+last.width/2, line )	' Horzontal line
		
		For Local child:TGNode = EachIn children
			child.draw( ofsx, ofsy, callback )
			' Temporarily draw a straight line to the child
			'DrawLine( x+width/2, y+height, child.x+child.width/2, child.y )
			
			SetColor( GUI.PRIMARY )
			DrawLine( ofsx + child.x+child.width/2, line, ofsx + child.x+child.width/2, child.y )
		Next
		
	End Method
	
	Method getText:String[]()
		If source; Return source.getText()
	End Method
	
End Type

' Visit all the children execpt the last, then to parent
' then the last child.
' Primarily this should be used on Binary trees!
Type TInOrderEnumerator

	Field list:TList
	
	Method New( node:TGNode )
		list = New TList()
		walk( node )
	End Method
	
	Method walk( node:TGNode )
		Local lastchild:Int = node.children.length
		' ADD LEFT CHILDREN SUBTREES
		For Local i:Int = 0 Until lastchild-1
			walk( node.children[i] )
		Next
		' ADD SELF
		list.addlast( node )
		' ADD RIGHT CHILD SUBTREE
		If lastchild>1; walk( node.children[lastchild-1] )
	End Method

	Method ObjectEnumerator:TGNodeIterator()
		Return New TGNodeIterator( list )
	End Method

End Type

Type TPreOrderEnumerator

	Field list:TList

	Method New( node:TGNode )
		list = New TList()
		' Build stack from tree
		Local todo:TList = New TList()
		todo.addlast( node )
		While Not todo.isEmpty()
			node = TGNode( todo.removeFirst() )
			list.addlast( node )
			For Local i:Int = 0 Until node.children.length
				todo.addlast( node.children[i] )
			Next
		Wend
	End Method

	Method ObjectEnumerator:TGNodeIterator()
		Return New TGNodeIterator( list )
	End Method

End Type

Type TPostOrderEnumerator

	Field list:TList

	Method New( node:TGNode )
		list = New TList()
		walk( node )
	End Method

	Method walk( node:TGNode )
		For Local i:Int = 0 Until node.children.length
			walk( node.children[i] )
		Next	
		list.addlast( node )
	End Method

	Method ObjectEnumerator:TGNodeIterator()
		Return New TGNodeIterator( list )
	End Method

End Type

Type TGNodeIterator
	Field list:TList

	Method New( list:TList )
		Self.list = list
	End Method
	
	Method hasnext:Int()
		Return Not list.isEmpty()
	End Method
	
	Method nextObject:Object()
		Return list.removefirst()
	End Method
End Type	
		
Type TTreeViewer Extends TComponent

	Global HPADDING:Int = 2		' Space inside the boxes
	Global VPADDING:Int = 2		' Space inside the boxes
	Global VMARGIN:Int = 20		' Space between rows of nodes
	Global SIBLINGSEP:Int = 4	' Sibling separation
	Global SUBTREESEP:Int = 4	' Subtree separation
	Global NODEHEIGHT:Int = 20
	Global NODEWIDTH:Int = 20
	
	Field root:TGNode
	Field dialog:TGNode			' Is a dialog being shown
	
	'Field _nodeSize:Int = 20	' Static or Dynamic node size
	
'	Global scaleX:Float = 1.0	' Set the unit of scale for X
'	Global scaleY:Float = 1.0	' Set the unit of scale for y
	
	'Field dx:Float = 20
	'Field dy:Float = 20
	
	'Field maxTextHeight:Int = 0	
	'Field rowcursor:Int[] = []
	
	Global mouseinside:TGNode	' Mouse is inside of this node
	Global mousepress:TGnode	' Mouse pressed inside this node

'	Method New( ui:Admin )
'		Self.ui = ui
'	End Method

	' Create a graphical tree from a tree structure
	Method Create( node:IViewable, nodesize:Int = -1 )
		' Build a structure to hold graphical representation of tree
		root = createtree( node )
		New TGNode( Null ).add( root, 0 ) ' NULL Ancestor of root

		' TEST CALLBACK
		'Print( "eachafter" )
		'root.eachAfter( testme )
		'Print( "eachBefore" )
		'root.eachBefore( testme )
		
		'Local str:String = ""
		'For Local node:TGNode = EachIn root.inOrder()
		'	str :+ node.caption+"."
		'Next
		'Print "INORDER: "+str
		'str = ""
		'For Local node:TGNode = EachIn root.preOrder()
		'	str :+ node.caption+"."
		'Next
		'Print "PREORDER: "+str
		'str = ""
		'For Local node:TGNode = EachIn root.postOrder()
		'	str :+ node.caption+"."
		'Next
		'Print "POSTORDER: "+str
		'DebugStop
		
		' Compute the layout using Buchheim et al.’s algorithm.

		' FIRST WALK - Calculate prelimary positions
		For Local node:TGNode = EachIn root.postOrder()
			firstwalk( node )
		Next
		'treedump( root, "FIRST WALK" )

		' Move the parent to the right
		root.parent.modifier = -root.prelim

		' SECOND WALK - Calculate location
		For Local node:TGNode = EachIn root.preOrder()
			Secondwalk( node )
		Next
		'treedump( root, "SECOND WALK" )
		
	End Method

	' Walk the source tree creating a new one we can use to build the projection
	' RECURSIVE
	Method createtree:TGNode( source:IViewable, depth:Int = 0 )
		Local node:TGNode = New TGNode( source, depth )
		'maxTextHeight = Max( box.text.length, maxTextHeight )	' Get max height of the rows
		'list.addlast( box )
		node.height = NODEHEIGHT
		node.width  = NODEWIDTH
		node.y = (( depth+1 ) * NODEHEIGHT ) + ( depth * VMARGIN )
		Local children:IViewable[] = source.getChildren()
		For Local sibling:Int = 0 Until children.length
			node.add( createtree( children[sibling], depth+1 ), sibling )
		Next
		Return node
	End Method

	' All other shifts, applied To the smaller subtrees between w- And w+, are
	' performed by this Function. To prepare the shifts, we have To adjust
	' change(w+), shift(w+), And change(w-).
Rem	Function executeShifts( node:TGNode )
		Local shift:Float = 0
		Local change:Float = 0
		Local children:TGNode[] = node.children
		'Local i:Int = children.length,
		Local child:TGNode
		For Local i:Int=children.length-1 To 0 Step -1
		'While (--i >= 0)
			child           = children[i]
			child.prelim   :+ shift
			child.modifier :+ shift
			change         :+ child.change
			shift          :+ child.shift + change
		Next
	End Function
EndRem

	Function Testme( node:TGNode, index:Int, parent:TGNode )
		Local name:String
		If node; name = node.caption
		'Print "'"+name+", "+index+", Object"
	End Function
	
	' Dumps a tree as a table
	Method treedump( root:TGNode, title:String="TREE DUMP" )
	
		Local header:String[] = ["NODE","X:4:INT","Y:4:INT","W:3","H:3","DEPTH:5:INT","PRELIM:8","MODIFIER:8"]

		Print Upper(title)+":"
		' Show header & calculate column widths
		Local widths:Int[] = []
		Local datatype:String[] = []
		Local line:String
		For Local x:Int = 0 Until header.length
			' Extract header + formatting information
			Local data:String[] = header[x].split(":")
			data = data[..3]
			' Save width
			If data[1]=""
				widths :+ [data[0].length]
			Else
				widths :+ [Int( data[1] )]
			End If
			' Save datatype
			datatype :+ [Lower( data[2] )]
			' Build header
			line :+ format(data[0],widths[x],"string")
		Next
		Print line
		Print " "[..line.length].Replace(" ","-")
		
		' Show data
		For Local node:TGNode = EachIn root.preorder()
			Local row:String[] = [ node.caption, node.x, node.y, node.width, node.height, node.depth, node.prelim, node.modifier ]
			Local line:String = ""
			For Local x:Int = 0 Until row.length
				If x>=widths.length; widths :+ [ row[x].length ]
				line :+ format(row[x],widths[x],datatype[x])
				'line :+ (row[x])[..widths[x]]+" "
			Next
			Print line
		Next
		
		Function format:String( data:String, width:Int, dtype:String )
			If dtype = "int"
				Return String(Int(data))[..width]+" "
			ElseIf dtype = "float"
				Return String(Float(data))[..width]+" "
			EndIf
			Return data[..width]+" "
		End Function
		
	End Method
	
	' The first walk performs a preliminary positioning of all nodes
	Method firstWalk( node:TGNode )
		Local children:TGNode[] = node.children
		Local siblings:TGNode[]
		Local sibling:TGNode
'Local DEBUG:String="N"	
'If Node.caption = DEBUG; DebugStop
		If node.parent; siblings = node.parent.children
		'w = v.i ? siblings[v.i - 1] : null;
		If node.sibling>0; sibling = siblings[node.sibling-1]

		If children
			'executeShifts( node )
			Local midpoint:Float = ( children[0].prelim + children[children.length-1].prelim) / 2
			If sibling
				' NON-First-born NODE WITH CHILDREN
				' 9/9/23, Fixed mean-size of left siblings
				node.prelim = sibling.prelim + separation(node, sibling) + mean_size( siblings, node.sibling )
				node.modifier = node.prelim - midpoint
'Print node.caption + ": prelim="+node.prelim+", mod="+node.modifier+ " (BEFORE)"
				' Check for overlaps
				checkOverlaps( node )
			Else
				' LEFT (OR ONLY) NODE WITH CHILDREN
				node.prelim = midpoint
			End If
		ElseIf sibling
			' LEAF (NO CHILDREN) WITH SIBLINGS TO LEFT
			' Mean size of left siblings + separation
			'DebugStop
			' 9/9/23, Fixed mean-size of left siblings
			node.prelim = sibling.prelim + separation( node, sibling ) + mean_size( siblings, node.sibling )
		Else
			' LEAF WITH NO SIBLINGS
		EndIf
		'	
		Local ancestor:TGNode
		If siblings; ancestor = siblings[0]
		If Not ancestor; ancestor = node.parent.defaultAncestor
		'node.parent.defaultAncestor = apportion( node, sibling, ancestor  )
'Print node.caption + ": prelim="+node.prelim+", mod="+node.modifier
'If Node.caption = DEBUG; DebugStop
	EndMethod

	' Calculate mean sibling width
	Method mean_size:Float( siblings:TGnode[], sibling:Int )
		' As siblings all have a fixed width, the mean will always be that size!
		Return NODEWIDTH		
'		Local sum:Float
'		For Local index:Int = 0 Until sibling
'			sum :+ siblings[index].width
'		Next
'		Return sum / Float(sibling)
	EndMethod

	' Computes all real x-coordinates by summing up the modifiers recursively.
	Method secondWalk( node:TGNode )
'DebugStop
		node.x = (node.prelim + sum_modifiers( node.parent ) ) 
		'node.y = node.depth * scaleY
		'node.height = scaleY
		'node.width = scaleX
	EndMethod
	
	' Calculate the spacing between two nodes
	Method Separation:Float( a:TGNode, b:TGNode )
		If a.parent = b.parent; Return SIBLINGSEP
		Return SUBTREESEP
	EndMethod

	Method setsize( w:Int, h:Int =0 )
		NODEWIDTH = w
		If h=0; h=20
		NODEHEIGHT = h
	End Method

	' In his paper; Dr Dobbs describes this step as:
Rem
Move down one level. 
The leftmost descendant of node N, node G, currently has a positioning of 
0 + 12 = 12 (PRELIM(G) plus the MODIFIER(N), its parent). 
The rightmost descendant of node E, node D is positioned at 6 + 0 = 6 (PRELIM(D) plus 
the MODIFIER(E), its parent). 
Their difference is 12 - 6 = 6, which is equal To the minimum 
separation (subtree separation plus mean node size), so N's subtree does not need to be 
moved, since there is no overlap at this level.

Move down another level. 
The leftmost descendant of node N is node H. 
It is positioned at 0 + -6 + 12 = 6 (PRELIM(H) plus MODIFIER(M) And MODIFIER(N)). 
The rightmost descendant of node E, node C, is positioned at 
6 + 3 + 0 = 9 (PRELIM(C) plus MODIFIER(D) And MODIFIER(E)). 
Their difference is 6 - 9 = -3; it should be 6, the minimum subtree separation plus the mean node size. 
Thus node N And its subtree need To be moved To the Right a distance of 6 - -3 = 9.
End Rem

	' This method follows the rightmost node of a left subtree and leftmost node of
	' a right subtree, calculating the distance between them and adjusting if too small.

	Method checkOverlaps( node:TGNode )
'DebugStop
		' We are only interested in nodes with siblings
		If Not node.parent Or Not node.parent.children Or node.parent.children.length < 2; Return
'If node.parent.caption = "O"; DebugStop
'If node.parent.caption = "N"; DebugStop

		' Set up a loop through siblings
		Local nodeDescendent:TGNode = node
		Local siblingDescendent:TGNode = node
		Local depth:Int = 0
'DebugStop
'Print "CONTOUR OF NODE "+node.caption
'If node.caption = "D"; DebugStop
		'Local leftmost:TGNode
		Repeat
			' Find descendent at this depth of node
			depth :+ 1
			nodeDescendent = find_left_node( node, depth )
			If Not nodeDescendent; Exit
			
			' loop through siblings descendents at this depth
			For Local sibling:Int = 0 Until node.sibling
				' Get sibling decendent
				siblingDescendent = find_right_node( node.parent.children[sibling], depth )
				If Not siblingDescendent; Continue
'If nodeDescendent.caption="H" And siblingDescendent.caption="C"
'	DebugStop
'End If
				' Check for overlap
'If node.caption = "N"; DebugStop
				Local lpos:Float = nodeDescendent.prelim + sum_modifiers( nodeDescendent.parent )
				Local rpos:Float = siblingDescendent.prelim + sum_modifiers( siblingDescendent.parent )
				Local diff:Float = lpos-rpos
				Local spacing:Float = SUBTREESEP * (sibling+1) + mean_size( node.parent.children, sibling+1 )
				Local shift:Float = spacing - diff
				If diff < spacing
					'movesubtree( node, spacing - diff )
					node.prelim   :+ shift
					node.modifier :+ shift
				End If
'If siblingDescendent And nodeDescendent
'	Print " LEVEL: "+depth+", LEFT: "+siblingDescendent.caption+", RIGHT: "+nodeDescendent.caption
'ElseIf siblingDescendent
'	Print " LEVEL: "+depth+", LEFT: "+siblingDescendent.caption+", RIGHT: NULL"
'ElseIf nodeDescendent
'	Print " LEVEL: "+depth+", LEFT: NULL, RIGHT:"+nodeDescendent.caption
'Else
'	Print " LEVEL: "+depth+", LEFT: NULL, RIGHT: NULL"
'End If
			Next
		Forever
	
Rem		Return
 DebugStop
' RUBBISH HERE
		Local lastchild:Int = node.parent.children.length - 1
		Local sibling:Int = lastchild

		' Trees to compare

		Local lefttree:TGNode = node.parent.children[0]
		Local righttree:TGNode = node.parent.children[lastchild]
		
		Local RightNodeLeftTree:TGNode
		Local LeftNodeRightTree:TGNode
		'_checkoverlap( rightmost, leftmost )

		' Follow contour
		Repeat
			' Move down one level
			If Not lefttree.children Or Not righttree.children
				' Have we worked through all siblings?
				If sibling = 0; Exit
				' Set up next loop
				sibling :- 1
				lefttree = node.parent.children[sibling]
				righttree = node.parent.children[lastchild]
			Else
				lefttree = lefttree.children[ lefttree.children.length-1 ]
				righttree = righttree.children[0]
			End If
			
			If Not lefttree.children Or Not righttree.children; Continue
			
			Local lpos:Float = lefttree.prelim + lefttree.parent.modifier
			Local rpos:Float = righttree.prelim + righttree.parent.modifier
			Local diff:Float = lpos-rpos
			Local spacing:Int = SUBTREESEP + mean_size( node.parent.children, sibling )
			If diff < spacing
				movesubtree( righttree, spacing )
			End If
			
		Forever
EndRem
	EndMethod

'	Function _checkoverlap( nodelefttree:TGNOde, noderighttree:TGNode )
'		Local posLeft:Float = nodelefttree.prelim + nodelefttree.parent.modifier
'		Local posRight:Float = noderighttree.prelim + noderighttree.parent.modifier
'	End Function

	' Find the leftmost descendant node at a given depth
	' RECURSIVE
	Method find_left_node:TGNode( node:TGNode, maxdepth:Int, depth:Int=1 )
		If Not node.children; Return Null
'DebugStop
		' If we are at maxdepth, the left child will be the leftmost node
		If depth >= maxdepth ; Return node.children[0]
		' Loop through all children
		Local leftmost:TGnode
		For Local child:Int = 0 Until node.children.length
			Local this:TGNode = find_left_node( node.children[child], maxdepth, depth+1 )
			If Not this; Continue
			If Not leftmost Or ( this.prelim < leftmost.prelim ); leftmost = this
		Next
		Return leftmost
	EndMethod
	
	' Find the rightmost descendant node at a given depth
	' RECURSIVE
	Method find_right_node:TGNode( node:TGNode, maxdepth:Int, depth:Int=1 )
		If Not node.children; Return Null
'DebugStop
		' If we are at maxdepth, the right child will be the rightmost node
		If depth >= maxdepth ; Return node.children[ node.children.length-1 ]
		' Loop through all children
		Local rightmost:TGnode
		For Local child:Int = 0 Until node.children.length
			Local this:TGNode = find_right_node( node.children[child], maxdepth, depth+1 )
			If Not this; Continue
			If Not rightmost Or ( this.prelim > rightmost.prelim ); rightmost = this
		Next
		Return rightmost
	EndMethod
	
	' Calculate sum of all ancestor modifiers
	Method sum_modifiers:Float( node:TGNode )
		If Not node; Return 0
		Local sum:Float
		Repeat
			sum :+ node.modifier
			node = node.parent
		Until Not node
		Return sum
	EndMethod
	
Rem		
	' This is used to join subtrees together checking contours
	' node: 	The node we are working on
	' sibling:	The nodes next-left sibling
	' ancestor:
	Function apportion:TGNode( node:TGNode, sibling:TGNode, ancestor:TGNode )
		' Only calculate on non-left siblings
		If Not sibling; Return ancestor

If node.caption="N"; DebugStop
		Local vip:TGNode = node						' Node Left Walker
		Local vop:TGNode = node						' Node Right Walker
		Local vim:TGNode = sibling					' younger-sibling, Right Side Walker
		Local vom:TGNode = vip.parent.children[0]	' first-born sibling
		Local sip:Int = vip.modifier				' Node Walker Left modifier
		Local sop:Int = vop.modifier				' Node Walker Right modifier
		Local sim:Int = vim.modifier				' younger subling, right walker modifier
		Local som:Int = vom.modifier				' first born sibling modifier
		Local shift:Int								' Current movement
		Repeat
			vim = nextRight( vim )
			vip = nextLeft( vip )
			If Not vim Or Not vip; Exit
			vom = nextLeft( vom )
			vop = nextRight( vop )
			vop.ancestor = node
			shift = vim.prelim + sim - vip.prelim - sip + separation( vim, vip )
			If shift > 0
				moveSubtree( nextAncestor( vim, node, ancestor ), node, shift )
				sip :+ shift
				sop :+ shift
			EndIf
			sim :+ vim.modifier
			sip :+ vip.modifier
			som :+ vom.modifier
			sop :+ vop.modifier
		Forever
		If vim And Not nextRight( vop )
			vop.thread = vim
			vop.modifier :+ sim - sop
		EndIf
		If vip And Not nextLeft( vom )
			vom.thread = vip
			vom.modifier :+ sip - som
			ancestor = node
		EndIf
		Return ancestor
	EndFunction
End Rem

	Function nextAncestor:TGNode( vim:TGNode, node:TGNode, ancestor:TGNode )
	
'TODO: NOT SURE IF THIS IS CORRECT!
		If Not vim Or Not vim.ancestor; Return ancestor
	
		If vim.ancestor.parent = node.parent; Return vim.ancestor
		Return ancestor
	EndFunction

'	Function nextLeft:TGNode( node:TGNode )
'		Local children:TGNode[] = node.children
'		If children; Return children[0]
'		Return node.thread
'	EndFunction

'	Function nextRight:TGNode( node:TGNode )
'		Local children:TGNode[] = node.children
'		If children; Return children[children.length-1]
'		Return node.thread
'	EndFunction

'	Function moveSubtree( node:TGNode, shift:Float )
'		node.prelim   :+ shift
'		node.modifier :+ shift
'	End Function

'	Function moveSubtree( wm:TGNode, wp:TGNode, shift:Float )
'		Local change:Float = shift / ( wp.sibling - wm.sibling )
'		wp.change   :- change
'		wp.shift    :+ shift
'		wm.change   :+ change
'		wp.prelim   :+ shift
'		wp.modifier :+ shift
'	EndFunction

'	Method SetScale( width:Float, height:Float )
'		Self.scaleX = width
'		Self.scaleY = height
'	End Method

	' OLD STUFF BEYOND HERE / NON FUNCTIONAL
	Rem
	Method walk( node:TGNode, row:Int )
		'DebugStop

		' Expand rowcursor so there is one for each row
		If rowcursor.length <= row; rowcursor :+ [0]

'If node.caption="E"; DebugStop

		node.x = rowcursor[ row ]
		node.w = TextWidth( node.caption ) + HPADDING * 2
		node.h = TextHeight( node.caption ) + VPADDING * 2
		node.y = row * TextHeight("hy") * 3

Local class:String = ["NODE","LEAF"][node.children.length=0]
Print node.caption+"; row="+row+"; class="+class+"; #" + node.sibling + "; xy="+node.x+","+node.y+"; wh="+node.w+","+node.h 

		If node.children.length > 0
			Local widthsum:Int = 0
			For Local child:TGNode = EachIn node.children
	'If node.caption="O"; DebugStop
				walk( child, row+1 )
				widthsum :+ child.w
			Next
			widthsum :+ HMARGIN * (node.children.length - 1)
			
			node.x :+ (widthsum - node.w) / 2
		End If
'DebugStop

'		If children.length = 0
'			node.x = rowcursor[ row ]
'		End If
		
'Print node.caption+"; row="+row+"; class="+class+"; #" + node.sibling + "; xy="+node.x+","+node.y+"; wh="+node.w+","+node.h 
		
'		rowcursor[row] :+ node.w + HMARGIN
		
	End Method
	EndRem
	
	Method render()
		
		mouseinside = Null
		
		SetClsColor( GUI.SURFACE )
		Cls
		
		'DrawBox( 0,0,w-1,h-1 )
		'DebugStop
		'If root; root.draw( widget.width/2, 0, callback )
		
		' Show Tree as buttons
		If root
			For Local node:TGNode = EachIn root.preOrder()
				SetLineWidth(1)

				Local wx:Int = widget.x+widget.width/2
			
				Local btn:SWidget = New SWidget( node.caption, wx+node.x, widget.y+node.y, node.width, node.height )
				If ui.button( btn, False )				
					'Print "pressed "+node.caption
					FlushKeys()	' Remove previous ESCAPE keypresses
					dialog = node
				End If
				
				' Don't draw connecting line if there are no children
				If Not node.children; Continue

				' DRAW THE CONNECTING TREE LINES
				SetLineWidth(2)
				
				SetColor( GUI.PRIMARYLO )				
				Local first:TGNode = node.children[0]
				Local last:TGNode = node.children[node.children.length-1]

				' Calculate position of horizontal line
				Local line:Int = btn.y + btn.height + VMARGIN/2
				DrawLine( wx+first.x+first.width/2, line, wx+last.x+last.width/2, line )
				
				' Draw vertical drop-line from parent
				DrawLine( btn.x+btn.width/2, btn.y+btn.height, btn.x+btn.width/2, line )	' Vertical drop-line
				
				' Draw vertical drop-lines to children
				For Local child:TGNode = EachIn node.children
					DrawLine( wx+child.x+child.width/2, line, wx+child.x+child.width/2, widget.y+child.y )
				Next			
				
			Next
		End If
		SetLineWidth(1)

		' Show a dialog box if one if defined
		If dialog
			'DebugStop
			Local widget:SWidget = New SWidget( dialog.caption, widget.x+widget.width/2+dialog.x, widget.y+dialog.y, 0,0 )
			'widget.width = 200
			'widget.height = 100
			If ui.dialog( widget, dialog.getTExt(), True )
				dialog = Null
			End If
		End If

		If mouseinside
			'Print( "- inside "+mouseinside.caption )
			If MouseDown(0)
				mousepress = mouseinside
				'Print "PRESSED "+mousepress.caption
			ElseIf mousepress
				'Print "CLICKED "+mousepress.caption
			Else
				'Print "TBC"
			End If
		Else
			' Drop mousepress
			' mousepress = Null
		End If
		
	End Method
	
	' Callback used to handle mouse-inside
	Function callback( node:TGNode )
		'Print "Mouse inside node "+node.caption
		TTreeViewer.mouseinside = node
	End Function
	
End Type