#pragma once
#include "cocos2d.h"
#include "Singleton.h"

USING_NS_CC;
class GameConst : public Singleton<GameConst>
{
private:
	
public:
	GameConst(){};
	void init(const std::string& filename);
	void cleanUp();

	const std::string& getVersonFileAddress();
	
	CCRect boundingBox( CCNode* node ){ return node->boundingBox(); };

	bool isContainsPoint( CCRect rect , CCPoint point ){ return rect.containsPoint(point); };

	long getCurrTime();

	static GameConst* getInstance();
};