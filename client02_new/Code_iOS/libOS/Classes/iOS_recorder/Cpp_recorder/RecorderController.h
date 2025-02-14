#pragma once
#include <stddef.h>
#include <assert.h>
#include <string>

enum RecorderType
{
	RECORDER_TYPE_NORMAL = 8000,
	RECORDER_TYPE_MIDDLE = 44100,
	RECORDER_TYPE_HIGH = 96000
};

class RecorderReceptionProtocol
{
public:
	virtual void onRecorderStarted(unsigned int rTag) = 0;
	virtual void onRecorderRecording(double rVolumn, unsigned int rTag) = 0;
	virtual void onRecorderSucceed(unsigned int rTag) = 0;
	virtual void onRecorderFailed(unsigned int rTag) = 0;
	virtual void onRecorderDestroyed(unsigned int rTag) = 0;
};

class RecorderOfficerProtocol
{
public:
	virtual bool openRecorder(RecorderType rType, unsigned int rTag, std::string& inFileName) = 0;
	virtual bool closeRecorder(unsigned int rTag) = 0;
	virtual bool destoryRecorder(unsigned int rTag) = 0;
};

//use this object must set Delegate
class RecorderController
{
public:

	RecorderController()
		: mOfficerDelegate(NULL), mReceptionDelegate(NULL), mTag(0), mType(RECORDER_TYPE_NORMAL){};
	RecorderController(RecorderOfficerProtocol* rOfficerDelegate, RecorderReceptionProtocol* rReceptionDelegate, unsigned int rTag, RecorderType rType)
		: mOfficerDelegate(rOfficerDelegate), mReceptionDelegate(rReceptionDelegate), mTag(rTag), mType(rType){};
	~RecorderController();

	void setOfficerDelegate(RecorderOfficerProtocol* rOfficerDelegate);
	void setReceptionDelegate(RecorderReceptionProtocol* rReceptionDelegate);
	void setTag(unsigned int rTag);
	void setType(RecorderType rType);
	void setDelegateAndTagAndType(RecorderOfficerProtocol* rOfficerDelegate, RecorderReceptionProtocol* rReceptionDelegate, unsigned int rTag, RecorderType rType);


	bool openRecorder(RecorderType rType, unsigned int rTag, std::string& inFileName);
	bool closeRecorder(unsigned int rTag);
	bool destoryRecorder(unsigned int rTag);

	void onRecorderStarted(unsigned int rTag);
	void onRecorderRecording(double rVolumn, unsigned int rTag);
	void onRecorderSucceed(unsigned int rTag);
	void onRecorderFailed(unsigned int rTag);
	void onRecorderDestroyed(unsigned int rTag);

private:
	RecorderOfficerProtocol* mOfficerDelegate;
	RecorderReceptionProtocol* mReceptionDelegate;
	unsigned int mTag;
	RecorderType mType;
};