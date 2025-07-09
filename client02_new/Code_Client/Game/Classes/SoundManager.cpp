
#include "stdafx.h"

#include "SoundManager.h"
#include "GameMessages.h"
#include "BlackBoard.h"

#include "SimpleAudioEngine.h"
#include "DataTableManager.h"
#define generalmusic "general.mp3"
#define battlemusic "battle.mp3"
#define clicksound_1 "click_1.mp3"
#define clicksound_2 "click_2.mp3"
#define clicksound_cancel "click_cancel.mp3"
#define clicksound_func "click_func.mp3"
#define click_prebattle "click_prebattle.mp3"
#define click_eff_lvup "eff_lvup.mp3"
#define click_GloryHole "click_gloryhole.mp3"
#define loadingmusic "loadingMusic.mp3"
#define gvgmusic "GVG_Bg.mp3"
#define worldbossmusic "WorldBoss_Bg.mp3"

SoundManager::SoundManager(void)
	:mMusicOn(true),mEffectOn(true)
{
	// 
	// init config
	std::string musicStepKey = "SetttingsMusic";
	std::string eftSoundStepKey = "SetttingsEffect";
	
	mMusicOn = cocos2d::CCUserDefault::sharedUserDefault()->getIntegerForKey(musicStepKey.c_str(), 1) >= 1 ? true : false;
	mEffectOn = cocos2d::CCUserDefault::sharedUserDefault()->getIntegerForKey(eftSoundStepKey.c_str(), 1) >= 1 ? true : false;
	// the end
}


SoundManager::~SoundManager(void)
{
}

void SoundManager::playLoadingMusic()
{
	//
	// login UI

	if (mMusicOn && (StringConverter::parseInt(VaribleManager::getInstance()->getSetting("musicAndSoundOn")) == 1))
	{
		// the end
		mPlayMusic=VaribleManager::Get()->getSetting("LoadingMusic");
		CocosDenshion::SimpleAudioEngine::sharedEngine()->playBackgroundMusic(mPlayMusic.c_str(), true);
	}
}

void SoundManager::playGeneralMusic()
{
    if(mMusicOn && mPlayMusic != generalmusic && (StringConverter::parseInt(VaribleManager::getInstance()->getSetting("musicAndSoundOn")) == 1))
	{
		mPlayMusic=VaribleManager::Get()->getSetting("GeneralMusic");
		CocosDenshion::SimpleAudioEngine::sharedEngine()->playBackgroundMusic(mPlayMusic.c_str(), true);
		mPlayMusic = generalmusic;
	}
	// "MainScenePage"
	
}
void SoundManager::playFightMusic(std::string music)
{
    if(mMusicOn && mPlayMusic != music && (StringConverter::parseInt(VaribleManager::getInstance()->getSetting("musicAndSoundOn")) == 1))
	{
		CocosDenshion::SimpleAudioEngine::sharedEngine()->playBackgroundMusic(music.c_str(), true);
		mPlayMusic = music;
	}
}

void SoundManager::playMusic( std::string music, bool isLoop )
{
	CCLog("************mPlayMusic : %s, music : %s", mPlayMusic.c_str(), music.c_str());
	if (mMusicOn  && mPlayMusic != music && (StringConverter::parseInt(VaribleManager::getInstance()->getSetting("musicAndSoundOn")) == 1))
		CocosDenshion::SimpleAudioEngine::sharedEngine()->playBackgroundMusic(music.c_str(), isLoop);
	mPlayMusic = music;
	CCLog("************mPlayMusic2 : %s, music2 : %s", mPlayMusic.c_str(), music.c_str());
}
void SoundManager::playOtherMusic(std::string music, bool isLoop)
{
	if (mMusicOn && (StringConverter::parseInt(VaribleManager::getInstance()->getSetting("musicAndSoundOn")) == 1))
		CocosDenshion::SimpleAudioEngine::sharedEngine()->playOtherBackgroundMusic(music.c_str(), isLoop);

}
void SoundManager::playAdventureMusic(unsigned int itemId)
{
	const AdventureItem* item=AdventureTableManager::Get()->getAdventureItemByID(itemId);
	if(!item)
		return;
	std::string musicName=item->music;
	if(musicName=="")
		return;
	if(mMusicOn && mPlayMusic !=musicName && (StringConverter::parseInt(VaribleManager::getInstance()->getSetting("musicAndSoundOn")) == 1))
		CocosDenshion::SimpleAudioEngine::sharedEngine()->playBackgroundMusic(musicName.c_str(), true);
	mPlayMusic=musicName;
}

void SoundManager::onReceiveMassage( const GameMessage * message )
{
	if(mEffectOn && (StringConverter::parseInt(VaribleManager::getInstance()->getSetting("musicAndSoundOn")) == 1))
	{
		MsgButtonPressed* msg = dynamic_cast<MsgButtonPressed*>(message->clone());
		if (!msg)
		{
			return;
		}
		SoundEffectItem* item = SoundEffectTableManager::Get()->getSoundEffectById(msg->tag);
		if (item)
		{
			CocosDenshion::SimpleAudioEngine::sharedEngine()->playEffect(item->file.c_str(),false);
		}
		else
		{	
			const char* soundToPlay = nullptr;

			switch (msg->tag)
			{
			case -1: soundToPlay = clicksound_2; break;
			case  0: soundToPlay = clicksound_1; break;
			case  1: soundToPlay = clicksound_cancel; break;
			case  2: soundToPlay = clicksound_func; break;
			case  12531: soundToPlay = clicksound_func; break;
			case  3: soundToPlay = click_prebattle; break;
			case  4: soundToPlay = click_eff_lvup; break;
			case  5: soundToPlay = click_GloryHole; break;
			case -2: break;
			default: break;
			}

			if (soundToPlay)
			{
				CCLog("Playing sound: %s (tag = %d)", soundToPlay, msg->tag);
				CocosDenshion::SimpleAudioEngine::sharedEngine()->playEffect(soundToPlay, false);
			}
		}
		delete msg;
	}
}

int SoundManager::playEffectByID( int musicID )
{
	//
	if(mEffectOn && (StringConverter::parseInt(VaribleManager::getInstance()->getSetting("musicAndSoundOn")) == 1))
	{
		if(!BlackBoard::Get()->isSamSungi9100Audio)
		{
			SoundEffectItem* item = SoundEffectTableManager::Get()->getSoundEffectById(musicID);
			if (item)
			{
				CocosDenshion::SimpleAudioEngine::sharedEngine()->playEffect(item->file.c_str(),false);
			}
			else
			{
				CocosDenshion::SimpleAudioEngine::sharedEngine()->playEffect(clicksound_1, false);
			}
		}
		else
		{
			return -1;
		}
	}
	return -1;
}

void SoundManager::init()
{
    MessageManager::Get()->regisiterMessageHandler(MSG_BUTTON_PRESSED, this);
    
	CocosDenshion::SimpleAudioEngine::sharedEngine()->preloadBackgroundMusic(loadingmusic);
	CocosDenshion::SimpleAudioEngine::sharedEngine()->preloadBackgroundMusic(generalmusic);
	if(!BlackBoard::Get()->isSamSungi9100Audio)
	{
		CocosDenshion::SimpleAudioEngine::sharedEngine()->preloadEffect(clicksound_1);
	}
	
}

void SoundManager::setMusicOn( bool isOn)
{
	if(mMusicOn != isOn)
	{
		mMusicOn = isOn;
		if(isOn)
		{
			if(mPauseMusic == mPlayMusic)
				CocosDenshion::SimpleAudioEngine::sharedEngine()->resumeBackgroundMusic();
			else
				CocosDenshion::SimpleAudioEngine::sharedEngine()->playBackgroundMusic(mPlayMusic.c_str(), true);
		}
		else
		{
			CocosDenshion::SimpleAudioEngine::sharedEngine()->pauseBackgroundMusic();
			mPauseMusic = mPlayMusic;
		}
		std::string stepKey = "SetttingsMusic";
		cocos2d::CCUserDefault::sharedUserDefault()->setIntegerForKey(stepKey.c_str(),mMusicOn?1:0);
		cocos2d::CCUserDefault::sharedUserDefault()->flush();
	}
}

void SoundManager::setEffectOn( bool isOn)
{
	if (mEffectOn != isOn)
	{
		mEffectOn = isOn;
		if (!isOn)
		{
			if (!BlackBoard::Get()->isSamSungi9100Audio)
			{
				CocosDenshion::SimpleAudioEngine::sharedEngine()->stopAllEffects();
			}
		}

		std::string stepKey = "SetttingsEffect";
		cocos2d::CCUserDefault::sharedUserDefault()->setIntegerForKey(stepKey.c_str(), mEffectOn ? 1 : 0);
		cocos2d::CCUserDefault::sharedUserDefault()->flush();
	}

	/*mEffectOn = isOn;
	if(!isOn)
	{
		if(!BlackBoard::Get()->isSamSungi9100Audio)
		{
			CocosDenshion::SimpleAudioEngine::sharedEngine()->stopAllEffects();
		}
	}
	std::string stepKey = "SetttingsEffect";
	cocos2d::CCUserDefault::sharedUserDefault()->setIntegerForKey(stepKey.c_str(),mEffectOn?1:0);
	cocos2d::CCUserDefault::sharedUserDefault()->flush();*/
}

int SoundManager::playEffectByName(std::string effect, bool isLoop)
{
	if (effect.empty())
		return -1;
	if (effect == "none")
		return -1;

	//
	if (mEffectOn && (StringConverter::parseInt(VaribleManager::getInstance()->getSetting("musicAndSoundOn")) == 1))
	{
		return CocosDenshion::SimpleAudioEngine::sharedEngine()->playEffect(effect.c_str(), isLoop);
	}
	return -1;
}

int SoundManager::playEffect( std::string effect )
{
	if (effect.empty())
		return -1;
	if (effect == "none")
		return -1;

	//
	if(mEffectOn && (StringConverter::parseInt(VaribleManager::getInstance()->getSetting("musicAndSoundOn")) == 1))
	{
		//CocosDenshion::SimpleAudioEngine::sharedEngine()->unloadEffect( effect.c_str());
		if(!BlackBoard::Get()->isSamSungi9100Audio)
		{
			return CocosDenshion::SimpleAudioEngine::sharedEngine()->playEffect( effect.c_str() , false);
		}
		else
		{
			return -1;
		}
	}
	return -1;
}

void SoundManager::appGotoBackground()
{
	CocosDenshion::SimpleAudioEngine::sharedEngine()->pauseBackgroundMusic();
	//if(!BlackBoard::Get()->isSamSungi9100Audio)
	//{
	//	CocosDenshion::SimpleAudioEngine::sharedEngine()->pauseAllEffects();
	//}
	CocosDenshion::SimpleAudioEngine::sharedEngine()->pauseAllEffects();
}	

void SoundManager::appResumeBackground()
{
	if(mMusicOn)
		CocosDenshion::SimpleAudioEngine::sharedEngine()->resumeBackgroundMusic();
	if(mEffectOn)
	{
		//if(!BlackBoard::Get()->isSamSungi9100Audio)
		//{
		//	CocosDenshion::SimpleAudioEngine::sharedEngine()->resumeAllEffects();
		//}
		CocosDenshion::SimpleAudioEngine::sharedEngine()->resumeAllEffects();
	}
}

SoundManager* SoundManager::getInstance()
{
	return SoundManager::Get();
}

void SoundManager::stopAllEffect()
{
	CocosDenshion::SimpleAudioEngine::sharedEngine()->stopAllEffects();
}

void SoundManager::stopMusic()
{
	mPlayMusic = "";
	CocosDenshion::SimpleAudioEngine::sharedEngine()->stopBackgroundMusic();
}
void SoundManager::stopOtherMusic()
{
	CocosDenshion::SimpleAudioEngine::sharedEngine()->stopOtherBackgroundMusic();
}

