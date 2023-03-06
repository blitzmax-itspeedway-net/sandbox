SuperStrict

Import "UI.bmx"

Global quit:Int = False

Function WindowClose( event:TEvent )
	quit = True
End Function

Local win:UIWindow = New UIWindow( 320,200, 100,100, "Test1" )
win.on( EVENT_WINDOWCLOSE, WindowClose )
win.show()

Local tv:UITreeview = New UITreeview( window, 10, 10, 100, 100 )

Local root:UINode = tv.add( "This is the root" )

root.add( "First" )
root.add( "Second" )
root.add( "Third" )

Repeat
	WaitEvent()
Until AppTerminate() Or quit
