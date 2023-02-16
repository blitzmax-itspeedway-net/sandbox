Rem 
	16 FEB 2023 - FIXED IN LATEST / FAILS IN OFFICIAL
End Rem

SuperStrict
DebugStop

Struct TOKEN
	Field ch:String
	Method New( ch:String )
		Self.ch = ch
	End Method
EndStruct

Local tokens:TOKEN[2]

tokens[0] = New TOKEN("A")
tokens[1] = New TOKEN("B")

DebugStop
Rem
	When you get here:
	* Look in MaxIDE Debug Tab
	* Expand "Local tokens:TOKEN[]=$..."
	* Look at the two array values
	* Now change Type TOKEN into Struct TOKEN
	* Repeat the procedure
	
	When it is a Struct, you get "Segmentation fault (core dumped)"
	

EndRem
