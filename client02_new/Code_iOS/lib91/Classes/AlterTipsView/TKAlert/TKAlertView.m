//
//  TKAlertView.m
//  SinaMusic
//
//  Created by fanlees on 11-9-8.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "TKAlertView.h"
#import "UIView+TKCategory.h"

@implementation TKAlertView

- (id) init{
	if(!(self = [super initWithFrame:CGRectMake(0, 0, 100, 100)])) return nil;
	_messageRect = CGRectInset(self.bounds, 10, 10);
	self.backgroundColor = [UIColor clearColor];
	return self;
	
}
- (void) dealloc{
	[_text release];
	[_image release];
	[super dealloc];
}

- (void) drawRect:(CGRect)rect{
	[[UIColor colorWithWhite:0 alpha:0.8] set];
	[UIView drawRoundRectangleInRect:rect withRadius:10];
	[[UIColor whiteColor] set];
	[_text drawInRect:_messageRect withFont:[UIFont boldSystemFontOfSize:14] lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentCenter];
	
	CGRect r = CGRectZero;
	r.origin.y = 15;
	r.origin.x = (rect.size.width-_image.size.width)/2;
	r.size = _image.size;
	
	[_image drawInRect:r];
}

#pragma mark Setter Methods
- (void) adjust{
	
	CGSize s = [_text sizeWithFont:[UIFont boldSystemFontOfSize:14] constrainedToSize:CGSizeMake(160,200) lineBreakMode:UILineBreakModeWordWrap];
	
	float imageAdjustment = 0;
	if (_image) {
		imageAdjustment = 7+_image.size.height;
	}
	
	self.bounds = CGRectMake(0, 0, s.width+40, s.height+15+15+imageAdjustment);
	
	_messageRect.size = s;
	_messageRect.size.height += 5;
	_messageRect.origin.x = 20;
	_messageRect.origin.y = 15+imageAdjustment;
	
	[self setNeedsLayout];
	[self setNeedsDisplay];
	
}
- (void) setMessageText:(NSString*)str{
	[_text release];
	_text = [str retain];
	[self adjust];
}
- (void) setImage:(UIImage*)img{
	[_image release];
	_image = [img retain];
	[self adjust];
}

@end
