
/*	C VERSION CHECKING
**	Si Dunford [Scaremonger], March 2023
**	Public Domain / No Warranty / Do what you want with it
*/

/*	Note on C versions
*			__STDC__	__STDC_VERSION__	__cplusplus
*	C89		n/a			n/a					n/a
*	C90		defined		n/a					n/a
*	C94		defined		199409L				n/a
*	C++98									199711L
*	C99		defined		199901L				n/a
*	C++11									201103L
*	C11		defined		201112L				n/a
*	C++14									201402L
*	C++17									201703L
*	C17		defined		201710L				n/a
*	C23		defined		2023?

#if defined (__STDC__)
	#if defined (__STDC_VERSION__)
		#define __CVER __STDC_VERSION__
	#else
		#define __CVER 1990
	#endif
#else
	#define __CVER 1972
#endif
#if defined (__cplusplus)
	#define __CVER __cplusplus
#endif
