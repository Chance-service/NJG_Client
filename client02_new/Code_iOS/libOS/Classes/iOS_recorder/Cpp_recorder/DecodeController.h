#pragma once

#include <string>
#include<assert.h>


class DecodeOfficerProtocol
{
public:
	virtual void decodeRecordFile(std::string& inFileName, std::string& outFileName, unsigned int rTag) = 0;
};


class DecodeReceptionProtocol
{
public:
	virtual void onDecodeSucceed(unsigned int sTag) = 0;

	virtual void onDecodeFailed(unsigned int sTag) = 0;
};


//use this object must set Delegate
class DecodeController
{
public:

	DecodeController()
		: mOfficerDelegate(NULL), mReceptionDelegate(NULL), mTag(0){};
	DecodeController(DecodeOfficerProtocol* rOfficerDelegate, DecodeReceptionProtocol* rReceptionDelegate, unsigned int rTag)
		: mOfficerDelegate(rOfficerDelegate), mReceptionDelegate(rReceptionDelegate), mTag(rTag){};
	~DecodeController();

	void setTag(unsigned int rTag);
	void setDelegate(DecodeOfficerProtocol* rOfficerDelegate, DecodeReceptionProtocol* rReceptionDelegate);
	void setOfficerDelegate(DecodeOfficerProtocol* rOfficerDelegate);
	void setReceptionDelegate(DecodeReceptionProtocol* rReceptionDelegate);

	void decodeRecordFile(std::string& inFileName, std::string& outFileName, unsigned int rTag);
	void onDecodeSucceed(unsigned int sTag);
	void onDecodeFailed(unsigned int sTag);

private:
	DecodeOfficerProtocol* mOfficerDelegate;
	DecodeReceptionProtocol* mReceptionDelegate;
	unsigned int mTag;
};