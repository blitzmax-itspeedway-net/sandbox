' 04 SEP 2021

SuperStrict
Local Text:String = "}}"
DebugStop
Print Text

Rem
16 FEB 2023
FIXED IN LATEST RELEASE

MANUAL FIX FOR OFFICIAL RELEASE
A fix was found by GWRON (on Discord) for this issue as follows:

open up /mods/maxgui.mod/localization.mod/localization.bmx, go to line 222 and replace:

                        'If previous char was also a closing "}" then we're leaving a token, so interpret it.
                        If tmpPrevChar = Text[i] Then
with:

                        'If previous char was also a closing "}" then we're leaving a token, so interpret it.
                        'ensure tmpCount is > 0 ("{{" was found)
                        If tmpPrevChar = Text[i] and tmpCount > 0 Then

Recompile maxgui.mod
Recompile MaxIDE
Copy maxide as MaxIDE into /BlitzMax folder replacing the shipped one.

EndRem
