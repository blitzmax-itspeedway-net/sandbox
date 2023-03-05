
'	An Iterator interface
'	It is used as an alternative to the BlitzMax Iterator
'	Author Si Dunford [Scaremonger] March 2023

'	PUBLIC DOMAIN / NO WARRANTY / USE AT YOUR OWN RISK

SuperStrict

Interface IIterator
	Method each:Object()
End Interface



Rem
In Blitzmax you need to define an ObjectEnumerator like this:

Type TMyType

	Method ObjectEnumerator:TMyEnum()
		Local enumeration:TMyEnum = New TMyEnum
		enumeration._link=_head._succ
		Return enumeration
	End Method

End type

Then create a type that is used as your Enum:

	Type TMyEnum

		Field _link:TLink

		Method HasNext()
			Return _link._value<>_link
		End Method

		Method NextObject:Object()
			Local value:Object=_link._value
			Assert value<>_link
			_link=_link._succ
			Return value
		End Method

	End Type

This enables eachin support.

But many Blitzmax types like Tlist have to have another type to support the links

	Type TLink

		Field _value:Object
		Field _succ:TLink,_pred:TLink
		
		Method Value:Object()
			Return _value
		End Method

		Method NextLink:TLink()
			If _succ._value<>_succ Return _succ
		End Method

		Method PrevLink:TLink()
			If _pred._value<>_pred Return _pred
		End Method

		Method Remove()
			_value=Null
			_succ._pred=_pred
			_pred._succ=_succ
		End Method

	End Type

EndRem

Type TExample
	Field name:String
End Type

Type MyList Extends TList Implements IIterator

	Method each:Object()
	
	
	End Method
	
End Type

Local list:TMyList = New TMyList()
list.addlast( "Scaremonger" )
list.addlast( "GWRon" )
list.addlast( "Vemod" )
list.addlast( "Brucey" )
list.addlast( "Midimaster" )

' You need to override the default eachin behaviour
'	(Unless Brucey finds this useful And makes it standard)
For Local X:TExample = EachIn list.each()
	Print X.name
Next

