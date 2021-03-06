//
//  AppUtils.m
//  DigitalSense
//
//  Created by baolicheng on 16/5/12.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import "AppUtils.h"
#import "MBProgressHUD.h"
#import "MBProgressCustomView.h"
#import "URLManager.h"
#import <CommonCrypto/CommonDigest.h>
#import <math.h>
#define MBTAG  1001
#define AMTAG  1111
#define MBProgressTAG 1002
#define MBProgressCustomTag 1003
@implementation AppUtils
+(void)setUrlWithState:(BOOL)state
{
    [[URLManager defaultManager] setUrlWithState:state];
}

+(NSString *)returnBaseUrl
{
    return [[URLManager defaultManager] returnBaseUrl];
}

+ (NSString*) appVersion {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}


+(NSString *)generateSignatureString:(NSDictionary *)parameters Method:(NSString *)method URI:(NSString *)uri Key:(NSString *)subKey
{
    NSMutableString *signatureString = nil;
    if (parameters) {
        NSArray *allKeys = [parameters allKeys];
        NSArray *sortKeys = [allKeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            return [obj1 compare:obj2];
        }];
        
        signatureString = [[NSMutableString alloc] initWithFormat:@"%@:%@:",method,uri];
        for (NSString *key in sortKeys) {
            NSString *paraString = nil;
            if ([key isEqualToString:[sortKeys lastObject]]) {
                paraString = [NSString stringWithFormat:@"%@=%@:",key,[parameters objectForKey:key]];
            }else{
                paraString = [NSString stringWithFormat:@"%@=%@&",key,[parameters objectForKey:key]];
            }
            [signatureString appendString:paraString];
        }
        
        [signatureString appendString:subKey];
    }
    return signatureString;
}

+(NSString*) sha1:(NSString *)text
{
    const char *cstr = [text cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:text.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
}

+(NSString *)getMd5_32Bit:(NSString *)str {
    const char *cStr = [str UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, str.length, digest );
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [result appendFormat:@"%02x", digest[i]];
    return result;
}

+(void)showInfo:(NSString *)text
{
    if ([[NSThread currentThread] isMainThread]) {
        UIWindow *appRootView = [UIApplication sharedApplication].keyWindow;
        MBProgressHUD *HUD = (MBProgressHUD *)[appRootView viewWithTag:MBTAG];
        if (HUD == nil) {
            HUD = [[MBProgressHUD alloc] initWithView:appRootView];
            HUD.tag = MBTAG;
            [appRootView addSubview:HUD];
            [HUD show:YES];
        }
        
        HUD.removeFromSuperViewOnHide = YES; // 设置YES ，MB 再消失的时候会从super 移除
        
        if ([self isNullStr:text]) {
            //        HUD.animationType = MBProgressHUDAnimationZoom;
            [HUD hide:YES];
        }else{
            HUD.mode = MBProgressHUDModeText;
            HUD.labelText = text;
            HUD.labelFont = [UIFont fontWithName:@"HelveticaNeue" size:15];
            [HUD hide:YES afterDelay:1];
        }
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            UIWindow *appRootView = [UIApplication sharedApplication].keyWindow;
            MBProgressHUD *HUD = (MBProgressHUD *)[appRootView viewWithTag:MBTAG];
            if (HUD == nil) {
                HUD = [[MBProgressHUD alloc] initWithView:appRootView];
                HUD.tag = MBTAG;
                [appRootView addSubview:HUD];
                [HUD show:YES];
            }
            
            HUD.removeFromSuperViewOnHide = YES; // 设置YES ，MB 再消失的时候会从super 移除
            
            if ([self isNullStr:text]) {
                //        HUD.animationType = MBProgressHUDAnimationZoom;
                [HUD hide:YES];
            }else{
                HUD.mode = MBProgressHUDModeText;
                HUD.labelText = text;
                HUD.labelFont = [UIFont fontWithName:@"HelveticaNeue" size:15];
                [HUD hide:YES afterDelay:1];
            }
        });
    }
}

/**
 *  @author RenRenFenQi, 16-07-30 14:07:14
 *
 *  对float型数字四舍五入
 *
 *  @param value float型数字
 *
 *  @return 四舍五入后的整型
 */
+(NSInteger)floatToInt:(CGFloat)value
{
    CGFloat temp = roundf(value);
    return [[NSNumber numberWithFloat:temp] integerValue];
}

/**
 *  @author RenRenFenQi, 16-07-30 15:07:34
 *
 *  根据业务需求，将float型数字转为整型
 *
 *  @param value    float型数字 介于0~maxValue之间
 *  @param maxValue 最大值
 *
 *  @return 整型数字
 */
+(NSInteger)floatToInt:(CGFloat)value WithMaxValue:(NSInteger)maxValue
{
    CGFloat temp = value / maxValue;
    if (temp < 0.4) {
        return 9;
    }
    
    if (temp < 0.73) {
        return 5;
    }
    
    if (temp < 1.0) {
        return 2;
    }
    return 5;
}

+(NSString *)switchSecondsToTime:(NSInteger)seconds
{
    NSInteger second = seconds % 60;
    NSInteger minite = (seconds - second) / 60;
    NSString *result;
    if (minite < 10) {
        result = [NSString stringWithFormat:@"%02ld:%02ld",minite,second];
    }else{
        result = [NSString stringWithFormat:@"%ld:%02ld",minite,second];
    }
    return result;
}


+ (BOOL)isNullStr:(NSString *)str
{
    if (str == nil || [str isEqual:[NSNull null]] || str.length == 0) {
        return  YES;
    }
    
    return NO;
}

+ (BOOL)isNetworkURL:(NSString *)url
{
    BOOL result = NO;
    if (url) {
        if ([url hasPrefix:@"http://"]) {
            result = YES;
        }
    }
    return result;
}

+(void)showHudProgress:(NSString *)title ForView:(UIView *)view;
{
    if ([[NSThread currentThread] isMainThread]) {
        MBProgressHUD *HUD = (MBProgressHUD *)[view viewWithTag:MBProgressTAG];
        if (HUD == nil) {
            HUD = [[MBProgressHUD alloc] initWithView:view];
            HUD.mode = MBProgressHUDModeCustomView;
            HUD.customView = [[MBProgressCustomView alloc] init];
            HUD.square = YES;
            HUD.tag = MBProgressTAG;
            [view addSubview:HUD];
        }
        [HUD setLabelText:title];
        [HUD show:YES];
        HUD.removeFromSuperViewOnHide = YES; // 设置YES ，MB 再消失的时候会从super 移除
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            MBProgressHUD *HUD = (MBProgressHUD *)[view viewWithTag:MBProgressTAG];
            if (HUD == nil) {
                HUD = [[MBProgressHUD alloc] initWithView:view];
                HUD.mode = MBProgressHUDModeCustomView;
                HUD.customView = [[MBProgressCustomView alloc] init];
                HUD.square = YES;
                HUD.tag = MBProgressTAG;
                [view addSubview:HUD];
            }
            [HUD setLabelText:title];
            [HUD show:YES];
            HUD.removeFromSuperViewOnHide = YES; // 设置YES ，MB 再消失的时候会从super 移除
        });
    }
}

+(void)hidenHudProgressForView:(UIView *)view
{
    if ([[NSThread currentThread] isMainThread]) {
        MBProgressHUD *HUD = (MBProgressHUD *)[view viewWithTag:MBProgressTAG];
        if (HUD != nil) {
            [HUD hide:YES];
        }
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            MBProgressHUD *HUD = (MBProgressHUD *)[view viewWithTag:MBProgressTAG];
            if (HUD != nil) {
                [HUD hide:YES];
            }
        });
    }
}

+(void)showCustomHudProgress:(NSString *)title CustomView:(UIView *)customView ForView:(UIView *)view
{
    if ([[NSThread currentThread] isMainThread]) {
        MBProgressHUD *HUD = (MBProgressHUD *)[view viewWithTag:MBProgressCustomTag];
        if (HUD == nil) {
            HUD = [[MBProgressHUD alloc] initWithView:view];
            HUD.mode = MBProgressHUDModeCustomView;
            HUD.customView = customView;
            HUD.square = YES;
            HUD.tag = MBProgressCustomTag;
            [view addSubview:HUD];
        }
        [HUD setLabelText:title];
        [HUD show:YES];
        HUD.removeFromSuperViewOnHide = YES; // 设置YES ，MB 再消失的时候会从super 移除
        [HUD hide:YES afterDelay:1];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            MBProgressHUD *HUD = (MBProgressHUD *)[view viewWithTag:MBProgressCustomTag];
            if (HUD == nil) {
                HUD = [[MBProgressHUD alloc] initWithView:view];
                HUD.mode = MBProgressHUDModeCustomView;
                HUD.customView = customView;
                HUD.square = YES;
                HUD.tag = MBProgressCustomTag;
                [view addSubview:HUD];
            }
            [HUD setLabelText:title];
            [HUD show:YES];
            HUD.removeFromSuperViewOnHide = YES; // 设置YES ，MB 再消失的时候会从super 移除
            [HUD hide:YES afterDelay:1];
        });
    }
}

+(void)hidenCustomHudProgressForView:(UIView *)view
{
    if ([[NSThread currentThread] isMainThread]) {
        MBProgressHUD *HUD = (MBProgressHUD *)[view viewWithTag:MBProgressCustomTag];
        if (HUD != nil) {
            [HUD hide:YES];
        }
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            MBProgressHUD *HUD = (MBProgressHUD *)[view viewWithTag:MBProgressCustomTag];
            if (HUD != nil) {
                [HUD hide:YES];
            }
        });
    }
}


//中档:0.602  高档:0.275   低档:0.895
+(CGFloat)powerFixed:(CGFloat)power;
{
    if (power < 0.44) {
        return 0.275;
    }
    
    if (power < 0.75) {
        return 0.602;
    }
    
    if (power < 1.0) {
        return 0.895;
    }
    return 0.602;
}

+(NSString *)imageNameWithPower:(CGFloat)power
{
    if (power < 0.44) {
        return @"highPower";
    }
    
    if (power < 0.75) {
        return @"normalPower";
    }
    
    if (power < 1.0) {
        return @"lowPower";
    }
    return nil;
}

+(NSString *)powerLevelWithPower:(CGFloat)power
{
    if (power < 0.44) {
        return @"highPower";
    }
    
    if (power < 0.75) {
        return @"normalPower";
    }
    
    if (power < 1.0) {
        return @"lowPower";
    }
    return @"normalPower";
}
@end
