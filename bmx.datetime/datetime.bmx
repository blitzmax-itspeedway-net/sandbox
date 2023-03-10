
'	Datetime module for Blitzmax
'	(c) Copyright Si Dunford [Scaremonger], Feb 2023
'	Version 1.0

SuperStrict

'Module bmx.datetime

Framework pub.stdc		' strftime_(), putenv_%( str$ ), getenv_$( env$ )
Import brl.blitz		' TRuntimeException
Import "datetime.c"

Extern	' datetime.c
	'"int setenv(const char *name, const char *value, int overwrite);"
	'Function __setenv:Int( name$z, value$z, overwrite:Int = True ) = "setenv"
	' CURRENT LOCALE TIMESTAMP
	Function timestamp_now:Long() = "timestamp_now"
	' DIFFERENCE BETWEEN TWO TIMESTAMPS
	Function timestamp_diff:Double( Start:Long, Finish:Long ) = "timestamp_diff"
	' TIMESTAMP TO DATETIME
	Function timestamp_to_datetime( TimeStamp:Long, TimeInfo:DateTime Var) = "timestamp_to_datetime"
	' DATETIME TO TIMESTAMP
	Function datetime_to_timestamp:Long( TimeInfo:DateTime Var ) = "datetime_to_timestamp"
	' STRING TO DATETIME
	Function string_to_datetime:Int( datestr$z, dateformat$z, TimeInfo:DateTime Var ) = "string_to_datetime"
End Extern


Rem
' string_to_datetime() uses getdate_r() which requires an environment variable
' called DATEMSK to point to a folder containing definitions.

' %Y-%m-%d %H:%M:%S
'Function putenv_%( str$ )
'Function getenv_$( env$ )
Local DATEMSK:String = getenv_( "DATEMSK" )
If Not DATEMSK 
	DATEMSK = "datemask.txt"
	setenv( "DATEMSK", DATEMSK )
End If
If Not FileType( DATEMSK ) = FILETYPE_FILE
	Local file:TStream = WriteFile( DATEMSK )
	WriteLine( file, "%Y-%m-%d %H:%M:%S" )
	CloseStream( file )
End If
	
DebugStop
End Rem


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

Const DT_SECONDS:Int = 1
Const DT_MINUTES:Int = DT_SECONDS*60
Const DT_HOURS:Int   = DT_MINUTES*60
Const DT_DAYS:Int    = DT_HOURS*24
'Const DT_MONTHS:Int  = 0	' Needs some special calculations
'Const DT_YEARS:Int   = 0	' Needs some special calculations

' DateTime structure
Struct DateTime
	' Do not change the order of these field, they match "Struct tm" in C
	Field _second:Int	' 0-59
	Field _minute:Int	' 0-59
	Field _hour:Int		' 0-23
	Field _day:Int		' 1-31, Day of the month
	Field _month:Int	' 0-11
	Field _year:Int		' Years since Epoch (1900)
	Field _weekday:Int	' 0-6
	Field _yearday:Int	' 0-366
	Field _dst:Int		' daylight saving time 0=Not in effect, +ve=In effect, -ve=Unknown

	' Create a new blank DateTime
	Method New()
		Local timestamp:Long = timestamp_now()
		timestamp_to_datetime( timestamp, Self )
'		Return Self
	End Method
	
	' Create a new DateTime from a Timestamp
	Method New( timestamp:Long )
		timestamp_to_datetime( timestamp, Self )
	End Method
	
	' Create a new DateTime from a string
	Method New( timestr:String, dateformat:String = DT_DATETIME )
		Local err:Int = string_to_datetime( timestr, dateformat, Self )
		If err=0; Throw New TDateTimeError( "Failed to convert timestring")
	End Method

	Method year:Int();		Return 1900+_year;	End Method
	Method month:Int();		Return _month+1;	End Method
	Method day:Int();		Return _day;		End Method
	Method hour:Int();		Return _hour;		End Method
	Method minute:Int();	Return _minute;		End Method
	Method second:Int();	Return _second;		End Method
	Method yearday:Int();	Return _yearday;	End Method
	Method weekday:Int();	Return _weekday;	End Method
	Method isDSTValid:Int();Return _dst>=0;		End Method	' Is DST known
	Method isDST:Int();		Return _dst>0;		End Method	' If Valid, in operation?

	' Set DateTime from Year, month, day etc...
	Method set:DateTime( year:Int, month:Int=1, day:Int=1, hour:Int=0, minute:Int=0, second:Int=0 )
		If month<1 Or month>12; Throw New TDateTimeError( "Invalid Month '"+month+"'" )
		If day<0 Or day>=31; Throw New TDateTimeError( "Invalid Day '"+day+"'" )
		If hour<0 Or hour>=60; Throw New TDateTimeError( "Invalid Hour '"+hour+"'" )
		If minute<0 Or minute>=60; Throw New TDateTimeError( "Invalid Minute '"+minute+"'" )
		If second<0 Or second>=60; Throw New TDateTimeError( "Invalid Second '"+second+"'" )
		_year   = year-1900
		_month  = month-1
		_day    = day
		_hour   = hour
		_minute = minute
		_second = second
		' Update 
		_update()
		Return Self
	End Method
	
	Method year(value:Int)
		_year = value-1900
		_update()
	End Method

	Method month(value:Int)
		If value<0 Or value>=12; Throw New TDateTimeError( "Invalid Month '"+value+"'" )
		_month = value-1
		_update()
	End Method

	Method day(value:Int)
		If value<1 Or value>31; Throw New TDateTimeError( "Invalid Day of Month '"+value+"'" )
		_month = value
		_update()
	End Method

	Method hour(value:Int)
		If value<0 Or value>=60; Throw New TDateTimeError( "Invalid Hour '"+value+"'" )
		_month = value
	End Method

	Method minute(value:Int)
		If value<0 Or value>=60; Throw New TDateTimeError( "Invalid Minute '"+value+"'" )
		_month = value
	End Method

	Method second(value:Int)
		If value<0 Or value>=60; Throw New TDateTimeError( "Invalid Second '"+value+"'" )
		_month = value
	End Method
	
	' Return locales Month name
	Method MonthName:String( shortname:Int = True )
		If shortname; Return DateTime.toString( Self, "%b" )
		Return DateTime.toString( Self, "%B" )
	End Method
	
	' Return locales Day name
	Method DayName:String( shortname:Int = True )
		If shortname; Return DateTime.toString( Self, "%a" )
		Return DateTime.toString( Self, "%A" )
	End Method

	' Return locales morning or afternoon
	Method AMPM:String()
		Return DateTime.toString( Self, "%p" )
	End Method
	
	' Add a predefined interval
	Method addInterval( quantity:Int, interval:Int )
		Local timestamp:Long = datetime_to_timestamp( Self )
		timestamp :+ ( quantity * interval)
		timestamp_to_datetime( timestamp, Self )
	End Method

	' Add a manual interval
	Method addInterval( interval:Int )
		Local timestamp:Long = datetime_to_timestamp( Self )
		timestamp :+ interval
		timestamp_to_datetime( timestamp, Self )
	End Method
	
	Method time:DateTime( hour:Int, minute:Int, second:Int )
		If hour<0 Or hour>=60; Throw New TDateTimeError( "Invalid Hour '"+hour+"'" )
		If minute<0 Or minute>=60; Throw New TDateTimeError( "Invalid Minute '"+minute+"'" )
		If second<0 Or second>=60; Throw New TDateTimeError( "Invalid Second '"+second+"'" )
		_hour = hour
		_minute = minute
		_second = second
		Return Self
	End Method
	
	' Difference between two DateTime values
	Method diff:Long( against:DateTime, interval:Int=-1 )
		Local time1:Long = datetime_to_timestamp( Self )
		Local time2:Long = datetime_to_timestamp( against )
		Local seconds:Long = timestamp_diff( time1, time2 )
		If interval>0; Return seconds/interval
		Return seconds
	End Method
	
	' Valildate date by converting to Timestamp and back again.
	' This validates, but also updates yearday and weekday
	Method _update()
		' DateTime to Timestamp
		Local timestamp:Long = datetime_to_timestamp( Self )
		' Timestamp to Datetime
		timestamp_to_datetime( timestamp, Self )
	End Method
	
	Method format:String( dateformat:String = DT_DATETIME )
		Return DateTime.toString( Self, dateformat )
	End Method
	
	' DATETIME to STRING
	Function toString:String( timeinfo:DateTime, dateformat:String = DT_DATETIME )
		' Custom MSSQL_TIMESTAMP Support uses "%" and returns timestamp as a string
		If dateformat="%"
			' Convert to TIMESTAMP
			Local timestamp:Long = datetime_to_timestamp( timeinfo )
			Return String(timestamp)	
		End If
		' Convert to string
		Local buff:Byte[256]
		strftime_( buff, 256, dateformat, Varptr( timeinfo ) )
		Return String.FromCString(buff)
	End Function

	' TIMESTAMP to STRING
	Function toString:String( timestamp:Long, dateformat:String = DT_DATETIME )
		' Custom MSSQL_TIMESTAMP Support uses "%" and returns timestamp as a string
		If dateformat="%"
			Return String(timestamp)
		End If
		' Convert to DATETIME
		Local dateinfo:DateTime = New DateTime( timestamp )
		' Convert to string
		Local buff:Byte[256]
		strftime_( buff, 256, dateformat, Varptr( dateinfo ) )
		Return String.FromCString(buff)
	End Function
	
	' Get the current Timestamp 
	Function Now:Long()
		Return timestamp_now()
	End Function	

	' Difference between two Timestamps
	Function TimeDiff:Long( start:Long, finish:Long )
		Return timestamp_diff( start, finish )
	End Function

EndStruct

Type TDateTimeError Extends TRuntimeException
End Type

