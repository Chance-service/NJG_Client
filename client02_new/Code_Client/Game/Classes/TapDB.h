//
//  TapDB.h
//
//  Created by 杜阳阳 on 16/8/18.
//
//

#ifndef cocos2dx_TapDB_h
#define cocos2dx_TapDB_h
#include "cocos2d.h"

enum TGTUserType{
	TGTTypeAnonymous = 0, // 匿名用户
	TGTTypeRegistered = 1  // 注册用户
};

enum TGTUserSex{
	TGTSexMale = 0, // 男性
	TGTSexFemale = 1, // 女性
	TGTSexUnknown = 2 // 性别未知
};


//warning 注意：所有字符串必须为UTF-8编码

class TapDB{

public:
    /**
     * 初始化，尽早调用
     * appId: TapDB注册得到的appId
     * channel: 分包渠道名称，可为空
     * version: 游戏版本，可为空，为空时，自动获取游戏安装包的版本
     */
    static void onStart(const char* appId,const char* channel,const char* version);
    
    /**
     * 记录一个用户（注意是平台用户，不是游戏角色！！！！），需要保证唯一性
     * userId: 用户的ID（注意是平台用户ID，不是游戏角色ID！！！！），如果是匿名用户，由游戏生成，需要保证不同平台用户的唯一性
     * userType: 用户类型
     * userSex: 用户性别
     * userAge: 用户年龄，年龄未知传递0
     */
    static void setUser(const char *userId,int userType, int userSex,int userAge,const char *userName);
    
    /**
     * 设置用户等级，初次设置时或升级时调用
     * level: 等级
     */
    static void setLevel(int level);
    
    /**
     * 设置用户服务器，初次设置或更改服务器的时候调用
     * server: 服务器
     */
    static void setServer(const char *server);
    
    /**
     * 发起充值请求时调用
     * orderId: 订单ID，不能为空
     * product: 产品名称，可为空
     * amount: 充值金额（分）
     * currencyType: 货币类型，可为空，参考：人民币 CNY，美元 USD；欧元 EUR
     * virtualCurrencyAmount: 充值获得的虚拟币
     * payment: 支付方式，可为空，如：支付宝
     */
    static void onChargeRequest(const char *orderId,const char *product,long amount,const char *currencyType,long virtualCurrencyAmount,const char *payment);
    
    /**
     * 充值成功时调用
     * orderId: 订单ID，不能为空，与上一个接口的orderId对应
     */
    static void onChargeSuccess(const char *orderId);
    
    /**
     * 充值失败时调用
     * orderId: 订单ID，不能为空，与上一个接口的orderId对应
     * reason: 失败原因，可为空
     */
    static void onChargeFail(const char *orderId,const char *reason);
    
    /**
     * 当客户端无法跟踪充值请求发起，只能跟踪到充值成功的事件时，调用该接口记录充值信息
     * orderId: 订单ID，可为空
     * product: 产品名称，可为空
     * amount: 充值金额（单位分，即无论什么币种，都需要乘以100）
     * currencyType: 货币类型，可为空，参考：人民币 CNY，美元 USD；欧元 EUR
     * virtualCurrencyAmount: 充值获得的虚拟币
     * payment: 支付方式，可为空，如：支付宝
     */
    static void onChargeOnlySuccess(const char *orderId,const char *product,long amount,const char *currencyType,long virtualCurrencyAmount,const char *payment);

};


#endif /* TapDB_h */
