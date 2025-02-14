#include "PlayerController.h"

PlayerController::~PlayerController()
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

void PlayerController::setDelegate(PlayerOfficerProtocol* rOfficerDelegate, PlayerReceptionProtocol* rReceptionDelegate)
{
	mOfficerDelegate = rOfficerDelegate;
	mReceptionDelegate = rReceptionDelegate;
}

void PlayerController::setOfficerDelegate(PlayerOfficerProtocol* rOfficerDelegate)
{
	mOfficerDelegate = rOfficerDelegate;
}

void PlayerController::playRecordFile(std::string& fileName, unsigned int rTag)
{
	if (mOfficerDelegate)
	{
		mOfficerDelegate->playRecordFile(fileName, rTag);
	}

}

void PlayerController::stopPlayRecordFile(std::string& fileName, unsigned int rTag)
{
	if (mOfficerDelegate)
	{
		mOfficerDelegate->stopPlayRecordFile(fileName, rTag);
	}

}

void PlayerController::setReceptionDelegate(PlayerReceptionProtocol* rReceptionDelegate)
{
	mReceptionDelegate = rReceptionDelegate;
}

void PlayerController::onPlayerDidStarted(unsigned int rTag)
{
	if (mReceptionDelegate)
	{
		mReceptionDelegate->onPlayerDidStarted(rTag);
	}

}

void PlayerController::onPlayerPlaying(double pVolumn, unsigned int rTag)
{
	if (mReceptionDelegate)
	{
		mReceptionDelegate->onPlayerPlaying(pVolumn, rTag);
	}

}

void PlayerController::onPlayerDidFinishPlayering(bool successfully, unsigned int rTag)
{
	if (mReceptionDelegate)
	{
		mReceptionDelegate->onPlayerDidFinishPlaying(successfully, rTag);
	}

}

void PlayerController::audioPlayerDecodeError(unsigned int errorCode, unsigned int rTag)
{
	if (mReceptionDelegate)
	{
		mReceptionDelegate->audioPlayerDecodeError(errorCode, rTag);
	}

}

void PlayerController::setTag(unsigned int rTag)
{
	mTag = rTag;
}
