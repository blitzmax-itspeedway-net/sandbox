' MINIGUI EXAMPLE

SuperStrict

Import "../minigui.bmx"

Graphics 800,600

' Allocate a context for the GUI
Global ctx:GUIContext

Repeat
	Cls
	DebugStop
	
	If ctx.start()
		If ( mg_begin_window(ctx, "My Window", New SRect(10, 10, 140, 86) ))
			mg_layout_row(ctx, 2, [ 60, -1 ], 0)

			FLabel(ctx, "First:")
			If (FButton(ctx, "Button1"))
				Print("Button1 pressed\n")
			End If

			FLabel(ctx, "Second:");
			If (FButton(ctx, "Button2"))
				mg_open_popup(ctx, "My Popup")
			End If

			If (mg_begin_popup(ctx, "My Popup"))
				FLabel(ctx, "Hello world!")
				mg_end_popup(ctx)
			End If

			mg_end_window(ctx)
		EndIf

		' Clean up and render
		ctx.finish()
	End If
	
	Flip
Until KeyHit( KEY_ESCAPE ) Or AppTerminate()