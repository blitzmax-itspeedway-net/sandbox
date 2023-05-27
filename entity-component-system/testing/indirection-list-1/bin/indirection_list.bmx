
'	Indirected List
'	(c) Copyright Si Dunford, Feb 2028, All Rights Reserved

'	EXPERIMENTAL
'	VERSION 1.0

'	OBSERVATIONS:
'	Firstly, it appears to work quite well, although I think the list itself could benefit from
'	a change in the way entities are reallocated.
'
'	We know that Structs are created and copied when returned or passed, so the preferred option
'	is to pass them by reference.
'
'	The "free" stack is currently FILO, so index values for short-lived objects would be re-used 
'	quickly. This in turn means the version would increase quickly relative to others and loop
'	back to zero causing a potential loss of uniqueness. Using a FIFO stack would reduce this issue.
'
'	The next issue is iteration of the stack. I keep a count and loop through the linked list, but
'	this is not going to be as efficient memory-wise as a packed array. It may be better to iterate
'	through a fixed-size array. This would mean the counter points to the top of the stack and when 
'	you delete an entity, you move the top of stack into the position occuped by the deleted record.
'	Whether this copy and re-organisation will improve speed is currently unknown and because of the
'	level of indirection used in the index it may make no difference at all.
'
'	The "type" or "signature" works nicely, but it does mean you can only have a finite amount of
'	systems (each with a different signature). I think the system manager might be better creating
'	its own list of entities that register with it.
'
'	Currently the handle is a type and we extend it for components and systems. I think it could 
'	easily be reduced to a Struct with one field "ID:UINT". As you cannot return NULL for a Struct;
'	id=0 should be reserved as NULL which is similar to what is done now.
'
'	I think 1 byte is enough for the version, but whether we should reference it through a
'	byte ptr[0] instead of a seperate field is unknown, if we do then the index will need to be 
'	obtained using "AND $0FFF" which could increase processing time.
'
'	The library needs some additional features for use in an ECS
'		Custom sorting, using an Interface or blitzmax built-in iteration (Need to test speeds).
'		A swap function that moves the array positions and updates the index

Rem NOTES:
	When updating objects, they need a dirty flag. The list needs a pointer to "top-dirty" and
	as objects are updated they are swapped to the start of the array. We can then iterate over
	dirty objects instead of the entire stack.
	Instead of using observer to inform every system of entity deletions; use of a deleted flag
	might be helpful. The stack could then have a built-in GC (reaper) that cleans up as it finds them
	with some limit (say 5 or 6) on actual deletion. Maybe add them to a stack as found and reap
	infrequently!
endrem

Rem

	Instead of pointers this ECS uses handles containing an index to a table.
	The advantage is that an old index cannot point to an unreferenced or deleted object
	it simply points to something that returns invalid!
	
	We have created one level of indirection.

	A handle is a 32 bit UINT constructed from three fields:

	UINT:	0000000000 00000000 00000000000000
            Type-----> Version> Index-------->

	This bit masking can be changed by updating THandle.IBITS, VBITS and TBITS
	
	Type is used to identify the signature of a component
	Version is used to keep the list elements unique when records are changed
	Index is a unique entity, which means you can has 2^IBITS entities in your game
		(16384 entities)
	These can be tweaked and later I might expand this to a ULONG if required.
	
	Default is:
	
		Type:		TBITS	= 10	Also known as Signature
		Version:	VBITS	= 8
		Index:		IBITS	= 14

	HOW DOES IT WORK?
	The index maintains a linked list of free and used THandleRecords.
	When you add, a record is moved from the free list to the used.
	When you delete, the record is moved from the used to the free.
	
	An index version must match before the list is updated
	so an invalid key no longer points to a record in the list.

End Rem

SuperStrict

Type THandle

	' NOTE: We cannot use a STRUCT here because we need to return NULL
	'       When a record no longer exists.
	'		We also need to extend this and we can;t do that for a struct!


	Const INVALID:UInt = 0

	Private

	Field index:UInt, version:UInt, signature:UInt
	'Field indexbits:Byte = IBITS, verbits:Byte = VBITS, sigbits:Byte = TBITS
	
	Public 

	Method New( index:UInt, version:UInt, signature:UInt )
		Self.index     = index
		Self.version   = version
		Self.signature = signature
	End Method

	'Method resize( indexbits:Byte, verbits:Byte, signature:Byte )
	'	Self.indexbits = indexbits
	'	Self.verbits = verbits
	'	Self.sigbits = sigbits
	'End Method
	
	'Method UInt32:UInt()
	'	Return index | (version Shl verbits) | signature Shl sigbits
	'End Method

	'Method maxIndex:Int()
	'	Return 2^indexbits
	'End Method
	
	Method add( signature:UInt )
		Self.signature = Self.signature | signature
	End Method

	Method remove( signature:UInt )
		Self.signature = Self.signature & ~signature
	End Method

End Type

'	The handle index needs to store a Type that we will call THandleRecord which contains the real data
'	pointer along with some management fields for version and the free list

Type THandleRecord
	'Field handle:THandle		' The owning handle
	Field name:String
	'
	Field version:UInt			' Version of the data (Should match the handle)
	Field freeptr:Int			' pointer to next free record. 0=none
	'
	Field enable:Int = False
	
	Method enabled:Int()
		Return enable
	End Method
EndType

'	Now we use THandleRecord to construct an index for the data

Type THandleIndex

	' Default bits
	Const IBITS:Byte = 14, VBITS:Byte = 8, TBITS:Byte = 10

	Field list:THandleRecord[]
	Field counter:Int = 0			' Number of allocated records
	Field indexbits:Byte = IBITS, verbits:Byte = VBITS, sigbits:Byte = TBITS
	Field imask:UInt, vmask:UInt, smask:UInt

	Method New( indexbits:Byte = IBITS, verbits:Byte = VBITS, sigbits:Byte = TBITS )
		Self.indexbits = indexbits
		Self.verbits = verbits
		Self.sigbits = sigbits
		'
		Self.imask = ( (2^indexbits)-1 ) 
		Self.vmask = ( (2^verbits)-1 ) Shl verbits
		Self.smask = ( (2^sigbits)-1 ) Shl (verbits+sigbits)
		
		'Print "CREATING "+indexbits+" BIT LIST CONTAINING "+2^indexbits+" RECORDS (INCLUDING INDEX)"
		list = New THandleRecord[ 2^indexbits ]
		reset()
	End Method
	
	' Reset the list freeing all entries
	Method reset()
		counter = 0
		For Local i:Int = 0 Until list.length
			If Not list[i] ; list[i] = New THandleRecord()
			list[i].freeptr = i + 1
			list[i].enable = False
		Next
		list[list.length-1].freeptr=0
	End Method
	
'	Method Allocate:THandle()
'		' First record in list is not useable, but holds a reference to first free record
'		Local index:Int = list[0].freeptr
'		If index=0 ; Return Null ' No handles available
		'
		' Update freeptr
'		list[0].freeptr = list[index].freeptr
'		' Update handle
'		list[index].freeptr = 0		' Allocate handle
'		list[index].version :+ 1
'	End Method

	Method add:THandle( name:String="" )
	
		Local index:UInt = list[0].freeptr
		If index=0 ; Return Null ' No handles available
		
		list[0].freeptr = list[index].freeptr
		list[index].freeptr = 0		' Clear free ptr
		list[index].enable = True	' Enable handle
		list[index].version :+ 1	' Increment revision
		' Fix increment overflow issues

		If list[index].version > 2^indexbits ; list[index].version = 1
		If list[index].version = 0 ; list[index].version = 1
		'
		list[index].name = name
		counter :- 1	' Decrease counter
		
		Return New THandle( index, list[index].version, 0 )
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
			' insert into top of free list
			list[index].freeptr = list[0].freeptr
			list[index].enable = False	' Disable handle
			list[0].freeptr = index
			counter :- 1	' Decrease counter
		End If
	End Method

	' Returns the amount of active records
	Method size:Int()
		Return counter
	End Method
	
	' Handle to Serialised Index
	Method serialise:UInt( handle:THandle )
		If Not handle Return THandle.INVALID
		Return handle.index | (handle.version Shl verbits) | handle.signature Shl (verbits+sigbits)
	End Method

	' Serialised Index to Handle
	Method deserialise:THandle( index:UInt )
		Return New THandle( index & imask, (index & vmask) Shr indexbits, (index & smask) Shr (indexbits+verbits) )
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
	
	' SIGNATURE MANAGEMENT
'	Method signature_add( handle:THandle, sig:UInt )
'	End Method

	' SIGNATURE MANAGEMENT
'	Method signature_add( handle:THandle, sig:UInt )
'	End Method
	
End Type


