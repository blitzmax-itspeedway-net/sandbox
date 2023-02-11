SuperStrict

Struct TOKEN
	Field ch:String
	Method New( ch:String )
		Self.ch = ch
	End Method
End Struct

Local tokens:TOKEN[]

tokens :+ [ New TOKEN("A") ]
tokens :+ [ New TOKEN("B") ]

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
