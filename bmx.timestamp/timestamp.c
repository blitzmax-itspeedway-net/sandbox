/*
**	Timestamp functions for BlitzMax
**	(c) Copyright Si Dunford [Scaremonger], March 2023
*/

/*

              THREADSAFE  CVER	DEPRC  RECOMMENDED
<time.h>      
asctime()         NO      C89   C11    Use strftime()
asctime_r()       YES     C99   C11    Use strftime()
asctime_s()               C++11
clock()           YES
ctime()           NO      C89	C11    Use strftime()
ctime64()         NO
ctime64_r()       YES
ctime_r()         YES           C11    Use strftime()
ctime_s()                 C++11
difftime()        YES     C89          Use (t1 - t0)
difftiem64()      YES
getdate()                 C11          Use strptime()
gmtime()          NO      C89          Use gmtime_r()
gmtime64()        NO
gmtime64_r()      YES
gmtime_r()        YES                  *
gmtime_s()        YES     C++11
localtime()       NO      C89          Use localtime_r()
localtime64()     NO
localtime64_r()   YES
localtime_r()     YES                  *
localtime_s()             C++11
mktime()          YES     C89          *
mktime64()        YES
setdate()
setlocale()               C89
strptime()        YES     C11          *
strftime()        YES     C89          *
time()            YES     C89          *
time64()          YES
timespec_get()            C++11
timespec_getres()         C++23 
tzname()                  C11
tzset()                   C11

struct tm         n/a     C89
typedef time_t    n/a     C89
typedef clock_t   n/a     C89
timespec          n/a     C11

Source:
* https://www.ibm.com/docs/en/i/7.3?topic=functions-gmtime-convert-time
* https://linux.die.net/man/3
*/

//#include <stdlib.h>
#include <time.h>
//#include <sys/time.h>
#include <brl.mod/blitz.mod/blitz.h>

extern int getdate_err;

/*/	Get size of the C tm structure
*/
BBINT c_sizeof_tm(){
	return sizeof( struct tm );
};

// Get timestamp (Already exposed in blitzmax as time_() )
//BBLONG c_time() {
//	return time(NULL);
//};
//void c_timea( BBLONG *timestamp) {
//	time( timestamp );
//};

// Convert time_t to tm
void c_gmtime( BBLONG timestamp, struct tm *timeinfo ) {
	gmtime_r( timestamp, timeinfo );					// Threadsafe
}

// Convert tm to time_t
BBLONG c_mktime( struct tm *timeinfo ) {
	return mktime( timeinfo );							// Threadsafe
};

// Convert String to tm
void c_strptime( char *buf, BBString *sformat, struct tm *timeinfo ) {
	char *pformat = bbStringToCString( sformat );
	int res = strptime( buf, pformat, timeinfo );
	bbMemFree(pformat);
};

// Get field from tm
int c_tm_field( struct tm *timeinfo, int field ) {
	switch( field ){
	case 0: return timeinfo->tm_year;
	case 1: return timeinfo->tm_mon;
	case 2: return timeinfo->tm_mday;
	case 3: return timeinfo->tm_hour;
	case 4: return timeinfo->tm_min;
	case 5: return timeinfo->tm_sec;
	case 6: return timeinfo->tm_yday;
	case 7: return timeinfo->tm_wday;
	case 8: return timeinfo->tm_isdst;
	}
	return 0;
};

// Get Date and Time
int c_getdate( struct tm *timeinfo, int *year, int *month, int *day ) {
	(*year)  = timeinfo->tm_year;
	(*month) = timeinfo->tm_mon;
	(*day)   = timeinfo->tm_mday;
};
int c_gettime( struct tm *timeinfo, int *hour, int *minute, int *second ) {
	(*hour)   = timeinfo->tm_hour;
	(*minute) = timeinfo->tm_min;
	(*second) = timeinfo->tm_sec;
};

// Set Date and Time
int c_setdatetime( struct tm *timeinfo, int year, int month, int day, int hour, int minute, int second ) {
	timeinfo->tm_year = year;
	timeinfo->tm_mon  = month;
	timeinfo->tm_mday = day;
	timeinfo->tm_hour = hour;
	timeinfo->tm_min  = minute;
	timeinfo->tm_sec  = second;
	// validate and update
	mktime( timeinfo );								// Threadsafe	
};
int c_setdate( struct tm *timeinfo, int year, int month, int day ) {
	timeinfo->tm_year = year;
	timeinfo->tm_mon  = month;
	timeinfo->tm_mday = day;
	// validate and update
	mktime( timeinfo );								// Threadsafe
};
int c_settime( struct tm *timeinfo, int hour, int minute, int second ) {
	timeinfo->tm_hour = hour;
	timeinfo->tm_min  = minute;
	timeinfo->tm_sec  = second;
	// validate and update
	mktime( timeinfo );								// Threadsafe
};




