SuperStrict

'# THE LOADER DOES NOT CURRENTLY SUPPORTED NESTED OBJECTS
'# A FORM, PANEL OR SIZER ARE ALL CONTAINERS AND CAN CONTAIN OTHER CONTAINERS
'# OR WIDGETS
'# NEED TO CHANGE LOADER TO SUPPORT THIS BEFORE ANY FURTHER WORK IS DONE

Import Maxgui.drivers

Global FLAGS:Int

' Comment/uncomment any of the following lines to experiment with the different styles.

FLAGS:| WINDOW_TITLEBAR
FLAGS:| WINDOW_RESIZABLE
FLAGS:| WINDOW_MENU
FLAGS:| WINDOW_STATUS
FLAGS:| WINDOW_CLIENTCOORDS
'FLAGS:| WINDOW_HIDDEN
FLAGS:| WINDOW_ACCEPTFILES
'FLAGS:| WINDOW_TOOL
'FLAGS:| WINDOW_CENTER

Local window:TGadget = CreateWindow( AppTitle, 100, 100, 320, 240, Null, FLAGS )

Local panel:TGadget = CreatePanel(10,10,ClientWidth(window)-20,ClientHeight(window)-20,window,PANEL_RAISED)
SetGadgetLayout panel, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED
SetGadgetColor(panel,$FF,$FF,$FF)

' and finally a group panel with a child button

Local group:TGadget = CreatePanel(10,ClientHeight(panel)-56,ClientWidth(panel)-20, 36,panel,PANEL_GROUP)
Local button:TGadget = CreateButton("OK",5,5,60,26,group)

'# THE ACTUAL TEST
Global form:TForm = New TForm.Create( panel )	'# Create a form and attach it to the canvas
form.Load( "example.bmf" )					'# Load the form
form.Show()									'# Display the form

DebugStop
Local surname:TGadget = form.getGadget( "surname" )
Local name:TWidget = form.getWidget( "name" )


SetGadgetText( surname, "Dunford" )

'# Debug
For Local item:TWidget = EachIn form.children
	Print "Gadget:   " + item.name + " " + Chr(34) + GadgetText(item.gad) + Chr(34)
	Print "Position: " + item.x + ", " + item.y
	Print "Size:     " + item.w + ", " + item.h
	Print ""
	
Next

If (FLAGS & WINDOW_STATUS) Then
	SetStatusText( window, "Left aligned~tCenter aligned~tRight aligned" )
EndIf

Repeat
	WaitEvent()
	Print CurrentEvent.ToString()
	Select EventID()
		Case EVENT_APPTERMINATE, EVENT_WINDOWCLOSE
			End
	End Select
Forever


'############################################################
Type TForm
'# Global Styling
Global GridX%=30, GridY%=30
Global MarginTop%=5, MarginLeft%=5, MarginRight%=5, MarginBottom%=5
Global Padding%=2
Global CharSize%= 12	'# Average width of a character, used for sizing objects
'#
Field parent:TGadget
Field children:TList = CreateList()		'# List of objects on this form
Field Name:String						'# Form Name
Field Caption:String					'# Form Title
'#
'# Layout Manager
Field XPos% = MarginLeft
Field YPos% = MarginTop

	'------------------------------------------------------------
	Method Create:TForm( _parent:TGadget, visible%=False )
		parent = _parent
		show()
	Return Self
	End Method
	
	'------------------------------------------------------------
	Method show( visible% = True )
		If visible Then
			ShowGadget( parent )
		Else
			HideGadget( parent )
		End If	
	End Method

	'------------------------------------------------------------
	Method Hide()
		HideGadget( parent )
	End Method

	'------------------------------------------------------------
	Method Load%( definition$ )
	
		Const MODE_START% = 0
		Const MODE_FORM% = 1
		Const MODE_WIDGET% = 2
		Const MODE_COMPLETE% = 99
	
		Const COMMAND% = 1
		Const ATTRIBUTE% = 2
DebugStop		
		'#
	Local line$, items$[], cmd$, key$, value$, pos%, args%, mode%, arg%
	Local file:TStream 
	Local this:TWidget
	'# LAYOUT MANAGER
	Local XPos% = 0
	Local YPos% = 0 

'		If FileType( definition ) <> 1 Then Return False
		file = OpenFile( definition, True, False )
		If Not file Then Return False
			
		While Not Eof( file )	
			line = ReadLine( file )
			line = Replace( line, "~t", " " )	'# Turn tabs to spaces
			line = Trim( line )
			If Not line Or line[..1]="!" Then Continue
			'#
			cmd = ""
			key = ""
			value = ""
			items = Null
			'#
			pos = Instr(line,"=")
			If pos=0 Then '# COMMAND not ATTRIBUTE
				arg = COMMAND
				'# Simply split on space
				items = line.split(" ")
				args  = items.length
				cmd   = Upper( items[0] )
'Print items.length
				If items.length>1 Then key = items[1]
				If items.length>2 Then value = value.join( items[2..] )
			Else
				arg = ATTRIBUTE
				'#
				args  = 2	'# ALWAYS 1 ARGUMENT
				key   = Upper(Trim(line[..(pos-1)]))
				value = Trim(line[pos..])
			End If
			value = stripQuotes( value )
			'#
'DebugStop
			Select mode 
			Case MODE_START
				If cmd <> "FORM" Then Return fail( file ) 
				If Not key Then Return fail( file )
				name 	= key
				caption = value
				mode 	= MODE_FORM
			Case MODE_FORM
				Select arg
				Case ATTRIBUTE
					Select key
					Case "CAPTION"
						If args<>2 And arg<>ATTRIBUTE Then Return fail( file )
						Caption = value
					Default
						Return fail(file)
					End Select
				Case COMMAND					
					Select cmd
					Case "END"
						If arg<>1 Then fail( file )
						mode = MODE_COMPLETE
					Case "LABEL"
						this = New TWidget.add( Self, key, CreateLabel( value,0,0,5,5,parent ))
						mode = MODE_WIDGET
					Case "TEXTBOX"
						this = New TWidget.add( Self, key, CreateTextField( 0,0,5,5,parent ))
						mode = MODE_WIDGET
					Case "BUTTON"
						this = New TWidget.add( Self, key, CreateButton( value,0,0,5,5,parent ))
						mode = MODE_WIDGET
					Case "GRIDSIZER"
						this = New TWidget.add( Self, "", CreatePanel( 0,0,ClientWidth(parent),ClientHeight(parent),parent ))
						mode = MODE_WIDGET					
					Default
						Return fail( file )
					End Select
				End Select
			Case MODE_WIDGET
				Select arg
				Case ATTRIBUTE
					Select key
					Case "TEXT"		SetGadgetText( this.gad, value )
					Case "TOP"		this.setY( value.toint() * GridY )
					Case "LEFT"		this.setX( value.toint() * GridX ) 
					Case "WIDTH"	this.setW( value.toint() * GridY )
					Case "HEIGHT"	this.setW( (value.toint() * GridY) - Padding )
					Case "CAPTION"	
					Default
						Return fail( file )
					End Select
				Case COMMAND
					Select cmd
					Case "END"
						If arg<>1 Then fail( file )
						this = Null
						mode = MODE_FORM
					Default
						Return fail(file)
					End Select
				End Select
			Default
				Return fail( file )
			End Select
				
		Wend
		
		CloseFile( file )
	End Method
		
	'------------------------------------------------------------
	Method stripQuotes:String( from:String )
	Local pos%
		' Remove quotes around string
		If from[..1]=Chr(34) Then 
			If from.endswith(Chr(34)) Then
				pos = Len(from)-1
				Return from[1..pos]
			End If
		End If
		Return from
	End Method

	'------------------------------------------------------------
	Method Fail:Int( file:TStream )
		CloseFile( file )
		For Local item:TWidget = EachIn children
			item.die()
		Next
		ClearList( children )
		Return False
	End Method	

	'------------------------------------------------------------
	'# Gets the MaxGUI gadget
	Method getGadget:TGadget( name:String )
	Local result:TWidget = _find( name )
		If result Then Return result.gad
		Return Null
	End Method
	
	'------------------------------------------------------------
	'# Gets the Form Widget
	Method getWidget:TWidget( name:String )
	Return _find( name )
	End Method
	
	'------------------------------------------------------------
	'# Gets the Form Widget
	Method _find:TWidget( name:String )
		For Local item:TWidget = EachIn Children
			If item.name = name Then Return item
		Next	
	Return Null
	End Method

End Type

'############################################################
Type TWidget
Global tx%=0, ty%=0, tw%=50, th%=30		'# TEMPLATE SIZES
Field form:TForm
Field gad:TGadget
Field name:String
Field link:TLink
Field x%,y%,w%,h%
	'------------------------------------------------------------
	Method Add:TWidget( _parent:TForm, _name:String, _gadget:TGadget )
		name = _name
		gad  = _gadget
		form = _parent
		link = ListAddLast( form.children, Self )
		'#
		x=form.XPos
		y=form.Ypos
		w=Len(GadgetText( gad ) ) * form.CharSize
		h=Form.GridY - Form.Padding
		'#
		resize()
		
	Return Self
	End Method
	'------------------------------------------------------------
	Method SetX(value%)
		x=value
		resize()
	End Method
	'------------------------------------------------------------
	Method SetY(value%)
		y=value
		resize()
	End Method
	'------------------------------------------------------------
	Method SetW(value%)
		w=value
		resize()
	End Method
	'------------------------------------------------------------
	Method SetH(value%)
		h=value
		resize()
	End Method
	'------------------------------------------------------------
	Method resize()
		SetGadgetShape( gad, x, y, w, h )
		form.XPos = x + w + form.Padding
		form.YPos = y + h + form.Padding
	End Method
	'------------------------------------------------------------
	Method die()
		If gad Then FreeGadget( gad )
		RemoveLink( link )
	End Method
	
End Type