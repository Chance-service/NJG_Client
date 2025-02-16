#include "libOS.h"
#include "libOSObj.h"
#include <sys/sysctl.h>
#include <mach/mach.h>
#include <sys/utsname.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>
#import "UIDevice+IdentifierAddition.h"
#import "MovieMgr.h"
#import "WCAlertView.h"
#import "InputView.h"
#import "SvUDIDTools.h"
#import "FCUUID.h"
#import <AdSupport/ASIdentifierManager.h>

#ifdef RECODER
#import "ZZRecorderManager.h"
#import "ZZPlayerManager.h"
#import "ZZEncoderManager.h"
#import "ZZDecoderManager.h"
#import "ZZPlayer.h"
#import "ZZRecorder.h"
#import "ZZEncoder.h"
#import "ZZDecoder.h"
#endif

#import "../../../Code_Client/xcode/Game/Game/ios/AppController.h"

libOS * libOS::m_sInstance = 0;
libOSObj* s_libOSOjb = 0;

int _enc_unicode_to_utf8_one(wchar_t unic, std::string& outstr)  
{  

	if ( unic <= 0x0000007F )  
	{  
		// * U-00000000 - U-0000007F:  0xxxxxxx  
		outstr.push_back(unic & 0x7F);  
		return 1;  
	}  
	else if ( unic >= 0x00000080 && unic <= 0x000007FF )  
	{  
		// * U-00000080 - U-000007FF:  110xxxxx 10xxxxxx  
		outstr.push_back(((unic >> 6) & 0x1F) | 0xC0); 
		outstr.push_back((unic & 0x3F) | 0x80);  
		return 2;  
	}  
	else if ( unic >= 0x00000800 && unic <= 0x0000FFFF )  
	{  
		// * U-00000800 - U-0000FFFF:  1110xxxx 10xxxxxx 10xxxxxx  
		outstr.push_back( ((unic >> 12) & 0x0F) | 0xE0);  
		outstr.push_back(((unic >>  6) & 0x3F) | 0x80);  
		outstr.push_back( (unic & 0x3F) | 0x80);  
		return 3;  
	}  
	else if ( unic >= 0x00010000 && unic <= 0x001FFFFF )  
	{  
		// * U-00010000 - U-001FFFFF:  11110xxx 10xxxxxx 10xxxxxx 10xxxxxx  
		outstr.push_back( ((unic >> 18) & 0x07) | 0xF0); 
		outstr.push_back( ((unic >> 12) & 0x3F) | 0x80);
		outstr.push_back( ((unic >>  6) & 0x3F) | 0x80);
		outstr.push_back( (unic & 0x3F) | 0x80);
		return 4;  
	}  
	else if ( unic >= 0x00200000 && unic <= 0x03FFFFFF )  
	{  
		// * U-00200000 - U-03FFFFFF:  111110xx 10xxxxxx 10xxxxxx 10xxxxxx 10xxxxxx  

		outstr.push_back( ((unic >> 24) & 0x03) | 0xF8); 
		outstr.push_back( ((unic >> 18) & 0x3F) | 0x80);
		outstr.push_back( ((unic >> 12) & 0x3F) | 0x80);
		outstr.push_back( ((unic >>  6) & 0x3F) | 0x80);  
		outstr.push_back( (unic & 0x3F) | 0x80);  
		return 5;  
	}  
	else if ( unic >= 0x04000000 && unic <= 0x7FFFFFFF )  
	{  
		// * U-04000000 - U-7FFFFFFF:  1111110x 10xxxxxx 10xxxxxx 10xxxxxx 10xxxxxx 10xxxxxx  
		outstr.push_back( ((unic >> 30) & 0x01) | 0xFC);
		outstr.push_back( ((unic >> 24) & 0x3F) | 0x80); 
		outstr.push_back( ((unic >> 18) & 0x3F) | 0x80);
		outstr.push_back( ((unic >> 12) & 0x3F) | 0x80);  
		outstr.push_back( ((unic >>  6) & 0x3F) | 0x80);  
		outstr.push_back( (unic & 0x3F) | 0x80); 
		return 6;  
	}  

	return 0;  
}
void libOS::requestRestart()
{
	exit(0);
}
NetworkStatus libOS::getNetWork()
{
    //¥¥Ω®¡„µÿ÷∑£¨0.0.0.0µƒµÿ÷∑±Ì æ≤È—Ø±æª˙µƒÕ¯¬Á¡¨Ω”◊¥Ã¨
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    // Recover reachability flags
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    //ªÒµ√¡¨Ω”µƒ±Í÷æ
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    //»Áπ˚≤ªƒ‹ªÒ»°¡¨Ω”±Í÷æ£¨‘Ú≤ªƒ‹¡¨Ω”Õ¯¬Á£¨÷±Ω”∑µªÿ
    if (!didRetrieveFlags)
    {
        return NotReachable;
    }
    //∏˘æ›ªÒµ√µƒ¡¨Ω”±Í÷æΩ¯––≈–∂œ
    bool isReachable = flags & kSCNetworkFlagsReachable;
    bool needsConnection = flags & kSCNetworkFlagsConnectionRequired;
    bool is3G = flags & kSCNetworkReachabilityFlagsIsWWAN;
    return (isReachable && !needsConnection) ? (is3G ? ReachableViaWWAN : ReachableViaWiFi) : NotReachable;
}
void libOS::rmdir(const char* path)
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString* nPath = [NSString stringWithUTF8String:path];
    [fileManager removeItemAtPath:nPath error:nil];
}
std::string libOS::getCurrentCountry()
{
    return "";
}

void libOS::facebookShare(std::string& link,std::string& picture,std::string& name,std::string& caption,std::string& description)
{


}


const std::string& libOS::generateSerial()
{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
	CFStringRef guid = CFUUIDCreateString(NULL, theUUID);
	CFRelease(theUUID);
	NSString *uuidString = [((__bridge NSString *)guid) stringByReplacingOccurrencesOfString:@"-" withString:@""];
	CFRelease(guid);
	static std::string ret;
    ret = [[uuidString lowercaseString] UTF8String];
    return ret;
}
void libOS::showInputbox(bool multiline, int InputMode, const std::string content /*= ""*/, bool chatState /*= false*/)
{
    if(InputMode == 2){//numberic keyboard
        
        setChatState(chatState);
        NSString *str= [NSString stringWithUTF8String:content.c_str()];
        if(m_gameconfig.gameid != "21")
        {
            if (IS_IOS7||IS_IOS8  )
            {
                UIAlertView* dialog = [[UIAlertView alloc] init];
                [dialog setDelegate:s_libOSOjb];
                [dialog setTitle:@""];
                [dialog setMessage:@""];
                [dialog addButtonWithTitle:@"OK"];
                dialog.tag = multiline?1002:1001;
                dialog.alertViewStyle = UIAlertViewStylePlainTextInput;
                [dialog textFieldAtIndex:0].keyboardType = UIKeyboardTypeNumberPad;
                [dialog textFieldAtIndex:0].text = str;
                CGAffineTransform moveUp = CGAffineTransformMakeTranslation(0.0, 0.0);
                [dialog setTransform: moveUp];
                [dialog show];
                [dialog release];
            }
            else
            {
                UIAlertView *prompt = nil;
                if(!s_libOSOjb) s_libOSOjb = [libOSObj new];
                if(multiline)
                {
                    prompt= [WCAlertView showAlertWithTitle:@"" message:@"\n\n\n\n\n\n" content:str delegate:s_libOSOjb customizationBlock:^(WCAlertView *alertView) {
                        alertView.style = WCAlertViewStyleWhiteHatched;
                    } completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
                        if (buttonIndex == 0) {
                            NSLog(@"OK");
                        }
                        else
                        {
                            NSLog(@"CANCEL");
                        }
                    } cancelButtonTitle:@"OK" otherButtonTitles:@"CANCEL", nil];
                    /*prompt = [[UIAlertView alloc] initWithTitle:@""
                     message:@"\n\n\n\n\n\n"
                     delegate:s_libOSOjb
                     cancelButtonTitle:@"OK"
                     otherButtonTitles:nil, nil];*/
                    UITextView *textField = [[UITextView alloc] initWithFrame:CGRectMake(27.0, 27.0, 230.0, 120.0)];
                    [textField setBackgroundColor:[UIColor whiteColor]];
                    [textField setText:str];
                    textField.keyboardType = UIKeyboardTypeNumberPad;
                    [textField setTag:1002];
                    [prompt addSubview:textField];
                    [textField release];
                }
                else
                {
                    prompt = [WCAlertView showAlertWithTitle:@"" message:@"\n\n\n" content:str delegate:s_libOSOjb customizationBlock:^(WCAlertView *alertView) {
                        alertView.style = WCAlertViewStyleWhiteHatched;
                    } completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
                        if (buttonIndex == 0) {
                            NSLog(@"OK");
                        }
                        else
                            
                        {
                            NSLog(@"CANCEL");
                        }
                    } cancelButtonTitle:@"OK" otherButtonTitles:@"CANCEL", nil];
                    /*prompt = [[UIAlertView alloc] initWithTitle:@"\n"
                     message:@""
                     delegate:s_libOSOjb
                     cancelButtonTitle:@"OK"
                     otherButtonTitles:nil, nil];*/
                    
                    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(27.0, 27.0, 230.0, 28.0)];
                    [textField setBackgroundColor:[UIColor whiteColor]];
                    [textField setText:str];
                    textField.keyboardType = UIKeyboardTypeNumberPad;
                    [textField setPlaceholder:@""];
                    [textField setTag:1001];
                    [prompt addSubview:textField];
                    [textField release];
                }
                
                [prompt setTransform:CGAffineTransformMakeTranslation(0.0, -100.0)];  //ø…“‘µ˜’˚µØ≥ˆøÚ‘⁄∆¡ƒª…œµƒŒª÷√
                
                [prompt show];
            }
        }
        else
        {
            if(s_libOSOjb.bHideView)
            {
                s_libOSOjb.bHideView = NO;
                UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
                InputView *inputView = [[InputView alloc]initWithFrame:window.bounds bMultiline:YES];
                inputView.textView.text = str;
                inputView.textView.keyboardType = UIKeyboardTypeNumberPad;
                inputView.delegate = s_libOSOjb;
                [window.rootViewController.view addSubview:inputView];
                [inputView release];
            }
        }
    
    
    }else{//not numberic keyboard
    
        setChatState(chatState);
        NSString *str= [NSString stringWithUTF8String:content.c_str()];
        if(m_gameconfig.gameid != "21")
        {
            if (IS_IOS7||IS_IOS8  )
            {
                UIAlertView* dialog = [[UIAlertView alloc] init];
                [dialog setDelegate:s_libOSOjb];
                [dialog setTitle:@""];
                [dialog setMessage:@""];
                [dialog addButtonWithTitle:@"OK"];
                dialog.tag = multiline?1002:1001;
                dialog.alertViewStyle = UIAlertViewStylePlainTextInput;
                [dialog textFieldAtIndex:0].keyboardType = UIKeyboardTypeDefault;
                [dialog textFieldAtIndex:0].text = str;
                CGAffineTransform moveUp = CGAffineTransformMakeTranslation(0.0, 0.0);
                [dialog setTransform: moveUp];
                [dialog show];
                [dialog release];
            }
            else
            {
                UIAlertView *prompt = nil;
                if(!s_libOSOjb) s_libOSOjb = [libOSObj new];
                if(multiline)
                {
                    prompt= [WCAlertView showAlertWithTitle:@"" message:@"\n\n\n\n\n\n" content:str delegate:s_libOSOjb customizationBlock:^(WCAlertView *alertView) {
                        alertView.style = WCAlertViewStyleWhiteHatched;
                    } completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
                        if (buttonIndex == 0) {
                            NSLog(@"OK");
                        }
                        else
                        {
                            NSLog(@"CANCEL");
                        }
                    } cancelButtonTitle:@"OK" otherButtonTitles:@"CANCEL", nil];
                    /*prompt = [[UIAlertView alloc] initWithTitle:@""
                     message:@"\n\n\n\n\n\n"
                     delegate:s_libOSOjb
                     cancelButtonTitle:@"OK"
                     otherButtonTitles:nil, nil];*/
                    UITextView *textField = [[UITextView alloc] initWithFrame:CGRectMake(27.0, 27.0, 230.0, 120.0)];
                    [textField setBackgroundColor:[UIColor whiteColor]];
                    [textField setText:str];
                    [textField setTag:1002];
                    [prompt addSubview:textField];
                    [textField release];
                }
                else
                {
                    prompt = [WCAlertView showAlertWithTitle:@"" message:@"\n\n\n" content:str delegate:s_libOSOjb customizationBlock:^(WCAlertView *alertView) {
                        alertView.style = WCAlertViewStyleWhiteHatched;
                    } completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
                        if (buttonIndex == 0) {
                            NSLog(@"OK");
                        }
                        else
                            
                        {
                            NSLog(@"CANCEL");
                        }
                    } cancelButtonTitle:@"OK" otherButtonTitles:@"CANCEL", nil];
                    /*prompt = [[UIAlertView alloc] initWithTitle:@"\n"
                     message:@""
                     delegate:s_libOSOjb
                     cancelButtonTitle:@"OK"
                     otherButtonTitles:nil, nil];*/
                    
                    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(27.0, 27.0, 230.0, 28.0)];
                    [textField setBackgroundColor:[UIColor whiteColor]];
                    [textField setText:str];
                    [textField setPlaceholder:@""];
                    [textField setTag:1001];
                    [prompt addSubview:textField];
                    [textField release];
                }
                
                [prompt setTransform:CGAffineTransformMakeTranslation(0.0, -100.0)];  //ø…“‘µ˜’˚µØ≥ˆøÚ‘⁄∆¡ƒª…œµƒŒª÷√
                
                [prompt show];
            }
        }
        else
        {
            if(s_libOSOjb.bHideView)
            {
                s_libOSOjb.bHideView = NO;
                UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
                InputView *inputView = [[InputView alloc]initWithFrame:window.bounds bMultiline:YES];
                inputView.textView.text = str;
                inputView.delegate = s_libOSOjb;
                [window.rootViewController.view addSubview:inputView];
                [inputView release];
            }
        }
        
    }

}
void libOS::showInputbox(bool multiline, const std::string content, bool chatState)
{
    setChatState(chatState);
    NSString *str= [NSString stringWithUTF8String:content.c_str()];
    if(m_gameconfig.gameid != "21")
    {
        if (IS_IOS7||IS_IOS8  )
        {
            UIAlertView* dialog = [[UIAlertView alloc] init];
            [dialog setDelegate:s_libOSOjb];
            [dialog setTitle:@""];
            [dialog setMessage:@""];
            [dialog addButtonWithTitle:@"OK"];
            dialog.tag = multiline?1002:1001;
            dialog.alertViewStyle = UIAlertViewStylePlainTextInput;
            [dialog textFieldAtIndex:0].keyboardType = UIKeyboardTypeDefault;
            [dialog textFieldAtIndex:0].text = str;
            CGAffineTransform moveUp = CGAffineTransformMakeTranslation(0.0, 0.0);
            [dialog setTransform: moveUp];
            [dialog show];
            [dialog release];
        }
        else
        {
            UIAlertView *prompt = nil;
            if(!s_libOSOjb) s_libOSOjb = [libOSObj new];
            if(multiline)
            {
                prompt= [WCAlertView showAlertWithTitle:@"" message:@"\n\n\n\n\n\n" content:str delegate:s_libOSOjb customizationBlock:^(WCAlertView *alertView) {
                    alertView.style = WCAlertViewStyleWhiteHatched;
                } completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
                    if (buttonIndex == 0) {
                        NSLog(@"OK");
                    }
                    else
                    {
                        NSLog(@"CANCEL");
                    }
                } cancelButtonTitle:@"OK" otherButtonTitles:@"CANCEL", nil];
                /*prompt = [[UIAlertView alloc] initWithTitle:@""
                 message:@"\n\n\n\n\n\n"
                 delegate:s_libOSOjb
                 cancelButtonTitle:@"OK"
                 otherButtonTitles:nil, nil];*/
                UITextView *textField = [[UITextView alloc] initWithFrame:CGRectMake(27.0, 27.0, 230.0, 120.0)];
                [textField setBackgroundColor:[UIColor whiteColor]];
                [textField setText:str];
                [textField setTag:1002];
                [prompt addSubview:textField];
                [textField release];
            }
            else
            {
                prompt = [WCAlertView showAlertWithTitle:@"" message:@"\n\n\n" content:str delegate:s_libOSOjb customizationBlock:^(WCAlertView *alertView) {
                    alertView.style = WCAlertViewStyleWhiteHatched;
                } completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
                    if (buttonIndex == 0) {
                        NSLog(@"OK");
                    }
                    else
                        
                    {
                        NSLog(@"CANCEL");
                    }
                } cancelButtonTitle:@"OK" otherButtonTitles:@"CANCEL", nil];
                /*prompt = [[UIAlertView alloc] initWithTitle:@"\n"
                 message:@""
                 delegate:s_libOSOjb
                 cancelButtonTitle:@"OK"
                 otherButtonTitles:nil, nil];*/
                
                UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(27.0, 27.0, 230.0, 28.0)];
                [textField setBackgroundColor:[UIColor whiteColor]];
                [textField setText:str];
                [textField setPlaceholder:@""];
                [textField setTag:1001];
                [prompt addSubview:textField];
                [textField release];
            }
            
            [prompt setTransform:CGAffineTransformMakeTranslation(0.0, -100.0)];  //ø…“‘µ˜’˚µØ≥ˆøÚ‘⁄∆¡ƒª…œµƒŒª÷√
            
            [prompt show];
        }
    }
    else
    {
        if(s_libOSOjb.bHideView)
        {
            s_libOSOjb.bHideView = NO;
            UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
            InputView *inputView = [[InputView alloc]initWithFrame:window.bounds bMultiline:YES];
            inputView.textView.text = str;
            inputView.delegate = s_libOSOjb;
            [window.rootViewController.view addSubview:inputView];
            [inputView release];
        }
    }
}

void libOS::showInputbox(bool multiline, int InputMode,int nMaxLength, std::string content/* = ""*/, bool chatState/* = false*/)
{
    
}
// ios no MessageBox, use CCLog instead
void libOS::showMessagebox(const std::string& _msg, int tag)
{
    if(!s_libOSOjb) s_libOSOjb = [libOSObj new];
    NSString * title =  nil;
    NSString * msg = [NSString stringWithUTF8String : _msg.c_str()];
    UIAlertView * messageBox = [[UIAlertView alloc] initWithTitle: title
                                                          message: msg
                                                         delegate: s_libOSOjb
                                                cancelButtonTitle: @"OK"
                                                otherButtonTitles: nil];
    [messageBox setTag:tag];
    [messageBox show];
    
    
    //boardcastShowMessageBox(_msg,tag);
}


void libOS::openURL(const std::string& url)
{
    NSString * urlstr = [NSString stringWithUTF8String:url.c_str()];
    if (urlstr && ([urlstr hasPrefix:@"http://"] || [urlstr hasPrefix:@"https://"] ))
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlstr]];
    }
    else
    {
        std::string head("http://");
        head.append([urlstr UTF8String]);
        urlstr = [NSString stringWithUTF8String:head.c_str()];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlstr]];
    }
   
}

void libOS::openURLHttps(const std::string& url)
{
    NSString * urlstr = [NSString stringWithUTF8String:url.c_str()];
    NSRange range6 = NSMakeRange(0, 8);
    NSString* str = [[urlstr substringWithRange:range6] lowercaseString];
    if([urlstr length]<7 || ![[[urlstr substringWithRange:range6] lowercaseString]isEqualToString:@"https://"])
    {
        std::string head("https://");
        head.append([urlstr UTF8String]);
        urlstr = [NSString stringWithUTF8String:head.c_str()];
    }
    if(urlstr)
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlstr]];
    
    
}

void libOS::checkIosSDKVersion(const std::string &version, GetStringCallback p_callback)
{
    NSString *webPath=[NSString stringWithUTF8String:version.c_str()];
    webPath = [webPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]; //url不允许为中文等特殊字符，需要进行字符串的转码为URL字符串，例如空格转换后为“%20”；
    
    dispatch_queue_t dispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(dispatchQueue, ^{
        NSURL *url=[NSURL URLWithString:webPath];//1.创建url
        //2.根据ＷＥＢ路径创建一个请求
        NSURLRequest  *request=[NSURLRequest requestWithURL:url];
        NSURLResponse *respone;//获取连接的响应信息，可以为nil
        NSError *error;        //获取连接的错误时的信息，可以为nil
        //3.得到服务器数据
        NSData  *data=[NSURLConnection sendSynchronousRequest:request returningResponse:&respone error:&error];//苹果官方认证
        if(data!=nil && error == nil)
        {
            NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            std::string stddata([string UTF8String]);
            
            if(p_callback != NULL)
            {
                p_callback(stddata);
            }else{
                exit(0);
            }
            return;
        }
    });
}

void libOS::emailTo( const std::string& mailto, const std::string & cc , const std::string& title, const std::string & body )
{
	NSString * n_mailto = [NSString stringWithUTF8String:mailto.c_str()];
	NSString * n_title = [NSString stringWithUTF8String:title.c_str()];
	NSString * n_body = [NSString stringWithUTF8String:body.c_str()];
	NSString * n_cc = [NSString stringWithUTF8String:cc.c_str()];
	
	NSString* str = [NSString stringWithFormat:@"mailto:%@?cc=%@&subject=%@&body=%@",  
                     n_mailto, n_cc, n_title, n_body];  
  
    str = [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];  
     
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];  
}

long libOS::avalibleMemory()
{
    vm_statistics64_data_t vmStats;
    mach_msg_type_number_t infocount = HOST_VM_INFO_COUNT;
    kern_return_t kernRet = host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmStats, &infocount);
    if(kernRet!=KERN_SUCCESS)
    {
        return 0;
    }
    else
    {
        return (unsigned long)vm_page_size*(unsigned long)vmStats.free_count/1024/1024;
    }
    
}

void libOS::setWaiting(bool show)
{
	if(!s_libOSOjb) s_libOSOjb = [libOSObj new];
    if(show)
    {
        [s_libOSOjb showWait];
    }
    else
    {
        [s_libOSOjb hideWait];
    }
}
void libOS::clearNotification()
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}
void libOS::addNotification(const std::string& msg, int secondsdelay, bool daily)
{
    UILocalNotification* notification = [[UILocalNotification alloc]init];
    if(notification!=nil)
    {
        NSDate* nowtime = [NSDate new];
        notification.fireDate = [nowtime dateByAddingTimeInterval:secondsdelay];
        [nowtime release];
        if(daily)
            notification.repeatInterval = kCFCalendarUnitDay;
        else
            notification.repeatInterval = 0;

        notification.timeZone = [NSTimeZone defaultTimeZone];
        //notification.applicationIconBadgeNumber = 1;
        NSString* message = [NSString stringWithUTF8String:msg.c_str()];
        notification.alertBody = message;
        notification.applicationIconBadgeNumber = 1;
        notification.soundName = UILocalNotificationDefaultSoundName;
        //notification.soundName = @"audio/006.mp3";
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];

        //[[UIApplication sharedApplication] scheduledLocalNotifications:notification];
    }
    [notification release];
}

long long libOS::getFreeSpace()
{

//    long long totalSpace = -1;
    long long totalFreeSpace = -1;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];

    if (dictionary) {
//        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
//        totalSpace = [fileSystemSizeInBytes longLongValue];
        totalFreeSpace = [freeFileSystemSizeInBytes longLongValue];
    }

    return totalFreeSpace;
//
//	struct statfs buf;  
//    long long freespace = -1;  
//    if(statfs("/var", &buf) >= 0){  
//        freespace = (long long)(buf.f_bsize * buf.f_bfree);  
//    } 
//	return freespace;
}

const std::string libOS::getDeviceID()
{
    NSString *id = [FCUUID uuidForDevice];
    UIDevice *device = [UIDevice currentDevice];
    if ([[device systemVersion] floatValue] < 6.0) {
        
    }
    else{
        if([[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled]){
            id = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
        }
    }
    NSString* value = [[NSUserDefaults standardUserDefaults] stringForKey:@"CurrentDevicesId"];
    if(value)
    {
        return [value UTF8String];
    }
    return [id UTF8String];
}

//?????
const std::string  getDeviceIDForAppStore()
{
    NSString *nsDeviceId=[[SvUDIDTools getDeviceIdIDFAOrMAC] retain];
    if(nsDeviceId)
    {
        std::string sDeviceID([nsDeviceId UTF8String]);
        return sDeviceID;
    }
        return "";
}

const std::string libOS::getPlatformInfo()
{
    NSString *nsSystemVersion = [NSString stringWithString:[[UIDevice currentDevice] systemVersion]];
    std::string sSystemVersion([nsSystemVersion UTF8String]);
    NSString *nsSystemName = [NSString stringWithString:[[UIDevice currentDevice] systemName]];
    std::string sSystemName([nsSystemName UTF8String]);
    
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = (char*)malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *nsPlatform = [NSString stringWithUTF8String:machine];
    free(machine);
    std::string splatform([nsPlatform UTF8String]);
    std::string connect = getConnector();
    std::string deviceType = getDeviceType();
    return deviceType+connect+sSystemVersion+connect+sSystemName+connect+"IOS";
}

#pragma mark----
#pragma mark-----------------------与win32对应libos 一致修改文件----------------
void libOS::reEnterGameGetServerlistForKakao(){
    
    
}
void libOS::reEnterLoading(){
    

}
void libOS::OnLuaExitGame(){

}
//官方网站  Finished
void libOS::OnEntermateHomepage(){


}
//活动  Finished
void libOS::OnEntermateEvent(){
    
    
}
void libOS::OnUnregister(){

    
}
//发送玩家信息变化 Finished
void libOS::OnUserInfoChange(std::string& playerid,std::string& name,std::string& serverId,std::string& level,std::string& exp,std::string& vip,std::string& gold){
    
}

void libOS::OnEntermateCoupons(std::string& strCoupons){

    
}
std::string libOS::getPathFormBundle(const std::string& fileName)
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithUTF8String:fileName.c_str()] ofType:nil];
    std::string str = [filePath UTF8String];
    return str;
}
std::string libOS::getDeviceInfo()
{
    return "ios_device";
}
//获取包名
std::string libOS::getPackageNameToLua()
{
    NSBundle *bundle = NSBundle.mainBundle;
    NSDictionary *infoDictionary = bundle.infoDictionary;
    NSString *bundeIdentifier = [infoDictionary objectForKey:(NSString *)kCFBundleIdentifierKey];
    std::string packageName = [bundeIdentifier UTF8String];
    return packageName;
}

void libOS::setClipboardText(std::string& text)
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    
    pasteboard.string = [NSString stringWithUTF8String:text.c_str()];
}

std::string libOS::getClipboardText()
{
    return "";
}

void libOS::setEditBoxText(std::string& text)
{
    
}

std::string libOS::getGameVersion()
{
    return "20171114";
}
#pragma mark-----------------------与win32对应libos 一致修改文件----------------
void libOS::initUserID(const std::string userid)
{

}
void libOS::analyticsLogEvent(const std::string& event)
{
	
 
}
void libOS::analyticsLogEvent(const std::string& event, const std::map<std::string, std::string>& dictionary, bool timed)
{
	
}
void libOS::analyticsLogEndTimeEvent(const std::string& event)
{

}
void libOS::platformSharePerson(const std::string& shareContent, const std::string& shareImgPath, int platFormCfg)
{
    NSString *imagePath = @"";
    NSString *nsShareContent = [NSString stringWithUTF8String:(const char *) shareContent.c_str()];
    if (!shareImgPath.empty())
    {
        NSString *nsshareImgPath = [NSString stringWithUTF8String:(const char *) shareImgPath.c_str()];
        imagePath = [[NSBundle mainBundle] pathForResource:nsshareImgPath ofType:@"png"];
    }
    
    [s_libOSOjb onPresent:nsShareContent shareImgPath:imagePath platFormCfg:platFormCfg];
}
void libOS::playMovie(const char * fileName, int loop)
{
    //setShareWCCallBackEnabled();
    //MovieMgr::instance()->playMovie(fileName,need_skip);
    AppController* app = [(AppController*)[UIApplication sharedApplication] delegate];
    NSString *name = [NSString stringWithUTF8String:fileName];
    [app playVideo:loop fullScreen:0 file:name fileExtension:@"mp4"];
}

void libOS::playMovie(const char * fileName, bool loop)
{
    AppController* app = [(AppController*)[UIApplication sharedApplication] delegate];
    NSString *name = [NSString stringWithUTF8String:fileName];
    [app playVideo:loop fullScreen:0 file:name fileExtension:@"mp4"];
}

void libOS::stopMovie()
{
    AppController* app = [(AppController*)[UIApplication sharedApplication] delegate];
    [app stopVideo];
}

void libOS::pauseMovie()
{
    AppController* app = [(AppController*)[UIApplication sharedApplication] delegate];
    [app pauseVideo];
}

void libOS::resumeMovie()
{
    AppController* app = [(AppController*)[UIApplication sharedApplication] delegate];
    [app resumeVideo];
}

void libOS::setKeyChainUDIDGroup(const std::string& keyChainUDIDAccessGroup)
{
    [SvUDIDTools setKeyChainUDIDGroup:[NSString stringWithUTF8String:keyChainUDIDAccessGroup.c_str()]];
}

//////////////////////////////zhanche//////////////////////////////
long libOS::totalMemory()
{
    size_t size = sizeof(long);
    long results;
    int mib[2] = {CTL_HW,HW_USERMEM};
    sysctl(mib,2,&results,&size,NULL,0);
    return results/1048576;
}

void libOS::setCanPressBack(bool enable)
{
    
}

bool libOS::getIsDebug()
{
    return false;
}

const std::string libOS::getDeviceType()
{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    static std::string str = [deviceString UTF8String];
    if ([deviceString isEqualToString:@"iPhone1,1"])
         str = "iPhone 1G";
    if ([deviceString isEqualToString:@"iPhone1,2"])
         str = "iPhone 3G";
    if ([deviceString isEqualToString:@"iPhone2,1"])
        str = "iPhone 3GS";
    if ([deviceString isEqualToString:@"iPhone3,1"])
        str = "iPhone 4";
    if ([deviceString isEqualToString:@"iPhone3,3"])
        str = "Verizon iPhone 4";
    
    if ([deviceString isEqualToString:@"iPhone4,1"])
        str = "iPhone 4S";
    if ([deviceString isEqualToString:@"iPhone5,1"])
        str = "iPhone 5 (A1428)";
    if ([deviceString isEqualToString:@"iPhone5,2"])
        str = "iPhone 5 (A1429)";
    if ([deviceString isEqualToString:@"iPhone5,3"])
        str = "iPhone 5c (A1456/A1532)";
    if ([deviceString isEqualToString:@"iPhone5,4"])
        str = "iPhone 5c (A1507/A1516/A1529)";
    if ([deviceString isEqualToString:@"iPhone6,1"])
        str = "iPhone 5s (A1433/A1453)";
    if ([deviceString isEqualToString:@"iPhone6,2"])
        str = "iPhone 5s (A1457/A1518/A1530)";
    if ([deviceString isEqualToString:@"iPhone7,1"])
        str = "iPhone 6 Plus";
    if ([deviceString isEqualToString:@"iPhone7,2"])
        str = "iPhone 6";
    if ([deviceString isEqualToString:@"iPhone8,1"])
        str = "iPhone 6s";
    if ([deviceString isEqualToString:@"iPhone8,2"])
        str = "iPhone 6s Plus";
    if ([deviceString isEqualToString:@"iPhone8,4"])
        str = "iPhone SE";
  
    
    if ([deviceString isEqualToString:@"iPod1,1"])
        str = "iPod Touch 1G";
    if ([deviceString isEqualToString:@"iPod2,1"])
        str = "iPod Touch 2G";
    if ([deviceString isEqualToString:@"iPod3,1"])
        str = "iPod Touch 3G";
    if ([deviceString isEqualToString:@"iPod4,1"])
        str = "iPod Touch 4G";
    if ([deviceString isEqualToString:@"iPod6,1"])
        str = "iPod Touch 5G";
    if ([deviceString isEqualToString:@"iPod7,1"])
        str = "iPod Touch 6G";
    
    if ([deviceString isEqualToString:@"iPad1,1"])
        str = "iPad";
    if ([deviceString isEqualToString:@"iPad2,1"])
        str = "iPad 2 (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,2"])
        str = "iPad 2 (GSM)";
    if ([deviceString isEqualToString:@"iPad2,3"])
        str = "iPad 2 (CDMA)";
    if ([deviceString isEqualToString:@"iPad2,4"])
        str = "iPad 2(WiFi + New Chip)";
    if ([deviceString isEqualToString:@"iPad2,5"])
        str = "iPad mini (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,6"])
        str = "iPad mini (GSM)";
    if ([deviceString isEqualToString:@"iPad2,7"])
        str = "ipad mini (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPad3,1"])
        str = "iPad 3(WiFi)";
    if ([deviceString isEqualToString:@"iPad3,2"])
        str = "iPad 3(GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPad3,3"])
        str = "iPad 3(GSM)";
    if ([deviceString isEqualToString:@"iPad3,4"])
        str = "iPad 4(WiFi)";
    if ([deviceString isEqualToString:@"iPad3,5"])
        str = "iPad 4(GSM)";
    if ([deviceString isEqualToString:@"iPad3,6"])
        str = "iPad 4(GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPad4,1"])
        str = "iPad Air (Wi-Fi)";
    
    if ([deviceString isEqualToString:@"iPad4,2"])
        str = "iPad Air (Wi-Fi+LTE)";
    if ([deviceString isEqualToString:@"iPad4,3"])
        str = "iPad Air (Rev)";
    if ([deviceString isEqualToString:@"iPad4,4"])
        str = "iPad mini 2 (Wi-Fi)";
    if ([deviceString isEqualToString:@"iPad4,5"])
        str = "iPad mini 2 (Wi-Fi+LTE)";
    if ([deviceString isEqualToString:@"iPad4,6"])
        str = "iPad mini 2 (Rev)";
    if ([deviceString isEqualToString:@"iPad4,7"])
        str = "iPad mini 3 (Wi-Fi)";
    if ([deviceString isEqualToString:@"iPad4,8"])
        str = "iPad mini 3 (A1600)";
    if ([deviceString isEqualToString:@"iPad4,9"])
        str = "iPad mini 3 (A1601)";
    if ([deviceString isEqualToString:@"iPad5,1"])
        str = "iPad mini 4 (Wi-Fi)";
    if ([deviceString isEqualToString:@"iPad5,2"])
        str = "iPad Air (Wi-Fi)";
    if ([deviceString isEqualToString:@"iPad4,1"])
        str = "iPad mini 4 (Wi-Fi+LTE)";
    if ([deviceString isEqualToString:@"iPad5,3"])
        str = "iPad Air 2 (Wi-Fi)";
    if ([deviceString isEqualToString:@"iPad5,4"])
        str = "iPad Air 2 (Wi-Fi+LTE)";
    if ([deviceString isEqualToString:@"iPad6,7"])
        str = "iPad Pro (Wi-Fi)";
    if ([deviceString isEqualToString:@"iPad6,8"])
        str = "iPad Pro (Wi-Fi+LTE)";
    
    if ([deviceString isEqualToString:@"i386"])
        str = "Simulator";
    if ([deviceString isEqualToString:@"x86_64"])
        str = "Simulator";
    
    return str;
}
/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////

#ifdef RECODER
bool libOS::openRecorder(std::string&fileName, unsigned int rType, unsigned int rTag)
{
    
    NSString* name = [NSString stringWithUTF8String:fileName.c_str()];
    
    ZZRecorder* recorder = [[ZZRecorderManager sharedRecorderManager] createRecorderWithType:rType andTag:rTag andFileName:name];
    [recorder beginRecorder];
    
    
    if (recorder != nil) {
        return YES;
    }
    return NO;
}

bool libOS::closeRecorder(unsigned int rTag)
{
    ZZRecorder* recorder = [[ZZRecorderManager sharedRecorderManager] getRecorderByTag:rTag];
    
    if (recorder != nil) {
        [recorder finishRecorder];
        
        return YES;
    }
    
    return NO;
}

bool libOS::destoryRecorder(unsigned int rTag)
{
    [[ZZRecorderManager sharedRecorderManager] destoryRecorderByTag:rTag];
    
    return YES;
}

void libOS::playRecordFile(std::string &fileName, unsigned int rTag)
{
    ZZPlayer* player = [[ZZPlayerManager sharedPlayerManager] createPlayerWithType:0 andTag:rTag];
    
    const char* cStr = fileName.c_str();
    
    NSString* str = [NSString stringWithUTF8String:cStr];
    
    [player playSoundWithName:str];
    
}

void libOS::stopPlayRecordeFile(std::string &fileName, unsigned int rTag)
{
    ZZPlayer* player = [[ZZPlayerManager sharedPlayerManager] getPlayerByTag:rTag];
    
    if (player != nil) {
        [player stopPlaying];
    }
}

void libOS::encodeRecordFile(std::string &inFileName, std::string &outFileName, unsigned int rTag)
{
    ZZEncoder* encoder = [[ZZEncoderManager sharedEncoderManager] createEncoderWithTag:rTag];
    
    NSString* inStr = [NSString stringWithUTF8String:inFileName.c_str()];
    NSString* outStr = [NSString stringWithUTF8String:outFileName.c_str()];
    
    [encoder encodeFileWithInputName:inStr andOutputName:outStr];
}

void libOS::decodeRecordFile(std::string &inFileName, std::string &outFileName, unsigned int rTag)
{
    ZZDecoder* decoder = [[ZZDecoderManager sharedDecoderManager] createDecoderWithTag:rTag];
    
    NSString* inStr = [NSString stringWithUTF8String:inFileName.c_str()];
    NSString* outStr = [NSString stringWithUTF8String:outFileName.c_str()];
    
    [decoder decodeFileWithInputName:inStr andOutputName:outStr];
    
}
#endif
