/* Lua CJSON floating point conversion routines */

/* Buffer required to store the largest string representation of a double.
 *
 * Longest double printed with %.14g is 21 characters long:
 * -1.7976931348623e+308 */
# define FPCONV_G_FMT_BUFSIZE   32

#ifdef USE_INTERNAL_FPCONV
static inline void fpconv_init()
{
    /* Do nothing - not required */
}
#else
extern __inline void fpconv_init();
#endif

#ifdef _WIN32
#include <float.h>

#ifndef snprintf
#define snprintf _snprintf
#endif

#if !defined(isnan)
#define isnan   _isnan
#endif

#if !defined(strncasecmp)
#define strncasecmp   strnicmp
#endif

#endif



extern int fpconv_g_fmt(char*, double, int);
extern double fpconv_strtod(const char*, char**);

/* vi:ai et sw=4 ts=4:
 */
