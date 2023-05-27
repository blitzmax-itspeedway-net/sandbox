SuperStrict

'# HEIRARCHY
'#
'# IControl
'#   TWidget
'#   TSizer
'#     TSizerBox


' Need to make sizer event aware and process resize messages itself.

Import Maxgui.drivers

Global FLAGS:Int

' Comment/uncomment any of the following lines to experiment with the different styles.

FLAGS:| WINDOW_TITLEBAR
FLAGS:| WINDOW_RESIZABLE
'FLAGS:| WINDOW_MENU
'FLAGS:| WINDOW_STATUS
FLAGS:| WINDOW_CLIENTCOORDS
'FLAGS:| WINDOW_HIDDEN
'FLAGS:| WINDOW_ACCEPTFILES
'FLAGS:| WINDOW_TOOL
FLAGS:| WINDOW_CENTER

Global window:TGadget = CreateWindow( AppTitle, 100, 100, 300, 200, Null, FLAGS )


'# LAYOUT FLAGS:
'Const szPRESERVE% = 0	'# Preserve size (Default)
Const szEXPAND%		= $0010		'# Forces it to resize with sizer
'Const szSHAPE% = 2		'# Forces resize but keeping aspect ratio

'# BoxSizer Orientations
Const szHORIZONTAL% = $3000
Const szVERTICAL% 	= $C000

'# Border Layout Flags (YOu can also use szHORIZONTAL & szVERTICAL )
Const szLEFT%		= $1000
Const szRIGHT%		= $2000
Const szBOTTOM%		= $4000
Const szTOP%		= $8000
Const szALL%		= $F000

'# Gadget alignment					'0000111100000000
'# Not valid when szEXPAND is being used.
Const szALIGN_LEFT%		= $0000		'xx00	0
Const szALIGN_RIGHT%	= $0001		'xx01	1
Const szALIGN_HCENTER%	= $0002	    'xx10	2
Const szALIGN_TOP%		= $0000    	'00xx	0
Const szALIGN_BOTTOM%	= $0004	    '01xx	4
Const szALIGN_VCENTER%	= $0008		'10xx	8'
Const szALIGN_CENTER%	= $000A		'1010	A

'# CreateButtonSizer Button definitions
Const szOK%				=	$0001
Const szYES%			=	$0002
Const szNO%				=	$0004
Const szCANCEL%			=	$0008
Const szYESNO%			=	$0006	
Const szYESNOCANCEL%	=	$000E	
Const szOKCANCEL%		=	$0009	
Const szNO_DEFAULT%		=	$8000	'# Default NO when return, otherwise OK/YES are default
Const szHELP%			=	$0010
Const szFORWARD%		=	$0020
Const szBACKWARD%		=	$0040
Const szSETUP%			=	$0080
Const szMORE%			=	$0100

'# FIRST TEST - BOX SIZER - HORIZONTAL
'DebugStop
'Local sizer:TBoxSizer = New TBoxSizer.Create( szHORIZONTAL )
Local sizer:TBoxSizer = New TBoxSizer.Create( szVERTICAL )
Local obj:TWidget
	sizer.add( CreatePanel(0,0,20,20,window), 1, szEXPAND | szLEFT, 0 )
	sizer.add( CreateButton("BUTTON1",0,0,83,27,window), 0, szALIGN_LEFT, 0 )
	sizer.add( CreateButton("BUTTON2",0,0,83,27,window), 0, szALIGN_RIGHT|szRIGHT, 10 )
	sizer.add( CreateButton("BUTTON3",0,0,83,27,window), 0, szALIGN_CENTER, 0 )

'# Insert a Horizontal sizer with three components
Local hsizer:TBoxSizer = New TBoxSizer.Create( szHORIZONTAL )
'	hsizer.add( Null )		'# AUTOFILL OBJECT
'	hsizer.add( "Example" )	'# Special Widget
	hsizer.add( CreateButton("Yes",0,0,83,27,window), 0, szALL|szALIGN_CENTER, 2 )
	hsizer.add( CreateButton("No",0,0,83,27,window), 0, szALL, 2 )
	sizer.add( hSizer, 0, szALIGN_RIGHT, 0  )

'sizer.add( CreateButtonSizer( window, szYES|szNO ) )

sizer.assign( window )  '# Can be a Window or Panel etc.


'# SECOND TEST - BOX SIZER - VERTICAL
'Local topsizer:TBoxSizer = New TBoxSizer.Create( szVERTICAL ) 

'Local obj:TWidget
'	topsizer.add( CreatePanel(0,0,5,5,window), szLEFT, 0 )
'	topsizer.add( CreatePanel(0,0,5,5,window), szRIGHT, 0 )

'Local bottomsizer:TBoxSizer = New TBoxSizer.Create( szHORIZONTAL ) 
'	topsizer.add( bottomsizer )
'	bottomsizer.add( CreatePanel(0,0,5,5,window), szLEFT, 0 )
'	bottomsizer.add( CreatePanel(0,0,5,5,window), szLEFT, 0 )

'topsizer.fit( window )

Repeat
	WaitEvent()
	Print CurrentEvent.ToString()
	Select EventID()
		Case EVENT_WINDOWSIZE
			sizer.fit()
		Case EVENT_APPTERMINATE, EVENT_WINDOWCLOSE
			End	
	End Select
Forever



'############################################################
Type IControl
Field _link:TLink
Field _gad:TGadget			' MaxGUI gadget
		' MaxGUI gadget
'# Fields required for Layout Manager
Field _Proportion:Float	= 0	'# Proportion of surplus space, Zero takes only it's own share of the space
Field _BorderSize:Int = 0
Field _Flags% =0
Field _Height:Float	= 0 	'# Height of object (When not expanding)
Field _Width:Float	= 0 	'# Width of object (When not expanding)

	'------------------------------------------------------------
	'# Methods required for Layout Manager
	Method _getMinimumHeight:Float()	;	Return _Height		;	End Method	
	Method _getMinimumWidth:Float()		;	Return _Width		;	End Method	
	Method _getProportion:Float()		;	Return _Proportion	;	End Method
	Method _setShape( xx:Float, yy:Float, ww:Float, hh:Float )	;	End Method
	'------------------------------------------------------------
	Method _CalcOffset( xo% Var, yo% Var, ww%, hh% )
		'# HORIZONTAL ALIGNMENT
		Select (_flags & $0003 )
		Case szALIGN_LEFT
			If (_flags & szLEFT) Then xo = _bordersize
		Case szALIGN_HCENTER
			xo = ( ww-_Width ) /2
		Case szALIGN_RIGHT
			If (_flags & szRIGHT) Then 
				xo = ww - _Width - _borderSize
			Else
				xo = ww - _Width
			End If			
		End Select
		'# VERTICAL ALIGNMENT
		Select (_flags & $000C )	
		Case szALIGN_TOP
			If (_flags & szTOP) Then yo = _bordersize
		Case szALIGN_VCENTER
			yo = ( hh-_Height ) /2
		Case szALIGN_BOTTOM
			If (_flags & szBOTTOM) Then 
				yo = hh - _Height - _borderSize
			Else
				yo = hh - _Height
			End If			
		End Select
	End Method
End Type

'############################################################
Type TSizer Extends IControl
Field Children:TList = CreateList()
Field Orientation%
'Field minimumW:Float, minimumH:Float

	'------------------------------------------------------------
	'# Add a gadget, widget or sizer to this sizer
	Method add:IControl( obj:Object, proportion:Float=0, flags%=0, bordersize:Float=0 )
	Local gadget:TGadget = TGadget( obj )
	Local sizer:TSizer = TSizer( Obj )
	Local widget:TWidget = TWidget( Obj )
'	Local str:String = String( Obj )
		Select True
		Case obj=Null	'# An Empty, autosizing cell.
			'# Insert Autosizing widget
			widget = New TWidget
			widget._proportion = 1
			widget._flags = 0
			widget._borderSize = 0
			widget._link = ListAddLast( children, widget )
		Case gadget<>Null
			'# Insert MaxGUI gadget into a TWidget container
			widget = New TWidget.fromGadget( gadget)
			widget._proportion = proportion
			widget._flags = flags
			widget._borderSize = borderSize
			widget._link = ListAddLast( children, widget )
		Case sizer<>Null
			'# Add a sizer
			sizer._proportion = proportion
			sizer._flags = flags
			sizer._borderSize = borderSize
			sizer._link = ListAddLast( children, sizer )
' This does not work unless a MaxGUI parent has been assigned already... 
' Later on, Create a TLebelWidget that either draws it or creates label during draw or something...
'		Case Str<>Null
'			'# Insert MaxGUI Label into a TWidget container
'			widget = New TWidget.fromGadget( CreateLabel( str,0,0,0,0,_gad ) )
'			widget._proportion = proportion
'			widget._flags = flags
'			widget._borderSize = borderSize
'			widget._link = ListAddLast( children, widget )
		Case widget<>Null
			'# Widget being added
			widget._proportion = proportion
			widget._flags = flags
			widget._borderSize = borderSize
			widget._link = ListAddLast( children, widget )
		Default
			Return Null
		End Select
	Return widget
	End Method

	'------------------------------------------------------------
	'# Fit the sizer objects to the window.
	Method assign( parent:TGadget )
		_gad = parent
		'#
		If _gad Then _fitChildren( 0,0, GadgetWidth( _gad ), GadgetHeight( _gad ) )		
	End Method

	'------------------------------------------------------------
	'# Fit the sizer objects to the window.
	Method fit()
		If _gad Then _fitChildren( 0,0, GadgetWidth( _gad ), GadgetHeight( _gad ) )		
	End Method
	
	'------------------------------------------------------------
	'# Fit the sizer objects to the window.
	Method _fitChildren( xx:Float, yy:Float, ww:Float, hh:Float ) Abstract
	
	'------------------------------------------------------------
	'# Minimum height of a Sizer is the maximum of it's children's minimums!
	Method _getMinimumHeight:Float()
	Local value:Float
		For Local item:IControl = EachIn Children
			value = Max( value, item._GetMinimumHeight() )
		Next
	Return value
	End Method	
	'------------------------------------------------------------
	'# Minimum width of a Sizer is the maximum of it's children's minimums!
	Method _getMinimumWidth:Float()
	Local value:Float
		For Local item:IControl = EachIn Children
			value = Max( value, item._GetMinimumWidth() )
		Next
	Return value
	End Method	
	'------------------------------------------------------------
	'# Changing the shape of a sizer updates all of it's children.
	Method _setShape( xx:Float, yy:Float, ww:Float, hh:Float )
		_fitChildren( xx, yy, ww, hh )
	End Method

End Type

'############################################################
'# Layout in an identical sized grid (Think calculator buttons)
Type TGridSizer Extends TSizer
End Type

'############################################################
'# Layout either horizontally or vertically. Elements have stretch properties to
'# Allow them to use more of the available space if necessary.
Type TBoxSizer Extends TSizer

	'------------------------------------------------------------
	Method Create:TBoxSizer( _orientation% = szHORIZONTAL )
		orientation = _orientation		
	Return Self
	End Method

	'------------------------------------------------------------
	'# Fit the sizer objects to the window.
	Method _fitChildren( xx:Float, yy:Float, ww:Float, hh:Float )
	Local item:IControl
	Local minSize:Float, bids:Float, size:Float, bidsize:Float, surplus:Float
	Local n:Float
'DebugStop
		Select orientation
		Case szHORIZONTAL
			'# Loop though children obtaining the Minimum width
			For item = EachIn Children
				minSize :+ item._GetMinimumWidth()
				bids    :+ item._GetProportion()
			Next
			'# We now have the minimum width, compare against real width and get surplus
'			minimumW = minSize	'# Save it...
			surplus = ww - minSize
			'#
			If surplus<=0 Then Return	'# WINDOW TOO SMALL!!!
			'#	
			If bids = 0 Then	'# Nothing expands so distribute evenly
'DebugStop

This is incorrect - If nothing expands, the sizer must align within the parent
A Right-Aligned sizer will display minimum-width/height objects aligned as required.

				size = ww / Float(CountList( children ))
				n = 0
				For item = EachIn Children
					item._setShape( n, yy, size, hh )
					n :+ size
				Next
			Else	
				'# Get the value for each bid
				bidsize = surplus / bids
				n = 0
				'# Calculate new size by splitting surplus between bidders
				For item = EachIn Children
					bids    = item._GetProportion()
					minSize = item._GetMinimumWidth()
					If bids>0 Then
						size = minsize + (bids * bidsize)
						item._setShape( n, yy, size, hh )
						n :+ size
					Else
						item._setShape( n, yy, minsize, hh )
						n :+ minsize
					End If
				Next
			End If
		Case szVERTICAL
'DebugStop
			'# Loop though children obtaining the Minimum height
			For item = EachIn Children
				minSize :+ item._GetMinimumHeight()
				bids    :+ item._GetProportion()
			Next
			'# We now have the minimum width, compare against real width and get surplus
'			minimumH = minSize	'# Save it...
			surplus = hh - minSize
			'#
			If surplus<=0 Then Return	'# WINDOW TOO SMALL!!!
			'#	
			If bids = 0 Then	'# Nothing expands so distribute evenly
				size = hh / Float(CountList( children ))
				n = 0
				For item = EachIn Children
					item._setShape( xx, n, ww, size )
					n :+ size
				Next
			Else	
				'# Get the value for each bid
				bidsize = surplus / bids
				n = 0
				'# Calculate new size by splitting surplus between bidders
				For item = EachIn Children
					bids    = item._GetProportion()
					minSize = item._GetMinimumHeight()
					If bids>0 Then
						size = minsize + (bids * bidsize)
						item._setShape( xx, n, ww, size )
						n :+ size
					Else
						item._setShape( xx, n, ww, minsize )
						n :+ minsize
					End If
				Next
			End If
		End Select
	End Method

End Type

'############################################################
'# Layout identical to TBoxSizer except that content is contained in a "Grouping panel".
Type TStaticBoxSizer Extends TBoxSizer
End Type

'############################################################
'# As per Grid sizer, but rows and columns can stretch
Type TFlexGridSize Extends TGridSizer
End Type

'############################################################
'# Create standard button sizer
'# Creates a Horizontal BoxSizer with standard buttons in it.
Function CreateButtonSizer:TBoxSizer( parent:TGadget, buttons%, ButtonX%=83, ButtonY%=27, ButtonSP%=5 )
Local sizer:TBoxSizer
	If buttons=0 Then Return Null
	'#
	Sizer = New TBoxSizer.Create( szHORIZONTAL )
	sizer.add( Null )		'# AUTOFILL OBJECT
	If (buttons & szYES) Then 
		If (buttons & szNO_DEFAULT ) Then
			sizer.add( CreateButton( "Yes", 0, 0, ButtonX, ButtonY, parent, BUTTON_PUSH|BUTTON_CANCEL ), 0, szALL, ButtonSP )
		Else
			sizer.add( CreateButton( "Yes", 0, 0, ButtonX, ButtonY, parent, BUTTON_PUSH|BUTTON_OK ), 0, szALL, ButtonSP )
		End If
	End If
	If (buttons & szNO) Then 
		If (buttons & szNO_DEFAULT ) Then
			sizer.add( CreateButton( "No", 0, 0, ButtonX, ButtonY, parent, BUTTON_PUSH|BUTTON_OK ), 0, szALL, ButtonSP )
		Else
			sizer.add( CreateButton( "No", 0, 0, ButtonX, ButtonY, parent, BUTTON_PUSH|BUTTON_CANCEL ), 0, szALL, ButtonSP )
		End If
	End If
	If (buttons & szOK) Then 		sizer.add( CreateButton( "OK", 0, 0, ButtonX, ButtonY, parent, BUTTON_PUSH|BUTTON_OK ), 0, szALL, ButtonSP )
	If (buttons & szCANCEL) Then 	sizer.add( CreateButton( "Cancel", 0, 0, ButtonX, ButtonY, parent, BUTTON_PUSH|BUTTON_CANCEL ), 0, szALL, ButtonSP )
	If (buttons & szHELP) Then 		sizer.add( CreateButton( "Help", 0, 0, ButtonX, ButtonY, parent, BUTTON_PUSH ), 0, szALL, ButtonSP )
	If (buttons & szFORWARD) Then 	sizer.add( CreateButton( "Forward", 0, 0, ButtonX, ButtonY, parent, BUTTON_PUSH ), 0, szALL, ButtonSP )
	If (buttons & szBACKWARD) Then 	sizer.add( CreateButton( "Backward", 0, 0, ButtonX, ButtonY, parent, BUTTON_PUSH ), 0, szALL, ButtonSP )
	If (buttons & szSETUP) Then 	sizer.add( CreateButton( "Setup", 0, 0, ButtonX, ButtonY, parent, BUTTON_PUSH ), 0, szALL, ButtonSP )
	If (buttons & szMORE) Then 		sizer.add( CreateButton( "More", 0, 0, ButtonX, ButtonY, parent, BUTTON_PUSH ), 0, szALL, ButtonSP )
Return sizer
End Function

'############################################################
'# A Widget is a wrapper for a TGadget
Type TWidget Extends IControl
Field link:TLink
Field r% = Rand(0,255)
Field g% = Rand(0,255)
Field b% = Rand(0,255)

'#
	'------------------------------------------------------------
	'# Default creation for testing only - Adds a Panel!
'	Method Create:TWidget()
'		gad = CreatePanel( 0,0,10,10,window)
'		SetGadgetColor( gad, r, g, b )
'		'# Minimum height and Width are the size they are created
'		_MinH = GadgetHeight( gad )
'		_MinW = GadgetWidth( gad )
'	Return Self
'	End Method
	
	'------------------------------------------------------------
	Method FromGadget:TWidget( gadget:TGadget )
		_gad = gadget
		SetGadgetColor( _gad, r, g, b )
		'# Minimum height and Width are the size they are created
		_Height = GadgetHeight( _gad )
		_Width = GadgetWidth( _gad )
	Return Self
	End Method
	
	'------------------------------------------------------------
	Method resize()
	End Method

	'------------------------------------------------------------
	Method _setShape( xx:Float, yy:Float, ww:Float, hh:Float )
	Local xo%, yo%				'# Offset
		If Not _gad Then Return	'# Ignore Autofill Widget
		If ( _flags & szEXPAND ) Then
			'# EXPAND
			SetGadgetShape( _gad, Int(xx), Int(yy), Int(ww+0.5), Int(hh+0.5) )
		Else
			'# POSITION ONLY
			_CalcOffset( xo, yo, ww, hh )

			'# Position the object
			SetGadgetShape( _gad, xx+xo, yy+yo, _Width, _Height )
		End If
	End Method


	'------------------------------------------------------------
	Method _getMinimumHeight:Float()
	Local border%=0
		If _BorderSize <= 0 Then Return _Height
		If (_flags & szTOP ) Then border :+ _borderSize	
		If (_flags & szBOTTOM ) Then border :+ _borderSize	
	Return _Height + Border
	End Method	

	'------------------------------------------------------------
	Method _getMinimumWidth:Float()
	Local border%=0
		If _BorderSize <= 0 Then Return _Width
		If (_flags & szLEFT ) Then border :+ _borderSize	
		If (_flags & szRIGHT ) Then border :+ _borderSize	
	Return _Width + Border
	End Method	

End Type
