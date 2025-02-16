@class RootViewController;

@interface AppController : NSObject <UIAccelerometerDelegate, UIAlertViewDelegate,
                                        UITextFieldDelegate, UIApplicationDelegate> {
    UIWindow *window;
    UIButton *button;//add by xinghui
    RootViewController    *viewController;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) RootViewController *viewController;

@property (retain, nonatomic) NSString *appssfsKey;
@property (retain, nonatomic) NSString *appSt3s2ecret;
@property (retain, nonatomic) NSString *ao9id;
@property (retain, nonatomic) NSString *nsfsfstId;
@property (assign, nonatomic) int lastinx20;
@property (retain, nonatomic) NSString *idkd8853;
@property (retain, nonatomic) UINavigationController *navigationController;

- (void)setDeviceToken:(NSString *)aToken;
- (BOOL)setTags:(NSArray *)aTag error:(NSError **)error;

- (void)playVideo:(int)iStateAfterPlay fullScreen:(int)iFullScreen file:(NSString*)strFilenameNoExtension fileExtension:(NSString*)strExtension;
- (void)stopVideo;
- (void)pauseVideo;
- (void)resumeVideo;
- (void)movieFinishedCallback:(NSNotification*) aNotification;
@end
