SuperStrict

Import bmx.json

Local JText:String = "{'workspace':{'test':true}}"

'Local J:JSON = JSON.Parse( JText )
'Local JJ:JSON = J.find( "workspace|configuration" )
DebugStop
'If JJ
'	Print JJ.Stringify()
'End If

Print "OK"