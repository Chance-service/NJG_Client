#include "RecourceFilePath.h"

void RecourceFilePathItem::readline(std::stringstream& _stream)
{
	std::string str;
	_stream
		>>itemID
		>>path;
}

void RecourceFilePathManager::init( const std::string& filename )
{
	RecourcePathList::iterator itr = mRecourcePathList.begin();
	while(itr != mRecourcePathList.end())
	{
		delete itr->second;
		itr->second =NULL;
		++itr;
	}
	mRecourcePathList.clear();

	parse(filename, 1);
}

void RecourceFilePathManager::readline( std::stringstream& _stream )
{
	RecourceFilePathItem* data = new RecourceFilePathItem;
	data->readline(_stream);
	mRecourcePathList.insert(RecourcePathList::value_type(data->itemID, data));
}

RecourceFilePathManager* RecourceFilePathManager::getInstance()
{
	return RecourceFilePathManager::Get();
}