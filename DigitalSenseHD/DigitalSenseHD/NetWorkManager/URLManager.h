//
//  URLManager.h
//  renrenfenqi
//
//  Created by baolicheng on 15/8/3.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface URLManager : NSObject
{
    NSString *BaseURL;
}
+(id)defaultManager;
-(NSString *)returnBaseUrl;
-(void)setUrlWithState:(BOOL)state;
@end
