'SuperStrict
'#

'# Include the basic components
Include "bin/GObject"

'# Include the default GUI driver
Include "bin/Driver_MaxGUI.bmx"

'HOW DO I Create OVERLAPPING OBJECTS And Select WHICH SET To USE?





'# To Over-ride this, you need to call
'# TMax2DDriver.install()
'# TMaxGUIDriver.install()
'# TFryGuiDriver.install()
'# etc

'# Include the Definition file Parser
Include "bin/TFormParser.bmx"

'# Constants
Const MODAL:Int		= True

'############################################################
Type TGUIDriver
End Type

Rem SOURCE DOCS

form.show( MODAL=false)
form.load
form.unload
frm.hide

pass "me" into handlers

Form_Unload( me:TForm )

'# Possible extensions
form.center
form.

End Rem

Rem TO DO
* load() shoudl identify if the input string is a file. If so it should read it, if not then it should treat it like file content and aprse it.

End Rem



Rem
@@@@@@ VERSION 0.1 AFTER THIS POINT @@@@@

Const ERR_SUCCESS%			= 0		'# Not really an error!
Const ERR_EOF%				= 1		'# Unexpected End of file
Const ERR_FILEOPEN%			= 2		'# Error opening file
Const ERR_UNSUPPORTED%		= 3		'# File unsupported
Const ERR_INVALID%			= 4		'# File content invalid 

Const MODAL% = True

'############################################################
'Function LoadForm:TForm( file:String, handler:Object )
'Return New TForm.Load( file, handler )
'End Function

Rem

'############################################################
Type TForm
Field LastErrCode%, LastErrText$, LastErrLine%
Field parser:TFormParser	'# The parser that is being used to create form
Field window:TElement		'# The form window element
Field handler:TForm			'# The application event handler
Field driver:TFormDriver	'# The GUI driver that will create the window
'#
	'------------------------------------------------------------
	Method New()
		driver = New TFormDriverMAXGUI
	End Method
	
'Private
	'------------------------------------------------------------
	Method ErrCode%()
	Return LastErrCode
	End Method

	'------------------------------------------------------------
	Method ErrLine%()
	Return LastErrLine
	End Method

	'------------------------------------------------------------
	Method ErrTest$()
	Return LastErrText
	End Method

'Public
	'------------------------------------------------------------
	Method FormResult:TGadget( criteria$ )
	Local element:TElement = window.search( criteria )
	Return element._gadget
	End Method
	
	'------------------------------------------------------------
	Method GetGadgetByName:TGadget( criteria$ )
	Local element:TElement = window.search( criteria )
	Return element._gadget
	End Method

	'------------------------------------------------------------
	Method GetElementByName:TElement( criteria$ )
	Return window.search( criteria )
	End Method

	'------------------------------------------------------------
	Method Hide%()
	window.hide()
	End Method

	'------------------------------------------------------------
	'# load a definition file
	Method Load:TForm( file:String )
'	DebugStop
		If FileType( file )<>1 Then Return Null
		Select Lower( ExtractExt( file ))
		Case "bfd" ; parser = New TFormParserBFD.Create( Self )	'# BlitzMAX Form Definition
'		Case "frm" ; parser = New TFormParserFRM.Create( Self )	'# VB6 Form Definition  ## EXPERMIMENTAL ##
		End Select
		If Not parser Then Return Null
		'#
		If Not parser.Load( file ) Then Return Null
		handler = Self
	Return Self
	End Method

Rem	'------------------------------------------------------------
	'# Read a definition from a text string
	Method Read:TForm( filedata:String, format$="bfd" )
	DebugStop
		Select Lower( format )
		Case "bfd" ; parser = New TFormParserBFD.Create( Self )	'# BlitzMAX Form Definition
'		Case "frm" ; parser = New TFormParserFRM.Create( Self )	'# VB6 Form Definition  ## EXPERMIMENTAL ##
		End Select
		If Not parser Then Return Null
		'#
		If Not parser.Load( filedata ) Then Return Null
		handler = Self
	Return Self
	End Method
End Rem
	
Rem

	'------------------------------------------------------------
	'# Change the GUI driver from the MAXGUI default.
	Method setDriver( d:TFormDriver )
		If driver Then driver = Null
		driver = d
	End Method
	
	'------------------------------------------------------------
	Method Show%( Modal% = False )
	Local quit% = False
'TODO: Add second variable to allow loading as well!
'DebugStop
		If Not window Then Return False	'# Fail if no window element exists
		window.build( parser, handler )
		window.show()
		AddHook EmitEventHook, EventHandler
		Repeat
			WaitEvent()
			Print CurrentEvent.ToString()
			Select EventID()
				Case EVENT_APPTERMINATE, EVENT_WINDOWCLOSE
					quit = True
			End Select
		Until quit
		RemoveHook EmitEventHook, EventHandler
		window.demolish()
		window = Null
	End Method

	'------------------------------------------------------------
	'# Sets the status text of the form (if statusbar is enabled of course)
	Method StatusText( text$ )
		If window Then window.statusText( text )
	End Method
	
'Private
	'------------------------------------------------------------
	Function EventHandler:Object( id:Int, data:Object, context:Object )
'	Local Element:TFormElement = TFormElement( context )
	Local event:TEvent = TEvent( data )
	Local gadget:TGadget 
	Local element:TElement

		If Not event Then Return data
Print "EVENT:    "+event.tostring()

		gadget = TGadget( event.source )
		If gadget Then
			element = TElement( gadget.extra )
			If element Then
				Select event.id
				Case EVENT_APPSUSPEND
				Case EVENT_APPRESUME
				Case EVENT_APPTERMINATE
				Case EVENT_KEYDOWN
				Case EVENT_KEYUP
				Case EVENT_KEYCHAR
				Case EVENT_MOUSEDOWN
				Case EVENT_MOUSEUP
				Case EVENT_MOUSEMOVE
				Case EVENT_MOUSEWHEEL
				Case EVENT_MOUSEENTER
				Case EVENT_MOUSELEAVE
				Case EVENT_TIMERTICK
				Case EVENT_HOTKEYHIT
				Case EVENT_MENUACTION
				Case EVENT_WINDOWMOVE
				Case EVENT_WINDOWSIZE
				Case EVENT_WINDOWCLOSE
				Case EVENT_WINDOWACTIVATE
				Case EVENT_WINDOWACCEPT
				Case EVENT_GADGETACTION
Print "===> " + Element.name + "_GadgetAction()"
					callHandler( Element, "Action", event )
				Case EVENT_GADGETPAINT
				Case EVENT_GADGETSELECT
				Case EVENT_GADGETMENU
				Case EVENT_GADGETOPEN
				Case EVENT_GADGETCLOSE
				Case EVENT_GADGETDONE
				End Select
'			Print "->" + element.gettext()		
		Print "CALLING: " + Element.name + "_" + event.id + "()" + event.tostring()
			End If
		End If
	
	Return data	
	End Function

	'------------------------------------------------------------
	Function callHandler( Element:TElement, Action$, event:TEvent )
	Local tid:TTypeId=TTypeId.ForObject( Element.form )
	Local run:TMethod
	Local call$ 
'DebugStop
		If tid Then
			call = Element.Name + "_" + Action
			run = tid.findMethod( call )
			If run Then run.invoke(Element.form,[event])
		End If
	End Function
	
End Type



