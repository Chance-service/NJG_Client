#ifndef _CCB_CCBFILE_H_
#define _CCB_CCBFILE_H_

#include "cocos2d.h"
#include "CCBSelectorResolver.h"
#include "CCBMemberVariableAssigner.h"

#include <string>
#include <map>
#include <list>

NS_CC_EXT_BEGIN

class CCMenuItemCCBFile;
class CCScrollView;
class CCScale9Sprite;
class CCBAnimationManager;
class CCBFileNew;
class CCBFileListener
{
public:
	virtual void onMenuItemAction(const std::string& itemName, CCObject* sender, int tag){};
	virtual void onContolAction(const std::string& itemName, cocos2d::CCObject* sender, std::string tag){};
	virtual void onAnimationDone(const std::string& animationName, CCBFileNew* ccbfile=0){};
};
typedef void (*UpdateNode)(CCNode* node);
extern UpdateNode updateNodeHandle;
extern void setUpdateNodeHandle(UpdateNode handle);

class CCBFileNew : public CCNode
	, public CCBSelectorResolver
	, public CCBMemberVariableAssigner
{
	
public:
	
	static CCBFileNew* create();

	static CCBFileNew* CreateInPool(const std::string& CCBFileNew);
	static void purgeCachedData(void);

	CCBFileNew(void);
	virtual ~CCBFileNew(void);
	virtual bool init();
	virtual void onEnter();

	void setCCBFileName(const std::string& filename);
	const std::string& getCCBFileName();
	virtual void load(bool froceLoad = false);
	virtual void unload();
	virtual bool getLoaded();

	void setParentCCBFileNode(CCBFileNew* parent);
	CCBFileNew* getParentCCBFileNode();
	void setListener(CCBFileListener* listener, int tag = 0);
	CCBFileListener* getListener(){return mCCBFileListener;};

	void runAnimation(const std::string& actionname,bool hasEffect=false);
	bool hasAnimation(const std::string& animation);
	float getAnimationLength(const std::string& animation);
	std::string getCompletedAnimationName();

 	CCObject* getVariable(const std::string& variablename);
 	CCNode* getVarNode(const std::string& variablename);
 	CCSprite* getVarSprite(const std::string& variablename);
	CCLabelBMFont* getVarLabelBMFont(const std::string& variablename);
	CCLabelTTF* getVarLabelTTF(const std::string& variablename);
	CCBFileNew* getVarCCNFileNew(const std::string& variablename);
	CCMenu* getVarMenu(const std::string& variablename);
	CCMenuItem* getVarMenuItem(const std::string& variablename);
	CCMenuItemSprite* getVarMenuItemSprite(const std::string& variablename);
	CCMenuItemImage* getVarMenuItemImage(const std::string& variablename);
	CCScrollView* getVarScrollView(const std::string& variablename);
	CCScale9Sprite* getVarScale9Sprite(const std::string& variablename);
	CCParticleSystem* getParticleSystem(const std::string& variablename);
	CCMenuItemCCBFile* getVarMenuItemCCB(const std::string& variablename);
 	CCLayer* getVarLayer(const std::string& variablename);

	CCNode* getCCBFileNode();
	void playAutoPlaySequence();

	void registerFunctionHandler(int nHandler);
	void unregisterFunctionHandler();

	void setCCScrollViewChild(CCScrollView* parent);

	virtual std::string dumpInfo();

	friend class CCNodeLoader;
	friend class CCBAnimationManager;

	virtual void cleanup(void);

	void setCCBTag(int tag){mCCBTag = tag;}
	int getCCBTag(){return mCCBTag;}
	int mScriptTableHandler;
private:
	//CCBSelectorResolver
	virtual SEL_MenuHandler onResolveCCBCCMenuItemSelector(CCObject * pTarget, const char* pSelectorName){return NULL;}
	virtual SEL_MenuHandler onResolveCCBCCMenuItemSelectorWithSender(CCObject * pTarget, const char* pSelectorName, CCNode* sender);
	virtual SEL_CCControlHandler onResolveCCBCCControlSelector(CCObject * pTarget, const char* pSelectorName){return NULL;}
	virtual cocos2d::extension::SEL_CCControlHandler onResolveCCBCCControlSelectorWithSender(cocos2d::CCObject * pTarget, const char* pSelectorName, cocos2d::CCNode* sender);
	//CCBMemberVariableAssigner
	virtual bool onAssignCCBMemberVariable(CCObject* pTarget, const char* pMemberVariableName, CCNode* pNode) ;
	
	void _animationDone();
	void _animationDoneDelay(float);
	void _menuItemClicked(CCObject * pSender);
	void _menuItemClickedForCCControl(cocos2d::CCObject * pSender,unsigned int eventType);

	virtual void onAnimationDone(const std::string& animationName);
	virtual void onContolAction(const std::string& itemName, cocos2d::CCObject* sender, std::string tag);
	virtual void onMenuItemAction(const std::string& itemName, CCObject* sender);

	int Run_Script_Fun(const std::string& funname);

private:
	CCBAnimationManager *mActionManager;
	typedef std::map<std::string, CCObject*> VARIABLE_MAP;
	VARIABLE_MAP mVariables;

	typedef std::map<CCObject*, std::string> MENUITEM_MAP;
	MENUITEM_MAP mMenus;

	CCBFileListener* mCCBFileListener;

	int mCCBTag;
	std::string mLoadCCBFile;
	CCNode* mLoadCCBFileNode;
	CCBFileNew* mParentCCBFileNode;

	CCScrollView* mParentScrollView;

	static std::map<std::string,std::list<CCBFileNew*> > ccbsPool;
	bool mIsInPool;
	bool mIsInSchedule;

	std::list<std::string> mAnimationDoneList;
};

/**
example : 
CCBContainer *page = some_ccb_file;
CCB_FUNC(page,"mSkillBig",CCNode,removeAllChildren());
*/
#define CCB_FUNC(_ccb_,_var_,_type_,_func_) { \
	CCObject* __obj__ = _ccb_->getVariable(_var_); \
	_type_* __node__ = __obj__?dynamic_cast<_type_*>(__obj__):0; \
	if(__node__) __node__-> _func_;}

#define CCB_FUNC_R(_ccb_,_var_,_type_,_func_) { \
	CCObject* __obj__ = _ccb_.getVariable(_var_); \
	_type_* __node__ = __obj__?dynamic_cast<_type_*>(__obj__):0; \
	if(__node__) __node__-> _func_;}

#define CCB_FUNC_RETURN(_ccb_,_var_,_type_,_func_,_ret_) { \
	CCObject* __obj__ = _ccb_->getVariable(_var_); \
	_type_* __node__ = __obj__?dynamic_cast<_type_*>(__obj__):0; \
	if(__node__) _ret_ = __node__-> _func_;}

NS_CC_EXT_END

#endif
