'# Baseline object upon which entire GUI is contructed

'############################################################
'##### Root
Type GGadget Abstract
Global _Counter:Int=0	'# Unique object number for name generation
Field _freed:Int = True
Field _children:TList = New TList
Field _parent:GGadget
Field _link:TLink
'# Stylesheet identifiers
Field _class:String = "OBJECT"
Field _id:String = ""

	'------------------------------------------------------------
	Method GetClass:String()
	Return _class
	End Method

	'------------------------------------------------------------
	Method GetID:String()
	Return _id
	End Method

	'------------------------------------------------------------
	Method SetClass( str:String )
	_class = Upper( str )
	End Method

	'------------------------------------------------------------
	Method SetID( str:String )
	_id = str
	End Method
	
End Type

'========================================
Type GComponent Extends GObject
Global counter%=0	'# Unique object number for name generation
Field link:TLink	'# Position in container object list
Field id$			'# Name used in style selection
Field text$		'# Text used for object caption, text or title etc...
Field alignment%	= Align_Left
Field visible%		= True
	'----------------------------------------
	Method _Create( class$="obj", textstr$="", align%=ALIGN_LEFT )
		counter:+1
		id			= class + counter		'# Unique Object ID (USed in styles)
		text 		= textstr
		alignment 	= align
	End Method
	'----------------------------------------
	Method getAlignment%()		;	Return alignment	;	End Method
	Method getID$()				;	Return id			;	End Method
	Method getText$()				;	Return text		;	End Method
	'----------------------------------------
	Method setAlignment( val% )	;	alignment = val	;	End Method
	Method setID( str$ )			;	id = str			;	End Method
	Method setText( str$ )		;	text = str			;	End Method
	'----------------------------------------
	Method addActionListener( class:GComponent )
	End Method	
	'----------------------------------------
	Method setVisible( state% = True )
		visible = state
	End Method	
End Type

'############################################################
'##### GComponents

Type GContainer Extends GComponent
Field children:TList = CreateList()
Field layout:GLayoutManager
	'----------------------------------------
	'# Add a component to this container
	Method add( C:GComponent )
		C.link = ListAddLast( children, C )
	End Method
	'----------------------------------------
	'# Set the layout manager
	Method setLayout( mgr:GLayoutManager )
		layout = mgr
	End Method
End Type