#pragma once

#include <string>
#include<assert.h>


class PlayerOfficerProtocol
{
public:
	virtual void playRecordFile(std::string& fileName, unsigned int rTag) = 0;
	virtual void stopPlayRecordFile(std::string& fileName, unsigned int rTag) = 0;
};


class PlayerReceptionProtocol
{
public:
	virtual void onPlayerDidStarted(unsigned int rTag) = 0;
	virtual void onPlayerPlaying(double pVolumn, unsigned int rTag) = 0;
	virtual void onPlayerDidFinishPlaying(bool successfully, unsigned int rTag) = 0;
	virtual void audioPlayerDecodeError(unsigned int errorCode, unsigned int rTag) = 0;
};


//use this object must set Delegate
class PlayerController
{
public:

	PlayerController()
		: mOfficerDelegate(NULL), mReceptionDelegate(NULL), mTag(0){};
	PlayerController(PlayerOfficerProtocol* rOfficerDelegate, PlayerReceptionProtocol* rReceptionDelegate, unsigned int rTag)
		: mOfficerDelegate(rOfficerDelegate), mReceptionDelegate(rReceptionDelegate), mTag(rTag){};
	~PlayerController();

	void setDelegate(PlayerOfficerProtocol* rOfficerDelegate, PlayerReceptionProtocol* rReceptionDelegate);
	void setOfficerDelegate(PlayerOfficerProtocol* rOfficerDelegate);
	void setReceptionDelegate(PlayerReceptionProtocol* rReceptionDelegate);
	void setTag(unsigned int rTag);

	void playRecordFile(std::string& fileName, unsigned int rTag);
	void stopPlayRecordFile(std::string& fileName, unsigned int rTag);

	void onPlayerDidStarted(unsigned int rTag);
	void onPlayerPlaying(double pVolumn, unsigned int rTag);
	void onPlayerDidFinishPlayering(bool successfully, unsigned int rTag);
	void audioPlayerDecodeError(unsigned int errorCode, unsigned int rTag);

private:
	PlayerOfficerProtocol* mOfficerDelegate;
	PlayerReceptionProtocol* mReceptionDelegate;
	unsigned int mTag;
};