//
//  AdverView.m
//  lib91
//
//  Created by GuoDong on 14-9-24.
//  Copyright (c) 2014年 youai. All rights reserved.
//

#import "AdverView.h"
//#import <comHuTuoSDK.h>
@implementation AdverView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.frame = frame;
        self.backgroundColor = [UIColor colorWithRed:41.0/255.0 green:41.0/255.0 blue:41.0/255.0 alpha:0.7];
        float height = frame.size.width/8*5;
        UIImageView *iView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, height)];
        iView.center = self.center;
        //iView.image = [UIImage imageNamed:@"advertise.png"];
        [self addSubview:iView];
        [iView release];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = iView.frame;
        button.center = self.center;
        [iView addSubview:button];
        [button addTarget:self action:@selector(buttonDown) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        closeButton.frame = CGRectMake(0, 0, 100, 40);
        closeButton.center = CGPointMake(self.center.x, self.center.y-height/2-40);
        closeButton.layer.cornerRadius = 12;
        closeButton.backgroundColor = [UIColor blueColor];
        [self addSubview:closeButton];
        [closeButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
        [closeButton setTitle:@"CLOSE" forState:UIControlStateNormal];
        [closeButton setTitle:@"CLOSE" forState:UIControlStateSelected];
    }
    return self;
}

-(void)buttonDown
{
    //NSString *adurl = [comHuTuoSDK getPropertyFromIniFile:@"Ad" andAttr:@"adurl"];
    //if(adurl == nil){
    //    adurl = @"https://itunes.apple.com/";
    //}
    //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:adurl]];

}

-(void)close
{
    self.hidden = YES;
    [self removeFromSuperview];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
