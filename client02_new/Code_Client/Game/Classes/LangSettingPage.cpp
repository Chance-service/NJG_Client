#include "LangSettingPage.h"
#include "StringConverter.h"
#include "BlackBoard.h"
#include "GamePlatform.h"
#include "SeverConsts.h"
#include "MessageHintPage.h"
#include "GraySprite.h"

REGISTER_PAGE("LangSettingPage", LangSettingPage);
USING_NS_CC;
USING_NS_CC_EXT;

LangSettingPage::LangSettingPage(void)
{

}

LangSettingPage::~LangSettingPage(void)
{
}

void LangSettingPage::Enter(MainFrame*)
{
	tempSelectId = cocos2d::CCUserDefault::sharedUserDefault()->getIntegerForKey("LanguageType");
	refreshPage();
}

void LangSettingPage::Execute(MainFrame*)
{

}

void LangSettingPage::Exit(MainFrame*)
{

}

void LangSettingPage::onMenuItemAction(const std::string& itemName, cocos2d::CCObject* sender)
{
	if (itemName == "onClose" || itemName == "onCancel")
	{
		closePage();
	}
	if (itemName == "onSaveSettings")
	{
		if (tempSelectId >= kLanguageEnglish && tempSelectId <= kLanguageThai) {
			cocos2d::CCUserDefault::sharedUserDefault()->setIntegerForKey("LanguageType", tempSelectId);
			libOS::getInstance()->showMessagebox(Language::Get()->getString("@SDK12"));
			closePage();
		}
	}
	int pos = itemName.find("onSelect");
	if (pos != std::string::npos) {
		std::string langType = itemName.substr(8);
		tempSelectId = std::atoi(langType.c_str());
		refreshPage();
	}
}

void LangSettingPage::load(void)
{
	loadCcbiFile("LangSetUpPopUp.ccbi");
}

void LangSettingPage::closePage()
{
	removeFromParent();
}

void LangSettingPage::refreshPage()
{
	for (int i = kLanguageEnglish; i <= kLanguageThai; i++) {
		string s;
		ostringstream ostr(s);
		ostr << i;
		std::string fullName = "mLangOn" + ostr.str();
		CCSprite* selectImg = dynamic_cast<CCSprite*>(getVariable(fullName));
		if (selectImg) {
			if (i == tempSelectId) {
				selectImg->setVisible(true);
			}
			else {
				selectImg->setVisible(false);
			}
		}
	}
}