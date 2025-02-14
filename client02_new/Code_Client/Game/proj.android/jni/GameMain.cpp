/*
 *
 *
 *
 *
 * */



#include <jni.h>
#include <android/log.h>
#include "jni/Java_org_cocos2dx_lib_Cocos2dxHelper.h"

//
#include "cocos2d.h"
#include "platform/android/jni/JniHelper.h"

//#include "TDGAJniHelper.h"

//
#include "AppDelegate.h"

//
#define  LOG_TAG    "GameMain"
#define  LOGD(...)  __android_log_print(ANDROID_LOG_DEBUG,LOG_TAG,__VA_ARGS__)
//

using namespace cocos2d;

//
/*

		xinzheng 2013-06-20
		应用程序启动、更新检测、更新流程：
		apk和ipa程序入口相当于一个loader程序，应在loader拉起Game.so（AppDelegate被创建）的时候，准备好二者的衔接�?
		而且只是State(LoadingFrame)这个状态需要与loader通信�?
		以下顺序执行，为了减少麻烦，不并行：
		0、apk入口，显示公�?游戏logo、动画，这个过程不宜过长；检测网络、存储条件；
		0a、隔离平台的版本更新检测和实现；因为有些平台强制在初始化使用其版本更新功能�?
		1、初始化平台SDK，显示平台logo，如果平台不需显示logo，可以延�?步的显示界面；如果不接入平台SDK，直接跳到第2步；
		2、版本更新检测与下载安装，a、自有版本更新实现，需要区别是否使用平台提供的更新检测；b、调用平台SDK提供的更新实现；更新检测结果为可选或无时，进入第3步；
		3、初始化OpenGL ES Context、纹理、音频、输入等与系统相关的必须组件；这个过程会黑屏，需要在loader层保持最上层logo界面或者另外的logo、动画界面；
		4、初始化Game.so，创建AppDelegate，指定集成的登录&支付平台，准备好与loader的衔接，进入State(LoadingFrame)，通知可以发起内更新检测；移除loader层多余的界面，真正开始显示Game.so渲染的界面；
		5、内更新检测返回无需更新，发起调用平台账号登录；或者，内更新进行更新，成功完毕后，发起调用平台账号登录�?
		6、停留在State(LoadingFrame)，直到平台账号登录成功通知Game.so，解除与loader的衔接，允许进入游戏State(MainFrame）；
		7、目前进入State(MainFrame）后不允许再切换账号返回State(LoadingFrame)，只得重启；

*/
AppDelegate* g_pAppDelegate = NULL;
//
extern "C"
{

	/*
		java端：static {System.load(Game.so)}
	*/
	jint JNI_OnLoad(JavaVM *vm, void *reserved)
	{
		JniHelper::setJavaVM(vm);

		//TDGAJniHelper::setJavaVM(vm);

		LOGD("1		JNI_OnLoad");

		return JNI_VERSION_1_6;
	}
	/*
		4、初始化Game.so，创建AppDelegate，准备好与loader的衔接，进入State(LoadingFrame)，通知可以发起内更新检�?
	*/
	void Java_org_cocos2dx_lib_Cocos2dxRenderer_nativeInit(JNIEnv*  env, jobject thiz, jint w, jint h)
	{
		LOGD("Java_org_cocos2dx_lib_Cocos2dxRenderer_nativeInit");

		/*
		 * 按照GameContextState里使用GLSurfaceView的方法，有时需要下面if条件，有时不需要，
		 * 统一改为不需�?
		 * */
		//if (!CCDirector::sharedDirector()->getOpenGLView())
		CCDirector::sharedDirector()->getOpenGLView();
		{
			CCEGLView* view = CCEGLView::sharedOpenGLView();
			view->setFrameSize(w, h);

			g_pAppDelegate = new AppDelegate();
			CCApplication::sharedApplication()->run();
		}

	}
	/*
		
	*/
	void Java_org_cocos2dx_lib_Cocos2dxActivity_nativeOnDestroy(JNIEnv*  env, jobject thiz)
	{
		//test
		CCApplication::sharedApplication()->applicationWillGoToExit();
		//
		delete g_pAppDelegate;
	}

	/*
	 *
	 * */
	JNIEXPORT jint JNICALL Java_com_nuclear_gjwow_GameConfig_nativeReadGameAppID(JNIEnv*  env, jobject thiz,
			jint platform_type)
	{



		return 0;
	}
	/*
	 *
	 * */
	JNIEXPORT jstring JNICALL Java_com_nuclear_gjwow_GameConfig_nativeReadGameAppKey(JNIEnv*  env, jobject thiz,
			jint platform_type)
	{



		return 0;
	}
	/*
	 *
	 * */
	JNIEXPORT jstring JNICALL Java_com_nuclear_gjwow_GameConfig_nativeReadGameAppSecret(JNIEnv*  env, jobject thiz,
			jint platform_type)
	{

		if (platform_type == 3)
		{
			//enPlatform_360
			return JniHelper::string2jstring("8845b21d2d91200b47178cf843fcc68a");
		}

		return 0;
	}

	//--begin
	/*
		GameApp在各个平台的appid、appkey、各种secret等数字，字符串，
		在java代码很容易被反编译，
		硬编码在c++代码，提高反编译难度�?
		如果需要，可进一步加密字符串�?
		按json格式传到java，好解析
	*/
	static char gamePlatformAnZhi[] = "{ \"appkey\":\"1408527584cbTGhqToNTB5RgORmgIU\", \"appsecret\":\"jxJoK6Xm0gvwSVIuPcP3bS1e\"}";
	//360
	static char gamePlatform360[] = "{ \"appid\":\"201830256\", \"appkey\":\"92b5a1cdb0b44dcfa7be626d94f8a8ef\"}";

	static char gamePlatformDangLe[] = "{ \"cpid\":\"953\", \"appid\":\"2166\", \"svrid\":\"1\", \"appkey\":\"33z9VUVh\"}";

	static char gamePlatformXiaoMi[] = "{ \"appid\":\"2882303761517245711\", \"appkey\":\"5551724553711\"}";

	static char gamePlatformWanDouJia[] = "{ \"appid\":\"100011719\", \"appkey\":\"3faaf7ad41f7d99ed0da70ce5fa5d60c\"}";
	//百度 天天爱挂�?
	static char gamePlatformDuoKu[] = "{ \"appid\":\"3335326\", \"appkey\":\"Wz51eVCenN7Bs20FBPGfXZwd\", \"appsecret\":\"6b54FQvpmj1WQgOwifzUAjOxlqadDDY6\"}";

	//	static char gamePlatformDuoKu[] = "{ \"appid\":\"3335561\", \"appkey\":\"TSMHRtAM7gZt2iKQVHjTCfwg\", \"appsecret\":\"MwRKGxbj4YGjfz8CGCkAikFtCPVLQyq7\"}";

	static char gamePlatformYingYongHui[] = "{ \"appid\":\"10071400000001100714\", \"appkey\":\"Njc2MUJDMkUyNTU4MzVGNTY1MDY2QzJDOUQxM0JBRUUzQzI2RDU0RE1UUTBOalV5TkRBeU1ESXdORGs1T1RZNU9ERXJNVFV3TnpjNE9UVTVOemt6TXpVMU1qY3pPVGMzTURRMk16RTNNRFEyTXprd01qazRPVEEz\",\"payaddr\":\"http://android-pay.ttagj.com/callback/yyhpay/\"}";
	//酷派
	static char gamePlatformKupai[] = "{\"appid\":\"9\",\"appkey\":\"gjwowall_and\",\"appsecret\":\"gjwowall_googleftsec\", \"appid_cool\":\"3000539891\",\"appkey_cool\":\"RkMxMEZCMkVCRDI0NzAwODE1Rjg0Njk3MTZCOTMzRkY0NkY3NTgwRk1UWTRNelkwTkRBek5UTTROemcwTVRReU1URXJNVE0xTmpReE16QTFOalUyTnpFMk16SXdPRFl5T0RReU1EazFNVFU0TWpJMU5EWTFNak01\"}";
	//JinLi
	static char gamePlatformJinli[] = "{ \"loginurl\":\"http://android-pay.ttagj.com/callback/jinliOrderpay/\",\"appkey\":\"2F94EF64A8B6443B8C4DE7FCE9C27653\",\"app_secret\":\"D2375914B19F4F958A0B2DA3723A4EC7\",\"payaddr\":\"http://android-pay.ttagj.com/callback/jinlipay/\"}";
	//Vivo
	static char gamePlatformVivo[] = "{ \"appid\":\"21229b97a967453fe989d00eda5cc205\", \"cpid\":\"20140821172058948222\", \"cpkey\":\"846ed1c3a6eb65d390d9f79030c86ecf\", \"payaddr\":\"http://android-pay.ttagj.com/callback/vivopay/\"}";
	//OPPO
	static char gamePlatformOppo[] = "{ \"appid\":\"2080\", \"appkey\":\"4mT6k24DvlwkCS8cgOoSw8gos\",\"app_secret\":\"F72e134Db03f0023Fef09ABeE356D44A\",\"payaddr\":\"http://android-pay.ttagj.com/callback/oppopay/\"}";
	//HTC
	static char gamePlatformHTC[]="{ \"appid\":\"2815820284782\",\"publicKey\":\"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDe1tcJpN6xdJ+H71p1CseEe79JfItLhZ/by9ndGUGjGR9+0stPWfHBao2EYKfNw7l4nQcOPrDFsh1naGELfAKNzDd1BwEuiGBTjO7v8V1wV2nJY9i2ckVv7aY2m3QOjtMhNoGVRnxlVyZ5VbZDbdySvJBY7lPSjMFXkJCx6j3/hwIDAQAB\", \"payaddr\":\"http://android-pay.ttagj.com/callback/joloplaypay/\", \"private\":\"MIICdgIBADANBgkqhkiG9w0BAQEFAASCAmAwggJcAgEAAoGBAMrT6hBnBhG9iiHC15c0rbHduad7iz4gX80eiHgDA2A2jzTHgIlEm/peHOOg9VEk+ANhVVKyNufUAzdWuzN4ClZ/2Ii8BFZrGP8CTf7AeGqngN0L/8EOXYgmOulpd8uEv4t4XR3yF9JX5586z5NkZfrtEov6UhaDItTlm7+40pNRAgMBAAECgYBwpMJwe5b+UUKev2QWYLY6ewZ5gn5xcW9jLprh8+JzE7nyuP2kvorVwGDQ9npnp11qGytUsw8VL0Td/fgXfIpYRKfq4S/eM25NutXCeoP4cWKzqicxXjiiu+5N/qjXj//exqnBbYe9fB7jWuQZ/03h/t84Zs4a3MuRvQfGoZfbJQJBAOZSl0HqYngma5MA3NcxQgRc5e5th2w2WRSeNMUOlrA2gXm4GBicP6EoS1RcPpJgm3d2OrtGjJ8ONWlgB3pEORsCQQDhcJ7uNoNwNFakked+5kIDBVHdBK92qFdYjyqk8ItYDXREkYLa0WHcHS4W4yiRyp6bux2HRqo7XSRjEEo5GDgDAkAnDUnoOz2G8by7qCHJuuhepQG3c4rKpkxkWo7H+rlCF3vMj5JGWffP820SWLGjUA4MK1e5+TROo7Ias9WQvZCRAkEAsky5VlxFHmQ2tpgzCFmikfMOKQkAoY9I7eDlcGhTPQP/FhAj916s0EM/5ZgpyQ0A3thh5VDNaIAlPDhxC7EM8wJAMoqerQPvkqA4CNErn64+u57dKCHufm0lbUCucKJD1jjjxGMdpNw1asHaCJmGn50lX08c0b2GlW5Huy8qaigo5A==\"}";

	static char gamePlatformPPTV[]="{ \"gid\":\"qmgj\",\"appkey\":\"53f6b4adfd98c54d4f0009ba\",  \"payaddr\":\"http://android-pay.ttagj.com/callback/pptvpay/\"}";
	//魅族
	static char gamePlatformMeizu[] = "{ \"appid\":\"A928\",\"appkey\":\"f0cd3af5b2420c471f747e93412c307b\"}";

	static char gamePlatform37ZF1[] = "{ \"appid\":\"A1139\",\"appkey\":\"dc748aaf95b25b7a1fdc885a94a4b65e\"}";

	static char gamePlatform37ZF2[] = "{ \"appid\":\"A1140\",\"appkey\":\"dc748aaf95b25b7a1fdc885a94a4b65e\"}";
	//JinShan
	static char gamePlatformJinShan[] = "{ \"gid\":\"124\", \"appid\":\"200124\", \"appkey\":\"4ilfdz29p36599\", \"payaddr\":\"http://android-pay.ttagj.com/callback/kingsoftpay/\"}";
	//优酷
	static char gamePlatformYouku[]="{ \"appid\":\"684\",\"appkey\":\"bb2c536c8c2ebc20\", \"appsecret\":\"6175417a62d1e7ae01b5b4274a0d72f4\", \"paykey\":\"247f3f6e7593cef5231b4e6a4b25c602\", \"payaddr\":\"http://android-pay.ttagj.com/callback/youkupay/\"}";
	//UC
	static char gamePlatformUC[] = "{ \"cpid\":\"43259\", \"appid\":\"543854\", \"svrid\":\"3443\", \"appkey\":\"3ececf79aabe999f10a86dd42b15ad05\",\"payaddr\":\"http://android-pay.ttagj.com/callback/ucpay/\"}";
	//lenovo
	static char gamePlatformLenovo[] = "{ \"appid\":\"1408200068767.app.ln\",\"appkey\":\"NEJCMDRFOTk4NEIzMEEwRjMwRDY0MkE0QzdGRDUzNjI1RDYxNjBENU1USTVNak0zTlRFd05UY3lOemcxTkRVek5qa3JNVFkxT1RRM056STNNak0xTVRRM01UTTFNemN5TVRjME9EQTNNVFl3TWpjeU9EVTJOalU1\",\"pay_id_str\":\"20032000000001200320\",\"payaddr\":\"http://203.195.193.41/recharge_gjwow_android/newrecharge.php\"}";
	//N�?
	static char gamePlatformNduo[]="{  \"appkey\":\"nuclearqmwowplatformnduo\",\"appsecret\":\"wtpy5thexxwbcj4csfeafr5ty7r8jxm2\"}";
	//HuaWei
	static char gamePlatformHuaWei[] = "{ \"appid\":\"10177186\",\"appkey\":\"zauwux9n0quinuhlc0qkqp75b1w2pq3u\", \"payid\":\"900086000021229991\", \"cpid\":\"900086000021229991\", \"private\":\"MIIBUwIBADANBgkqhkiG9w0BAQEFAASCAT0wggE5AgEAAkEAnyrthxFG6YjHPzrzqiLzZRh+lkqKUu7LS1TAdR82c1iINmvF5ekrac+c6fAPZVAM9A8G6Yf4ep10wMpYUuz5ZwIDAQABAkAe0n5KwJK92InU+cKDuN7vPc4NpoOgybM+dDwMsi2mKjh3KyYaRT03CS+3L5OdrUxBoqVsg33dD4n0ulwr7eL5AiEA7qgHbSvtCcc5wIxykRDsEPF7K/nLQd6mxAZ6o9KBkuUCIQCqvBa9hDM18Umd0z9EffdhhAq/GKCGltogdDAZEoCaWwIgOFiBkFvrlgBseTJvpiJZqdJpo0NRotafhu6ErAL6RqUCIHJ35nsrfjYlTqj878cY+Vms8JOMjFuQGjB2FaVJrWVPAiAnLCyb3ACnujHhcp2r033v5l5KQJwzcJpbyAMdXu6muw==\", \"public\":\"MFwwDQYJKoZIhvcNAQEBBQADSwAwSAJBAJ8q7YcRRumIxz8686oi82UYfpZKilLuy0tUwHUfNnNYiDZrxeXpK2nPnOnwD2VQDPQPBumH+HqddMDKWFLs+WcCAwEAAQ==\", \"payaddr\":\"http://203.195.193.41/recharge_gjwow_android/newrecharge.php\", \"buoykey\":\"MIICdQIBADANBgkqhkiG9w0BAQEFAASCAl8wggJbAgEAAoGBAIpzbHmLWNiaGyOq69BkqQSoxINC4h5A95etaEsR7VnCLm9iGaVgro8wjQLo7vcI6GKbsDcN5zSfKtUylSuc5nopOPsoWMEHPiplMoR6nkeLEDQvgpjiCrCrb7WfLK/6qWJH2op4pPOHpOckGKsVoS5WnmBlCBHwwH0RkO4S47FpAgMBAAECgYB056WOs/UfYHDOG0LnQjfdcUwNseoQtbba4leQG+EYy3g+IM2a8Ro0WkCXVmyBN4pRyThwJFM4AbY/M2j13JRXCSLF1b0dbU6D9YUS+NtKn9DognCeXLs9gWIW3in3RWoK+ApxZvrRzf3aK71RMO40hmRM3YETIAuQ3PySsHymAQJBAOmJUyzEzWOTi+g9UUVIYD4CdQDi9sNb6sgrYehuetM2OR6JACK+xUU+0SHSNCanodJ8gTjYaJsTITbYY9FcQ4kCQQCXxK6YgCpA1/oYJAX3GpSi7QLKi9RtX/FhLrGyY/3iVr7TOq5BYG1DaKql22l2CqsEmuA6b1UY4KiBrhPJFibhAkAjCR8ZUE0f6zrKFKjko/8MToIPJ/2tQVTvwtJldG2o0jGviw4iKEygHtRxJn/8bJmyYktgo9bNrQkGmWAgQJ9BAkAF0mOoMfJs/lv3pRodeoWNIm5i+q4xa+bEhZgHcdKBZjZ3v96DX4GRfmhdaGdJQeuBh7dmRnMLO0L7hoP3yMPBAkAgA8BFUV1KjOgqKOFpseZAyNG1crhB1wPyVbF17ZAupeLtNki703bOJU/JD0zoeglU8hmVXc7eqqZvULkqgs78\"}";
	//google fanti
	static char gamePlatformGoogleFT[] = "{ \"appid\":\"20\",\"appkey\":\"gjwow_and\",\"appsecret\":\"gjwowandlelqizperceqlrecw\",\"rechargeurl\":\"http://203.90.236.37/callback/googlepay/\",\"public_str\":\"MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA7O1gO7A9IXZNkhhe72Q6Z6M8rzSk7kYXxDPXjVu6ZZclAZO9X8xtU+7wQX6cbYulPV3zZOeVRT31Zyow+3ACt1dZNgZg066vkg2vELDM2gO8d0F4lEYtWYzHNhzczJnD9VkK3f4cuKFnh1BQOvDQr1a1tuGf+4j4Gs8dxVFq1isESkpocS48AZcLkBhJNZ2Vo10sxavWBgHVr5Y8qH96OVw2RmZCoOwp3JKHfwldzOqsGtVUbH9TSdBEp+Qz0IIz4HXymRxDtNR06dBupG/1dfsFILIFrrVFMKIAfc9ypLKDmXEIKg3A8dwztMxfwn5Jvvr+wrTdN4xvUACYFN79qQIDAQAB\"}";
	//google fanti-纯谷歌支�?
	static char gamePlatformGoogleFTGP[] = "{ \"appid\":\"20\",\"appkey\":\"gjwow_and\",\"appsecret\":\"gjwowandlelqizperceqlrecw\",\"rechargeurl\":\"http://203.90.236.37/callback/guajikinggooglepay/\",\"public_str\":\"MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAn0jdo6om0MrjeuEYTtvzwRgLWNo9h2f5qrDB9oPI9X2wJqDdd+cWc5r/ajqRReFkgMiTtS3T0gySuQAtr7YQZelBZ5MlOMQB6feHWLBPRNeKilY8G+vgP8Jf6MkRvnUbSeqHnjoO8KSLoeYcIdcqP0iIEBWZtvtq2fW+27J1s9P9O607Hy01+sZRPDSUvSVOqXh3KVTpZGQI0pMCa23U/TH9KmMUFacD5EesU3YDfq9J8NMccHWUOPUKnhS8El2++XTVzfPFsjQP3/iAgbnS4kScM7pQ6OgKUga+GeFhE2bqeVutRk0yX7ZIK3YuqPQPKhu20vKMq56D7kQQsHrEPwIDAQAB\"}";
	//google fanti-我是挂机�?
	static char gamePlatformGoogleFTGJW[] = "{ \"appid\":\"24\",\"appkey\":\"hwgjw\",\"appsecret\":\"hwgjwandweljqoqfodlzel\",\"rechargeurl\":\"http://203.90.236.37/callback/googlepay/\",\"public_str\":\"MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAyrZVDUmkNdEQRtuVIVJXMvYRzy1I259ccoZEdiGwJRTXc49HdwyedyYNZFEVP2/iCwpABvExL0oTm6JASHugYcqtEyRagkWQwr2FEtk80vbwt32WIyfi1rexUTB7nJRG2NjC+wz2ExMcwjLEOfcLCX92ZhcPg3grvn7kky3do17hCNiuHOFAetJ4Ol5unND+xCdUdDw0YFEcVC3abQUsD5RselVAbmfm13RJ8YB6jVcvIjIm8kZjtsK16TNUVCD/vu7WTp3nlYDnBD+u+9jfTx4yUokcCw0ufTe1fR4s6FW1erv6j4b9Cxbnv1+OcUoWxzZzOGkmDotgGYuXNtiiiQIDAQAB\"}";
	//baofeng
	static char gamePlatformBaoFeng[] = "{ \"cpid\":\"11\",\"cpkey\":\"71441699\",\"payaddr\":\"http://android-pay.ttagj.com/callback/baofenpay/\"}";
	//3G 2324
	static char gamePlatformGame2324[] = "{ \"appid\":\"2635\",\"appkey\":\"2324quanminguaji\",\"cpid\":\"26236\"}";
	




	//
	static char gamePlatformNd91[] = "{ \"appid\":\"112727\", \"appkey\":\"1f44424ae0be1bb982e50f9cca953c6788d0596189d8f21c\"}";

	static char gamePlatformRenRen[] = "{ \"appid\":\"237963\", \"appkey\":\"086a46f2b98447c498a74e740208fb8d\", \"appsecret\":\"4e04c89aa3bb42a2b877fd7f5676cb8e\"}";

	static char gamePlatformAnZhiGG[] = "{ \"appkey\":\"1384499343k7G722RQrQlfnusjqX6p\", \"appsecret\":\"75zh135C89I7OnVc20WxH810\"}";

	//static char gamePlatformJinShan[] = "{ \"appid\":\"200005\", \"appkey\":\"LaL39DyVzLWpXn\", \"appsecret\":\"5\"}";
	//static char gamePlatformJinShan[] = "{ \"appid\":\"200068\", \"appkey\":\"rf7rnjdc6s8r92\", \"appsecret\":\"68\"}";
	//static char gamePlatformJinShan[] = "{ \"appid\":\"200012\", \"appkey\":\"t09Azn53iu4Shl\", \"appsecret\":\"12\"}";
	static char gamePlatformGameSSJJ[] = "{ \"appid\":\"1373981244746530\", \"appkey\":\"e96e4f36bb599d286fa87f2de495cbff\",\"appsecret\":\"4011a79216417a346b4800d0ef22f11d\"}";

	static char gamePlatformKuWo[] = "{ \"appid\":\"6\", \"appkey\":\"mg_6_login\", \"appsecret\":\"mg_6_recharge\"}";

	static char gamePlatformBaiDuGame[] = "{ \"appkey\":\"408f743d01405e13d0283ee895854ef5\", \"appsecret\":\"8a97a7b2408f743d014095854ef53ee9\"}";

	static char gamePlatformLvDou[] = "{ \"appid\":\"10004\", \"appkey\":\"1ad613287e114d6d9571de4e7fb4e64ef95972eabd5c45faa91c7924c620ed65\",\"payaddr\":\"http://203.195.147.63/recharge_android/newrecharge.php\"}";

	static char gamePlatformChuKong[] = "{ \"appid\":\"377144676\", \"appkey\":\"73e9e7352c80143cab960053189798a6\",\"appsecret\":\"http://203.195.147.63/tokenValidate/chukong.php?\"}";

	static char gamePlatformGTV[] = "{ \"appid\":\"2\", \"appkey\":\"39\",\"appsecret\":\"a5bc13014740c509161891da4104f8e2\", \"svrid\":\"0\"}";

	static char gamePlatformXunLei[] = "{ \"cpid\":\"000002\", \"appid\":\"10002\"}";

	static char gamePlatformKuGou[] = "{ \"appid\":\"51\", \"gameid\":\"10170\", \"appkey\":\"0|gTv3}O{%g2z7xU]q%18dR*d%dz%|Gk55cRs6{RN\"}";

	static char gamePlatformYouai[] = "{ \"appid\":\"20\",\"appkey\":\"gjwow_and\",\"appsecret\":\"gjwowandlelqizperceqlrecw\"}";

	static char gamePlatformSouGou[] = "{ \"appid\":\"188\", \"appkey\":\"a9c6bbd42c3786660a36aba1da3e424d52491798f943cbbe30d9430d9a4b3cae\", \"appsecret\":\"1fdfedc550f855924c22d0fd1ad4a44877a5ab9560253c8b4a03066d1a7579ba\", \"payaddr\":\"http://203.195.147.63/tokenValidate/sougou.php\"}";

	static char gamePlatformBaiDuMobile[] = "{ \"appid\":\"1507188\", \"appkey\":\"u2ioWS3pw3rw3TNxo5maVPHS\",\"payaddr\":\"http://203.195.182.28/recharge/newrecharge.php\"}";

	static char gamePlatformCmge[] = "{ \"appid\":\"M1017A\"}";

	static char gamePlatformYdmm[] = "{ \"appid\":\"9\",\"appkey\":\"gjwowall_and\",\"appsecret\":\"gjwowall_googleftsec\",\"payid\":\"300003946053\",\"private\":\"8B5D48D64DACA635\"}";

	static char gemePlatformPipaw[]="{ \"cpid\":\"42\",\"gameid\":\"71\",\"appid\":\"421383273655\",\"privateKey\":\"987f7af09f4cf1810ee5f695d414446d\"}";


	static char gemePlatformOupeng[]="{  \"appid\":\"20003800000001200038\",\"appkey\":\"N0M3NzFFNTFDMUIwMTU2Rjk3RkQ0MDJGOUQ0RTVBOTY5RjZDN0FCNU1URTBNREV4TWpFMk9UZzFOVGc0TXpjMU5ETXJNVEU1T0RFNU9UWTRNek13TWpBNE1EWTFOelk1T0RnMU5Ua3lOVE16TmpjNU56RTRORE01\"}";

	static char gamePlatformSjyx[] = "{ \"appid\":\"30\",\"appkey\":\"b4f96ba6ce5e442489b76df5b66446a3\"}";
	
	static char gamePlatformSqwan[] = "{ \"appid\":\"27\",\"appsecret\":\"6b2fc5f0f63a27ac34723d8cd85259cc\"}";



	static char gamePlatformLenoq[] = "{ \"appid\":\"9\",\"appkey\":\"gjwowall_and\",\"app_secret\":\"gjwowall_googleftsec\",\"pay_id_str\":\"20019100000001200191\",\"public_str\":\"M0I4NDQ3RTA4MzY3NjkwNDYwRkNBMzkwQkZFRjA1QzdBMkI0RkQ4Q01UQXhNVGt6TXpVNE5EYzNNelkxTWpneE1qRXJNamcyTnpZNE1ETXdOalk1T0RFMU1ESTFNREk0TmpVMk1qYzJNalF5TlRjM01UZ3dOakE1\"}";
	
	static char gemePlatformTianyi[]="{  \"appid\":\"9\",\"appkey\":\"gjwowall_and\",\"appsecret\":\"gjwowall_googleftsec\",\"pay_id_str\":\"1005360\",\"privateKey\":\"EC0F3768F9D4FED8E040007F010019D6\"}";

	static char gamePlatformSqw[] = "{ \"appid\":\"1000026\",\"appkey\":\"6,wDQu&V!IF13xsei8atb2Z;XH4LJN$9\",\"appsecret\":\"sy00000_1\"}";
	
	//卓然
	static char gamePlatformJorGame[] = "{ \"appid\":\"X10232A\",\"appkey\":\"C10016A\",\"private\":\"F1017A\"}";
	
	//51
	static char gamePlatformFiveOne[] = "{ \"appkey\":\"9a1131e20977b5f3fa5bbde6d75ff844\",\"publicKey\":\"254e1958fde486075d1bb7bb10630c29\"}";

	//木蚂�?
	static char gamePlatformMumayi[] = "{\"appkey\":\"d8df2551bcddc43f8uubmwJesUxaN5nZ0ZyCHkMRUCHJuZaVFqx9ftRR2XOIhiY\"}";

	static char gamePlatformOpenqq[] = "{\"appid\":\"1102333883\",\"appkey\":\"QLt8wjt6c4DX5hGN\",\"payaddr\":\"http://android-pay.ttagj.com/callback/yybData/\"}";
	
	static char gamePlatformItoolsOpenqq[] = "{\"appid\":\"1102333621\",\"appkey\":\"7mRXLf2xW3gAkwAp\",\"payaddr\":\"http://android-pay.ttagj.com/callback/itoolsyybpay/\"}";
	
	static char gamePlatformPPS[]="{ \"appid\":\"651\",\"appkey\":\"74974bf301ff7e270d0e1e6860735f38\", \"paykey\":\"QMGJ83isS58o03adD32bnPpsgames651\", \"payaddr\":\"http://android-pay.ttagj.com/callback/ppspay/\"}";
	/*
	 *
	 * */
	JNIEXPORT jstring JNICALL Java_com_nuclear_gjwow_GameConfig_nativeReadGamePlatformInfo(JNIEnv*  env, jobject thiz,
			jint platform_type)
	{

		if (platform_type == 1)
		{
			//enPlatform_91
			return JniHelper::string2jstring(gamePlatformNd91);
		}
		if (platform_type == 2)
		{
			//enPlatform_UC
			return JniHelper::string2jstring(gamePlatformUC);
		}
		if (platform_type == 3)
		{
			//enPlatform_360
			return JniHelper::string2jstring(gamePlatform360);
		}
		if (platform_type == 4)
		{
			//enPlatform_DangLe
			return JniHelper::string2jstring(gamePlatformDangLe);
		}
		if (platform_type == 5)
		{
			//enPlatform_XiaoMi
			return JniHelper::string2jstring(gamePlatformXiaoMi);
		}
		else if (platform_type == 6)
		{
			//enPlatform_WanDouJia
			return JniHelper::string2jstring(gamePlatformWanDouJia);
		}
		else if (platform_type == 7)
		{
			//enPlatform_BaiduDuoKu
			return JniHelper::string2jstring(gamePlatformDuoKu);
		}
		else if(platform_type == 14)
		{
			return JniHelper::string2jstring(gamePlatformRenRen);
		}
		else if(platform_type == 17)
		{
			return JniHelper::string2jstring(gamePlatformYingYongHui);
		}
		else if(platform_type == 13)
		{
			return JniHelper::string2jstring(gamePlatformAnZhi);
		}
		else if(platform_type == 23)
		{
			return JniHelper::string2jstring(gamePlatformJinShan);
		}
		else if(platform_type == 16)
		{
			return JniHelper::string2jstring(gamePlatformGameSSJJ);
		}
		else if(platform_type == 10)
		{
				return JniHelper::string2jstring(gamePlatformKuWo);
		}
		else if(platform_type == 24)
		{
				return JniHelper::string2jstring(gamePlatformBaiDuGame);
		}
		else if(platform_type == 25)
		{
				return JniHelper::string2jstring(gamePlatformLvDou);
		}
		else if(platform_type == 26)
		{
				return JniHelper::string2jstring(gamePlatformOppo);
		}
		else if(platform_type == 27)
		{
				return JniHelper::string2jstring(gamePlatformChuKong);
		}
		else if(platform_type == 28)
		{
				return JniHelper::string2jstring(gamePlatformXunLei);
		}
		else if(platform_type == 30)
		{
				return JniHelper::string2jstring(gamePlatformKuGou);
		}
		else if(platform_type == 29)
		{
				return JniHelper::string2jstring(gamePlatformGTV);
		}
		else if(platform_type == 31)
		{
				return JniHelper::string2jstring(gamePlatformHuaWei);
		}
		else if(platform_type == 111)
		{
				return JniHelper::string2jstring(gamePlatformYouai);
		}
		else if(platform_type == 32)
		{
			return JniHelper::string2jstring(gamePlatformSouGou);
		}
		else if(platform_type == 33)
		{
			return JniHelper::string2jstring(gamePlatformBaiDuMobile);
		}
		else if(platform_type == 34)
		{
			return JniHelper::string2jstring(gamePlatformCmge);
		}
		else if(platform_type == 35)
		{
			return JniHelper::string2jstring(gamePlatformYdmm);
		}
		else if(platform_type == 36)
		{
			return JniHelper::string2jstring(gemePlatformPipaw);
		}
		else if(platform_type==37){
			return JniHelper::string2jstring(gamePlatformLenovo);
		}
		else if(platform_type == 38)
		{
			return JniHelper::string2jstring(gamePlatformNduo);
		}
		else if(platform_type == 39)
		{
			return JniHelper::string2jstring(gamePlatformSjyx);
		}
		else if(platform_type == 40)
		{
			return JniHelper::string2jstring(gemePlatformOupeng);
		}
		else if(platform_type == 41)
		{
			return JniHelper::string2jstring(gamePlatformMeizu);
		}
		else if(platform_type == 42)
		{
			return JniHelper::string2jstring(gamePlatformSqwan);
		}
		else if(platform_type == 44)
		{
			return JniHelper::string2jstring(gamePlatformLenoq);
		}
		else if(platform_type == 46)
		{
			return JniHelper::string2jstring(gemePlatformTianyi);
		}
		else if(platform_type == 133)
		{
			return JniHelper::string2jstring(gamePlatformAnZhiGG);
		}
		else if(platform_type==47)
		{
			return JniHelper::string2jstring(gamePlatformSqw);
		}
		else if(platform_type==48)
		{
			return JniHelper::string2jstring(gamePlatformJorGame);
		}
		else if(platform_type==49)
		{
			return JniHelper::string2jstring(gamePlatformJinli);
		}
		else if(platform_type==50)
		{
			return JniHelper::string2jstring(gamePlatformGame2324);
		}
		else if(platform_type==51)
		{
			return JniHelper::string2jstring(gamePlatformFiveOne);
		}
		else if(platform_type==52)
		{
			return JniHelper::string2jstring(gamePlatformMumayi);
		}
		else if(platform_type==53)
		{
			return JniHelper::string2jstring(gamePlatformGoogleFT);
		}
		else if(platform_type==54)
		{
			return JniHelper::string2jstring(gamePlatformVivo);
		}
		else if(platform_type==55)
		{
			return JniHelper::string2jstring(gamePlatformKupai);
		}
		else if(platform_type==58)
		{
			return JniHelper::string2jstring(gamePlatformHTC);
		}
		else if(platform_type==60)
		{
			return JniHelper::string2jstring(gamePlatformPPTV);
		}
		else if(platform_type==63)
		{
			return JniHelper::string2jstring(gamePlatformYouku);
		}else if(platform_type==61)
		{
            return JniHelper::string2jstring(gamePlatformPPS);
		}
		else if(platform_type==64)
		{
	        return JniHelper::string2jstring(gamePlatformOpenqq);
		}
		else if(platform_type==70)
		{
			return JniHelper::string2jstring(gamePlatformGoogleFTGP);
		}
		else if(platform_type==71)
		{
			return JniHelper::string2jstring(gamePlatformGoogleFTGJW);
		}
		else if(platform_type==72)
		{
			return JniHelper::string2jstring(gamePlatformItoolsOpenqq);
		}
		else if(platform_type==73)
		{
			return JniHelper::string2jstring(gamePlatformBaoFeng);
		}
		else if(platform_type==75)
		{
			return JniHelper::string2jstring(gamePlatform37ZF1);
		}
		else if(platform_type==76)
		{
			return JniHelper::string2jstring(gamePlatform37ZF2);
		}
		return 0;
	}
	//--end

}//extern "C"

