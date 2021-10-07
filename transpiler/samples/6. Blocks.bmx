SuperStrict ' da da

Type mytype1        ' THINGY

    Field x:Int

End Type

Type mytype2
    
    Field x:Int

    Method add()
        x:+1
    End Method

EndType

Struct Thing
    Field one:Int
End Struct

Enum Bool
	yes,no
EndEnum

Local daytime:Bool = Bool.yes
Print daytime.toString()

Rem

    type falsefn
    local x
    end type

end rem

Function abc:Int()
    Return False
End Function

Function xyz( a:Int )
    Print( a )
EndFunction

For Local x:Int = 1 To 10
    Print x
Next

If True Print "TRUE"

If True=False
    Print "no way"
End If

If False=True Then
    Print "no way"
EndIf

Local x:Int = 10
While x>0
   x :- 1
Wend

x=10
Repeat
    x :- 1
Until x<1

Select x
Case 0
	Print "ZERO"
Case 1
	Print "ONE"
Default
	Print "NONE"
EndSelect








