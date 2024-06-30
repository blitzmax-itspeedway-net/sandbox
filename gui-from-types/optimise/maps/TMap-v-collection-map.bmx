SuperStrict

' The problem with TMap/TStringMap/TTreeMap is that objects are 
' returned during iteration in a different order than they were
' inserted.

Const MAXTEST:Int = 10000

Local planets:String[] = ["Mercury","Venus","Earth","Mars","Ceres","Jupiter","Saturn","Uranus","Neptune","Pluto","Haumea","Makemake","Eris"]
Local index:Int

Local start:Int
' TMap
Print "TMap:"
Local map:TMap = New TMap()
For Local planet:String = EachIn planets
	map.insert( planet, planet )
Next

start=MilliSecs()
For Local test:Int = 0 To MAXTEST
	index = 0
	For Local planet:String = EachIn map.keys()
		Local item:String = planets[index]
		Local test:String = String( map.ValueForKey( planet ) )
		Local error:Int = ( test = item )
		If test=0; Print( (index + ".")[..4] + item[..8] + " == "+ test[..8] + " : "+["FAILURE","SUCCESS"][error] )
		index :+ 1
	Next
Next
Print "ITERATION TIME="+(MilliSecs()-start)+"ms"

start=MilliSecs()
For Local test:Int = 0 To MAXTEST
	For Local index:Int = 0 Until planets.length
		Local key:String = planets[index]
		Local result:String = String(map.valueforkey( key ))
'		Print result
	Next
Next
Print "LOOKUP TIME=   "+(MilliSecs()-start)+"ms"

'==================================================

' TStringMap
Print "~nTStringMap:"
Local smap:TStringMap = New TStringMap()
For Local planet:String = EachIn planets
	smap.insert( planet, planet )
Next

start=MilliSecs()
For Local test:Int = 0 To MAXTEST
	index = 0
	For Local planet:String = EachIn smap.keys()
		Local item:String = planets[index]
		Local test:String = String( smap.ValueForKey( planet ) )
		Local error:Int = ( test = item )
		If test=0; Print( (index + ".")[..4] + item[..8] + " == "+ test[..8] + " : "+["FAILURE","SUCCESS"][error] )
		index :+ 1
	Next
Next
Print "ITERATION TIME="+(MilliSecs()-start)+"ms"

start=MilliSecs()
For Local test:Int = 0 To MAXTEST
	For Local index:Int = 0 Until planets.length
		Local key:String = planets[index]
		Local result:String = String(smap.valueforkey( key ))
'		Print result
	Next
Next
Print "LOOKUP TIME=   "+(MilliSecs()-start)+"ms"

'==================================================

' TTreeMap

Print "~nTTreeMap:"
Local trm:TTreeMap<String,String> = New TTreeMap<String,String>()
For Local planet:String = EachIn planets
	trm.add( planet, planet )
Next

start=MilliSecs()
For Local test:Int = 0 To MAXTEST
	index = 0
	For Local planet:String = EachIn trm.keys()
		Local item:String = planets[index]
		Local test:String = String( trm[ planet ] )
		Local error:Int = ( test = item )
		If test=0; Print( (index + ".")[..4] + item[..8] + " == "+ test[..8] + " : "+["FAILURE","SUCCESS"][error] )
		index :+ 1
	Next
Next
Print "ITERATION TIME="+(MilliSecs()-start)+"ms"

start=MilliSecs()
For Local test:Int = 0 To MAXTEST
	For Local index:Int = 0 Until planets.length
		Local key:String = planets[index]
		Local result:String = String(trm[key])
'		Print result
	Next
Next
Print "LOOKUP TIME=   "+(MilliSecs()-start)+"ms"

'==================================================

' What I need is a Dictionary that doesn't sort the keys
' TLookup

Type TLookup<V>

	Field list:String[]
	'Field index:String[]	' Hashed index
	Field data:V[]
	Field total:Int
	Field size:Int

	Field stepsize:Int = 50
	
	Method New()
	End Method

	Method add( key:String, value:V )
		Local id:Int = find( key )
		If id>=total; expand()
		If id>=size; size=id+1
		list[id]  = key
		data[id]  = value
		'index[id] = key.hash()
	End Method

	Method count:Int()
		Return size
	End Method
	
	Method expand()
		total :+ stepsize 
		list  = list[..total]
		data  = data[..total]
		'index = index[..total]
	End Method
	
	Method find:Int( key:String )
		For Local id:Int = 0 Until size
			If list[id]=key; Return id
		Next
		' Not found
		Return size
	End Method
	
	Method keys:String[]()
		Return list[..size]
	End Method

	' Add an object
	Method Operator[]=( key:String, value:V )
		add( key, value )
	End Method
		
	Method Operator[]:V( key:String )
		Return valueForKey( key )
	End Method

	Method Operator[]:V( index:Int )
		Return V(data[index])
	End Method
		
	Method valueForKey:V( key:String )
		Local id:Int = find( key )
		If id > total; Return Null
		Return data[id]
	End Method
End Type

Print "~nTLookup:"
'DebugStop
Local lookup:TLookup<String> = New TLookup<String>()
For Local planet:String = EachIn planets
	lookup.add( planet, planet )
Next

Print "~nTLookup by keys:"
start=MilliSecs()
For Local test:Int = 0 To MAXTEST
	index = 0
	For Local planet:String = EachIn lookup.keys()
		Local item:String = planets[index]
		Local test:String = lookup[ planet ]
		Local error:Int = ( test = item )
		If test=0; Print( (index + ".")[..4] + item[..8] + " == "+ test[..8] + " : "+["FAILURE","SUCCESS"][error] )
		index :+ 1
	Next
Next
Print "ITERATION TIME="+(MilliSecs()-start)+"ms"

'==================================================

Print "~nTLookup by index:"
start=MilliSecs()
For Local test:Int = 0 To MAXTEST
	For Local index:Int = 0 Until lookup.count()
		Local item:String = planets[index]
		Local test:String = lookup[ index ]
		Local error:Int = ( test = item )
		If test=0; Print( (index + ".")[..4] + item[..8] + " == "+ test[..8] + " : "+["FAILURE","SUCCESS"][error] )
	Next
Next
Print "ITERATION TIME="+(MilliSecs()-start)+"ms"

start=MilliSecs()
For Local test:Int = 0 To MAXTEST
	For Local index:Int = 0 Until planets.length
		Local key:String = planets[index]
		Local result:String = String(lookup.valueforkey( key ))
'		Print result
	Next
Next
Print "LOOKUP TIME=   "+(MilliSecs()-start)+"ms"

'==================================================


