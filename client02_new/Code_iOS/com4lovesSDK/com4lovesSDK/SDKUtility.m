//
//  SDKUtility.m
//  com4lovesSDK
//
//  Created by fish on 13-8-26.
//  Copyright (c) 2013年 com4loves. All rights reserved.
//

#import "SDKUtility.h"
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

#import <CommonCrypto/CommonDigest.h>
#import <UIKit/UIKit.h>
#import "comHuTuoSDK.h"
#include "SvUDIDTools.h"
#define RequestTimeOut 6

@interface SDKUtility()
{

    SEL asynHttpSel;
    id asynHttpObj;
    
}
@property (nonatomic, retain) NSMutableData* mData;
@property (nonatomic, retain) UIActivityIndicatorView *waitView;
@end

@implementation SDKUtility
@synthesize waitView = _waitView;
@synthesize mData;

+ (SDKUtility *)sharedInstance
{
    static SDKUtility *_instance = nil;
    if (_instance == nil) {
        _instance = [[SDKUtility alloc] init];
    }
    return _instance;
}
- (id)init
{
    self = [super init];
    if(!self)
    {
        return nil;
    }
       CGRect rect = [UIScreen mainScreen].applicationFrame; //获取屏幕大小
        _waitView = [[UIActivityIndicatorView alloc] initWithFrame:rect];//定义图标大小，此处为32x32
        [self.waitView setCenter:CGPointMake(rect.size.width/2,rect.size.height/2)];//根据屏幕大小获取中心点
        [self.waitView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];//设置图标风格，采用灰色的，其他还有白色设置
        [self.waitView setBackgroundColor:[ UIColor colorWithWhite: 0.0 alpha: 0.5 ]];
        if ([[UIDevice currentDevice] systemVersion].floatValue<=4.4) {
            [self.waitView setBounds:CGRectMake(0, 0, 50, 50)];
        }
        //[self.view addSubview:waitView];//添加该waitView
    return self;
}

- (NSString*)encodeURL:(NSString *)urlString
{
    //把NSString 转 CFStringRef
    CFStringRef originalURLString = (__bridge CFStringRef)urlString;
    CFStringRef preprocessedString =
    CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault, originalURLString, CFSTR(""), kCFStringEncodingUTF8);
    CFStringRef urlString1 =
    CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, preprocessedString, NULL, NULL, kCFStringEncodingUTF8);
    CFURLRef url = CFURLCreateWithString(kCFAllocatorDefault, urlString1, NULL);
    //CFStringRef 转 NSString
    NSString* urlStringret = (__bridge NSString*) url;
    
    //转换后，发现并非NSString 而是NSURL 这很奇怪 所以再转一次
    if ([urlStringret isKindOfClass:[NSURL class]]) {
        NSURL *url2 = (__bridge NSURL*) url;;
        urlStringret = [url2 absoluteString];
    }
    YALog(@"nsstring:%@",urlStringret);
    return urlStringret;
}
-(void) setWaiting:(BOOL) isWait
{
    if(self.waitView)
    {
        if(isWait == YES)
        {
            [[[UIApplication sharedApplication] keyWindow] addSubview:self.waitView];
            [self.waitView startAnimating];
        }
        else
        {
            [self.waitView stopAnimating];
            [self.waitView removeFromSuperview];
        }
    }
    
}

- (NSString*)base64forData:(NSData*)theData {
    const uint8_t* input = (const uint8_t*)[theData bytes];
    NSInteger length = [theData length];
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;
    NSInteger i;
    for (i=0; i < length; i += 3) {
        NSInteger value = 0;
        NSInteger j;
        for (j = i; j < (i + 3); j++) {
            value <<= 8;
            
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        NSInteger theIndex = (i / 3) * 4;
        output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
        output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}

-(NSString*) httpRequest: (NSString*) actionUrl postData:(NSData *)postStr
{
    NSURL *url=[NSURL URLWithString:actionUrl];//把相关的网络请求的接口存放到url里
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc]initWithURL:url];//创建一个可变请求，并且请求的接口为url
    [request setHTTPMethod:@"POST"];//请求方式设置为POST
    [request setTimeoutInterval:RequestTimeOut];//设置4秒超时
    
    [request setHTTPBody:postStr];
    //[request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    NSMutableData *mutabledata = [[NSMutableData alloc] init];
    NSURLResponse *response;
    NSError *err;
    [mutabledata appendData:[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err]];//同步请求连接服务器，并且告诉服务器，请求的内容是什么，把同步方法返回的NSData加到刚刚创建的可变数组mutabledata中
    NSString *datastr=[[[NSString alloc]initWithData:mutabledata encoding:NSUTF8StringEncoding] autorelease];//data数据转换成string类型
    [request release];
    [mutabledata release];
    return datastr;
}

-(NSString*) httpRequest: (NSString*) actionUrl postData:(NSData *)postStr md5check:(NSString*) check method:(NSString*) method
{
    NSURL *url=[NSURL URLWithString:actionUrl];//把相关的网络请求的接口存放到url里
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc]initWithURL:url];//创建一个可变请求，并且请求的接口为url
    [request setHTTPMethod:method];//请求方式设置为POST
    [request setTimeoutInterval:RequestTimeOut];//设置4秒超时

    if(check)
    {
        [request setValue:check forHTTPHeaderField:@"Game-Checksum"];
    }
    [request setValue:@"" forHTTPHeaderField:@"Expect"];
    [request setHTTPBody:postStr];
    //[request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
      NSMutableData *mutabledata = [[NSMutableData alloc] init];
    NSURLResponse *response;
    NSError *err;
    [mutabledata appendData:[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err]];//同步请求连接服务器，并且告诉服务器，请求的内容是什么，把同步方法返回的NSData加到刚刚创建的可变数组mutabledata中
    NSString *datastr=[[[NSString alloc]initWithData:mutabledata encoding:NSUTF8StringEncoding] autorelease];//data数据转换成string类型
    [request release];
    [mutabledata release];
    return datastr;
}

-(int) httpForStatus: (NSString*) actionUrl postData:(NSData *)postStr md5check:(NSString*) check method:(NSString *)method
{
    //actionUrl = @"https://192.168.50.150:9999/apple/huTuoPayNotice";
    NSURL *url=[NSURL URLWithString:actionUrl];//把相关的网络请求的接口存放到url里
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc]initWithURL:url];//创建一个可变请求，并且请求的接口为url
    [request setHTTPMethod:method];//请求方式设置为POST
    [request setTimeoutInterval:RequestTimeOut];//设置4秒超时
    if(check)
    {
        [request setValue:check forHTTPHeaderField:@"Game-Checksum"];
    }
    //[request setValue:@"" forHTTPHeaderField:@"Expect"];
     [request setHTTPBody:postStr];
    
    
    //NSString *postStr1 = @"price=10";
    //NSData *postdata1=[postStr1 dataUsingEncoding:NSUTF8StringEncoding];
   
    /* nsurl request请求方式 不能设置可变参数 不能设置header 不能设置post get 默认是get
    //NSString  * urlNew=  @"http://192.168.50.44:9999/apple/huTuoPayNotice?uid=sg_FF34F3363981&serverId=1&productid=jp.co.school.battle.60&price=10&currencyCode=JPY&amount=1&ext=1&receipt=11";
    //NSString * encodingStr = @"";
    //NSString  * urlNew=  [[NSString alloc] initWithFormat:@"http://192.168.50.44:9999/apple/huTuoPayNotice?receipt=%@",encodingStr];
    //NSString  * urlNew=  @"http://192.168.50.44:9999/apple/huTuoPayNotice?receipt=1";
    //NSURL *urlNew1=[NSURL URLWithString:urlNew];//把相关的网络请求的接口存放到url里
     //创建请求对象
    //NSURLRequest *request1=[NSURLRequest requestWithURL:urlNew1];
    */
    
    //ios新的请求网络的方式
    //创建信号量 实现同步请求
//    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
//    static  int statusCode = 0;
//    NSURLSession *session = [NSURLSession sharedSession];
//
//    NSURLSessionDataTask * dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        if(data && (error == nil)){
//
//            NSLog(@"data=%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
//            NSHTTPURLResponse *httpReponse = (NSHTTPURLResponse * )response;
//            statusCode = [httpReponse statusCode];
//            //statusCode = 200;
//           //return statusCode;
//        }else
//        {
//            NSLog(@"error=%@",error);
//
//        }
//        //发送
//        dispatch_semaphore_signal(semaphore);
//    }];
//
//    [dataTask resume];
//    //等待阻塞线程
//    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
//
//    [request release];
//    return statusCode;
    
    
    
    NSURLResponse *response;
    NSError *err = nil;

   NSData *data= [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];//同步请求连接服务器，并且告诉服务器，请求的内容是什么，把同步方法返回的NSData加到刚刚创建的可变数组mutabledata中
    if(!err)
    {
        NSLog(@"%@",[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]);
        //NSLog(@"%@",err);
    }else
    {
        NSLog(@"error=%@",err);
    }
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    int statusCode = [httpResponse statusCode];
    YALog(@"status %d",statusCode);
    [request release];
    return  statusCode;
    
}

-(NSString*) httpPost: (NSString*) actionUrl postData:(NSData *)postStr md5check:(NSString*) check
{
    return [self httpRequest:actionUrl postData:postStr md5check:check method:@"POST"];
}
-(NSString*) httpPost: (NSString*) actionUrl postData:(NSData *)postStr
{
    return [self httpPost:actionUrl postData:postStr md5check:nil];
}

-(NSString*) httpPut: (NSString*) actionUrl postData:(NSData *)postStr md5check:(NSString*) check
{
    return [self httpRequest:actionUrl postData:postStr md5check:check method:@"PUT"];
}
-(NSString*) httpPut: (NSString*) actionUrl postData:(NSData *)postStr
{
    return [self httpPut:actionUrl postData:postStr md5check:nil];
}
-(int) httpPostForStatus: (NSString*) actionUrl postData:(NSData *)postStr md5check:(NSString*) check
{
    return [self httpForStatus:actionUrl postData:postStr md5check:check method:@"POST"];
}

-(int) httpPutForStatus: (NSString*) actionUrl postData:(NSData *)postStr md5check:(NSString*) check
{
    return [self httpForStatus:actionUrl postData:postStr md5check:check method:@"PUT"];
}

-(NSString*) getMacAddress
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0 )
    {
        return [SvUDIDTools UDID] ;
    }
    
    return [self getMacAddressOnly];
}
-(NSString*) getMacAddressOnly
{
    int                 mib[6];
    size_t              len;
    char                *buf;
    unsigned char       *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl  *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex errorn");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1n");
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        printf("Could not allocate memory. error!n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2");
        free(buf);
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *outstring = [NSString stringWithFormat:@"%X:%X:%X:%X:%X:%X",
                           *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    free(buf);
    
    return outstring;
}
-(NSString *) md5HexDigest :(NSString*) str
{
    const char *original_str = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(original_str, strlen(original_str), result);
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < 16; i++)
        [hash appendFormat:@"%02X", result[i]];
    return [hash lowercaseString];
}

-(void) showAlertMessage: (NSString*)message
{
    UIAlertView*alert = [[UIAlertView alloc]initWithTitle:[comHuTuoSDK getLang:@"notice"]
                                                  message:message
                                                 delegate:nil
                                        cancelButtonTitle:[comHuTuoSDK getLang:@"ok"]
                                        otherButtonTitles:nil];
    [alert show];
    [alert release];
}

-(BOOL)checkInput:(NSString*) userName password:(NSString*)password email:(NSString*)email
{
    if([userName length]>12)
    {
        [[SDKUtility sharedInstance] showAlertMessage:[comHuTuoSDK getLang:@"notice_username_toolong"]];
        return NO;
    }
    if([userName length]<6)
    {
        [[SDKUtility sharedInstance] showAlertMessage:[comHuTuoSDK getLang:@"notice_username_tooshoot"]];
        return NO;
    }
    if([password length]<6 || [password length]>12)
    {
        [[SDKUtility sharedInstance] showAlertMessage:[comHuTuoSDK getLang:@"notice_password_length"]];
        return NO;
    }
    if(email && [email length]>64)
    {
        [[SDKUtility sharedInstance] showAlertMessage:[comHuTuoSDK getLang:@"notice_email_toolong"]];
        return NO;
    }
    
    NSRegularExpression *regex2 = [NSRegularExpression regularExpressionWithPattern:@"[^A-Za-z0-9]" options:0 error:nil];
    if (regex2) {
        NSTextCheckingResult *result2 = [regex2 firstMatchInString:userName options:0 range:NSMakeRange(0, [userName length])];
        if (result2) {
            [[SDKUtility sharedInstance] showAlertMessage:[comHuTuoSDK getLang:@"notice_username_ilegl"]];
            return NO;
        }
        NSTextCheckingResult *result3 = [regex2 firstMatchInString:password options:0 range:NSMakeRange(0, [password length])];
        if (result3) {
            [[SDKUtility sharedInstance] showAlertMessage:[comHuTuoSDK getLang:@"notice_password_ilegl"]];
            return NO;
        }
    }
    
    if(email)
    {
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\b([a-zA-Z0-9%_.+\\-]+)@([a-zA-Z0-9.\\-]+?\\.[a-zA-Z]{2,6})\\b" options:0 error:nil];
        NSInteger count = [regex numberOfMatchesInString:email options:0 range:NSMakeRange(0, [email length])];
        if(count==0 && [email length]>0 && ![email isEqualToString:[comHuTuoSDK getLang:@"email_optional"]])
        {
            [[SDKUtility sharedInstance] showAlertMessage:[comHuTuoSDK getLang:@"notice_email_ilegl"]];
            return NO;
        }
    }
    
    return YES;
}

////////////// asynic http request //////////////
-(void) httpAsynPut: (NSString*) actionUrl postData:(NSData *)postStr md5check:(NSString*) check selector:(SEL)selector object:(id)object
{
    asynHttpSel = selector;
    asynHttpObj = object;
    
    NSURL *url=[NSURL URLWithString:actionUrl];//把相关的网络请求的接口存放到url里
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc]initWithURL:url];//创建一个可变请求，并且请求的接口为url
    [request setHTTPMethod:@"PUT"];//请求方式设置为POST
    [request setTimeoutInterval:RequestTimeOut];//设置4秒超时

    if(check)
    {
        [request setValue:check forHTTPHeaderField:@"Game-Checksum"];
    }
    [request setHTTPBody:postStr];
    //[request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    mData = nil;
    [NSURLConnection connectionWithRequest:request delegate:self];
    [request release];
}
- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response
{
    
//    NSInteger responseCode = [(NSHTTPURLResponse *)response statusCode];
    //YALog(@"response length=%lld  statecode%d", [response expectedContentLength],responseCode);
}


// A delegate method called by the NSURLConnection as data arrives.  The
// response data for a POST is only for useful for debugging purposes,
// so we just drop it on the floor.
- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)data
{
    if (self.mData == nil) {
        mData = [[[NSMutableData alloc] initWithData:data] autorelease];
    } else {
        [self.mData appendData:data];
    }
    //YALog(@"response connection");
}

// A delegate method called by the NSURLConnection if the connection fails.
// We shut down the connection and display the failure.  Production quality code
// would either display or log the actual error.
- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error
{
    [self showAlertMessage:[error localizedFailureReason]];
    //YALog(@"response error%@", [error localizedFailureReason]);
}

// A delegate method called by the NSURLConnection when the connection has been
// done successfully.  We shut down the connection with a nil status, which
// causes the image to be displayed.
- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection
{
    NSString *responseString = [[NSString alloc] initWithData:mData encoding:NSUTF8StringEncoding];
    //YALog(@"response body%@", responseString);
    [asynHttpObj performSelector:asynHttpSel withObject:responseString];
}

- (void)dealloc{
    [_waitView release];
    
    [super dealloc];
}
@end
