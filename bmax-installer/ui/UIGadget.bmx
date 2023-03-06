
'	MaxGUI Object Interface
'	(c) Copyright Si Dunford [Scaremonger], FEB 2023, All rights reserved

Type UIGadget Abstract

	Private
	
	Field parent:UIGadget
	Field children:TList

	Field gad:TGadget
	
	Field handlers:TIntMap
	Field Handler_OnKeyChar( this:UIGadget, event:TEvent )
	Field Handler_OnKeyUp( this:UIGadget, event:TEvent )
	Field Handler_OnKeyDown( this:UIGadget, event:TEvent )
	
	Public
	
	Method New()
	
		handlers = New TIntMap()
		
		AddHook( EmitEventHook, EventHook, Self )
		
	End Method
	
	' Function Handler
	Method on( event:Int, handler( event:TEvent ) )
		handler.insert( event, handler )
	End Method

	' Object handler
	'Method on( event:Int, gadget:UIGadget )
	'	handler.insert( event, gadget )
	'End Method
		
	Method off( event:Int )
		handler.remove( event )
	End Method
	
	Method onKeyChar( event:TEvent )
		Local handler( this:UIGadget, event:TEvent ) = handler.valueForKey( event )
	End Method
	
	
	Function EventHook:Object( id:Int, data:Object, context:Object )
		Local gadget:UIGadget = UIGadget( context )
		Local event:TEvent = TEvent( data )
		If Not gadget Or Not event; Return data
		'
		
		Local handler:int( event:TEvent )
		handler = gadget.handlers.valueforkey( event.id )
		DebugStop
		If Not handler; Return data
		
		Select event.id
		
		' GENERIC EVENTS
		Case EVENT_KEYCHAR, EVENT_KEYDOWN, EVENT_KEYUP
			handler( event )
		Case EVENT_MOUSEDOWN, EVENT_MOUSEENTER, EVENT_MOUSELEAVE, EVENT_MOUSEMOVE, EVENT_MOUSEWHEEL
			handler( event )
		Case EVENT_GADGETACTION
			handler( event )
					
		' WINDOW EVENTS
		Case EVENT_WINDOWACCEPT, EVENT_WINDOWACTIVATE, EVENT_WINDOWCLOSE, EVENT_WINDOWMOVE, EVENT_WINDOWSIZE
			Local win:UIWindow = UIWindow( gadget )
			If Not win; Return Data
			handler( event )
		
		' TREE VIEW EVENTS
		Case EVENT_GADGETCLOSE, EVENT_GADGETOPEN, EVENT_GADGETSELECT
			Local tv:UITreeView = UITreeView( gadget )
			If Not tv; Return Data
			handler( event )

		' MENU EVENTS		
		Case EVENT_MENUACTION
			Local menu:UIMenu = IMenu(gadget)
			If menu = Null Or gadget.gad = Null; Return Data
			If event.source <> gadget.gad; Return Data
			'If gadget._freed Then Return obj	
			If menu.id = event.data; handler( event )
		Case EVENT_GADGETMENU
			Local txt:UITextbox = UITextbox( gad )
			Local tv:UITreeview = UITreeview( gad )
			If UITextbox( gadget ) Or UITreeview( gadget ); handler( event )

		' HTMLVIEW
		Case EVENT_GADGETDONE
			If UIHTMLview( gadget ); handler( event )
			
		' CANVAS
		Case EVENT_GADGETPAINT
			If UICanvas( gadget ); handler( event )
			
		End Select
		
		Return data	
	End Function
	
End Type
