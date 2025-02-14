//
//  GameAppController.h
//  Game
//
//  Created by fish on 13-2-18.
//  Copyright __MyCompanyName__ 2013年. All rights reserved.
//

#import "RootViewController.h"

@implementation RootViewController

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
 
*/
// Override to allow orientations other than the default portrait orientation.
// This method is deprecated on ios6
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)shouldAutorotate
{
    //NSNumber *autorotate = [SPluginWrapper shouldAutorotate];
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;//只支持这一个方向(正常的方向)
}
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewSafeAreaInsetsDidChange {
    
    [super viewSafeAreaInsetsDidChange];
    // NSLog(@NSStringFromUIEdgeInsets(self.view.safeAreaInsets));
    [self updateOrientation];
}

bool changeViewFrame = false;
- (void)updateOrientation {
    if (@available(iOS 11.0, *)) {
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
            
            CGFloat leftX = 0;
            CGFloat leftY = 0;
            CGFloat leftW = 500;
            CGFloat leftH = 200;
        
            if (width*scale_screen ==1125 and height*scale_screen ==2436) {
                leftX = 0;
                leftY = 30;
                leftW = 375;
                leftH = 760;
                
            }else if (width*scale_screen ==1242 and height*scale_screen ==2688)
            {
                leftX = 0;
                leftY = 30;
                leftW = 414;
                leftH = 840;
            }else if (width*scale_screen ==828 and height*scale_screen ==1792)
            {
                leftX = 0;
                leftY = 30;
                leftW = 414;
                leftH = 840;
            }
            if (self.view and !changeViewFrame)
            {
//                CGRect s = CGRectMake(self.view.safeAreaInsets.left,0,self.view.frame.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right,self.view.frame.size.height - self.view.safeAreaInsets.bottom);
                //x,y,width,height
               CGRect s = CGRectMake(leftX,leftY,leftW,leftH);
                self.view.frame = s;
                // 只需要记录一次，因为每次change view frame 都会改变一次这个
                changeViewFrame = true;
            }
        }
    }
}

- (void)dealloc {
    [super dealloc];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}


@end
