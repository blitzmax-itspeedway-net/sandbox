
SuperStrict

Local fallback:String = "John Doe"

Local names:String[] = ["Fred","Diana","George","","Jessie"]

For Local name:String = EachIn names
	Print name | fallback
	Print "-"*20
Next

