SuperStrict

Import maxgui.drivers
'Include "../bin/TForms.bmx"

'# First get a file definition
'Local filename$ = RequestFile( "Form", "BlitzMax Form:bmf" )
Local filename$ = "Example1.frm"
If Not filename Then End



'# Now create a window upon whcih to display the form
'# (Form is shown on a panel)
Local style% = WINDOW_TITLEBAR | WINDOW_RESIZABLE | WINDOW_CENTER
Global window:TGadget = CreateWindow( AppTitle, 0,0,800,600, Null,style )

'# Create form
Local form:TForm = New TForm.Create( window )

form.Load( "FORM1", filename )

'form.setValue( "name", "Si Dunford" )

form.show()
'form.showModal()

'# After calling show, the application continues...

'# Need to find a awy to capture action assigned to button so that we can progress along a workflow path..
'# A FORM must return TRUE (SUCCESS/OK), FALSE (FAIL/CANCEL). It can also return other values

'The form needs To be soft-coded To the buttons, maybe we can use extra s=To store the FORM Ptr?

'We also need GetElementByName

Repeat
	WaitEvent()
	Print CurrentEvent.ToString()
	Select EventID()
		Case EVENT_APPTERMINATE, EVENT_WINDOWCLOSE
			End
		Case EVENT_GADGETACTION
			Local f:TForm 
			Local gad:TGadget = TGadget( EventSource() )
				If gad Then 
					f = TForm( GadgetExtra( gad ) )
					If f Then f.click( gad )
				End If
	End Select
Forever

Function form1_button1_click()
Print "CLICK"
End Function

Type TForm Extends TWidget
Field parent:TGadget
Field children:TList = CreateList()
'
'# GRID
Field GX%=30, GY%=30

	Method New()
		
	End Method
	
	Method Delete()
		Print "YES IT WORKED"
	End Method

	Method Create:TForm( window:TGadget )
		parent = window
		Return Self
	End Method

	Method Load:TForm( name$, file$ )
	Local data$
	Local widget:TWidget
	Local line$, symbols$[], this:TFormField
	Local f:TStream

	Const STATE_NONE%=0
	Const STATE_FORM%=1
	Const STATE_OBJECT%=2

		'# IS FILE A FILENAME OR DATA	
		If Not file Then Return Null
		If FileType( data ) = FILETYPE_FILE Then 
			Try
				data = LoadString( file )
				If Not data Then Return Null
			Catch exception$
				Return Null
			EndTry
		Else 
			data = file
		End If

		'# Now loop through form definition, line at a time
		
		_Configure( data )
		If Trim(data) Then Print "WARNING: Contet past end of definition has been ignored"
		
		
		'# Create some dummy objects rather than load them at the moment
		ListAddLast( children, CreateLabel( "NAME:", 10,10,50,30, canvas ) )
		ListAddLast( children, CreateLabel( "TEL:", 10,50,50,30, canvas ) )

		ListAddLast( children, CreateTextField( 60,10,50,30, canvas ) )
		ListAddLast( children, CreateTextField( 60,50,50,30, canvas ) )
		
	Local btn:TGadget
		btn = CreateButton( "Save", 10,100,60,30, canvas )
		SetGadgetExtra( btn, Self )
		ListAddLast( children, btn )
		
		btn = CreateButton( "Canvas", 80,100,60,30, canvas )
		SetGadgetExtra( btn, Self )
		ListAddLast( children, btn )

		
	End Method
	
	Method _configure%( data$ )
		line = Trim(_getline( data ))
		If Not line Then Continue		'# Ignore empty lines
		If line[..1]="!" Then Continue 	'# Ignore line comments
		
		'# Valid line
		symbols = line.split( " " )
		If symbols.length<>3 Then Return Null	'# Incorrect format
		If Not (Upper(symbols[0]) = "OBJECT" And Upper( symbols[2] ) = "FORM" ) Then Return Null	'# Unexpected
		
		gadget = CreateCanvas( 20, 20, 300, 300, window )
		_LoadData( data )
		
	End Method

	Method show()
	End Method
	
	Method hide()
	End Method
	
	Method showModel()
	End Method

	Method click( gad:TGadget )
	Print "CLICKED ON " + GadgetText( gad )
	End Method

	Method getElementByName:TGadget( name$ )
	Return Null
	End Method

End Type

Type TWidget
Field Name$
Field Class$
Field gadget:TGadget

	'#--
	Method _getLine$( data$ Var )
	Local pos%		= Instr(data,Chr(10))		'# Find linefeed
	Local line$		= data[..pos]
		data = data[pos..]
	Return line
	End Method

	Method _configure%( data$ )
		Repeat
			line = Trim(_getline( data ))
			If Not line Then Continue		'# Ignore empty lines
			If line[..1]="!" Then Continue 	'# Ignore line comments
			
			'# Valid line
			symbols = line.split( " " )
			If symbols.length<>3 Then Return Null	'# Incorrect format
			If Not (Upper(symbols[0]) = "OBJECT" And Upper( symbols[2] ) = "FORM" ) Then Return Null	'# Unexpected
			
			gadget = CreateCanvas( 20, 20, 300, 300, window )
			Read( data )
									
		'		End If				
				
			If line And Upper(line)="END" Then
				Return True
			Else
				Return False	'# Error occurred
			End If
		Until Not line Or Not data
	End Method

End Type

