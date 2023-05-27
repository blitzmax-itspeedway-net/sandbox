
'	Indirected List
'	(c) Copyright Si Dunford, Feb 2028, All Rights Reserved

'	EXPERIMENTAL
'	VERSION 2.0

Rem	OBSERVATIONS:
EndRem

Rem

	Instead of pointers this ECS uses handles containing an index to a table.
	The advantage is that an old index cannot point to an unreferenced or deleted object
	it simply points to something that returns invalid!
	
	We have created one level of indirection.

	In this version:
	* I have dropped the signature field in preference that the System Manager
	  maintains its own list.
	* Dropping the signature ID, means that I can split the handle in two and still have
	  the 16 lower bits for the index.
	* The bit-mask is static
	* The Free stack has been changed from a FILO to a FIFO to reduce wrap-around version 
	  numbers for Short lived objects

	A handle is a 32 bit UINT constructed from two fields:

	UINT:	00000000 00000000 00000000 00000000 
            Spare--> Version> Index----------->

	Version is used to keep the list elements unique when records are changed
	Index is a unique entity, which means you can has 2^16 entities in your game
	
	HOW DOES IT WORK?
	The index maintains a linked list of free and used THandleRecords.
	When you add, a record is moved from the free list to the used.
	When you delete, the record is moved from the used to the free.
	
	An index version must match before the list is updated
	so an invalid entity key no longer points to a record in the list.

End Rem

Const DEFAULT_ARRAY_SIZE:Int = 1024

Type THandle

	' NOTE: We cannot use a STRUCT here because we need to return NULL
	'       When a record no longer exists.
	'		We also need to extend this and we can't do that for a struct!


	Const INVALID:UInt = 0

	Private

	Field index:UInt, version:UInt
	
	Public 

	Method New( index:UInt, version:UInt )
		Self.index     = index
		Self.version   = version
	End Method
	
	'Method add( signature:UInt )
	'	Self.signature = Self.signature | signature
	'End Method

	'Method remove( signature:UInt )
	'	Self.signature = Self.signature & ~signature
	'End Method

End Type

'	The handle index needs to store a Type that we will call THandleRecord which contains the real data
'	pointer along with some management fields for version and the free list

Type THandleRecord
	'Field handle:THandle		' The owning handle
	Field name:String
	'
	Field version:UInt			' Version of the data (Should match the handle)

	Field _prev:Int				' pointer to previous free record. 0=none
	Field _next:Int				' pointer to next free record. 0=none
	
	Field enable:Int = False
	
	Method enabled:Int()
		Return enable
	End Method
EndType

'	Now we use THandleRecord to construct an index for the data

Type TIndirectionList

	Field list:THandleRecord[]		' list[0] is RESERVED
	Field capacity:Int				' Size of the array
	
	' POinters to the free list
	Field head:Int = 0
	Field tail:Int = 0

	' Counters
	Field _used:Int = 0

	Method New()
		list = New THandleRecord[ DEFAULT_ARRAY_SIZE ]
		reset()
	End Method

	Method New( size:Int )
		'DebugStop
		list = New THandleRecord[ size ]
		capacity = size
		reset()
		'DebugStop
	End Method
	
	' Reset the list freeing all entries
	Method reset()
		_used = 0
		' Index 0 is invalid and therefore we do not create a record
		For Local i:Int = 1 Until list.length
			If Not list[i] ; list[i] = New THandleRecord()
			list[i]._prev = i - 1
			list[i]._next = i + 1
			list[i].enable = False
		Next
		' Adjust references
		head = 1
		tail = list.length-1
		list[head]._prev = 0
		list[tail]._next = 0
	End Method
	
	Method add:THandle( name:String="" )
	
		Local index:UInt = head
		If index=0 ; Return Null ' No handles available
		
		' Update head 
		head = list[head]._next
		If head; list[head]._prev = 0
		If tail = index; tail = 0

		' Allocate record
		list[index]._next = 0		' Clear free ptr
		list[index]._prev = 0		' Clear free ptr
		list[index].enable = True	' Enable handle
		list[index].version :+ 1	' Increment revision
		
		' Fix version overflow
		If list[index].version > $ff ; list[index].version = 1
		If list[index].version = 0 ; list[index].version = 1
		'
		list[index].name = name
		_used :+ 1
		
		Return New THandle( index, list[index].version )
	End Method

	' Replace data in a handle with new data
'	Method Replace( handle:THandle, data:Object )
'		Local index:Int = handle.index
'		' Only allow replacements for matching versions
'		If handle.index <> THandle.INVALID And handle.version = list[index].version And list[index].enabled()
'			list[index].data = dataI NOW NEED To CONVERT MY TEST To USE THE CONTROLLER
'		End If
'	End Method
	
	' Release a handle back to the system
	Method remove( handle:THandle )
		Local index:Int = handle.index
		If handle.index <> THandle.INVALID And handle.version = list[index].version And list[index].enabled()
			' insert into end of free list
			If head=0 And tail=0
				head = index
				tail = index
			Else				
				list[tail]._next = index
				list[index]._prev = tail
				tail = index
			EndIf
			
			list[index].enable = False	' Disable handle
			list[index].name = ""
			_used :- 1	' Decrease counter
		End If
	End Method

	' Returns the amount of active records
	Method size:Int()
		Return capacity-1
	End Method

	' Returns the amount of active records
	Method used:Int()
		Return _used
	End Method

	' Returns the amount of free records
	Method free:Int()
		Return capacity-_used-1
	End Method

	' Handle to Serialised Index
	Method serialise:UInt( handle:THandle )
		If Not handle Return THandle.INVALID
		Return handle.index | (handle.version Shl 16)
	End Method

	' Serialised Index to Handle
	Method deserialise:THandle( index:UInt )
		Return New THandle( index & $00ff, (index & $f000) Shr 24 )
	End Method
	
	' Return the maximum number of handles in the list
	Method maximum:Int()
		Return list.length-1
	End Method
	
	' Requests the data in a handle
	Rem
	Method get:Object( handle:THandle )
		Local index:Int = handle.index
		If handle.index <> THandle.INVALID And handle.version = list[index].version And list[index].enabled()
			Return list[index].data
		Else
			Return Null
		End If
	End Method
	EndRem
	
End Type

Type Iterable
End Type