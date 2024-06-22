SuperStrict

' MicroUI

Import "ui.microui/microui.bmx"

Graphics 800,600

Global ctx:Tmu_Context = New TMu_Context()

Repeat
	Cls
	DebugStop
	
	If ctx.begin()
	
	If (mu_begin_window(ctx, "My Window", mu_rect(10, 10, 140, 86)))
		mu_layout_row(ctx, 2, [ 60, -1 ], 0)

		mu_label(ctx, "First:")
		If (mu_button(ctx, "Button1"))
			Print("Button1 pressed\n")
		End If

		mu_label(ctx, "Second:");
		If (mu_button(ctx, "Button2"))
			mu_open_popup(ctx, "My Popup")
		End If

		If (mu_begin_popup(ctx, "My Popup"))
			mu_label(ctx, "Hello world!")
			mu_end_popup(ctx)
		End If

		mu_end_window(ctx)
	EndIf
	
	Flip
Until KeyHit( KEY_ESCAPE ) Or AppTerminate()