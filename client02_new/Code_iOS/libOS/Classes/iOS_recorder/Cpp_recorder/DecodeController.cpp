#include "DecodeController.h"

DecodeController::~DecodeController()
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

void DecodeController::setTag(unsigned int rTag)
{
	mTag = rTag;
}

void DecodeController::setDelegate(DecodeOfficerProtocol* rOfficerDelegate, DecodeReceptionProtocol* rReceptionDelegate)
{
	mOfficerDelegate = rOfficerDelegate;
	mReceptionDelegate = rReceptionDelegate;
}

void DecodeController::setOfficerDelegate(DecodeOfficerProtocol* rOfficerDelegate)
{
	mOfficerDelegate = rOfficerDelegate;
}

void DecodeController::setReceptionDelegate(DecodeReceptionProtocol* rReceptionDelegate)
{
	mReceptionDelegate = rReceptionDelegate;
}

void DecodeController::decodeRecordFile(std::string& inFileName, std::string& outFileName, unsigned int rTag)
{
	if (mOfficerDelegate)
	{
		mOfficerDelegate->decodeRecordFile(inFileName,outFileName, rTag);
	}

}

void DecodeController::onDecodeSucceed(unsigned int sTag)
{
	if (mReceptionDelegate)
	{
		mReceptionDelegate->onDecodeSucceed(sTag);
	}
}

void DecodeController::onDecodeFailed(unsigned int sTag)
{
	if (mReceptionDelegate)
	{
		mReceptionDelegate->onDecodeFailed(sTag);
	}

}
