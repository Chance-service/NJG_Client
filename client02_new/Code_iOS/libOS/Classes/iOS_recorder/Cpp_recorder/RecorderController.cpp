#include "RecorderController.h"
#include "RecorderControllerManager.h"

RecorderController::~RecorderController()
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

	mTag = 0;
	mType = RECORDER_TYPE_NORMAL;
}

void RecorderController::setOfficerDelegate(RecorderOfficerProtocol* rOfficerDelegate)
{
	mOfficerDelegate = rOfficerDelegate;
}

void RecorderController::setReceptionDelegate(RecorderReceptionProtocol* rReceptionDelegate)
{
	mReceptionDelegate = rReceptionDelegate;
}

void RecorderController::setTag(unsigned int rTag)
{
	mTag = rTag;
}

void RecorderController::setType(RecorderType rType)
{
	mType = rType;
}

void RecorderController::setDelegateAndTagAndType(RecorderOfficerProtocol* rOfficerDelegate, RecorderReceptionProtocol* rReceptionDelegate, unsigned int rTag, RecorderType rType)
{
	mOfficerDelegate = rOfficerDelegate;
	mReceptionDelegate = rReceptionDelegate;
	mTag = rTag;
	mType = rType;
}

bool RecorderController::openRecorder(RecorderType rType, unsigned int rTag, std::string &inFileName)
{
	if (mOfficerDelegate)
	{
		return mOfficerDelegate->openRecorder(rType, rTag, inFileName);
	}
    
    return false;

}

bool RecorderController::closeRecorder(unsigned int rTag)
{
	if (mOfficerDelegate)
	{
		return mOfficerDelegate->closeRecorder(rTag);
	}
    
    return false;

}

bool RecorderController::destoryRecorder(unsigned int rTag)
{
	if (mOfficerDelegate)
	{
		return mOfficerDelegate->destoryRecorder(rTag);
	}
    
    return false;

}

void RecorderController::onRecorderStarted(unsigned int rTag)
{
	if (mReceptionDelegate)
	{
		mReceptionDelegate->onRecorderStarted(rTag);
	}

}

void RecorderController::onRecorderRecording(double rVolumn, unsigned int rTag)
{
	if (mReceptionDelegate)
	{
		mReceptionDelegate->onRecorderRecording(rVolumn, rTag);
	}

}

void RecorderController::onRecorderSucceed(unsigned int rTag)
{
	if (mReceptionDelegate)
	{
		mReceptionDelegate->onRecorderSucceed(rTag);
	}

}

void RecorderController::onRecorderFailed(unsigned int rTag)
{
	if (mReceptionDelegate)
	{
		mReceptionDelegate->onRecorderFailed(rTag);
	}

}

void RecorderController::onRecorderDestroyed(unsigned int rTag)
{
	if (mReceptionDelegate)
	{
		mReceptionDelegate->onRecorderDestroyed(rTag);
	}
	

	RecorderControllerManager::Get()->destoryRecorderControllerWithTag(rTag);
}