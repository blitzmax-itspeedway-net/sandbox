
'	Test the CTime structure

SuperStrict

Import "../timestamp.bmx"

Print "SIZEOF(tm):     "+c_sizeof_tm()

Print "~nTEST TIMESTAMP:"
Local now:Long = CTime.time()
Print "NOW.UTC:        "+now

' We can do this using inline C, but it not pretty!
Local etc:Long
'!time( &bbt_etc );
Print "INLINE:         "+etc

Print "~nTEST STRING FORMATTING:"
Local today:CTime = New CTime()
Print "TODAY:          "+today.format()
Print "DT_DATE:        "+today.format(DT_DATE)
Print "DT_TIME:        "+today.format(DT_TIME)
Print "DT_DATESTR:     "+today.format(DT_DATESTR)
Print "DT_DATETIME:    "+today.format(DT_DATETIME)
Print "American:       "+today.format(DT_AMERICAN)
Print "British:        "+today.format(DT_BRITISH)

Local datestr:String = "1966-12-25 10:11:12"
Local xmas66:CTime = New CTime( datestr )
Print "XMAS '66:       "+xmas66.format( DT_DATESTR )

Print "~nABOUT TODAY:"
Print "Year:           "+today.year()
Print "Month:          "+today.month() + "/"+ today.monthname( True )+ "/"+ today.monthname()
Print "Day:            "+today.day()
Print "Hour:           "+today.hour()
Print "Minute:         "+today.minute()
Print "Second:         "+today.second()
Print "Day of Year:    "+today.yearday()
Print "Day of Week:    "+today.weekday()+ "/"+today.dayname( True )+"/"+today.dayname()

Print "~nTEST GET:"
Local Year:Int, Month:Int, Day:Int, Hour:Int, Minute:Int, Second:Int
today.getDate( Year, Month, Day )
today.getTime( Hour, Minute, Second )
Print "Year:           "+Year
Print "Month:          "+Month
Print "Day:            "+Day
Print "Hour:           "+Hour
Print "Minute:         "+Minute
Print "Second:         "+Second

Print "[year]          "+today["year"]

Print "~nTEST DIFFERENCE:"
Year = today.year()
Local xmas:CTime = New CTime( year, 12, 25 )
Print "Xmax is:        " + xmas.format( DT_DATESTR )
Print "Days to Xmas:   " + today.diff( xmas, DT_DAYS )

Print "~nTEST ADDING INTERVALS:"
Print "Today:          "+today.format()
today :+ CTime.Interval( 12, DT_DAYS )
Print "Today+12:       "+today.format()
today :- CTime.Interval( 5, DT_DAYS )
Print "Today+12-5:     "+today.format()




