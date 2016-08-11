//
//  SCNetWorkManager.h
//  IntelligentMask
//
//  Created by baolicheng on 16/4/5.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RFNetWorkHelper.h"
@interface SCNetWorkManager : NSObject
+(id)defaultManager;

-(void)post:(NSString *)uri parameters:(id)parameters success:(ApiSuccessCallback)success error:(ApiErrorCallback)errors failed:(ApiFailedCallback)failed isNotify:(BOOL)isNotify;

-(void)get:(NSString *)uri parameters:(id)parameters success:(ApiSuccessCallback)success error:(ApiErrorCallback)errors failed:(ApiFailedCallback)failed isNotify:(BOOL)isNotify;

-(void)put:(NSString *)uri parameters:(id)parameters success:(ApiSuccessCallback)success error:(ApiErrorCallback)errors failed:(ApiFailedCallback)failed isNotify:(BOOL)isNotify;

- (void)downloadFileWithOption:(NSDictionary *)paramDic
                 withInferface:(NSString*)requestURL
                     savedPath:(NSString*)savedPath
               downloadSuccess:(ApiSuccessCallback)success
               downloadFailure:(ApiFailedCallback)failure
                      progress:(ApiDownloadFileProgress)progress;
@end
