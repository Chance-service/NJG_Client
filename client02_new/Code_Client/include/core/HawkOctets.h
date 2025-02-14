#ifndef HAWK_OCTETS_H
#define HAWK_OCTETS_H

namespace Hawk
{
	/************************************************************************/
	/* ���ݲ�����װ                                                         */
	/************************************************************************/
	class HawkOctets 
	{
	public:
		//����������
		HawkOctets();
		
		//��ʼ�����ȹ���
		HawkOctets(int iSize);

		//��ʼ�����ݹ���
		HawkOctets(const void* pData, int iSize);

		//��ʼ�����ݹ���
		HawkOctets(void* pBegin, void* pEnd);

		//��������
		HawkOctets(const HawkOctets& xOctets);

		//����
		virtual ~HawkOctets();
		
	public:
		//��ֵ������
		HawkOctets& operator = (const HawkOctets& xOctets);

		//��ȱȽ�
		bool operator == (const HawkOctets& xOctets);

		//���ȱȽ�
		bool operator != (const HawkOctets& xOctets);

	public:
		//�������׵�ַ
		void*   Begin();

		//������β��ַ
		void*   End();

		//�������ֽڴ�С
		int  Size() const;

		//�Ƿ���Ч,�ڴ��ѿ���?
		bool    IsValid() const;

		//����������
		int  Capacity() const;

		//ʣ��ռ��ֽڴ�С
		int  EmptyCap() const;

	public:
		//�������׵�ַ
		const void*  Begin() const;

		//������β��ַ
		const void*  End() const;

		//�������
		HawkOctets&  Clear();

		//Ĩ������
		HawkOctets&  Erase(void* pBegin, void* pEnd);

		//Ĩ������
		HawkOctets&  Erase(void* pBegin, int iSize);

		//��������
		HawkOctets&  Insert(void* pPos, const void* pBegin, void* pEnd);

		//��������
		HawkOctets&  Insert(void* pPos, const void* pData, int iSize);

		//��������
		HawkOctets&  Insert(int iPos, const void* pData, int iSize);

		//�ҽ�����
		HawkOctets&  Append(const void* pData, int iSize);

		//���ô�С
		HawkOctets&  Resize(int iSize);

		//���ٿռ�
		HawkOctets&  Reserve(int iSize);

		//�滻����
		HawkOctets&  Replace(const void* pData, int iSize);

		//����������
		HawkOctets&  Swap(HawkOctets& xOctets);

	protected:
		//�������׵�ַ
		void*   m_pBase;
		//������β��ַ
		void*   m_pHigh;
		//��������
		int  m_iCap;
	};
}
#endif
