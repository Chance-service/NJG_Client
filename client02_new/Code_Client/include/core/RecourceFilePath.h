#pragma once
#include "Singleton.h"
#include "TableReader.h"
#include "IteratorWrapper.h"

class RecourceFilePathItem
{
public:	
	unsigned int	itemID;
	std::string		path;

public:

private:
	void readline(std::stringstream& _stream);

	friend class RecourceFilePathManager;
};

class RecourceFilePathManager
	: public TableReader
	,public Singleton<RecourceFilePathManager>
{
public:

	RecourceFilePathManager()
	{
		//init("RecourceFilePath.txt");
	}

	typedef std::map<unsigned int, RecourceFilePathItem* > RecourcePathList;
	typedef ConstMapIterator<RecourcePathList> RecourcePathListIterator;

	RecourcePathListIterator getRecourcePathIterator(void) 
	{
		return RecourcePathListIterator(mRecourcePathList.begin(), mRecourcePathList.end());
	}

	void init(const std::string& filename);
	
	static RecourceFilePathManager* getInstance();

private:
	virtual void readline(std::stringstream& _stream);

	RecourcePathList mRecourcePathList;
};

