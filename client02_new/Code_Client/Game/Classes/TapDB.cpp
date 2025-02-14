//
//  TyrantDB.cpp
//  HelloWorld
//
//  Created by 杜阳阳 on 16/8/19.
//
//
#include "TapDB.h"

#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
#include <jni.h>
#include "..\..\cocos2dx\platform\android\jni\JniHelper.h"
#include <android/log.h>
#endif

#define LOG_TAG "TapDB-cocos-bridge"
#define LOGD(...) __android_log_print(ANDROID_LOG_DEBUG,LOG_TAG,__VA_ARGS__)

using namespace cocos2d;

static const char * TGTUserTypeString[] = {
		"TGTTypeAnonymous", // 匿名用户
	    "TGTTypeRegistered" // 注册用户
};

static const char * TGTUserSexString[] = {
		"TGTSexMale", // 男性
		"TGTSexFemale", // 女性
		"TGTSexUnknown" // 性别未知
};

void TapDB::onStart(const char *appId, const char *channel, const char* version){
// for ios. do nothing on android
}

void TapDB::setUser(const char *userId, int userType, int userSex, int userAge, const char *userName){
#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
    JniMethodInfo minfo;

    if (JniHelper::getStaticMethodInfo(minfo,
            "com/xindong/tyrantdb/TyrantdbGameTracker",
            "setUser",
            "(Ljava/lang/String;Lcom/xindong/tyrantdb/TyrantdbGameTracker$TGTUserType;Lcom/xindong/tyrantdb/TyrantdbGameTracker$TGTUserSex;ILjava/lang/String;)V"))
    {
    	jstring juserId = minfo.env->NewStringUTF(userId);

    	jclass juserTypeClass    = minfo.env->FindClass("com/xindong/tyrantdb/TyrantdbGameTracker$TGTUserType");
    	jfieldID typeField    = minfo.env->GetStaticFieldID(juserTypeClass , TGTUserTypeString[userType], "Lcom/xindong/tyrantdb/TyrantdbGameTracker$TGTUserType;");
    	jobject juserType = minfo.env->GetStaticObjectField(juserTypeClass, typeField);

     	jclass juserSexClass    = minfo.env->FindClass("com/xindong/tyrantdb/TyrantdbGameTracker$TGTUserSex");
        jfieldID sexField    = minfo.env->GetStaticFieldID(juserSexClass , TGTUserSexString[userSex], "Lcom/xindong/tyrantdb/TyrantdbGameTracker$TGTUserSex;");
        jobject juserSex = minfo.env->GetStaticObjectField(juserSexClass, sexField);

    	jstring juserName = minfo.env->NewStringUTF(userName);

        minfo.env->CallStaticVoidMethod(minfo.classID, minfo.methodID, juserId, juserType, juserSex, userAge, juserName);

        minfo.env->DeleteLocalRef(juserId);
        minfo.env->DeleteLocalRef(juserName);
    	LOGD("setUser : %s__%d__%d__%d__%s\n",userId,userType,userSex,userAge,userName);
    }
#endif
}

void TapDB::setLevel(int level){
#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
	JniMethodInfo minfo;
	if (JniHelper::getStaticMethodInfo(minfo,
			 "com/xindong/tyrantdb/TyrantdbGameTracker",
			 "setLevel",
			 "(I)V"))
	{
		minfo.env->CallStaticVoidMethod(minfo.classID, minfo.methodID, level);
		LOGD("setLevel : %d\n",level);
	}
#endif
}

void TapDB::setServer(const char *server){
#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
	JniMethodInfo minfo;
	if (JniHelper::getStaticMethodInfo(minfo,
			 "com/xindong/tyrantdb/TyrantdbGameTracker",
			 "setServer",
			 "(Ljava/lang/String;)V"))
	{
		jstring jserver = minfo.env->NewStringUTF(server);
		minfo.env->CallStaticVoidMethod(minfo.classID, minfo.methodID, jserver);
		minfo.env->DeleteLocalRef(jserver);
		LOGD("setServer : %s\n",server);
	}
#endif
}

void TapDB::onChargeRequest(const char *orderId, const char *product, long amount, const char *currencyType, long virtualCurrencyAmount, const char *payment){
#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
	JniMethodInfo minfo;
	if (JniHelper::getStaticMethodInfo(minfo,
			 "com/xindong/tyrantdb/TyrantdbGameTracker",
			 "onChargeRequest",
			 "(Ljava/lang/String;Ljava/lang/String;JLjava/lang/String;JLjava/lang/String;)V"))
	{
		jstring jorderId = minfo.env->NewStringUTF(orderId);
		jstring jproduct = minfo.env->NewStringUTF(product);
		jstring jcurrencyType = minfo.env->NewStringUTF(currencyType);
		jstring jpayment = minfo.env->NewStringUTF(payment);

		jlong jamount = (jlong)amount;
		jlong jvirtualCurrencyAmount = (jlong)virtualCurrencyAmount;

		minfo.env->CallStaticVoidMethod(minfo.classID, minfo.methodID, jorderId, jproduct, jamount, jcurrencyType, jvirtualCurrencyAmount, jpayment);
		minfo.env->DeleteLocalRef(jorderId);
		minfo.env->DeleteLocalRef(jproduct);
		minfo.env->DeleteLocalRef(jcurrencyType);
		minfo.env->DeleteLocalRef(jpayment);
		LOGD("onChargeRequest : %s__%s__%ld__%s__%ld__%s\n",orderId,product,amount,currencyType,virtualCurrencyAmount,payment);
	}
#endif
}

void TapDB::onChargeSuccess(const char *orderId){
#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
	JniMethodInfo minfo;
	if (JniHelper::getStaticMethodInfo(minfo,
			 "com/xindong/tyrantdb/TyrantdbGameTracker",
			 "onChargeSuccess",
			 "(Ljava/lang/String;)V"))
	{
		jstring jorderId = minfo.env->NewStringUTF(orderId);
		minfo.env->CallStaticVoidMethod(minfo.classID, minfo.methodID, jorderId);
		minfo.env->DeleteLocalRef(jorderId);
		LOGD("onChargeSuccess : %s\n",orderId);
	}
#endif
}

void TapDB::onChargeFail(const char *orderId, const char *reason){
#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
	JniMethodInfo minfo;
	if (JniHelper::getStaticMethodInfo(minfo,
			 "com/xindong/tyrantdb/TyrantdbGameTracker",
			 "onChargeFail",
			 "(Ljava/lang/String;Ljava/lang/String;)V"))
	{
		jstring jorderId = minfo.env->NewStringUTF(orderId);
		jstring jreason = minfo.env->NewStringUTF(reason);
		minfo.env->CallStaticVoidMethod(minfo.classID, minfo.methodID, jorderId, jreason);
		minfo.env->DeleteLocalRef(jorderId);
		minfo.env->DeleteLocalRef(jreason);
		LOGD("onChargeFail : %s__%s\n",orderId,reason);
	}
#endif
}

void TapDB::onChargeOnlySuccess(const char *orderId, const char *product, long amount, const char *currencyType, long virtualCurrencyAmount, const char *payment){
#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
	JniMethodInfo minfo;
	if (JniHelper::getStaticMethodInfo(minfo,
			 "com/xindong/tyrantdb/TyrantdbGameTracker",
			 "onChargeOnlySuccess",
			 "(Ljava/lang/String;Ljava/lang/String;JLjava/lang/String;JLjava/lang/String;)V"))
	{
		jstring jorderId = minfo.env->NewStringUTF(orderId);
		jstring jproduct = minfo.env->NewStringUTF(product);
		jstring jcurrencyType = minfo.env->NewStringUTF(currencyType);
		jstring jpayment = minfo.env->NewStringUTF(payment);

		jlong jamount = (jlong)amount;
		jlong jvirtualCurrencyAmount = (jlong)virtualCurrencyAmount;

		minfo.env->CallStaticVoidMethod(minfo.classID, minfo.methodID, jorderId, jproduct, jamount, jcurrencyType, jvirtualCurrencyAmount, jpayment);
		minfo.env->DeleteLocalRef(jorderId);
		minfo.env->DeleteLocalRef(jproduct);
		minfo.env->DeleteLocalRef(jcurrencyType);
		minfo.env->DeleteLocalRef(jpayment);
		LOGD("onChargeOnlySuccess : %s__%s__%ld__%s__%ld__%s\n",orderId,product,amount,currencyType,virtualCurrencyAmount,payment);
	}
#endif
}




