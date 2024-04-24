'   BMX.VISITOR
'   (c) Copyright Si Dunford, MMM 2022, All Rights Reserved. 
'   VERSION: 1.0

'	Blitzmax implementation of the visitor pattern

'   CHANGES:
'   DD MMM YYYY  Initial Creation
'
SuperStrict

'Import bmx.pnode
Import "../packrat.pnode/pnode.bmx"

Include "bin/TVisitor.bmx"


'Module bmx.visitor

Interface IVisitable
	Method accept:Int( visitor:IVisitor )
End Interface

Interface IVisitor
	Method visit:Int( visitable:IVisitable )
End Interface



