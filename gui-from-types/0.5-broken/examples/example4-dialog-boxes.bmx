SuperStrict

'	Dialog Boxes
'	Author: Si Dunford [Scaremonger], June 2023

Include "../typegui.0-6.bmx"

AppTitle = "Example #4 - Image Template"

' TDialog not moved into library until tested
Type TDialog Extends TForm

	Field title:String = AppTitle
	Field state:Int = False
	
	Method New()
	End Method

	Method New( title:String )
		Self.title = title
	End Method

	Method onGui( id:Int, event:TEvent )
		' If id = EVENT_BUTTON_PRESSED and event.data="YES"
		'	state=True
		' end if
	End Method
	
	Method show:Int( modal:Int = False )
		Super.show( modal )
		Return state
	End Method

End Type

Graphics 320,200

'	Create a sample form
DebugStop
Local AreYouSure:TDialog = New TDialog( "Annoying question!" )
Local content:TPanel = New TPanel( LAYOUT_HORIZONTAL )
Local buttons:TPanel = New TPanel( LAYOUT_HORIZONTAL )

'content.add( New TIcon( ICON_QUESTION ) )
content.add( New TLabel( "Are you sure?" ) )
buttons.add( New TButton( "YES" ) )
buttons.add( New TButton( "NO" ) )

form.setModal( True )
form.add( content )
form.add( buttons )

form.center()	' Center the form
form.pack()		' Resize to minimum (Uses layout manager)

Local quit:Int = False
Repeat
	SetClsColor( 0,0,0 )
	Cls
	SetColor( $ff, $ff, $ff )
	DrawText( "Press Escape or [x] to close appliction" )

	If KeyHit( KEY_ESCAPE ) Or AppTerminate()
		quit = GUI.show( True )
	End If

	Flip
Until quit

