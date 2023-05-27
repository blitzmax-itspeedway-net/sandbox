'# GADGET FORM
'#
'############################################################
Type TGadget_Form
Field win:TGadget, canvas:TGadget, name:String
Field link:TLink
	'------------------------------------------------------------
	'# RETURN TRUE  - When you have processed the function (Stop propogation)
	'# RETURN FALSE - When it's not your event.
	Method onEvent:Int( event:TEvent )
		Select event.id
'		Case EVENT_APPSUSPEND 		; return onAppSuspend( event )		' Application suspended 
'		Case EVENT_APPRESUME 		; return onAppResume( event )		' Application resumed 
'		Case EVENT_APPTERMINATE 	; return onAppTerminate( event )	' Application wants To terminate 
'		Case EVENT_KEYDOWN 			; return onKeyDown( event )			' Key pressed. Event data contains keycode 
'		Case EVENT_KEYUP 			; return onKeyUp( event )			' Key released. Event data contains keycode 
'		Case EVENT_KEYCHAR 			; return onKeyChar( event )			' Key character. Event data contains unicode value 
		Case EVENT_MOUSEDOWN 		; Return onMouseDown( event )		' Mouse button pressed. Event data contains mouse button code 
		Case EVENT_MOUSEUP 			; Return onMouseUp( event )			' Mouse button released. Event data contains mouse button code 
		Case EVENT_MOUSEMOVE 		; Return onMouseMove( event )		' Mouse moved. Event x And y contain mouse coordinates 
'		Case EVENT_MOUSEWHEEL 		; return onMouseWheel( event )		' Mouse wheel spun. Event data contains delta clicks 
		Case EVENT_MOUSEENTER 		; Return onMouseEnter( event )		' Mouse entered gadget area 
		Case EVENT_MOUSELEAVE 		; Return onMouseLeave( event )		' Mouse Left gadget area 
'		Case EVENT_TIMERTICK 		; return onTimerTick( event )		' Timer ticked. Event source contains timer Object 
'		Case EVENT_HOTKEYHIT 		; return onHotKeyHit( event )		' Hot key hit. Event data And mods contains hotkey keycode And modifier 
		Case EVENT_MENUACTION 		; Return onMenuAction( event )		' Menu has been selected 
'		Case EVENT_WINDOWMOVE 		; return onWindowMove( event )		' Window has been moved 
		Case EVENT_WINDOWSIZE 		; Return onWindowSize( event )		' Window has been resized 
		Case EVENT_WINDOWCLOSE 		; Return onWindowClose( event )		' Window close icon clicked 
'		Case EVENT_WINDOWACTIVATE	; return onWindowActivate( event )	' Window activated 
'		Case EVENT_WINDOWACCEPT 	; return onWindowAccept( event )	' Drag And Drop operation was attempted 
'		Case EVENT_GADGETACTION 	; return onGadgetAction( event )	' Gadget state has been updated 
		Case EVENT_GADGETPAINT		' A Canvas Gadget needs To be redrawn 
		 	If event.source<>canvas Then Return False
			Return onGadgetPaint( event )
'		Case EVENT_GADGETSELECT 	; return onGadgetSelect( event )	' A TreeView Node has been selected 
'		Case EVENT_GADGETMENU 		; return onGadgetMenu( event )		' User has Right clicked a TreeView Node Or TextArea gadget 
'		Case EVENT_GADGETOPEN 		; return onGadgetOpen( event )		' A TreeView Node has been expanded 
'		Case EVENT_GADGETCLOSE 		; return onGadgetClose( event )		' A TreeView Node has been collapsed 
'		Case EVENT_GADGETDONE 		; return onGadgetDone( event )		' An HTMLView has completed loading a page
		Default
			DebugLog "NOT IMPLEMENTED: "+event.ToString()
		End Select
	Return False
	End Method
	
	'------------------------------------------------------------
	Method onAppSuspend:Int( event:TEvent )
	DebugLog "NOT IMPLEMENTED: "+event.ToString()
	Return False
	End Method
	
	'------------------------------------------------------------
	Method onAppResume:Int( event:TEvent )
	DebugLog "NOT IMPLEMENTED: "+event.ToString()
	Return False
	End Method
	
	'------------------------------------------------------------
	Method onAppTerminate:Int( event:TEvent )
	DebugLog "NOT IMPLEMENTED: "+event.ToString()
	Return False
	End Method
	
	'------------------------------------------------------------
	Method onKeyDown:Int( event:TEvent )
	DebugLog "NOT IMPLEMENTED: "+event.ToString()
	Return False
	End Method
	
	'------------------------------------------------------------
	Method onKeyUp:Int( event:TEvent )
	DebugLog "NOT IMPLEMENTED: "+event.ToString()
	Return False
	End Method
	
	'------------------------------------------------------------
	Method onKeyChar:Int( event:TEvent )
	DebugLog "NOT IMPLEMENTED: "+event.ToString()
	Return False
	End Method
	
	'------------------------------------------------------------
	Method onMouseDown:Int( event:TEvent )
	DebugLog "NOT IMPLEMENTED: "+event.ToString()
	Return False
	End Method
	
	'------------------------------------------------------------
	Method onMouseUp:Int( event:TEvent )
	DebugLog "NOT IMPLEMENTED: "+event.ToString()
	Return False
	End Method
	
	'------------------------------------------------------------
	Method onMouseMove:Int( event:TEvent )
	DebugLog "NOT IMPLEMENTED: "+event.ToString()
	Return False
	End Method
	
	'------------------------------------------------------------
	Method onMouseWheel:Int( event:TEvent )
	DebugLog "NOT IMPLEMENTED: "+event.ToString()
	Return False
	End Method
	
	'------------------------------------------------------------
	Method onMouseEnter:Int( event:TEvent )
	DebugLog "NOT IMPLEMENTED: "+event.ToString()
	Return False
	End Method
	
	'------------------------------------------------------------
	Method onMouseLeave:Int( event:TEvent )
	DebugLog "NOT IMPLEMENTED: "+event.ToString()
	Return False
	End Method
	
	'------------------------------------------------------------
	Method onTimerTick:Int( event:TEvent )
	DebugLog "NOT IMPLEMENTED: "+event.ToString()
	Return False
	End Method
	
	'------------------------------------------------------------
	Method onHotKeyHit:Int( event:TEvent )
	DebugLog "NOT IMPLEMENTED: "+event.ToString()
	Return False
	End Method
	
	'------------------------------------------------------------
	Method onMenuAction:Int( event:TEvent )
	DebugLog "NOT IMPLEMENTED: "+event.ToString()
	Return False
	End Method
	
	'------------------------------------------------------------
	Method onWindowMove:Int( event:TEvent )
	DebugLog "NOT IMPLEMENTED: "+event.ToString()
	Return False
	End Method
	
	'------------------------------------------------------------
	Method onWindowSize:Int( event:TEvent )
	DebugLog "NOT IMPLEMENTED: "+event.ToString()
	Return False
	End Method
	
	'------------------------------------------------------------
	Method onWindowClose:Int( event:TEvent ) ; End Method
	
	'------------------------------------------------------------
	Method onWindowActivate:Int( event:TEvent )
	DebugLog "NOT IMPLEMENTED: "+event.ToString()
	Return False
	End Method
	
	'------------------------------------------------------------
	Method onWindowAccept:Int( event:TEvent )
	DebugLog "NOT IMPLEMENTED: "+event.ToString()
	Return False
	End Method
	
	'------------------------------------------------------------
	Method onGadgetAction:Int( event:TEvent )
	DebugLog "NOT IMPLEMENTED: "+event.ToString()
	Return False
	End Method
	
	'------------------------------------------------------------
	Method onGadgetPaint:Int( event:TEvent )
	DebugLog "NOT IMPLEMENTED: "+event.ToString()
	Return False
	End Method
	
	'------------------------------------------------------------
	Method onGadgetSelect:Int( event:TEvent )
	DebugLog "NOT IMPLEMENTED: "+event.ToString()
	Return False
	End Method
	
	'------------------------------------------------------------
	Method onGadgetMenu:Int( event:TEvent )
	DebugLog "NOT IMPLEMENTED: "+event.ToString()
	Return False
	End Method
	
	'------------------------------------------------------------
	Method onGadgetOpen:Int( event:TEvent )
	DebugLog "NOT IMPLEMENTED: "+event.ToString()
	Return False
	End Method
	
	'------------------------------------------------------------
	Method onGadgetClose:Int( event:TEvent )
	DebugLog "NOT IMPLEMENTED: "+event.ToString()
	Return False
	End Method
	
	'------------------------------------------------------------
	Method onGadgetDone:Int( event:TEvent )
	DebugLog "NOT IMPLEMENTED: "+event.ToString()
	Return False
	End Method
	
	'============================================================
	Function EventHook:Object( id:Int, data:Object, context:Object )
	Local event:TEvent = TEvent( data )
	Local form:TGadget_Form = TGadget_Form( context )
		If Not event Or Not form Then Return data
		If form.onEvent( event ) Then Return Null
	Return data
	End Function
	
End Type
