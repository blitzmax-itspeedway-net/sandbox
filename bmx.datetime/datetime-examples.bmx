
'	Datetime Examples
'	(c) Copyright Si Dunford [Scaremonger], Feb 2023
'	Version 1.0

SuperStrict

Import "datetime.bmx"	'bmx.datetime

'DebugStop
Print "~nTEST TIMESTAMP:"
Local now:Long = DateTime.now()
Print "NOW (timestamp) " + now

Print "~nTEST CURRENT DATETIME:"
Local today:DateTime = New DateTime()
Print "DT_DATE:        "+today.format(DT_DATE)
Print "DT_TIME:        "+today.format(DT_TIME)
Print "DT_DATESTR:     "+today.format(DT_DATESTR)
Print "DT_DATETIME:    "+today.format(DT_DATETIME)
Print "American:       "+today.format(DT_AMERICAN)
Print "British:        "+today.format(DT_BRITISH)

Print "~nABOUT TODAY:"
Print "Day of Year:    "+today.yearday()
Print "Day of Week:    "+today.weekday()+ " ("+today.dayname()+")"

Print "~nTEST DIFFERENCE:"
Local year:Int = today.year()
Local xmas:DateTime = New Datetime().set( year, 12, 25 )
Print "Days to Xmas:   " + today.diff( xmas, DT_DAYS )

Print "~nTEST SETTING THE DATETIME:"
Local another:DateTime = New Datetime().set( 2000, 08, 21 )
Print "VALUE           "+another.format(DT_DATE)+", "+another.format(DT_DATESTR)

Print "~nTEST ADDING INTERVALS:"
Print "Today:          "+today.format()
today.addInterval( 12, DT_DAYS )
Print "Today+12:       "+today.format()
today.addInterval( -5, DT_DAYS )		' Subtraction
Print "Today+12-5:     "+today.format()

Print "~nTEST STRING TO DATETIME:"
'DebugStop
Local datestr:String = "1966-12-25 10:11:12"
Local xmas66:DateTime = New DateTime( datestr )
Print "XMAS '66:   "+xmas66.format( DT_DATESTR )

Print( "~nTESTING A DELAY COUNTER:" )
Local start:Long = DateTime.now()
Delay(5000)
Local finish:Long = DateTime.now()
Print( "Delay:     "+DateTime.TimeDiff( start, finish )+"s" )

Print( "~nRUNNING A CLOCK:" )	' Sort of!
Graphics 320,200
Repeat
	Cls
	Local now:Long = DateTime.now()
	Local dt:DateTime = New DateTime()
	DrawText( now, 10,10 )
	
	' UNCOMMENT THESE AND IT CRASHES
	
	'DrawText( dt.hour(), 10,20 )
	'DrawText( dt.minute(), 50,20 )
	'DrawText( dt.second(), 90,20 )
	DrawText( dt.format(DT_TIME), 10,30 )
	Flip
Until KeyHit( KEY_ESCAPE ) Or AppTerminate()



