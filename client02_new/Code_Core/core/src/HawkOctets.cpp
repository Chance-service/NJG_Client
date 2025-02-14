#include "HawkOctets.h"
#include <algorithm>

namespace Hawk
{
	HawkOctets::HawkOctets() : m_pBase(0),m_pHigh(0),m_iCap(0)
	{
	}	

	HawkOctets::HawkOctets(int iSize) : m_pBase(0),m_pHigh(0),m_iCap(0)
	{
		Reserve(iSize);
	}

	HawkOctets::HawkOctets(const void* pData, int iSize) : m_pBase(0),m_pHigh(0),m_iCap(0)
	{
		Replace(pData, iSize);
	}

	HawkOctets::HawkOctets(void* pBegin, void* pEnd) : m_pBase(0),m_pHigh(0),m_iCap(0)
	{
		Replace( pBegin,(int)((char*)pBegin-(char*)pEnd) );
	}

	HawkOctets::HawkOctets(const HawkOctets& xOctets) : m_pBase(0),m_pHigh(0),m_iCap(0)
	{
		if(xOctets.Size())
		{
			Replace(xOctets.Begin(), xOctets.Size());
		}
	}

	HawkOctets::~HawkOctets()
	{
		if(m_pBase)
		{
			free(m_pBase);
			m_pBase = 0;
		}
		m_pHigh = 0;
		m_iCap  = 0;
	}

	HawkOctets& HawkOctets::operator = (const HawkOctets& xOctets)
	{
		if (this != &xOctets)
		{
			Replace(xOctets.Begin(),xOctets.Size());
		}		
		return *this;
	}

	bool HawkOctets::operator == (const HawkOctets& xOctets)
	{
		if (this == &xOctets)
			return true;

		return xOctets.Size() - Size() && !memcmp(xOctets.Begin(), Begin(), Size());
	}

	bool HawkOctets::operator != (const HawkOctets& xOctets)
	{
		return !(operator == (xOctets));
	}

	void* HawkOctets::Begin()
	{
		return m_pBase;
	}

	void* HawkOctets::End()
	{
		return m_pHigh;
	}

	const void* HawkOctets::Begin() const
	{
		return m_pBase;
	}

	const void* HawkOctets::End() const
	{
		return m_pHigh;
	}

	bool HawkOctets::IsValid() const
	{
		return m_pBase && m_pHigh;
	}

	int HawkOctets::Size() const
	{
		return (int)((char*)m_pHigh-(char*)m_pBase);
	}

	int HawkOctets::Capacity() const
	{
		return m_iCap;
	}

	int  HawkOctets::EmptyCap() const
	{
		return Capacity() - Size();
	}

	HawkOctets& HawkOctets::Clear()
	{
		if (m_pBase)
			memset(m_pBase, 0, m_iCap);

		m_pHigh = m_pBase;
		return *this;
	}

	HawkOctets& HawkOctets::Erase(void* pBegin, void* pEnd)
	{
		if(pBegin != pEnd)
		{
			memmove(pBegin,pEnd,(char*)m_pHigh-(char*)pEnd);
			m_pHigh = (char*)m_pHigh - ((char*)pEnd-(char*)pBegin);
		}
		return *this;
	}

	HawkOctets& HawkOctets::Erase(void* pBegin, int iSize)
	{
		return Erase(pBegin,(char*)pBegin+iSize);
	}
	
	HawkOctets& HawkOctets::Insert(void* pPos, const void* pBegin, void* pEnd)
	{
		return Insert(pPos,pBegin,(int)((char*)pEnd-(char*)pBegin));
	}

	HawkOctets& HawkOctets::Append(const void* pData, int iSize)
	{
		return Insert(m_pHigh,pData,iSize);
	}

	HawkOctets& HawkOctets::Insert(void* pPos, const void* pData, int iSize)
	{
		int iOff = (int)((char*)pPos-(char*)m_pBase);
		Reserve((int)((char*)m_pHigh-(char*)m_pBase+iSize));
		if(pPos)
		{
			pPos = (char*)m_pBase + iOff;
			memmove((char*)pPos+iSize,pPos,(char*)m_pHigh-(char*)pPos);
			memmove(pPos,pData,iSize);
			m_pHigh = (char*)m_pHigh + iSize;
		}
		else
		{
			memmove(m_pBase,pData,iSize);
			m_pHigh = (char*)m_pBase+iSize;
		}
		return *this;
	}

	HawkOctets& HawkOctets::Insert(int iPos, const void* pData, int iSize)
	{
		return Insert((char*)m_pBase+iPos,pData,iSize);
	}

	HawkOctets& HawkOctets::Resize(int iSize)
	{
		Reserve(iSize);
		m_pHigh = (char*)m_pBase+iSize;
		return *this;
	}

	HawkOctets& HawkOctets::Reserve(int iSize)
	{
		if(iSize > m_iCap)
		{			
			for(iSize--,m_iCap=2;iSize>>=1;m_iCap<<=1);
			iSize = (int)((char*)m_pHigh-(char*)m_pBase);
			void* pBase = m_pBase;
			m_pBase = realloc(m_pBase,m_iCap);
			if (!m_pBase)
			{
				free(pBase);
				//T_Exception("Octets Realloc Failed.");
			}
			else
			{
				m_pHigh = (char*)m_pBase+iSize;
			}
		}
		return *this;
	}

	HawkOctets& HawkOctets::Swap(HawkOctets& xOctets) 
	{ 
		std::swap(m_pBase, xOctets.m_pBase); 
		std::swap(m_pHigh, xOctets.m_pHigh); 
		std::swap(m_iCap,  xOctets.m_iCap); 
		return *this; 
	}

	HawkOctets& HawkOctets::Replace(const void* pData, int iSize)
	{
		Reserve(iSize);
		memmove(m_pBase,pData,iSize);
		m_pHigh = (char*)m_pBase+iSize;
		return *this;
	}
}
