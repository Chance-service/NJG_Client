/* 
 * This file uses some implementations of gutf8.c in glib.
 *
 * gutf8.c - Operations on UTF-8 strings.
 *
 * Copyright (C) 1999 Tom Tromey
 * Copyright (C) 2000 Red Hat, Inc.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	 See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 */

#include "ccArabic.h"
#include "platform/CCCommon.h"
#include <set>

NS_CC_BEGIN

#define ARABIC_SIGN_REPLACE_MAP_COUNT_1 5
#define ARABIC_SIGN_REPLACE_MAP_COUNT_2 2
static unsigned short Arabic_Sign_Replace_MapArabic_Sign_Replace_Map[ARABIC_SIGN_REPLACE_MAP_COUNT_1][ARABIC_SIGN_REPLACE_MAP_COUNT_2] =
{
	{ 0x005b, 0x005d },		//[] ������
	{ 0x0022, 0x0022 },		//"" Ӣ�� ���� 
	{ 0x0028, 0x0029 },		//() Ӣ������
	{ 0x007b, 0x007d },		//{} Ӣ�Ĵ�����
	{ 0x003c, 0x003e }		//<> Ӣ�ļ�����
};



unsigned short get_arabic_sign_replace_change(unsigned short selfC)
{
	for (int i = 0; i < ARABIC_SIGN_REPLACE_MAP_COUNT_1; i++)
	{
		for (int j = 0; j < ARABIC_SIGN_REPLACE_MAP_COUNT_2; j++)
		{
			if (selfC == Arabic_Sign_Replace_MapArabic_Sign_Replace_Map[i][j])
			{
				return Arabic_Sign_Replace_MapArabic_Sign_Replace_Map[i][ARABIC_SIGN_REPLACE_MAP_COUNT_2 - 1 - j];
			}
		}
	}
	return selfC;
}


/**
rule normal:
�����������뵥��֮���пո�
1����������ĸ�������һ�����ʣ�����������ĸ��д����ǰ���пո�=����
2����������ĸ��һ�����ʵĴ��ף������ʵ����ұߣ���ǰ���ǿո�=�ڴ���
3����������ĸ��һ�����ʵ��м䣬ǰ����������ĸ����ǰ�󶼲��ǿո�=�ڴ���
4����������ĸ��һ�����ʵĴ�β�������ʵ�����ߣ��������ǿո�=�ڴ�β

rule normal add:
������һЩ�����ַ�ʱ(Arabic_Position_Spec��)��
�����Щ��ĸ���б����ĸ����ô���Ǻ������ĸҪ���ضϴ�������Ҫ���Ǻ����ַ��Ƿ���arabic���б���
                       old  15-4-23modify//���ڴ���������
�����Щ��ĸ����û�б����ĸ���ͻ�����rule normal�е�������


////////1���ַ����������λ�ñ��Σ��� Arabic_Position_Add �У�ǰ�ĸ�Ԫ�طֱ��Ӧ�ĸ�λ��
////////2���������ַ���ǰһ���ַ��� Arabic_Set1 �У����ַ�Ϊǰ���ַ�(first)��
////////3���������ַ��ĺ�һ���ַ��� Arabic_Set2 �У����ַ�Ϊ�����ַ�(last);
////////4�����2��3ͬʱ���㣬���ַ�Ϊ�м��ַ�(middle);
////////5�����2��3�������㣬���ַ�Ϊ�����ַ�(alone);

rule special:
���ַ��������ַ����� Arabic_Spec_front(0x0644) Ϊ��ǣ��ұ߸����� Arabic_Spec_follows
�е��ַ�֮һ��������Ϊi���� Arabic_Spec_front(0x0644) ���һ���ַ��� Arabic_Set1 �У���
�� Arabic_Specs[i][1] �滻�������ַ��������� Arabic_Specs[i][0] �滻��
��ע���滻˳��������ɣ���������Ա�����Ϲ��򣬰�������Դ��պ�0��1�෴��

**/

#define ARABIC_POSITION_SPEC_COUNT 11
static unsigned short Arabic_Position_Spec[ARABIC_POSITION_SPEC_COUNT] = {
	0x0624, 0x0621, 0x0622, 0x0625, 0x0623, 0x0627, 0x0648, 0x0632, 0x0631, 0x062f, 0x0630
};
#define ARABIC_POSITION_CHAR_COUNT 42
#define ARABIC_POSITION_CHAR_TYPE_COUNT 5


const unsigned short Arabic_Position_Add[ARABIC_POSITION_CHAR_COUNT][ARABIC_POSITION_CHAR_TYPE_COUNT] =  // last, first, middle, alone, spec
{
	// last,   first, middle,  alone, spec����Ҫ���ε��ַ�
	{ 0xfe80, 0xfe80, 0xfe80, 0xfe80, 0x621 },    // 0x621
	{ 0xfe82, 0xfe81, 0xfe82, 0xfe81, 0x622 },
	{ 0xfe84, 0xfe83, 0xfe84, 0xfe83, 0x623 },
	{ 0xfe86, 0xfe85, 0xfe86, 0xfe85, 0x624 },
	{ 0xfe88, 0xfe87, 0xfe88, 0xfe87, 0x625 },
	{ 0xfe8a, 0xfe8b, 0xfe8c, 0xfe89, 0x626 },
	{ 0xfe8e, 0xfe8d, 0xfe8e, 0xfe8d, 0x627 },
	{ 0xfe90, 0xfe91, 0xfe92, 0xfe8f, 0x628 },   // 0x628
	{ 0xfe94, 0xfe93, 0xfe94, 0xfe93, 0x629 },
	{ 0xfe96, 0xfe97, 0xfe98, 0xfe95, 0x62a },   // 0x62A
	{ 0xfe9a, 0xfe9b, 0xfe9c, 0xfe99, 0x62b },
	{ 0xfe9e, 0xfe9f, 0xfea0, 0xfe9d, 0x62c },
	{ 0xfea2, 0xfea3, 0xfea4, 0xfea1, 0x62d },	//0x62d
	{ 0xfea6, 0xfea7, 0xfea8, 0xfea5, 0x62e },
	{ 0xfeaa, 0xfea9, 0xfeaa, 0xfea9, 0x62f },
	{ 0xfeac, 0xfeab, 0xfeac, 0xfeab, 0x630 },   // 0x630  
	{ 0xfeae, 0xfead, 0xfeae, 0xfead, 0x631 },
	{ 0xfeb0, 0xfeaf, 0xfeb0, 0xfeaf, 0x632 },
	{ 0xfeb2, 0xfeb3, 0xfeb4, 0xfeb1, 0x633 },
	{ 0xfeb6, 0xfeb7, 0xfeb8, 0xfeb5, 0x634 },
	{ 0xfeba, 0xfebb, 0xfebc, 0xfeb9, 0x635 },
	{ 0xfebe, 0xfebf, 0xfec0, 0xfebd, 0x636 },
	{ 0xfec2, 0xfec3, 0xfec4, 0xfec1, 0x637 },
	{ 0xfec6, 0xfec7, 0xfec8, 0xfec5, 0x638 },  // 0x638
	{ 0xfeca, 0xfecb, 0xfecc, 0xfec9, 0x639 },
	{ 0xfece, 0xfecf, 0xfed0, 0xfecd, 0x63a },  //0x63a
	{ 0x63b, 0x63b, 0x63b, 0x63b, 0x63b },
	{ 0x63c, 0x63c, 0x63c, 0x63c, 0x63c },
	{ 0x63d, 0x63d, 0x63d, 0x63d, 0x63d },
	{ 0x63e, 0x63e, 0x63e, 0x63e, 0x63e },
	{ 0x63f, 0x63f, 0x63f, 0x63f, 0x63f },
	{ 0x640, 0x640, 0x640, 0x640, 0x640 },   // 0x640
	{ 0xfed2, 0xfed3, 0xfed4, 0xfed1, 0x641 },
	{ 0xfed6, 0xfed7, 0xfed8, 0xfed5, 0x642 },
	{ 0xfeda, 0xfedb, 0xfedc, 0xfed9, 0x643 },
	{ 0xfede, 0xfedf, 0xfee0, 0xfedd, 0x644 },	//0x644		add by lyj 15.3.4
	{ 0xfee2, 0xfee3, 0xfee4, 0xfee1, 0x645 },	//0x645		add by lyj 15.3.4
	{ 0xfee6, 0xfee7, 0xfee8, 0xfee5, 0x646 },
	{ 0xfeea, 0xfeeb, 0xfeec, 0xfee9, 0x647 },
	{ 0xfeee, 0xfeed, 0xfeee, 0xfeed, 0x648 },   // 0x648
	{ 0xfef0, 0xfef3, 0xfef4, 0xfeef, 0x649 },
	{ 0xfef2, 0xfef3, 0xfef4, 0xfef1, 0x64A }   // 0x64A
};

#define ARABIC_SET1_COUNT 24
#define ARABIC_SET2_COUNT 35

static unsigned short Arabic_Set1[ARABIC_SET1_COUNT] = {
	0x62c, 0x62d, 0x62e, 0x647, 0x639, 0x63a, 0x641, 0x642,
	0x62b, 0x635, 0x636, 0x637, 0x643, 0x645, 0x646, 0x62a,
	0x644, 0x628, 0x64a, 0x633, 0x634, 0x638, 0x626, 0x640
};  // 0x640 ����

static unsigned short Arabic_Set2[ARABIC_SET2_COUNT] = {
	0x62c, 0x62d, 0x62e, 0x647, 0x639, 0x63a, 0x641, 0x642,
	0x62b, 0x635, 0x636, 0x637, 0x643, 0x645, 0x646, 0x62a,
	0x644, 0x628, 0x64a, 0x633, 0x634, 0x638, 0x626,
	0x627, 0x623, 0x625, 0x622, 0x62f, 0x630, 0x631, 0x632,
	0x648, 0x624, 0x629, 0x649
};

#define ARABIC_SPEC_FOLLOWS_COUNT 4
#define ARABIC_SPEC_CHANGE_COUNT 2

static unsigned short Arabic_Spec_front = 0x0644;
static unsigned short Arabic_Spec_follows[ARABIC_SPEC_FOLLOWS_COUNT] = { 0x622, 0x623, 0x625, 0x627 };
static unsigned short Arabic_Specs[ARABIC_SPEC_FOLLOWS_COUNT][ARABIC_SPEC_CHANGE_COUNT] =
{
	{ 0xFEF5, 0xFEF6 },
	{ 0xFEF7, 0xFEF8 },
	{ 0xFEF9, 0xFEFA },
	{ 0xFEFB, 0xFEFC }
};

static std::set<unsigned short> Arabic_Position_Set_Spec(Arabic_Position_Spec, Arabic_Position_Spec + ARABIC_POSITION_SPEC_COUNT);

static std::set<unsigned short> Arabic_Set_First(Arabic_Set1, Arabic_Set1 + ARABIC_SET1_COUNT);
static std::set<unsigned short> Arabic_Set_Second(Arabic_Set2, Arabic_Set2 + ARABIC_SET2_COUNT);

static std::set<unsigned short> Arabic_Set_Spec_Follows(Arabic_Spec_follows, Arabic_Spec_follows + 4);

#define Check_Arabic_Char_Is_Position_Spec(p) (Arabic_Position_Set_Spec.find(p) != Arabic_Position_Set_Spec.end())

#define Check_Arabic_Char_Is_First(p) (Arabic_Set_First.find(p) != Arabic_Set_First.end())
#define Check_Arabic_Char_Is_Second(p) (Arabic_Set_Second.find(p) != Arabic_Set_Second.end())

#define Check_Arabic_Char_Is_Spec_Front(p) (p == Arabic_Spec_front)
#define Check_Arabic_Char_Is_Spec_Follow(p) (Arabic_Set_Spec_Follows.find(p) != Arabic_Set_Spec_Follows.end())
#define Check_Arabic_Char_Is_Spec_Change(selfC, rightC) (Check_Arabic_Char_Is_Spec_Front(selfC) && Check_Arabic_Char_Is_Spec_Follow(rightC))

//�����б��ι�����ǰ�����б�Ҫ�ȼ���ǲ��ǰ���������ַ���
//������ǣ��Ǿ�û��Ҫ���κμ��
bool check_char_is_arabic(unsigned short selfC)
{
	if (selfC >= 0x0600 && selfC <= 0x06FF)
	{
		return true;
	}
	if (selfC >= 0xFB50 && selfC <= 0xFDFF)
	{
		return true;
	}
	if (selfC >= 0xFE70 && selfC <= 0xFEFF)
	{
		return true;
	}
	return false;
}


bool check_char_is_arabic_spec(unsigned short selfC)
{
	if (selfC >= 0x0041 && selfC <= 0x005A)
	{
		return true;
	}
	if (selfC >= 0x0061 && selfC <= 0x007a)
	{
		return true;
	}
	if (selfC >= 0x0030 && selfC <= 0x0039)
	{
		return true;
	}
	return false;
}

static unsigned short get_arabic_char_change_type_index(unsigned short selfC)
{
	for (int i = 0; i < ARABIC_POSITION_CHAR_COUNT; i++)
	{
		for (int j = 0; j < ARABIC_POSITION_CHAR_TYPE_COUNT; j++)
		{
			if (selfC == Arabic_Position_Add[i][j])
			{
				return i;
			}
		}
	}
	return ARABIC_POSITION_CHAR_COUNT + 1;
}

/**
unsigned short get_arabic_char_normal_change(unsigned short selfC, unsigned short rightC = 0x0, unsigned short leftC = 0x0)
{
	unsigned short index = get_arabic_char_change_type_index(selfC);
	if (!check_char_is_arabic(selfC) || index > ARABIC_POSITION_CHAR_COUNT)
	{
		return selfC;
	}
	bool isFirst = false, isLast = false;
	if (check_char_is_arabic(rightC) && Check_Arabic_Char_Is_First(rightC))
	{
		isFirst = true;
	}

	if (check_char_is_arabic(leftC) && Check_Arabic_Char_Is_Second(leftC))
	{
		isLast = true;
	}

	if (!isFirst && isLast)
	{
		return Arabic_Position_Add[index][0];
	}

	if (isFirst && !isLast)
	{
		return Arabic_Position_Add[index][1];
	}

	//middle �м��ַ�
	if (isFirst && isLast)
	{
		return Arabic_Position_Add[index][2];
	}

	//alone �����ַ�
	if (!isFirst && !isLast)
	{
		return Arabic_Position_Add[index][3];
	}
	return selfC;
}
**/


unsigned short get_arabic_char_normal_change(unsigned short selfC, unsigned short rightC, unsigned short leftC)
{
	unsigned short index = get_arabic_char_change_type_index(selfC);
	if (!check_char_is_arabic(selfC) || index > ARABIC_POSITION_CHAR_COUNT)
	{
		return selfC;
	}

	bool left_statu = check_char_is_arabic(leftC);
	bool right_statu = check_char_is_arabic(rightC);

	//���rule normal add:
	bool is_self_spec_position = Check_Arabic_Char_Is_Position_Spec(selfC);
	bool is_left_spec_position = Check_Arabic_Char_Is_Position_Spec(leftC);
	//�������ǣ���ô���ַ�Ҫ��Ϊ���ڵ�һ��
	if (is_left_spec_position)
	{
		//return Arabic_Position_Add[index][1];
		left_statu = false;
	}
	//����Լ��ǣ���ô���ַ�����Ҫ��Ϊû�б�İ������ַ�
	if (is_self_spec_position)
	{
		right_statu = false;
	}

	//last
	if (left_statu && !right_statu)
	{
		return Arabic_Position_Add[index][0];
	}

	//first
	if (!left_statu && right_statu)
	{
		return Arabic_Position_Add[index][1];
	}

	//mid
	if (left_statu && right_statu)
	{
		return Arabic_Position_Add[index][2];
	}

	//alone
	if (!left_statu && !right_statu)
	{
		return Arabic_Position_Add[index][3];
	}
	return selfC;
}


static unsigned short get_arabic_char_spec_follow_index(unsigned short selfC)
{
	for (int i = 0; i < ARABIC_SPEC_FOLLOWS_COUNT; i++)
	{
		if (selfC == Arabic_Spec_follows[i])
		{
			return i;
		}
	}
	return ARABIC_SPEC_FOLLOWS_COUNT + 1;
}

/*
* get_arabic_char_spec_change:
* @selfC: �����ַ��������ַ���
* @rightC: �����ַ��ұߵ�һ���ַ�
* @leftC: �����ַ������һ���ַ�
* ����������򣬻�ȡ�仯��İ������ַ�
*
* Return value: �仯����ַ�����0
* */
unsigned short get_arabic_char_spec_change(unsigned short selfC, unsigned short rightC, unsigned short leftC)
{
	if (!check_char_is_arabic(selfC) || !check_char_is_arabic(rightC))
	{
		return 0x0;
	}
	if Check_Arabic_Char_Is_Spec_Change(selfC, rightC)
	{
		unsigned short index = get_arabic_char_spec_follow_index(rightC);
		if (index < ARABIC_SPEC_FOLLOWS_COUNT)
		{
			if Check_Arabic_Char_Is_First(leftC)
			{
				return Arabic_Specs[index][1];
			}
			else
			{
				return Arabic_Specs[index][0];
			}
		}
	}
	return 0x0;
}

static bool s_bTextIsRenderLeft2Right = true;
bool get_is_text_render_left_2_right()
{
	return s_bTextIsRenderLeft2Right;
}

void set_is_text_render_left_2_right(bool isLeft2Right)
{
	s_bTextIsRenderLeft2Right = isLeft2Right;	
}

NS_CC_END
