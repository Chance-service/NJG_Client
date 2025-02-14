#include "EncodeController.h"

EncodeController::~EncodeController()
{
	if (mOfficerDelegate)
	{
		//delete mOfficerDelegate;
		mOfficerDelegate = NULL;
	}

	if (mReceptionDelegate)
	{
		//delete mReceptionDelegate;
		mReceptionDelegate = NULL;
	}
}

void EncodeController::setTag(unsigned int rTag)
{
	mTag = rTag;
}

void EncodeController::setDelegate(EncodeOfficerProtocol* rOfficerDelegate, EncodeReceptionProtocol* rReceptionDelegate)
{
	mOfficerDelegate = rOfficerDelegate;
	mReceptionDelegate = rReceptionDelegate;
}

void EncodeController::setOfficerDelegate(EncodeOfficerProtocol* rOfficerDelegate)
{
	mOfficerDelegate = rOfficerDelegate;
}

void EncodeController::setReceptionDelegate(EncodeReceptionProtocol* rReceptionDelegate)
{
	mReceptionDelegate = rReceptionDelegate;
}



void EncodeController::encodeRecordFile(std::string& inFileName, std::string& outFileName, unsigned int rTag)
{
	if (mOfficerDelegate)
	{
		mOfficerDelegate->encodeRecordFile(inFileName,outFileName, rTag);
	}

}

void EncodeController::onEncodeSucceed(unsigned int sTag)
{
	if (mReceptionDelegate)
	{
		mReceptionDelegate->onEncodeSucceed(sTag);
	}

}

void EncodeController::onEncodeFailed(unsigned int sTag)
{
	if (mReceptionDelegate)
	{
		mReceptionDelegate->onEncodeFailed(sTag);
	}

}