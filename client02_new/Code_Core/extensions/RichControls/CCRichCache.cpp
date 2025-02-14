/****************************************************************************
 Copyright (c) 2013 Kevin Sun and RenRen Games

 email:happykevins@gmail.com
 http://wan.renren.com
 
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
#include "CCRichCache.h"
#include "CCRichElement.h"
#include "support/ccArabic.h"
#include <vector>

NS_CC_EXT_BEGIN;

//////////////////////////////////////////////////////////////////////////

RCacheBase::RCacheBase()
	: m_rHAlign(e_align_left)
	, m_rVAlign(e_align_bottom)
	, m_rLineHeight(0)
	, m_rSpacing(0)
	, m_rPadding(0)
	, m_rWrapLine(true)
{

}

#define LEFT_PADDING_WHEN_LEFT_TO_WORD 10

//
RRect RLineCache::flush(class IRichCompositor* compositor)
{
	//分情况判断采用哪种渲染方式
	if (get_is_text_render_left_2_right())
	{
		RRect line_rect;

		// no element yet, need not flush!
		element_list_t* line = getCachedElements();
		if (line->size() == 0)
			return line_rect;

		// line mark
		std::vector<element_list_t::iterator> line_marks;
		std::vector<short> line_widths;

		RRect zone = compositor->getMetricsState()->zone;
		bool wrapline = m_rWrapLine;

		// line width auto growth
		if (zone.size.w == 0)
			wrapline = false;

		RMetricsState* mstate = compositor->getMetricsState();

		RPos pen;
		RRect temp_linerect;
		short base_line_pos_y = 0;
		element_list_t::iterator inner_start_it = line->begin();
		line_marks.push_back(line->begin()); // push first line start
		for (element_list_t::iterator it = line->begin(); it != line->end(); it++)
		{
			RMetrics* metrics = (*it)->getMetrics();

			// prev composit event
			(*it)->onCachedCompositBegin(this, pen);

			// calculate baseline offset
			short baseline_correct = 0;
			if ((*it)->needBaselineCorrect())
			{
				baseline_correct = m_rBaselinePos;
			}

			// first element
			if (pen.x == 0)
			{
				pen.x -= metrics->rect.min_x();
			}

			// set position
			(*it)->setLocalPositionX(pen.x);
			(*it)->setLocalPositionY(pen.y + baseline_correct);

			RRect rect = metrics->rect;
			rect.pos.x += pen.x;
			rect.pos.y += baseline_correct;
			temp_linerect.extend(rect);

		
			// process wrapline
			element_list_t::iterator next_it = it + 1;

			REleGlyph* word = (next_it == line->end()) ? 0 : dynamic_cast<REleGlyph*>(*next_it);

			//add by lyj 2015-3-27 新增单词换行的判断，保证整词渲染
			//修改了原有的逻辑，也能实现，所以注视了下面代码
			//bool is_need_new_line_for_word = false;
			//element_list_t::iterator whole_word_it = it + 1;
			//if (wrapline && pen.x != 0 && whole_word_it != line->begin() && whole_word_it != line->end())
			//{
			//	REleGlyph* whole_word_curr = (whole_word_it == line->end()) ? 0 : dynamic_cast<REleGlyph*>(*whole_word_it);
			//	//碰到空格后开始进行后续单词遍历
			//	float whole_word_width = 0;
			//	if (whole_word_curr && !isspace_unicode(whole_word_curr->getCharCode()) && whole_word_curr->isWordBegin())
			//	{
			//		while (whole_word_it != line->end())
			//		{
			//			RMetrics* whole_word_metrics = (*whole_word_it)->getMetrics();
			//			float temp_add_width = whole_word_metrics->rect.pos.x + whole_word_metrics->rect.size.w + getPadding() * 2;
			//			if (pen.x + metrics->advance.x + whole_word_width + temp_add_width > zone.size.w)
			//			{
			//				is_need_new_line_for_word = true;
			//				break;
			//			}
			//			whole_word_width += whole_word_metrics->advance.x;
			//			whole_word_it += 1;
			//			whole_word_curr = (whole_word_it == line->end()) ? 0 : dynamic_cast<REleGlyph*>(*whole_word_it);

			//			if (!whole_word_curr || isspace_unicode(whole_word_curr->getCharCode()) || whole_word_curr->isWordBegin())
			//			{
			//				break;
			//			}
			//		}
			//	}
			//}

			//add by lyj 2015-3-30 
			//新的规则是：
			//如果每行到换行的时候这个单词的长度超出了剩余的可显示范围，会把单词换行
			//但是单词如果长度超过了行宽，那么会把单词截断，而不再换行该单词
			bool is_word_width_out_zone = false;
			if (word && word->getFirstGlyph())
			{
				float word_width = word->getFirstGlyph()->getWordWidth();
				if (word_width + getPadding() * 2 > zone.size.w)
				{
					is_word_width_out_zone = true;
					//is_need_new_line_for_word = false;
				}
			}


			if (next_it == line->end() ||	// last element
				(*next_it)->isNewlineBefore() || // line-break before next element
				(*it)->isNewlineFollow() ||	// line-break after this element
				(wrapline && pen.x != 0		// wrap line
				&& pen.x + metrics->advance.x + (*next_it)->getMetrics()->rect.pos.x + (*next_it)->getMetrics()->rect.size.w + getPadding() * 2 > zone.size.w
				&& (*next_it)->canLinewrap()) ||
				//is_need_new_line_for_word //||	//real for a whole word by lyj
				(word && word->isWordBegin() && wrapline && pen.x != 0 //for a whole word
				&& pen.x + metrics->advance.x + getPadding() * 2 + word->getWordWidth() + (*next_it)->getMetrics()->rect.pos.x >= zone.size.w)
				&& !is_word_width_out_zone
				)
			{
				// correct out of bound correct
				short y2correct = -temp_linerect.max_y();

				for (element_list_t::iterator inner_it = inner_start_it; inner_it != next_it; inner_it++)
				{
					RPos pos = (*inner_it)->getLocalPosition();
					(*inner_it)->setLocalPositionY(pos.y + y2correct);
					(*inner_it)->setLocalPositionX(pos.x /*+ x2correct*/);
				}

				temp_linerect.pos.y = pen.y;
				line_rect.extend(temp_linerect);

				pen.y -= (temp_linerect.size.h + getSpacing());
				pen.x = 0;

				// push next line start
				line_marks.push_back(next_it);
				line_widths.push_back(temp_linerect.size.w);

				inner_start_it = next_it;
				temp_linerect = RRect();
			}
			else
			{
				pen.x += metrics->advance.x;
			}

			// post composit event
			(*it)->onCachedCompositEnd(this, pen);
		}


		short align_correct_x = 0;
		size_t line_mark_idx = 0;
		if (getHAlign() == e_align_left)
			line_rect.size.w += getPadding() * 2;
		else
			line_rect.size.w = RMAX(zone.size.w, line_rect.size.w + getPadding() * 2); // auto rect
		for (element_list_t::iterator it = line->begin(); it != line->end(); it++)
		{
			// prev composit event
			(*it)->onCachedCompositBegin(this, pen);

			if (it == line_marks[line_mark_idx])
			{
				short lwidth = line_widths[line_mark_idx];

				// x correct
				switch (getHAlign())
				{
				case e_align_left:
					align_correct_x = getPadding();
					break;
				case e_align_center:
					align_correct_x = (line_rect.size.w - lwidth) / 2;
					break;
				case e_align_right:
					align_correct_x = line_rect.size.w - lwidth - getPadding();
					break;
				}

				line_mark_idx++; // until next line
			}

			RPos pos = (*it)->getLocalPosition();
			(*it)->setLocalPositionX(mstate->pen_x + pos.x + align_correct_x);
			(*it)->setLocalPositionY(mstate->pen_y + pos.y);

			// post composit event
			(*it)->onCachedCompositEnd(this, pen);
		}

		line_rect.pos.y = mstate->pen_y;

		// advance pen position
		mstate->pen_y -= (line_rect.size.h + getSpacing());
		mstate->pen_x = 0;

		clear();

		return line_rect;
	}
	else
	{
		RRect line_rect;

		// no element yet, need not flush!
		element_list_t* line = getCachedElements();
		if (line->size() == 0)
			return line_rect;

		// line mark
		std::vector<element_list_t::iterator> line_marks;
		std::vector<short> line_widths;

		RRect zone = compositor->getMetricsState()->zone;
		bool wrapline = m_rWrapLine;

		// line width auto growth
		if (zone.size.w == 0)
			wrapline = false;

		RMetricsState* mstate = compositor->getMetricsState();

		RPos pen;
		RRect temp_linerect;
		short base_line_pos_y = 0;
		element_list_t::iterator inner_start_it = line->begin();
		line_marks.push_back(line->begin()); // push first line start

		//只有当在渲染字符的时候才需要从 右边开始，<p><br/>等标签不需要
		for (element_list_t::iterator it = line->begin(); it != line->end(); it++)
		{
			if (dynamic_cast<REleGlyph*>(*it) != NULL)
			{
				pen.x = zone.size.w - LEFT_PADDING_WHEN_LEFT_TO_WORD;
				break;
			}
		}

		//用于保证非阿拉伯字符依然正常顺序渲染
		std::vector<element_list_t::iterator> temp_word_list;
		unsigned int temp_word_index = 0;
		int line_index = 0;
		for (element_list_t::iterator it = line->begin(); it != line->end(); it++)
		{
			element_list_t::iterator original_it = it;
			element_list_t::iterator render_it = it;
			REleGlyph* curr_word = (render_it == line->end()) ? 0 : dynamic_cast<REleGlyph*>(*render_it);
			element_list_t::iterator next_it = it + 1;
			REleGlyph* next_word = (next_it == line->end()) ? 0 : dynamic_cast<REleGlyph*>(*next_it);
			if (curr_word && !isspace_unicode(curr_word->getCharCode()))
			{
				bool last_char_isspace = false;
				if (line_index > 0)
				{
					element_list_t::iterator last_it = original_it - 1;
					REleGlyph* last_word = (last_it == line->end()) ? 0 : dynamic_cast<REleGlyph*>(*last_it);
					if (last_word && isspace_unicode(last_word->getCharCode()))
					{
						last_char_isspace = true;
					}

					if ((*last_it)->isNewlineBefore())
						last_char_isspace = true;

				}
				unsigned int curr_char = curr_word->getCharCode();
				if ((line_index == 0 || last_char_isspace || pen.x == zone.size.w - LEFT_PADDING_WHEN_LEFT_TO_WORD) &&	//单词首字母做处理
					!check_char_is_arabic(curr_char)		//不是阿语且不为空格的时候
					)
				{
					temp_word_list.clear();
					temp_word_index = 0;				
					element_list_t::iterator temp_it = original_it;
					while (temp_it != line->end())
					{
						REleGlyph* temp_element = (temp_it == line->end()) ? 0 : dynamic_cast<REleGlyph*>(*temp_it);
						if (temp_element)
						{
							unsigned int temp_charcode = temp_element->getCharCode();
							//只要不是英文或者数字的时候就断定为下一个词
							if (check_char_is_arabic(temp_charcode) || isspace_unicode(temp_charcode))
							{
								break;
							}
						}
						else
						{
							break;
						}
						temp_word_list.push_back(temp_it);
						temp_it++;								
					}
				}
			}

			size_t temp_word_size = temp_word_list.size();
			if (temp_word_size > 0)
			{
				if (temp_word_index < temp_word_size)
				{
					render_it = temp_word_list[temp_word_size - 1 - temp_word_index];
					if (temp_word_size - temp_word_index >= 2)
					{
						next_it = temp_word_list[temp_word_size - 2 - temp_word_index];
					}
					temp_word_index++;
				}
				else
				{
					temp_word_index = 0;
					temp_word_list.clear();
				}
			}

			RMetrics* metrics = (*render_it)->getMetrics();

			// prev composit event
			(*render_it)->onCachedCompositBegin(this, pen);

			// calculate baseline offset
			short baseline_correct = 0;
			if ((*render_it)->needBaselineCorrect())
			{
				baseline_correct = m_rBaselinePos;
			}

			// first element
			if (pen.x == zone.size.w - LEFT_PADDING_WHEN_LEFT_TO_WORD)
			{
				pen.x -= (metrics->rect.min_x() + metrics->rect.size.w);
			}

			// set position
			(*render_it)->setLocalPositionX(pen.x);
			(*render_it)->setLocalPositionY(pen.y + baseline_correct);

			RRect rect = metrics->rect;
			rect.pos.x += pen.x;
			rect.pos.y += baseline_correct;
			temp_linerect.extend(rect);



			// process wrapline
			if (next_it == line->end() ||	// last element
				(*next_it)->isNewlineBefore() || // line-break before next element
				(*original_it)->isNewlineFollow() ||	// line-break after this element
				(wrapline && pen.x != zone.size.w		// wrap line
				&& pen.x - metrics->advance.x - (*next_it)->getMetrics()->rect.pos.x - (*next_it)->getMetrics()->rect.size.w - getPadding() * 2 < 0
				&& (*next_it)->canLinewrap()) ||
				(next_word && next_word->isWordBegin() && wrapline && pen.x != zone.size.w //for a whole word
				&& pen.x - getPadding() * 2 - next_word->getWordWidth() - (*next_it)->getMetrics()->rect.pos.x <= 0))
			{
				// correct out of bound correct
				short y2correct = -temp_linerect.max_y();

				for (element_list_t::iterator inner_it = inner_start_it; inner_it != next_it; inner_it++)
				{
					RPos pos = (*inner_it)->getLocalPosition();
					(*inner_it)->setLocalPositionY(pos.y + y2correct);
					(*inner_it)->setLocalPositionX(pos.x /*+ x2correct*/);
				}

				temp_linerect.pos.y = pen.y;
				line_rect.extend(temp_linerect);

				pen.y -= (temp_linerect.size.h + getSpacing());
				if (next_word)
				{
					pen.x = zone.size.w - LEFT_PADDING_WHEN_LEFT_TO_WORD;
				}
				else
				{
					pen.x = 0;
				}


				// push next line start
				line_marks.push_back(next_it);
				line_widths.push_back(temp_linerect.size.w);

				inner_start_it = next_it;
				temp_linerect = RRect();
			}
			else
			{
				RMetrics* metrics_next = (*next_it)->getMetrics();			
				bool is_calc_end = false;

				if (next_word != NULL)
				{
					unsigned int charcode_next = next_word->getCharCode();
					if (isspace_unicode(charcode_next))
					{
						pen.x -= metrics_next->advance.x;
						is_calc_end = true;
					}
				}

				if (!is_calc_end)
				{
					pen.x -= (metrics_next->rect.min_x() + metrics_next->rect.size.w);
				}
			}
			// post composit event
			(*render_it)->onCachedCompositEnd(this, pen);

			line_index++;
		}


		short align_correct_x = 0;
		size_t line_mark_idx = 0;
		if (getHAlign() == e_align_left)
			line_rect.size.w += getPadding() * 2;
		else
			line_rect.size.w = RMAX(zone.size.w, line_rect.size.w + getPadding() * 2); // auto rect
		//for (element_list_t::iterator it = line->begin(); it != line->end(); it++)
		//{
		//	// prev composit event
		//	(*it)->onCachedCompositBegin(this, pen);

		//	if (it == line_marks[line_mark_idx])
		//	{
		//		short lwidth = line_widths[line_mark_idx];

		//		// x correct
		//		switch (getHAlign())
		//		{
		//		case e_align_left:
		//			align_correct_x = getPadding();
		//			break;
		//		case e_align_center:
		//			align_correct_x = (line_rect.size.w - lwidth) / 2;
		//			break;
		//		case e_align_right:
		//			align_correct_x = line_rect.size.w - lwidth - getPadding();
		//			break;
		//		}

		//		line_mark_idx++; // until next line
		//	}

		//	RPos pos = (*it)->getLocalPosition();
		//	(*it)->setLocalPositionX(mstate->pen_x + pos.x + align_correct_x);
		//	(*it)->setLocalPositionY(mstate->pen_y + pos.y);

		//	// post composit event
		//	(*it)->onCachedCompositEnd(this, pen);
		//}

		line_rect.pos.y = mstate->pen_y;
		line_rect.pos.x = 0;
		// advance pen position
		mstate->pen_y -= (line_rect.size.h + getSpacing());
		mstate->pen_x = 0;

		clear();

		return line_rect;
	}
}


////	original code
////	original code
//RRect RLineCache::flush(class IRichCompositor* compositor)
//{
//	RRect line_rect;
//
//	// no element yet, need not flush!
//	element_list_t* line = getCachedElements();
//	if (line->size() == 0)
//		return line_rect;
//
//	// line mark
//	std::vector<element_list_t::iterator> line_marks;
//	std::vector<short> line_widths;
//
//	RRect zone = compositor->getMetricsState()->zone;
//	bool wrapline = m_rWrapLine;
//
//	// line width auto growth
//	if (zone.size.w == 0)
//		wrapline = false;
//
//	RMetricsState* mstate = compositor->getMetricsState();
//
//	RPos pen;
//	RRect temp_linerect;
//	short base_line_pos_y = 0;
//	element_list_t::iterator inner_start_it = line->begin();
//	line_marks.push_back(line->begin()); // push first line start
//	for (element_list_t::iterator it = line->begin(); it != line->end(); it++)
//	{
//		RMetrics* metrics = (*it)->getMetrics();
//
//		// prev composit event
//		(*it)->onCachedCompositBegin(this, pen);
//
//		// calculate baseline offset
//		short baseline_correct = 0;
//		if ((*it)->needBaselineCorrect())
//		{
//			baseline_correct = m_rBaselinePos;
//		}
//
//		// first element
//		if (pen.x == 0)
//		{
//			pen.x -= metrics->rect.min_x();
//		}
//
//		// set position
//		(*it)->setLocalPositionX(pen.x);
//		(*it)->setLocalPositionY(pen.y + baseline_correct);
//
//		RRect rect = metrics->rect;
//		rect.pos.x += pen.x;
//		rect.pos.y += baseline_correct;
//		temp_linerect.extend(rect);
//
//
//
//		// process wrapline
//		element_list_t::iterator next_it = it + 1;
//
//		REleGlyph* word = (next_it == line->end()) ? 0 : dynamic_cast<REleGlyph*>(*next_it);
//
//		if (next_it == line->end() ||	// last element
//			(*next_it)->isNewlineBefore() || // line-break before next element
//			(*it)->isNewlineFollow() ||	// line-break after this element
//			(wrapline && pen.x != 0		// wrap line
//			&& pen.x + metrics->advance.x + (*next_it)->getMetrics()->rect.pos.x + (*next_it)->getMetrics()->rect.size.w + getPadding() * 2 > zone.size.w
//			&& (*next_it)->canLinewrap()) ||
//			(word && word->isWordBegin() && wrapline && pen.x != 0 //for a whole word
//			&& pen.x + getPadding() * 2 + word->getWordWidth() + (*next_it)->getMetrics()->rect.pos.x >= zone.size.w))
//		{
//			// correct out of bound correct
//			short y2correct = -temp_linerect.max_y();
//
//			for (element_list_t::iterator inner_it = inner_start_it; inner_it != next_it; inner_it++)
//			{
//				RPos pos = (*inner_it)->getLocalPosition();
//				(*inner_it)->setLocalPositionY(pos.y + y2correct);
//				(*inner_it)->setLocalPositionX(pos.x /*+ x2correct*/);
//			}
//
//			temp_linerect.pos.y = pen.y;
//			line_rect.extend(temp_linerect);
//
//			pen.y -= (temp_linerect.size.h + getSpacing());
//			pen.x = 0;
//
//			// push next line start
//			line_marks.push_back(next_it);
//			line_widths.push_back(temp_linerect.size.w);
//
//			inner_start_it = next_it;
//			temp_linerect = RRect();
//		}
//		else
//		{
//			pen.x += metrics->advance.x;
//		}
//
//		// post composit event
//		(*it)->onCachedCompositEnd(this, pen);
//	}
//
//
//	short align_correct_x = 0;
//	size_t line_mark_idx = 0;
//	if (getHAlign() == e_align_left)
//		line_rect.size.w += getPadding() * 2;
//	else
//		line_rect.size.w = RMAX(zone.size.w, line_rect.size.w + getPadding() * 2); // auto rect
//	for (element_list_t::iterator it = line->begin(); it != line->end(); it++)
//	{
//		// prev composit event
//		(*it)->onCachedCompositBegin(this, pen);
//
//		if (it == line_marks[line_mark_idx])
//		{
//			short lwidth = line_widths[line_mark_idx];
//
//			// x correct
//			switch (getHAlign())
//			{
//			case e_align_left:
//				align_correct_x = getPadding();
//				break;
//			case e_align_center:
//				align_correct_x = (line_rect.size.w - lwidth) / 2;
//				break;
//			case e_align_right:
//				align_correct_x = line_rect.size.w - lwidth - getPadding();
//				break;
//			}
//
//			line_mark_idx++; // until next line
//		}
//
//		RPos pos = (*it)->getLocalPosition();
//		(*it)->setLocalPositionX(mstate->pen_x + pos.x + align_correct_x);
//		(*it)->setLocalPositionY(mstate->pen_y + pos.y);
//
//		// post composit event
//		(*it)->onCachedCompositEnd(this, pen);
//	}
//
//	line_rect.pos.y = mstate->pen_y;
//
//	// advance pen position
//	mstate->pen_y -= (line_rect.size.h + getSpacing());
//	mstate->pen_x = 0;
//
//	clear();
//
//	return line_rect;
//}


element_list_t* RLineCache::getCachedElements()
{
	return &m_rCachedLine;
}

void RLineCache::appendElement(IRichElement* ele)
{
	m_rCachedLine.push_back(ele);

	m_rBaselinePos = RMIN(ele->getBaseline(), m_rBaselinePos);
}

void RLineCache::clear()
{
	m_rCachedLine.clear();
	m_rBaselinePos = 0;
}


RLineCache::RLineCache()
	: m_rBaselinePos(0)
{

}


//////////////////////////////////////////////////////////////////////////

element_list_t* RHTMLTableCache::getCachedElements()
{
	return &m_rCached;
}
void RHTMLTableCache::clear()
{
	m_rCached.clear();
}
void RHTMLTableCache::appendElement(IRichElement* ele)
{
	m_rCached.push_back(ele);
}
RRect RHTMLTableCache::flush(class IRichCompositor* compositor)
{
	RRect table_rect;

	if ( m_rCached.empty())
	{
		return table_rect;
	}

	// table content size
	std::vector<short> row_heights;
	std::vector<short> col_widths;
	std::vector<bool> width_set;
	short max_row_width = 0;
	short max_row_height = 0;
	for ( element_list_t::iterator it = m_rCached.begin(); it != m_rCached.end(); it++ )
	{
		REleHTMLRow* row = dynamic_cast<REleHTMLRow*>(*it);
		if ( !row )
		{
			CCLog("[CCRich] Table cache can only accept 'REleHTMLRow' element!");
			continue;
		}

		short current_row_height = 0;
		std::vector<class REleHTMLCell*>& cells = row->getCells();
		for ( size_t i = 0; i < cells.size(); i++ )
		{
			CCAssert(i <= col_widths.size(), "");
			if ( i == col_widths.size() )
			{
				col_widths.push_back(cells[i]->getMetrics()->rect.size.w + getPadding() * 2);
				width_set.push_back(cells[i]->isWidthSet());
			}
			else
			{
				if (width_set[i])
				{
					if (cells[i]->isWidthSet())
					{
						col_widths[i] = RMAX(col_widths[i], cells[i]->getMetrics()->rect.size.w + getPadding() * 2);
					}
					else
					{
						// do nothing
					}
				}
				else
				{
					if (cells[i]->isWidthSet())
					{
						col_widths[i] = cells[i]->getMetrics()->rect.size.w + getPadding() * 2;
						width_set[i] = true;
					}
					else
					{
						// do nothing use the first row default width
						//col_widths[i] = RMIN(col_widths[i], cells[i]->getMetrics()->rect.size.w + getPadding() * 2);
					}
				}
			}

			current_row_height = RMAX(current_row_height, cells[i]->getMetrics()->rect.size.h);
		}

		current_row_height += getPadding() * 2;
		row_heights.push_back(current_row_height);

		table_rect.size.h += current_row_height;
	}

	// max width
	for ( size_t i = 0; i < col_widths.size(); i++ )
	{
		table_rect.size.w += col_widths[i];
	}

	// set content metrics
	short spacing = getSpacing();
	short pen_x = 0;
	short pen_y = -m_rTable->m_rBorder;
	size_t row_idx = 0;
	for ( element_list_t::iterator it = m_rCached.begin(); it != m_rCached.end(); it++ )
	{
		REleHTMLRow* row = dynamic_cast<REleHTMLRow*>(*it);
		if ( !row )
		{
			CCLog("[CCRich] Table cache can only accept 'REleHTMLRow' element!");
			continue;
		}

		pen_x = m_rTable->m_rBorder;

		// set row metrics
		row->setLocalPositionX(pen_x);
		row->setLocalPositionY(pen_y);
		RMetrics* row_metrics = row->getMetrics();
		row_metrics->rect.size.h = row_heights[row_idx];
		row_metrics->rect.size.w = table_rect.size.w + spacing * (col_widths.size() - 1);

		// process cells in row
		short cell_pen_x = 0;
		std::vector<class REleHTMLCell*>& cells = row->getCells();
		for ( size_t i = 0; i < cells.size(); i++ )
		{
			cells[i]->setLocalPositionX(cell_pen_x);
			cells[i]->setLocalPositionY(0);
			RMetrics* cell_metrics = cells[i]->getMetrics();
			cell_metrics->rect.size.w = col_widths[i];
			cell_metrics->rect.size.h = row_heights[row_idx];

			recompositCell(cells[i]);

			cell_pen_x += col_widths[i];
			cell_pen_x += spacing;
		}

		pen_y -= row_heights[row_idx];
		pen_y -= spacing;
        row_idx++;
	}

	table_rect.size.h += m_rTable->m_rBorder * 2 + spacing * (row_heights.size() - 1);
	table_rect.size.w += m_rTable->m_rBorder * 2 + spacing * (col_widths.size() - 1);

	m_rCached.clear();

	return table_rect;
}

void RHTMLTableCache::travesalRecompositChildren(element_list_t* eles, short x_fixed, short y_fixed)
{
	for( element_list_t::iterator it = eles->begin(); it != eles->end(); it++ )
	{
		// travesal children
		if ( !(*it)->pushMetricsState() )
		{
			element_list_t* eles = (*it)->getChildren();
			if ( eles && !eles->empty() )
				travesalRecompositChildren(eles, x_fixed, y_fixed);
		}

		RPos pos = (*it)->getLocalPosition();
		(*it)->setLocalPositionX(pos.x + x_fixed);
		(*it)->setLocalPositionY(pos.y + y_fixed);
	}
}

void RHTMLTableCache::recompositCell(class REleHTMLCell* cell)
{
	RSize content_size = cell->m_rContentSize.size;
	RSize zone_size = cell->getMetrics()->rect.size;

	short padding = getPadding();
	short x_fixed = 0;
	short y_fixed = 0;
	EAlignment halign = cell->m_rHAlignSpecified ? 
		cell->m_rHAlignment : 
		( cell->m_rRow->m_rHAlignSpecified ? cell->m_rRow->m_rHAlignment : m_rHAlign);
	EAlignment valign = cell->m_rVAlignSpecified ? 
		cell->m_rVAlignment :
		( cell->m_rRow->m_rVAlignSpecified ? cell->m_rRow->m_rVAlignment : m_rVAlign);

	switch ( halign )
	{
	case e_align_left:
		x_fixed = 0 + padding;
		break;
	case e_align_center:
		x_fixed = ( zone_size.w - content_size.w ) / 2;
		break;
	case e_align_right:
		x_fixed = zone_size.w - content_size.w - padding;
		break;
	}

	switch ( valign )
	{
	case e_align_top:
		y_fixed = 0 - padding;
		break;
	case e_align_middle:
		y_fixed = -( zone_size.h - content_size.h ) / 2;
		break;
	case e_align_bottom:
		y_fixed = -(zone_size.h - content_size.h) + padding;
		break;
	}

	//x_fixed = RMIN( RMAX(x_fixed, 0), (zone_size.w - content_size.w) );
	//y_fixed = RMAX( RMIN(y_fixed, 0), -(zone_size.h - content_size.h) );

	element_list_t* eles = cell->getChildren();
	if ( eles && !eles->empty() )
		travesalRecompositChildren(eles, x_fixed, y_fixed);
}

void RHTMLTableCache::setTable(class REleHTMLTable* table)
{
	m_rTable = table;
}

RHTMLTableCache::RHTMLTableCache()
	: m_rTable(NULL)
{

}

NS_CC_EXT_END;
