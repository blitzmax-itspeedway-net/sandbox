SuperStrict

Import bmx.json

' Note the missing single quote
Local dummy:String = "{'jsonrpc':'2.0','id':22,'method':'dummy','request':{'example':'sample}}".Replace("'",Chr(34))
Local x:JSON = JSON.Parse( dummy )

Print x.stringify()


