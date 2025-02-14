/****************************************************************************
 Copyright (c) 2010-2012 cocos2d-x.org
 Copyright (c) 2013-2016 Chukong Technologies Inc.
 Copyright (c) 2017-2018 Xiamen Yaji Software Co., Ltd.

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

#include "CCDataNew.h"
//#include "base/CCConsole.h"

NS_CC_BEGIN

const DataNew DataNew::Null;

DataNew::DataNew() :
_bytes(nullptr),
_size(0)
{
    CCLOGINFO("In the empty constructor of Data.");
}

DataNew::DataNew(DataNew&& other) :
_bytes(nullptr),
_size(0)
{
    CCLOGINFO("In the move constructor of Data.");
    move(other);
}

DataNew::DataNew(const DataNew& other) :
_bytes(nullptr),
_size(0)
{
    CCLOGINFO("In the copy constructor of Data.");
    if (other._bytes && other._size)
    {
        copy(other._bytes, other._size);
    }
}

DataNew::~DataNew()
{
    CCLOGINFO("deallocing Data: %p", this);
    clear();
}

DataNew& DataNew::operator= (const DataNew& other)
{
    if (this != &other)
    {
        CCLOGINFO("In the copy assignment of Data.");
        copy(other._bytes, other._size);
    }
    return *this;
}

DataNew& DataNew::operator= (DataNew&& other)
{
    if (this != &other)
    {
        CCLOGINFO("In the move assignment of Data.");
        move(other);
    }
    return *this;
}

void DataNew::move(DataNew& other)
{
    if(_bytes != other._bytes) clear();
    
    _bytes = other._bytes;
    _size = other._size;

    other._bytes = nullptr;
    other._size = 0;
}

bool DataNew::isNull() const
{
    return (_bytes == nullptr || _size == 0);
}

unsigned char* DataNew::getBytes() const
{
    return _bytes;
}

size_t DataNew::getSize() const
{
    return _size;
}

size_t DataNew::copy(const unsigned char* bytes, const size_t size)
{
    //CCASSERT(size >= 0, "copy size should be non-negative");
    //CCASSERT(bytes, "bytes should not be nullptr");

    if (size <= 0) return 0;

    if (bytes != _bytes)
    {
        clear();
        _bytes = (unsigned char*)malloc(sizeof(unsigned char) * size);
        memcpy(_bytes, bytes, size);
    }

    _size = size;
    return _size;
}

void DataNew::fastSet(unsigned char* bytes, const size_t size)
{
    //CCASSERT(size >= 0, "fastSet size should be non-negative");
    //CCASSERT(bytes, "bytes should not be nullptr");
    _bytes = bytes;
    _size = size;
}

void DataNew::clear()
{
    if(_bytes) free(_bytes);
    _bytes = nullptr;
    _size = 0;
}

unsigned char* DataNew::takeBuffer(size_t* size)
{
    auto buffer = getBytes();
    if (size)
        *size = getSize();
    fastSet(nullptr, 0);
    return buffer;
}

NS_CC_END
