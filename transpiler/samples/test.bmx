'   This program tests framework, import and include statements
' More comments

REM More comments
END REM

REM AND EVEN MORE
ENDREM
superstrict

import abc.xyz
import brl.retri

include "xyz.bmx"

type abc
    method xyz()
    end method
end type

' My example type
type xyz extends abc    ' Mytype

    method abc123()
    end method

end type

function bbb()
    local a:int = 10
    print( a )
end function

local x:int = 10
print( x )
print x

function abc()
end function

