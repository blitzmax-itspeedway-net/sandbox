'# TElements are the components on the form
'#
'# 

'############################################################
Type TElement
Field _gadget:TGadget
Field form:TForm				'# Form handler to which this is connected
Field Component$				'# Type of component
Field Parent:TElement	
'# Supported parameters
Field Name$					'# Name of component
Field x%, y%, width%, height%
Field Style%
Field Caption$					'# Fields use this for "empty" content.
Field Text$					'# Fields use this for content
Field command%		=0
'# Form Styles
Field resize% 		= False
Field titlebar% = 1			'# 0=None, 1=Titlebar, 2=Toolbar
Field menu% = False
Field status% = False
Field center% = False
Field dragdrop% = False
'Field defValue$				'# Default Value

'Field element:TFormElement	'# Used during form parsing
'Field params:Tmap = CreateMap()
Field children:TList = CreateList()

	'------------------------------------------------------------
	Method Create:TElement( parent:TElement, Component$, Name$ )
		Self.Component = component
		Self.Name = name
		Self.Parent = parent
		If parent Then ListAddLast( parent.children, Self )
	Return Self
	End Method

	'------------------------------------------------------------
	Method build( parser:TFormParser, handler:Tform )
		form = handler
		_gadget = parser.form.driver.GenerateObject( Self, parser )
		If _gadget Then
			SetGadgetExtra( _gadget, Self )	
			For Local obj:TElement = EachIn children
				obj.build( parser, handler )
			Next
		End If
	End Method

	'------------------------------------------------------------
	Method demolish()
		SetGadgetExtra( _gadget, Null )
		For Local obj:TElement = EachIn children
			obj.demolish()
		Next
		children.clear()
		FreeGadget( _gadget )
	End Method

	'------------------------------------------------------------
	Method Event()

	End Method

	'------------------------------------------------------------
	'# Finds an Element by name
	Method search:TElement( criteria$ )
	Local result:TElement
		If name = criteria Then Return Self
		For Local child:TElement = EachIn children
			result = child.search( criteria ) 
			If result Then Return result
		Next
	Return Null
	End Method
	
	'------------------------------------------------------------
	Method StatusText( text$ )
		form.driver.statusText( _gadget, text )
	End Method	
	
	Method show()
		ShowGadget( _gadget )
	End Method

	Method hide()
		ShowGadget( _gadget )
	End Method
End Type