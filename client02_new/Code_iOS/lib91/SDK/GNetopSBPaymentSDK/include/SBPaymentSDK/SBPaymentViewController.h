//
//  ViewController.h
//  JFDepthVewExample
//
//  Created by Jeremy Fox on 10/17/12.
//  Copyright (c) 2012 Jeremy Fox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBPaymentBaeView.h"

@interface SBPaymentViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) SBPaymentBaeView* depthViewReference;
@property (weak, nonatomic) UIView* presentedInView;


@property (nonatomic)int mode; // 0: test 1:本番

@property (nonatomic,strong)NSString* payMethod ; //支払方法
//@property (nonatomic,strong)NSString* merchantId ;//マーチャントID
//@property (nonatomic,strong)NSString* serviceId ;//サービスID
@property (nonatomic,strong)NSString* custCode ;//顧客ID
//@property (nonatomic,strong)NSString* spsCustNo ;//SPS顧客ID

//@property (nonatomic,strong)NSString* spsPaymentNo ;//SPS支払方法管理番号
@property (nonatomic,strong)NSString* orderId ;//購入ID
@property (nonatomic,strong)NSString* itemId ;//商品ID
//@property (nonatomic,strong)NSString* payItemId ;//外部決済機関商品ID
@property (nonatomic,strong)NSString* itemName ;//商品名称

@property (nonatomic,strong)NSString* tax ;//税額
@property (nonatomic,strong)NSString* amount ;//金額(税込)
//@property (nonatomic,strong)NSString* payType ;//購入タイプ
//@property (nonatomic,strong)NSString* autoChargeType ;//自動課金タイプ
//@property (nonatomic,strong)NSString* serviceType ;//サービスタイプ

//@property (nonatomic,strong)NSString* divSettele ;//決済区分
//@property (nonatomic,strong)NSString* lastChargeMonth ;//最終課金月
//@property (nonatomic,strong)NSString* campType ;//キャンペーンタイプ
//@property (nonatomic,strong)NSString* trackingId ;//トラッキングID
//@property (nonatomic,strong)NSString* terminalType ;//顧客利用端末タイプ

@property (nonatomic,strong)NSString* successUrl ;//決済完了時URL
@property (nonatomic,strong)NSString* cancelUrl ;//決済キャンセル時URL
@property (nonatomic,strong)NSString* errorUrl ;//エラー時URL
@property (nonatomic,strong)NSString* pageconUrl ;//決済通知用CGI

@property (nonatomic,strong)NSString* free1 ;//自由欄1
@property (nonatomic,strong)NSString* free2 ;//自由欄2
@property (nonatomic,strong)NSString* free3 ;//自由欄3
//@property (nonatomic,strong)NSString* freeCSV ;


@property (nonatomic,strong) NSString* requestDate ;//リクエスト日時
@property (nonatomic,strong) NSString* limitSecond ;//レスポンス許容時間

- (IBAction)closeView:(id)sender;
//- (NSString*)getSPSCode;
@end
