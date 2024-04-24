SuperStrict

Import "ui.bmx"
Include "TTreeViewer.bmx"
Include "TLogViewer.bmx"

Type Admin Extends GUI

	Const BUTTONHEIGHT:Int = 33
	Const BUTTONWIDTH:Int = 88
	Const BORDER:Int = 5

	Field buttons:SWidget[] = []
	Field components:TComponent[] = []

	' Components
	Field treeViewer:TTreeViewer
	Field logviewer:TLogViewer 

	Method New( x:Int, y:Int )
		Super.New( x, y )
		treeviewer = New TTreeViewer(Self)
		add( "TREE", treeviewer )

		logviewer = New TLogViewer(Self)
		add( "LOG", logviewer )
	End Method
	
	' Add an admin component and a button
	Method add( caption:String, widget:TComponent )
		' Define button
		Local index:Int = buttons.length
		Local x:Float = BORDER + index*( BUTTONWIDTH + BORDER)
		Local y:Float = BORDER
		Local button:SWidget = New SWidget( caption, x,y, BUTTONWIDTH, BUTTONHEIGHT )
		buttons :+ [ button ]
		' Define Component
		components :+ [ widget ]
	End Method

	Method paint()
		For Local index:Int = 0 Until buttons.length
			If button( buttons[index], btn=index )
			'If button( buttons[index], BORDER + index*(BUTTONWIDTH+BORDER), BORDER, BUTTONWIDTH, BUTTONHEIGHT, btn=index )
				btn = index
			End If
		Next
		
		' Show selected component
		components[ btn ].show()
	EndMethod
EndType

Type TComponent

	Field widget:SWidget
	'Field x:Int
	'Field y:Int
	'Field width:Int
	'Field height:Int
	Field ui:Admin

	Method New( ui:Admin )
		Self.ui = ui
	End Method

	Method show()
		widget.x = ADMIN.BORDER
		widget.y = ADMIN.BORDER*2 + ADMIN.BUTTONHEIGHT
		widget.width = GraphicsWidth() - ADMIN.BORDER*2
		widget.height = GraphicsHeight() - ADMIN.BORDER*3 - ADMIN.BUTTONHEIGHT
'Local debug:TComponent = Self
'		DebugStop
		'Local vx:Int = GUI.BORDER
		'Local vy:Int = GUI.BORDER*2 + GUI.BUTTONHEIGHT
		'Local vw:Int = GraphicsWidth() - GUI.BORDER*2
		'Local vh:Int = GraphicsHeight() - GUI.BORDER*3 - GUI.BUTTONHEIGHT
		'SetViewport( vx, vy, vw, vh )
		'SetOrigin( vx, vy )
		'DebugStop
		SetViewport( widget.x, widget.y, widget.width, widget.height )
		'SetOrigin( widget.x, widget.y )
		'render( vw, vh )
		render()
		SetViewport( 0,0, GraphicsWidth(), GraphicsHeight() )
		'SetOrigin( 0, 0 )
	End Method
	
	Method render() Abstract
	
	'Method drawbox( x:Int, y:Int, w:Int, h:Int )
	'	DrawLine( x,   y,   x+w, y )
	'	DrawLine( x+w, y,   x+w, y+h )
	'	DrawLine( x+w, y+h, x,   y+h )
	'	DrawLine( x,   y+h, x,   y )
	'End Method

End Type