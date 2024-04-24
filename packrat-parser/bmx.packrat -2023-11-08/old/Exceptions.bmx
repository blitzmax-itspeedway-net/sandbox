

Interface IException

	Method message:String()
	Method set:IException( msg:String )
	
EndInterface

Type TException Extends TBlitzException Implements IException

	Field name:String
	
	Method set:IException( name:String )
		Self.name = name
		Return Self
	End Method
	
End Type


Type TFailedParse Extends TException
	
	Method message:String()
		Return "Unable to find rule '"+name+"'"
	End Method
	
End Type

Type TFailedRef Extends TException 
		
	Method message:String()
		Return "Unable to find rule '"+name+"'"
	End Method
	
End Type
