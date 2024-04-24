SuperStrict
'DebugStop
Local shortval:Short = 300
Local byteval:Byte = 32 
Local res:Short = shortval / byteval
Print res	' == 1

' This is caused by shortval being cast to a byte 
' before the division

