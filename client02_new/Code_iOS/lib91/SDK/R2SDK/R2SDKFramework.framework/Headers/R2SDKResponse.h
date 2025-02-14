//
//  R2Response.h
//  R2SDK
//
//  Created by luxing on 7/27/15.
//  Copyright (c) 2015 luxing. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol R2SDKResponse <NSObject>
-(void)initWithData:(NSData*)serverData;
-(int)getResponseCode;
-(NSString*)getResponseMsg;
-(NSDictionary*)getResponseData;
@end