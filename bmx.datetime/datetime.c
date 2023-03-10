/*
 *	Date, Time and Timestamp functions for BlitzMax
 *	(c) Copyright Si Dunford [Scaremonger], March 2023
 */

//#include <stdlib.h>
#include <time.h>
//#include <sys/time.h>
//#include <locale.h>
#include <brl.mod/blitz.mod/blitz.h>

extern int getdate_err;
/* 
	C DEFINITIONS

	time_t time(time_t *t)
	time_t mktime(struct tm *timeptr)
	double difftime(time_t time1, time_t time2)
	struct tm *localtime_r( const time_t *timer, struct tm *buf );
	struct tm *gmtime_r(const time_t *time, struct tm *result);
	void tzset(void)
	char *strptime(const char * __restrict__ buf, const char * __restrict__ fmt, struct tm * __restrict__ tm);
	
*/

// Get current microsecs
BBLONG MicroSecs(void) {
	struct timeval tv;
	gettimeofday( &tv, NULL );							// THREAD SAFETY UNKNOWN
	return (( (BBLONG)tv.tv_sec )*1000 )+( tv.tv_usec/1000 );
	/*return (( (long)tv.tv_sec )*1000 )*/;
}

// Get Miliseconds as a double with nanosecond resolution	
double Milli(void) {
	struct timeval tv;
	gettimeofday( &tv, NULL );							// THREAD SAFETY UNKNOWN
	return (tv.tv_sec+(double)tv.tv_usec/1000000.0);
}

// Get UNIXTIME adjusted for localtime
BBLONG timestamp_now() {
	time_t timestamp = time( NULL );					// Threadsafe
	struct tm timeinfo;
	localtime_r( &timestamp, &timeinfo );				// Threadsafe
	return mktime( &timeinfo );							// Threadsafe
};

// Difference between two Timestamps
BBDOUBLE timestamp_diff( BBLONG start, BBLONG finish ) {
	return difftime( finish, start );					// Threadsafe
};

// TIMESTAMP to DATETIME
void timestamp_to_datetime( BBLONG timestamp, struct tm *timeinfo ) {
//	localtime_r( &timestamp, timeinfo );				// Threadsafe
	gmtime_r( &timestamp, timeinfo );					// Threadsafe
};

// DATETIME to TIMESTAMP
BBLONG datetime_to_timestamp( struct tm *timeinfo ) {
	return mktime( timeinfo );							// Threadsafe
};

// STRING to DATETIME
BBINT string_to_datetime( char *string, char *format, struct tm *timeinfo ){
	int err;
	err = strptime( string, format, timeinfo );	
	return err;

};



