
# KNOWN BUGS

* TAB / SHift tab uses variables in the UI state, these should be in the frame state
  so that tabbing is local to the window or frame and not the whole UI
  Tabbing in a panel, should use the parent window or frame focus and not local state
  this could cause a weird bug, so will need some investigation first

# Components

| NAME      | VER | STATE
+-----------+-----+-------
| Button    | 1.0 |
| Container | 2.0 |
| Frame     | 1.0 |
| IntBox    | 1.0 |  
| Label     | 1.0 |
| Layout    | 2.0 |
| OnOff     | 1.0 |

# Version 3

* Based on Version 1 for simplicity
* Not backward compatible with version 2.0
* First public release
* Created several examples / demo
* Rename from proto.ux to bmx.imgui as a module
* Replaceable style
* Replaceable renderer

# Change Log

VER  DATE         DESCRIPTION
1.0  19 SEP 2022  Proto.UX  Initial version (Button, Frame, Intbox, Label, OnOff)
2.0  23 FEB 2023  Proto.UX  Added Container and Stack-based Layout using Objects
3.0  08 JUN 2024  BMX.IMGUI Based on Version 1.0 for simplicity
	- Replaced "Type UX" with "Struct IMGUI"
	  - Replaced Functions with methods
	  - Removed constants (They cannot exist inside a struct)
	- Added IMGUI.BeginDraw() and IMGUI.EndDraw() to manage state and rendering
	- Added replaceable Style (GUIStyle) using IMGUI.setStyle()
	- Added replaceable renderer using IMGUI.setRender()
	- Added render pipeline using SRenderer and renderlist
	- Created default style and renderer
	- Added initialise() to initialise styles and default renderer
	- Colour constants moved to bin/styles.bmx, renamed and re-ordered
	- Replaced V1.0 _DrawCaption_() with Pipeline IMGUI_RENDER_TEXT command
	- Replaced V1.0 DrawRect() with Pipeline IMGUI_RENDER_RECT command
	- Replaced V1.0 DrawLine() with Pipeline IMGUI_RENDER_LINE command
	- Added IMGUI.align(), renamed alignment constants, added vertical alignment
	- Renamed IMGUI.Frame() to IMGUI.Frame1() in preparation for replacement
	- Added IMGUI.Window() and EndWindow()
	- Added DrawIcon() with Pipeline IMGUI_RENDER_ICON command
	- Added DrawCircle() with Pipeline IMGUI_RENDER_CIRCLE command
	- Added DrawImage() with Pipeline IMGUI_RENDER_IMAGE command
	- Added image for default icon set (Only CLOSE icon at present)
	- Added OUTLINE option to draw an unfilled rectangle
	- Improved keyboard focus with better TAB/Sh-TAB support


