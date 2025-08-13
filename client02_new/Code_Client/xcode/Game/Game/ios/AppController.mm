#import <UIKit/UIKit.h>
#import "AppController.h"
#import "cocos2d.h"
#import "EAGLView.h"
#import "AppDelegate.h"
#import "libOS.h"
#import "libPlatform.h"
#import "RootViewController.h"

// Suppress the gl warning
#define GLES_SILENCE_DEPRECATION

#ifdef PROJECT_GUAJI_LONGXIAO
#import <UnKnownGame/UnKnownGame.h>
#endif

#pragma mark--------------------------Ryuk import ---------------------
#pragma mark -
#ifdef PROJECT_RYUK_NEW_JP
#import "GameCenterSDK.h"
#import "ShareSDKToDifPlatform.h"

//#import <Google/Analytics.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#endif


#ifdef PROJECT_GUAJI_YOUGU
#import "SCore/SCore.h"
#endif

#ifdef PROJECT_GUAJI_YOUGU_YIJIE
#import <OnlineAHelper/YiJieOnlineHelper.h>
#endif

//#import <MediaPlayer/MPMoviePlayerViewController.h>
//#import <MediaPlayer/MPMoviePlayerController.h>

#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>


AVPlayer *player = NULL;
AVPlayerViewController *playerViewController = NULL;

//MPMoviePlayerViewController *playerViewController = NULL;
//MPMoviePlayerController *player = NULL;
int g_iPlayVideoState = 0;

@implementation AppController

@synthesize window;
@synthesize viewController;

//-being for GexinSdk
@synthesize appssfsKey = _appssfsKey;
@synthesize appSt3s2ecret = _appSt3s2ecret;
@synthesize ao9id = _ao9id;
@synthesize nsfsfstId = _nsfsfstId;
@synthesize lastinx20 = _lastPaylodIndex;
@synthesize idkd8853 = _idkd8853;
//-end
@synthesize navigationController = _navigationController;
#pragma mark -
#pragma mark Application lifecycle


- (BOOL)adddkd002mAtURL:(NSURL *)URL {
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}

// cocos2d application instance
static AppDelegate s_sharedApplication;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    application.applicationSupportsShakeToEdit= YES; //在ios6.0后，这里其实都可以不写了
    // Override point for customization after application launch.
    
    [UIApplication sharedApplication].applicationIconBadgeNumber =0;
    
#ifdef PROJECT_GUAJI_YOUGU  // 必须在初始化 window 之前调用
    [SPluginWrapper application:application didFinishLaunchingWithOptions:launchOptions];
#endif

    // Add the view controller's view to the window and display.
    window = [[UIWindow alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
    EAGLView *__glView = [EAGLView viewWithFrame: [window bounds]
                                     pixelFormat: kEAGLColorFormatRGBA8
                                     depthFormat: GL_DEPTH24_STENCIL8_OES
                              preserveBackbuffer: NO
                                      sharegroup: nil
                                   multiSampling: NO
                                 numberOfSamples:0 ];
    
    // Set main game view to have transparent background
    // so we can play movie behind
    __glView.backgroundColor = [UIColor clearColor];
    // Use RootViewController manage EAGLView
    viewController = [[RootViewController alloc] init];
    viewController.edgesForExtendedLayout = UIRectEdgeNone; // Prevents extending under the navigation bar
    viewController.extendedLayoutIncludesOpaqueBars = NO;
    __glView.userInteractionEnabled = false;
    viewController.view = __glView;
    
    [window setRootViewController:viewController];
    
#ifdef PROJECT_GUAJI_YOUGU  // 初始化 window 后初始化 SDK
    [[SYSDK getInstance] setDebug:NO];
    NSDictionary *params = @{
                             @"name" : @"美人劫",
                             @"shortName" : @"mrj",
                             @"direction" : @"1",
                             };
    [[SYSDK getInstance] initWithParams:params];
#endif
    
#ifdef PROJECT_GUAJI_LONGXIAO
    [[UnKnownGame sharedPlatform] initWithGameID:@"1120" gameKey:@"MGX7A2rJhOkwuj" channelID:@"100161000"];
#endif
    
    //设置documents 不备份
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    NSLog(@"doc_dir:%@",docDir);
    NSURL* url = [NSURL fileURLWithPath:docDir];
    [self adddkd002mAtURL:url];
    
    
#ifdef PROJECT_RYUK_NEW_JP
#pragma mark - PROJECT_RYUK_NEW_JP
#pragma mark-----------------------------FaceBook-------------------------------
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    [FBSDKLoginButton class];
    
#pragma mark-----------------------------Adjust-------------------------------
    //（notice：sandbox setMode  YES, onAppstore setMode NO）

    [[ShareSDKToDifPlatform shareSDKPlatform] setAdjustEnvironmentWithState:NO isOpenAjustTracking:YES differentToken:@"qeri2zxcuxog"];
    
#pragma mark-----------------------------GoogleAnalytcs-------------------------------
    // Configure tracker from GoogleService-Info.plist.
    /* NSError *configureError;
    [[GGLContext sharedInstance] configureWithError:&configureError];
    //NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
    
    // Optional: configure GAI options.
    GAI *gai = [GAI sharedInstance];
    gai.trackUncaughtExceptions = YES;  // report uncaught exceptions
    gai.logger.logLevel = kGAILogLevelVerbose;  // remove before app release
    gai.dispatchInterval = 120;
    //------------------------------------------------------------
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    // This screen name value will remain set on the tracker and sent with
    // hits until it is set to a new value or to nil.

    [tracker set:kGAIScreenName
           value:@"Production"];//HomeScreenView Production -- Development

    // New SDK versions
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Event"     // Event category (required)
                                                          action:@"Action"  // Event action (required)
                                                           label:@"start_app"         // Event label
                                                           value:nil] build]];    // Event value
    
    */
    //        每次启动游戏时调用登录游戏接口
    [[GameCenterSDK GameCenterSharedSDK] loginGameByGameCenter];
    [window setRootViewController:viewController];
    
    
    if (@available(iOS 11.0, *))
    {
        CGRect rect = [[UIScreen mainScreen]bounds];
        
        CGSize size = rect.size;
        
        CGFloat width = size.width;
        
        CGFloat height = size.height;
        
        CGFloat scale_screen = [UIScreen mainScreen].scale;
        
        //通过分辨率判断是否是iPhoneX手机
        
        if ((width*scale_screen ==1125 and height*scale_screen ==2436)||
            (width*scale_screen ==1242 and height*scale_screen ==2688)||
            (width*scale_screen ==828 and height*scale_screen ==1792))
            
        {
//            CGRect s = CGRectMake(0,0,viewController.view.frame.size.width + viewController.view.safeAreaInsets.left + viewController.view.safeAreaInsets.right,viewController.view.frame.size.height + viewController.view.safeAreaInsets.bottom);
//            UIView *Ucolor = [[UIView alloc]initWithFrame:s];
//            Ucolor.backgroundColor = [UIColor darkGrayColor]; // 设置全局默认背景色 darkGrayColor whiteColor
//
//
//            UIView *viewLeft = [[UIView alloc]initWithFrame:CGRectMake(0,0,500,200)];
//            UIImageView* imageViewL = [[UIImageView alloc]initWithFrame:viewLeft.bounds];
//            //UIImage *image = [UIImage imageNamed:@"loadingScene/u_announcement.png"];
//            //UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
//            imageViewL.image = [UIImage imageNamed:@"LoadingUI_JP/loadingUI_AdaptiveUp.jpg"];
//
//            [viewLeft addSubview:imageViewL];
//
//            [window addSubview:viewLeft];
//
//            [window sendSubviewToBack:viewLeft];
//
//
//
//            UIView *viewRight = [[UIView alloc]initWithFrame:CGRectMake(0,732,500,200)];
//
//            UIImageView* imageView = [[UIImageView alloc]initWithFrame:viewRight.bounds];
//
//            imageView.image = [UIImage imageNamed:@"LoadingUI_JP/loadingUI_AdaptiveUp.jpg"];
//
//            [viewRight addSubview:imageView];
//            [window addSubview:viewRight];
//            [window sendSubviewToBack:viewRight];
            
            
            CGFloat leftX = 0;
            CGFloat leftY = 0;
            CGFloat leftW = 500;
            CGFloat leftH = 200;
            
            
            CGFloat rightX = 0;
            CGFloat rightY = 800;
            CGFloat rightW = 500;
            CGFloat rightH = 200;
            
            
            if (width*scale_screen ==1125 and height*scale_screen ==2436) {
                 leftX = 0;
                 leftY = 0;
                 leftW = 500;
                 leftH = 200;
                
                rightX = 0;
                rightY = 760;
                rightW = 500;
                rightH = 200;
                
            }else if (width*scale_screen ==1242 and height*scale_screen ==2688)
            {
                 leftX = 0;
                 leftY = 0;
                 leftW = 500;
                 leftH = 200;
                
                rightX = 0;
                rightY = 800;
                rightW = 500;
                rightH = 200;
            }else if (width*scale_screen ==828 and height*scale_screen ==1792)
            {
                leftX = 0;
                leftY = 0;
                leftW = 500;
                leftH = 200;
                
                rightX = 0;
                rightY = 800;
                rightW = 500;
                rightH = 200;
            }
           
            
           // 12345qweASD
            
            CGRect s = CGRectMake(0,0,viewController.view.frame.size.width + viewController.view.safeAreaInsets.left + viewController.view.safeAreaInsets.right,viewController.view.frame.size.height + viewController.view.safeAreaInsets.bottom);
            UIView *Ucolor = [[UIView alloc]initWithFrame:s];
            Ucolor.backgroundColor = [UIColor darkGrayColor]; // 设置全局默认背景色 darkGrayColor whiteColor
            
            
            UIView *viewLeft = [[UIView alloc]initWithFrame:CGRectMake(leftX,leftY,leftW,leftH)];
            UIImageView* imageViewL = [[UIImageView alloc]initWithFrame:viewLeft.bounds];
            //UIImage *image = [UIImage imageNamed:@"loadingScene/u_announcement.png"];
            //UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
            imageViewL.image = [UIImage imageNamed:@"LoadingUI_JP/loadingUI_AdaptiveUp.jpg"];
            
            imageViewL.transform = CGAffineTransformMakeTranslation(0, -3);
            
            [viewLeft addSubview:imageViewL];
            viewLeft.tag = 1;
            //[window addSubview:viewLeft];
             [window insertSubview:viewLeft atIndex:1];//插入在位置1
        
            [window sendSubviewToBack:viewLeft];
            
            
            
            UIView *viewRight = [[UIView alloc]initWithFrame:CGRectMake(rightX,rightY,rightW,rightH)];
            
            UIImageView* imageView = [[UIImageView alloc]initWithFrame:viewRight.bounds];
            imageView.transform = CGAffineTransformMakeTranslation(0, -3);
            
            imageView.image = [UIImage imageNamed:@"LoadingUI_JP/loadingUI_AdaptiveUp.jpg"];
            
            [viewRight addSubview:imageView];
          //  [window addSubview:viewRight];
             viewRight.tag = 2;
            [window insertSubview:viewRight atIndex:2];//插入在位置1
            [window sendSubviewToBack:viewRight];
            
            
        }
    }
#endif
#pragma mark -
    
    [window makeKeyAndVisible];
    
    [[UIApplication sharedApplication]
     setStatusBarHidden:YES
     withAnimation:UIStatusBarAnimationSlide];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];    //防止进入屏保状态
    
    // initialized sdk
    [self registerRemoteNotification];
#ifdef PROJECT_GUAJI_YOUGU_YIJIE
    return [[YJAppDelegae Instance] application:application didFinishLaunchingWithOptions:launchOptions];
#endif
    [NSThread sleepForTimeInterval:1];
    
    // Add a custom slpash view before calling cocos2d game
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:viewController.view.bounds];
    imageView.image = [UIImage imageNamed:@"SecondLaunchImage"]; // Ensure this image is in Assets.xcassets
    imageView.contentMode = UIViewContentModeCenter;
    [viewController.view addSubview:imageView];

    // Delay then switch cocos2d
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(),
   ^{
        cocos2d::CCApplication::sharedApplication()->run();
        [imageView removeFromSuperview];
        // Delay a bit to prevent crash by early touch, because we run cocos2d late
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(),
        ^{
            __glView.userInteractionEnabled = true;
        });
    });
    
    return YES;
}



- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
#ifdef PROJECT_GUAJI_YOUGU
    [SPluginWrapper application:application openURL:url sourceApplication:nil annotation:nil];
#endif
    
#ifdef PROJECT_GUAJI_YOUGU_YIJIE
    return [[YJAppDelegae Instance] application:application handleOpenURL:url];
#endif
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation NS_AVAILABLE_IOS(4_2){
#ifdef PROJECT_GUAJI_YOUGU
    [SPluginWrapper application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
#endif
    
    if(libOS::getInstance()->getShareWCCallBack())
    {
        
    }
    else
    {
        
#ifdef PROJECT_RYUK_NEW_JP
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                            openURL:url
                                                sourceApplication:sourceApplication
                                                        annotation:annotation
            ];
#endif
    }
    
#ifdef PROJECT_GUAJI_YOUGU_YIJIE
    BOOL yjResult = [[YJAppDelegae Instance] application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
    return yjResult;
#endif
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    cocos2d::CCDirector::sharedDirector()->pause();
    
#ifdef PROJECT_GUAJI_YOUGU
    [SPluginWrapper applicationWillResignActive:application];
#endif
    [self pauseVideo];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    
    /*********************************************
     处理程式再次启动
     *********************************************/
    
    cocos2d::CCDirector::sharedDirector()->resume();
#ifdef PROJECT_GUAJI_YOUGU
    [SPluginWrapper applicationDidBecomeActive:application];
#endif
    [self resumeVideo];
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
    /*********************************************
     处理程式完全进入后台
     *********************************************/
    
    cocos2d::CCApplication::sharedApplication()->applicationDidEnterBackground();
#ifdef PROJECT_GUAJI_YOUGU
    [SPluginWrapper applicationDidEnterBackground:application];
#endif
    
#ifdef PROJECT_GUAJI_YOUGU_YIJIE
    [[YJAppDelegae Instance] applicationDidEnterBackground:application];
#endif
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
    [UIApplication sharedApplication].applicationIconBadgeNumber =0;
    cocos2d::CCApplication::sharedApplication()->applicationWillEnterForeground();
#ifdef PROJECT_GUAJI_YOUGU
    [SPluginWrapper applicationWillEnterForeground:application];
#endif
    
#ifdef PROJECT_GUAJI_YOUGU_YIJIE
    [[YJAppDelegae Instance] applicationWillEnterForeground:application];
#endif
}

- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
    /*********************************************
     处理程式准备关闭
     *********************************************/
#ifdef PROJECT_GUAJI_YOUGU
    [SPluginWrapper applicationWillTerminate:application];
    
#endif
}
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_6_0

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
#ifdef PROJECT_GUAJI_YOUGU_YIJIE
    return [[YJAppDelegae Instance] application:application supportedInterfaceOrientationsForWindow:window];
#endif
    return UIInterfaceOrientationMaskPortrait;
}
#endif

#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
    cocos2d::CCApplication::sharedApplication()->purgeCachedData();
    cocos2d::CCDirector::sharedDirector()->purgeCachedData();
}


- (void)dealloc {
    
    //-begin for GexinSdk
    
    [_appssfsKey release];
    [_appSt3s2ecret release];
    [_ao9id release];
    [_nsfsfstId release];
    [_idkd8853 release];
    [super dealloc];
}
- (void)registerRemoteNotification
{
#ifdef __IPHONE_8_0
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        
        UIUserNotificationSettings *uns = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound) categories:nil];
       [[UIApplication sharedApplication] registerForRemoteNotifications];
        [[UIApplication sharedApplication] registerUserNotificationSettings:uns];
    } else {
        UIRemoteNotificationType apn_type = (UIRemoteNotificationType)(UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound|UIRemoteNotificationTypeBadge);
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:apn_type];
    }
#else
    UIRemoteNotificationType apn_type = (UIRemoteNotificationType)(UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound|UIRemoteNotificationTypeBadge);
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:apn_type];
#endif
}


/******************Efun***************************
 iOS 推送
 *********************************************/
#ifdef __IPHONE_8_0
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    
    
}
#endif

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
#ifdef PROJECT_GUAJI_YOUGU_YIJIE
    [[YJAppDelegae Instance] application:application didReceiveRemoteNotification:userInfo];
#endif
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
#ifdef PROJECT_GUAJI_YOUGU_YIJIE
    [[YJAppDelegae Instance] application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
#endif
}

// Add these as instance variables if you want to track/remove later
CALayer *topBlackLayer;
CALayer *bottomBlackLayer;

-(void)playVideo:(int)iStateAfterPlay fullScreen:(int)iFullScreen file:(NSString*)strFilenameNoExtension fileExtension:(NSString*)strExtension
{
    // Stop current one if there is any
    [self resetVideo];
    // 1 = loop, 0 = no loop
    g_iPlayVideoState = iStateAfterPlay;
    
    NSString *filename = strFilenameNoExtension;
    NSString *extension = strExtension;

    // Build hotupdate path
    NSString *documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *hotUpdatePath = [documentsPath stringByAppendingPathComponent:@"hotUpdate"];
    NSString *hotUpdateFilePath = [hotUpdatePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", filename, extension]];

    // Try to load from hotupdate directory
    NSString *urlPath = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:hotUpdateFilePath]) {
        urlPath = hotUpdateFilePath;
        NSLog(@"Play Video (from hotupdate): %@", urlPath);
    } else {
        urlPath = [[NSBundle mainBundle] pathForResource:filename ofType:extension];
        NSLog(@"Play Video (from main bundle): %@", urlPath);
    }
    
    NSLog(@"Play Video: url: %@ fullscreen: %d loop: %d", urlPath, iFullScreen, iStateAfterPlay);
    
    if (urlPath)
    {
        player = [AVPlayer playerWithURL:[NSURL fileURLWithPath:urlPath]];
        AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        CGSize containerSize = viewController.view.superview.bounds.size;
        CGFloat topBarHeight = 0;
        CGFloat bottomBarHeight = 0;
        
        // Load video track to get actual dimensions
        AVAsset *asset = player.currentItem.asset;
        NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
        CGFloat width = containerSize.width;
        CGFloat height = containerSize.height;
        if (tracks.count > 0) {
            AVAssetTrack *videoTrack = tracks[0];
            CGSize naturalSize = videoTrack.naturalSize;
            CGAffineTransform txf = videoTrack.preferredTransform;
            CGSize actualVideoSize = CGSizeApplyAffineTransform(naturalSize, txf);
            actualVideoSize = CGSizeMake(fabs(actualVideoSize.width), fabs(actualVideoSize.height));
            
            
            // Scale to match container width
            CGFloat videoAspectRatio = actualVideoSize.height / actualVideoSize.width;
            height = width * videoAspectRatio;
            
            CGFloat x = 0;
            CGFloat y = (containerSize.height - height) / 2.0; // Center vertically
            
            playerLayer.frame = CGRectMake(x, y, width, height);
            
            // Calculate overflow
            // Different movies have different resolution, so we fix the height
            //topBarHeight = height - containerSize.height;
            topBarHeight = 30;
            bottomBarHeight = height - containerSize.height;
        }
        // Insert as background
        [viewController.view.superview.layer insertSublayer:playerLayer atIndex:0];
        
        CALayer *containerLayer = viewController.view.superview.layer;

        // Clean up old bars
        [topBlackLayer removeFromSuperlayer];
        [bottomBlackLayer removeFromSuperlayer];

        // Add top bar
        if (topBarHeight > 0) {
            topBlackLayer = [CALayer layer];
            topBlackLayer.frame = CGRectMake(0, 0, width, topBarHeight);
            topBlackLayer.backgroundColor = [UIColor blackColor].CGColor;
            [containerLayer insertSublayer:topBlackLayer atIndex:1];
        }

        // Add bottom bar
        if (bottomBarHeight > 0) {
            bottomBlackLayer = [CALayer layer];
            bottomBlackLayer.frame = CGRectMake(0, containerSize.height - bottomBarHeight, width, bottomBarHeight);
            bottomBlackLayer.backgroundColor = [UIColor blackColor].CGColor;
            [containerLayer insertSublayer:bottomBlackLayer atIndex:1];
        }
        
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(movieFinishedCallback:)
         name:AVPlayerItemDidPlayToEndTimeNotification
         object:nil];
        
        [player play];
    } else
    {
        NSLog(@"Error: Video file not found in hotupdate or main bundle.");
    }
}

-(void)pauseVideo
{
    if (player == nil)
        return;
    [player pause];
}

-(void)resumeVideo
{
    if (player == nil)
        return;
    if (player.currentItem.status == AVPlayerItemStatusReadyToPlay)
    {
        if (player.timeControlStatus == AVPlayerTimeControlStatusPaused)
        {
            [player play];
        } else if (CMTimeCompare(player.currentTime,player.currentItem.duration) == 0)
        {
            [player seekToTime:kCMTimeZero completionHandler:^(BOOL finished)
             {
                [player play];
            }];
        }
    }
}

-(void)resetVideo
{
    if (player == nil)
        return;
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:AVPlayerItemDidPlayToEndTimeNotification
     object:nil];
    
    [topBlackLayer removeFromSuperlayer];
    bottomBlackLayer = nil;
    topBlackLayer = nil;

    [bottomBlackLayer removeFromSuperlayer];
    bottomBlackLayer = nil;
    
    [player pause];
    [player replaceCurrentItemWithPlayerItem:nil];
    [playerViewController.view removeFromSuperview];
    playerViewController = nil;
    player = nil;
}

-(void)stopVideo
{
    [self resetVideo];
    libPlatformManager::getPlatform()->sendMessageP2G("onPlayMovieEnd", "");
}

-(void)movieFinishedCallback:(NSNotification*) aNotification
{
    NSLog(@"movieFinishCallback with looping? %d", g_iPlayVideoState);
    // Looping?
    if (g_iPlayVideoState == 1)
    {
        // Seek to the beginning
        [player seekToTime:kCMTimeZero];
        [player play];
    }
    else
    {
        [self stopVideo];
    }
    
    libPlatformManager::getPlatform()->sendMessageP2G("onPlayMovieEnd", "");
}

@end


@implementation UIWindow (shake)

//这里很重要，因为大部分视图 默认 的  canBecomeFirstResponder 是 NO的

-(BOOL)canBecomeFirstResponder
{
    return NO;
}

-(void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    
}

-(void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    
    if (motion ==UIEventSubtypeMotionShake )
    {
        libOS::getInstance()->boardcastMotionShakeMessage();
    }
}

-(void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    
    
    
}

@end



