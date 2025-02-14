//
//  WCAlertView.h
//  WCAlertView

//add by linan
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, WCAlertViewStyle)
{
    WCAlertViewStyleDefault = 0,
    WCAlertViewStyleWhite,
    WCAlertViewStyleWhiteHatched,
    WCAlertViewStyleBlack,
    WCAlertViewStyleBlackHatched,
    WCAlertViewStyleViolet,
    WCAlertViewStyleVioletHatched,
};

@interface WCAlertView : UIAlertView

/*
 *  Predefined alert styles
 */
@property (nonatomic,assign) WCAlertViewStyle style;

/*
 *  Title and message label styles
 */
@property (nonatomic,strong) UIColor *labelTextColor;
@property (nonatomic,strong) UIColor *labelShadowColor;
@property (nonatomic,assign) CGSize   labelShadowOffset;

/*
 *  Button styles
 */
@property (nonatomic,strong) UIColor *buttonTextColor;
@property (nonatomic,strong) UIFont  *buttonFont;
@property (nonatomic,strong) UIColor *buttonShadowColor;
@property (nonatomic,assign) CGSize   buttonShadowOffset;
@property (nonatomic,assign) CGFloat  buttonShadowBlur;

/*
 *  Background gradient colors and locations
 */
@property (nonatomic,strong) NSArray *gradientLocations;
@property (nonatomic,strong) NSArray *gradientColors;

@property (nonatomic,assign) CGFloat cornerRadius;
/*
 * Inner frame shadow (optional)
 * Stroke path to cover up pixialation on corners from clipping!
 */
@property (nonatomic,strong) UIColor *innerFrameShadowColor;
@property (nonatomic,strong) UIColor *innerFrameStrokeColor;

/*
 * Hatched lines
 */
@property (nonatomic,strong) UIColor *verticalLineColor;

@property (nonatomic,strong) UIColor *hatchedLinesColor;
@property (nonatomic,strong) UIColor *hatchedBackgroundColor;

/*
 *  Outer frame color
 */
@property (nonatomic,strong) UIColor *outerFrameColor;
@property (nonatomic,assign) CGFloat  outerFrameLineWidth;
@property (nonatomic,strong) UIColor *outerFrameShadowColor;
@property (nonatomic,assign) CGSize   outerFrameShadowOffset;
@property (nonatomic,assign) CGFloat  outerFrameShadowBlur;

@property (nonatomic,strong) NSString  *str;
/*
 *  Setting default appearance for all WCAlertView's
 */
+ (void)setDefaultStyle:(WCAlertViewStyle)style;


+ (id)showAlertWithTitle:(NSString *)title message:(NSString *)message content:(NSString *)content delegate:(id)delegate customizationBlock:(void (^)(WCAlertView *alertView))customization completionBlock:(void (^)(NSUInteger buttonIndex, WCAlertView *alertView))block cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;


@end
