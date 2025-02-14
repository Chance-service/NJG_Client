//
//  ControlTKAlert.m
//  testAlertShow
//
//  Created by fanlees on 11-12-12.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "ControlTKAlert.h"

@implementation ControlTKAlert

+ (ControlTKAlert*) defaultCenter
{
    static ControlTKAlert *defaultCenter = nil;
    if (!defaultCenter) {
        defaultCenter = [[ControlTKAlert alloc] init];
    }
    return defaultCenter;
}

- (id) init{
	if(!(self=[super init])) return nil;
	
	_alerts = [[NSMutableArray alloc] init];
	_alertView = [[TKAlertView alloc] init];
	_active = NO;
	
	
	_alertFrame = [UIApplication sharedApplication].keyWindow.bounds;
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAppear:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillDisappear:) name:UIKeyboardDidHideNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationWillChange:) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
    
	return self;
}

- (void)openAlertViewWithMessage:(NSString *)message
                      duringtime:(double)howManry
{
    UIImage *aimage = [[UIImage alloc] init];
    NSNumber *duringtime = [[NSNumber alloc] initWithDouble:howManry];
    [_alerts addObject:[NSArray arrayWithObjects:message,aimage,duringtime,nil]];
    [aimage release];
    [duringtime release];
    if(!_active)
    {
        [self showAlerts];
    }
}

- (void)stopAlertView
{
    [self animationStep3];
}

- (void) showAlerts{
	
	if([_alerts count] < 1) {
		_active = NO;
		return;
	}
	
	_active = YES;
	
	_alertView.transform = CGAffineTransformIdentity;
	_alertView.alpha = 0;
	[[UIApplication sharedApplication].keyWindow addSubview:_alertView];
    
	
	
	NSArray *ar = [_alerts objectAtIndex:0];
	
	UIImage *img = nil;
	if([ar count] > 1) img = [[_alerts objectAtIndex:0] objectAtIndex:1];
	
	[_alertView setImage:img];
    
	if([ar count] > 0) [_alertView setMessageText:[[_alerts objectAtIndex:0] objectAtIndex:0]];
	
	
	
	_alertView.center = CGPointMake(_alertFrame.origin.x+_alertFrame.size.width/2, _alertFrame.origin.y+_alertFrame.size.height/2);
    
	
	CGRect rr = _alertView.frame;
	rr.origin.x = (int)rr.origin.x;
	rr.origin.y = (int)rr.origin.y;
	_alertView.frame = rr;
	
	UIInterfaceOrientation o = [UIApplication sharedApplication].statusBarOrientation;
	CGFloat degrees = 0;
	if(o == UIInterfaceOrientationLandscapeLeft ) degrees = -90;
	else if(o == UIInterfaceOrientationLandscapeRight ) degrees = 90;
	else if(o == UIInterfaceOrientationPortraitUpsideDown) degrees = 180;
	_alertView.transform = CGAffineTransformMakeRotation(degrees * M_PI / 180);
	_alertView.transform = CGAffineTransformScale(_alertView.transform, 2, 2);
	
	
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.15];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationStep2)];
	_alertView.transform = CGAffineTransformMakeRotation(degrees * M_PI / 180);
	_alertView.frame = CGRectMake((int)_alertView.frame.origin.x, (int)_alertView.frame.origin.y, _alertView.frame.size.width, _alertView.frame.size.height);
	_alertView.alpha = 1;
	
	[UIView commitAnimations];
}
- (void) animationStep2{
	[UIView beginAnimations:nil context:nil];
    
	// depending on how many words are in the text
	// change the animation duration accordingly
	// avg person reads 200 words per minute
    //	NSArray * words = [[[self.alerts objectAtIndex:0] objectAtIndex:0] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    //	double duration = MAX(((double)[words count]*60.0/200.0),1);
    
    double duration = [[[_alerts objectAtIndex:0] lastObject] doubleValue];
	//NSLog(@"*******%f*******",duration);
    
	[UIView setAnimationDelay:duration];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationStep3)];
	
	UIInterfaceOrientation o = [UIApplication sharedApplication].statusBarOrientation;
	CGFloat degrees = 0;
	if(o == UIInterfaceOrientationLandscapeLeft ) degrees = -90;
	else if(o == UIInterfaceOrientationLandscapeRight ) degrees = 90;
	else if(o == UIInterfaceOrientationPortraitUpsideDown) degrees = 180;
	_alertView.transform = CGAffineTransformMakeRotation(degrees * M_PI / 180);
	_alertView.transform = CGAffineTransformScale(_alertView.transform, 0.5, 0.5);
	
	_alertView.alpha = 0;
	[UIView commitAnimations];
}


- (void) animationStep3{
	[_alertView removeFromSuperview];
    [_alerts setArray:nil];
    [self showAlerts];
}


@end
