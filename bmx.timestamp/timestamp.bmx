
'	Timestamp module for Blitzmax
'	(c) Copyright Si Dunford [Scaremonger], Feb 2023
'	Version 0.00

SuperStrict

'Module bmx.datetime

Framework pub.stdc		' strftime_(), putenv_%( str$ ), getenv_$( env$ )
Import brl.blitz		' TRuntimeException
Import "timestamp.c"

Extern	' timestamp.c

	'	Get size of the tm structure
	Function c_sizeof_tm:Int() = "c_sizeof_tm"
	
	'	Get a field from the tm structure
	Function c_tm_field:Int( tm:Byte Ptr, fld:Int ) = "c_tm_field"
	
	'	Expose native C functions
	Function c_gmtime( time_t:Long Var, tm:Byte Ptr ) = "c_gmtime"
	Function c_mktime:Long( tm:Byte Ptr ) = "c_mktime"
	Function c_strptime( buf:Byte Ptr, format:String, tm:Byte Ptr ) = "c_strptime"

	' strftime() already exposed as strftime_()
	' time() already exposed as time_()

	'	Additional support
	Function c_getDate( tm:Byte Ptr, year:Int Var, month:Int Var, day:Int Var ) = "c_getdate"
	Function c_getTime( tm:Byte Ptr, hour:Int Var, minute:Int Var, second:Int Var ) = "c_gettime"
	Function c_setDatetime( tm:Byte Ptr, year:Int, month:Int, day:Int, hour:Int, minute:Int, second:Int ) = "c_setdatetime"
	Function c_setDate( tm:Byte Ptr, year:Int, month:Int, day:Int ) = "c_setdate"
	Function c_setTime( tm:Byte Ptr, hour:Int, minute:Int, second:Int ) = "c_settime"
	
End Extern

Const DT_DATETIME:String         = "%Y-%m-%d %H:%M:%S"
Const DT_DATE:String             = "%Y-%m-%d"
Const DT_TIME:String             = "%H:%M:%S"
Const DT_DATESTR:String          = "%d %b %Y"

Const DT_AMERICAN:String         = "%m %d %Y"
Const DT_BRITISH:String          = "%d %m %Y"

' MySQL Date Datatypes
Const MYSQL_DATE:String          = DT_DATE
Const MYSQL_DATETIME:String      = DT_DATETIME
Const MYSQL_TIMESTAMP:String     = DT_DATETIME
Const MYSQL_YEAR:String          = "%Y"

' Microsoft SQL Server Date Datatypes
Const MSSQL_DATE:String          = DT_DATE
Const MSSQL_DATETIME:String      = DT_DATETIME
Const MSSQL_TIMESTAMP:String     = "%"			' Custom support, see DateTime.Format()
Const MSSQL_SMALLDATETIME:String = DT_DATETIME

' Durations used in differences
Const DT_SECONDS:Int = 1
Const DT_MINUTES:Int = DT_SECONDS*60
Const DT_HOURS:Int   = DT_MINUTES*60
Const DT_DAYS:Int    = DT_HOURS*24
'Const DT_MONTHS:Int  = 0	' Needs some special calculations
'Const DT_YEARS:Int   = 0	' Needs some special calculations

Struct CTime

	Global _TMSIZE_:Int = c_sizeof_tm()

	Field tm:Byte[]		' Holds a C struct tm
	
	Method New()
		tm = New Byte[_TMSIZE_]			' Allocate C struct for tm
		Local time_t:Long 
		time_( Varptr time_t )			' Get timestamp
		c_gmtime( time_t, Varptr tm  ) 	' time_t to tm
	End Method

	Method New( dt:String, dateformat:String=DT_DATETIME )
		tm = New Byte[_TMSIZE_]						' Allocate C struct for tm
		c_strptime( dt, dateformat, Varptr tm ) 	' time_t to tm
	End Method

	Method New( year:Int, month:Int, day:Int, hour:Int=0, minute:Int=0, second:Int=0 )
		tm = New Byte[_TMSIZE_]						' Allocate C struct for tm
		c_setDatetime( Varptr tm, year-1900, month-1, day, hour, minute, second )
	End Method

	Method timestamp:Long(); Return c_mktime( tm ) ; End Method
		
	Method year:Int();     Return c_tm_field( Varptr tm, 0 )+1900; End Method
	Method month:Int();    Return c_tm_field( Varptr tm, 1 )+1;    End Method
	Method day:Int();      Return c_tm_field( Varptr tm, 2 );      End Method
	Method hour:Int();     Return c_tm_field( Varptr tm, 3 );      End Method
	Method minute:Int();   Return c_tm_field( Varptr tm, 4 );      End Method
	Method second:Int();   Return c_tm_field( Varptr tm, 5 );      End Method
	Method yearday:Int();  Return c_tm_field( Varptr tm, 6 );      End Method
	Method weekday:Int();  Return c_tm_field( Varptr tm, 7 );      End Method
	Method dst:Int();      Return c_tm_field( Varptr tm, 8 );      End Method
	
	Method getdate( year:Int Var, month:Int Var, day:Int Var )
		c_getdate( Varptr tm, year, month, day )
		year  :+ 1900
		month :+ 1
	End Method

	Method gettime( hour:Int Var, minute:Int Var, second:Int Var )
		c_gettime( Varptr tm, hour, minute, second )
	End Method

	Method setdate( year:Int, month:Int, day:Int )
		c_setDate( Varptr tm, year-1900, month-1, day)
	End Method
	
	Method setTime( hour:Int, minute:Int, second:Int )
		c_setTime( Varptr tm, hour, minute, second )
	End Method

	Method format:String( dateformat:String=DT_DATETIME )
		' Special support for MYSQL TIMESTAMP which should be a UNIXTIME number!
		If dateformat=MSSQL_TIMESTAMP Then Return String( timestamp() )
		Local buff:Byte[256]
		strftime_( buff, 256, dateformat, Varptr tm )
		Return String.FromCString(buff)
	End Method

	Method dayName:String( shortname:Int = False )
		Return format( ["%A","%a"][shortname] )
	End Method

	Method monthName:String( shortname:Int = False )
		Return format( ["%B","%b"][shortname] )
	End Method	
	
	Method diff:Double( future:CTime, interval:Long = DT_SECONDS )
		Local ts_now:Long = c_mktime( tm )
		Local ts_future:Long = c_mktime( future.tm )
		Return (ts_future-ts_now)/interval
	End Method

	Method diff:Double( ts_future:Long, interval:Long = DT_SECONDS )
		Local ts_now:Long = c_mktime( tm )
		Return (ts_future-ts_now)/interval
	End Method
	
	Method operator:+( amount:Int )
		Local time_t:Long = c_mktime( tm ) + amount
		c_gmtime( time_t, Varptr tm  ) 	' time_t to tm
	End Method

	Method operator:-( amount:Int )
		Local time_t:Long = c_mktime( tm ) - amount
		c_gmtime( time_t, Varptr tm  ) 	' time_t to tm
	End Method
	
	Method operator[]:Int( fld:String )
		Select Lower(fld)
		Case "year","yr"; Return year()
		Case "month","mon"; Return month()
		Case "day"; Return day()
		Case "hour","hr"; Return hour()
		Case "minute","min"; Return minute()
		Case "second","sec"; Return second()
		Case "dst"; Return dst()
		Default
			Return 0
		End Select
	End Method
	
	Function time:Long( locale:Int = True )
		If locale
			Local now:CTime = New CTime()
			Return c_mktime( now.tm )
		EndIf
		Local time_t:Long 
		time_( Varptr time_t )			' Get timestamp
		Return time_t
	End Function
	
	Function interval:Long( quantity:Int, interval:Int )
		Return quantity*interval
	End Function
	
End Struct