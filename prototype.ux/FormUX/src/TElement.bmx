'# TElements are the components on the form
'#
'# 

'############################################################
Type TElement
'Field _gadget:TGadget
Field form:TForm				'# Form handler to which this is connected
Field Component:String				'# Type of component
Field Parent:TElement	
'# Supported parameters
Field Name:String					'# Name of component
Field x:Int, y:Int, width:Int =-1, height:Int =-1
Field Style:Int
Field Caption:String					'# Fields use this for "empty" content.
Field Text:String					'# Fields use this for content
Field command:Int		=0
'# Form Styles
Field resize:Int 		= False
Field titlebar:Int = 1			'# 0=None, 1=Titlebar, 2=Toolbar
Field menu:Int = False
Field status:Int = False
Field center:Int = False
Field dragdrop:Int = False
'Field border:Int = PANEL_SUNKEN
'Field defValue:String				'# Default Value

'Field element:TFormElement	'# Used during form parsing
'Field params:Tmap = CreateMap()
Field children:TList = CreateList()

	Method New()
	End Method
	
	'------------------------------------------------------------
'	Method Create:TElement( parent:TElement, Component:String, Name:String, value:String="" )
'If parent Then
'	Print "Creating "+parent.component+":"+Component+"("+name+")="+value
'Else
'	Print "Creating "+Component+"("+name+")="+value
'End If
'		Self.Component = Trim(component)
'		Self.Name = Trim(name)
'		Self.Parent = parent
'		Self.caption = Trim(value)
'		If parent Then ListAddLast( parent.children, Self )
'	Return Self
'	End Method

	'------------------------------------------------------------
	Method build( parser:TFormParser, handler:Tform )
		'form = handler
		'_gadget = parser.form.driver.GenerateObject( Self, parser )
		'If _gadget Then
		'	SetGadgetExtra( _gadget, Self )	
		'	For Local obj:TElement = EachIn children
		'		obj.build( parser, handler )
		'	Next
		'End If
	End Method

	'------------------------------------------------------------
	Method demolish()
'		If _gadget Then SetGadgetExtra( _gadget, Null )
'		For Local obj:TElement = EachIn children
'			obj.demolish()
'		Next
'		children.clear()
'		If _gadget Then FreeGadget( _gadget )
	End Method

	'------------------------------------------------------------
	Method Event()

	End Method

	'------------------------------------------------------------
	'# Finds an Element by name
	Method search:TElement( criteria:String )
'	Local result:TElement
'		If name = criteria Then Return Self
'		For Local child:TElement = EachIn children
'			result = child.search( criteria ) 
'			If result Then Return result
'		Next
'	Return Null
	End Method
	
	'------------------------------------------------------------
	Method StatusText( text:String )
'		form.driver.statusText( _gadget, text )
	End Method	
	
	Method show()
'		ShowGadget( _gadget )
	End Method

	Method hide()
'		ShowGadget( _gadget )
	End Method
End Type