/****************************************************************************
Copyright (c) 2010 cocos2d-x.org

http://www.cocos2d-x.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
****************************************************************************/

#include "platform.h"

#include "CCStdC.h"

NS_CC_BEGIN

int CCTime::gettimeofdayCocos2d(struct cc_timeval *tp, void *tzp)
{
    CC_UNUSED_PARAM(tzp);
    if (tp)
    {
        static struct timeval t;
        gettimeofday(&t,  0);
        tp->tv_sec = t.tv_sec;
        tp->tv_usec = t.tv_usec;
    }
    return 0;
}

double CCTime::timersubCocos2d(struct cc_timeval *start, struct cc_timeval *end)
{
    if (! start || ! end)
    {
        return 0;
    }
    
    return ((end->tv_sec*1000.0+end->tv_usec/1000.0) - (start->tv_sec*1000.0+start->tv_usec/1000.0));
}

NS_CC_END
