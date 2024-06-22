

' This is a FREE/USED list, currently using TLIST
Type TStacked

	Field usedlist:TList
	Field freelist:TList
	Field usedPtr:Int = 0
	Field freePtr:Int = 0
	'Field chunksize:Int			' Size allocated to grow
	Field allocator:Object()	' Function used to allocate new nodes
	
	Method New( allocator:Object(), initial:Int=20, chunksize:Int=20 )
		usedlist = New TList()
		freelist = New TList()
		Self.allocator = allocator
	End Method
	
	' Get object from freelist or create new object
	Method allocate:Object()
		Local item:Object = freelist.removelast()
		If Not item; item = allocator()
		usedlist.addlast( item )
		Return item
	End Method
	
	' Move object from used list to freelist
	Method free( item:Object )
		usedlist.remove( item )
		freelist.addlast( item )
	End Method

	' Move object from used list to freelist
	'Method freelink( item:TLink )
	'	usedlist.removelink( link )
	'	freelist.addlast( item.value )
	'End Method
	
End Type



