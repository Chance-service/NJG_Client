//
//  TKLoadingView.h
//  Created by Devin Ross on 7/2/09.
//
/*
 
 tapku.com || http://github.com/devinross/tapkulibrary
 
 Permission is hereby granted, free of charge, to any person
 obtaining a copy of this software and associated documentation
 files (the "Software"), to deal in the Software without
 restriction, including without limitation the rights to use,
 copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following
 conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import <UIKit/UIKit.h>
@protocol TKActionDelegate;
@interface TKLoadingView : UIView {
	UIActivityIndicatorView *_activity;
	BOOL _hidden;
    UIButton *actionButton;
	NSString *_title;
	NSString *_message;
	float radius;
    NSInteger viewHight;
    UILabel *numberLable;
    id <TKActionDelegate> delegate;
}
@property (copy,nonatomic) NSString *title;
@property (copy,nonatomic) NSString *message;
@property (assign,nonatomic) float radius;
@property (nonatomic ,retain)UIButton *actionButton;
@property (nonatomic ,assign)id <TKActionDelegate> delegate;
@property (nonatomic ,assign)NSInteger viewHight;
@property (nonatomic ,retain)UILabel *numberLable;
- (id) initWithTitle:(NSString*)title message:(NSString*)message;
- (id) initWithTitle:(NSString*)title withViewHight:(NSInteger)hight;

- (void) startAnimating;
- (void) stopAnimating;
- (void) setActionButtonTitle:(NSString *)titleSt;
-(void) setNumberLableTitle:(NSString *)titleSt;
@end
@protocol TKActionDelegate <NSObject>
@optional
-(void)clickActionButton;
@end
