
' Interface for viewable data allowed external data structures to be read by components
Interface IViewable
	Method getChildren:IViewable[]()
	Method getText:String[]()
	Method getCaption:String()
End Interface