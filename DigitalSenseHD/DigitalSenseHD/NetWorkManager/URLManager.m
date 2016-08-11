//
//  URLManager.m
//  renrenfenqi
//
//  Created by baolicheng on 15/8/3.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import "URLManager.h"
static URLManager *manager;
@implementation URLManager
+(id)defaultManager
{
    if (manager == nil) {
        manager = [[URLManager alloc] init];
    }
    return manager;
}

-(NSString *)returnBaseUrl
{
    return BaseURL;
}

-(void)setUrlWithState:(BOOL)state
{
    if (state) {
        BaseURL = @"http://api.smell.renrenfenqi.com";
    }else{
        BaseURL = @"http://api.smell.renrenfenqi.com";
    }
}
@end
