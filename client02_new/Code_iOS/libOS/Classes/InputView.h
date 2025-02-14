//
//  testAlertView.h
//  AlertViewAnimation
//
//  Created by GuoDong on 14-8-15.
//  Copyright (c) 2014年 steven. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol InputViewDelegate <NSObject>
-(void) buttonOKTag:(int)tag content:(NSString*)content;
-(void) hideView;
@end

@interface InputView : UIView<UITextViewDelegate>
@property(nonatomic,assign)id<InputViewDelegate> delegate;
@property (nonatomic,retain)UITextView *textView;
- (id)initWithFrame:(CGRect)frame bMultiline:(BOOL)multiline;
@end
