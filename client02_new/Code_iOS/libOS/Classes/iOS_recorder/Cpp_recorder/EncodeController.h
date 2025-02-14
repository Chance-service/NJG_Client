#pragma once

#include <string>
#include<assert.h>


class EncodeOfficerProtocol
{
public:
	virtual void encodeRecordFile(std::string& inFileName, std::string& outFileName, unsigned int rTag) = 0;
};


class EncodeReceptionProtocol
{
public:
	virtual void onEncodeSucceed(unsigned int sTag) = 0;
	virtual void onEncodeFailed(unsigned int sTag) = 0;
};


//use this object must set Delegate
class EncodeController
{
public:


	EncodeController()
		: mOfficerDelegate(NULL), mReceptionDelegate(NULL),mTag(0){};
	EncodeController(EncodeOfficerProtocol* rOfficerDelegate, EncodeReceptionProtocol* rReceptionDelegate, unsigned int rTag)
		: mOfficerDelegate(rOfficerDelegate), mReceptionDelegate(rReceptionDelegate),mTag(rTag){};
	~EncodeController();

	void setTag(unsigned int rTag);
	void setDelegate(EncodeOfficerProtocol* rOfficerDelegate, EncodeReceptionProtocol* rReceptionDelegate);
	void setOfficerDelegate(EncodeOfficerProtocol* rOfficerDelegate);
	void setReceptionDelegate(EncodeReceptionProtocol* rReceptionDelegate);

	void encodeRecordFile(std::string& inFileName, std::string& outFileName, unsigned int rTag);
	
	void onEncodeSucceed(unsigned int sTag);
	void onEncodeFailed(unsigned int sTag);

private:
	EncodeOfficerProtocol* mOfficerDelegate;
	EncodeReceptionProtocol* mReceptionDelegate;
	unsigned int mTag;
};