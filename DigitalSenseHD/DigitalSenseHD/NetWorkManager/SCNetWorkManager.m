//
//  SCNetWorkManager.m
//  IntelligentMask
//
//  Created by baolicheng on 16/4/5.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import "SCNetWorkManager.h"
static AFHTTPRequestOperationManager *requestManager;
static SCNetWorkManager *scNetWorkManager;
@implementation SCNetWorkManager
+(id)defaultManager
{
    if (scNetWorkManager == nil) {
        scNetWorkManager = [[SCNetWorkManager alloc] init];
        requestManager = [AFHTTPRequestOperationManager manager];
        [requestManager.requestSerializer setTimeoutInterval:TimeOut];
    }
    return scNetWorkManager;
}

-(void)post:(NSString *)uri parameters:(id)parameters success:(ApiSuccessCallback)success error:(ApiErrorCallback)errors failed:(ApiFailedCallback)failed isNotify:(BOOL)isNotify
{
    NSMutableDictionary *para = nil;
    if (parameters) {
        para = [NSMutableDictionary dictionaryWithDictionary:parameters];
    }else{
        para = [NSMutableDictionary dictionary];
    }
    
    NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970];
    NSString *timeStamp = [NSString stringWithFormat:@"%.0f",nowTime];
    [para setObject:timeStamp forKey:@"timestamp"];
    NSString *signatureString = [AppUtils generateSignatureString:parameters Method:@"POST" URI:uri Key:SignatureAPPKey];
    NSString *signature = [AppUtils sha1:signatureString];
    [para setObject:signature forKey:@"sign"];
    
    NSString *url = [NSString stringWithFormat:@"%@%@",API_BASE,uri];
    [requestManager POST:url parameters:para success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation,responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSDictionary *responseObject = operation.responseObject;
        
        if (isNotify) {
            if (responseObject == nil) {
                [AppUtils showInfo:NetWorkConnectFailedDescription];
                failed(operation, error);
            }else{
                NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
                if (code % 2 != 0) {
                    [AppUtils showInfo:[responseObject objectForKey:@"msg"]];
                }
                errors(operation, error);
            }
        }else{
            if (responseObject == nil) {
                failed(operation, error);
            }else{
                errors(operation, error);
            }
        }
    }];
}

-(void)get:(NSString *)uri parameters:(id)parameters success:(ApiSuccessCallback)success error:(ApiErrorCallback)errors failed:(ApiFailedCallback)failed isNotify:(BOOL)isNotify
{
    NSMutableDictionary *para = nil;
    if (parameters) {
        para = [NSMutableDictionary dictionaryWithDictionary:parameters];
    }else{
        para = [NSMutableDictionary dictionary];
    }
    
    NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970];
    NSString *timeStamp = [NSString stringWithFormat:@"%.0f",nowTime];
    [para setObject:timeStamp forKey:@"timestamp"];
    NSString *signatureString = [AppUtils generateSignatureString:parameters Method:@"GET" URI:uri Key:SignatureAPPKey];
    NSString *signature = [AppUtils sha1:signatureString];
    [para setObject:signature forKey:@"sign"];
    
    NSString *url = [NSString stringWithFormat:@"%@%@",API_BASE,uri];
    [requestManager GET:url parameters:para success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation,responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSDictionary *responseObject = operation.responseObject;
        
        if (isNotify) {
            if (responseObject == nil) {
                [AppUtils showInfo:NetWorkConnectFailedDescription];
                failed(operation, error);
            }else{
                NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
                if (code % 2 != 0) {
                    [AppUtils showInfo:[responseObject objectForKey:@"msg"]];
                }
                errors(operation, error);
            }
        }else{
            if (responseObject == nil) {
                failed(operation, error);
            }else{
                errors(operation, error);
            }
        }
        
    }];
}

-(void)put:(NSString *)uri parameters:(id)parameters success:(ApiSuccessCallback)success error:(ApiErrorCallback)errors failed:(ApiFailedCallback)failed isNotify:(BOOL)isNotify
{
    NSMutableDictionary *para = nil;
    if (parameters) {
        para = [NSMutableDictionary dictionaryWithDictionary:parameters];
    }else{
        para = [NSMutableDictionary dictionary];
    }
    
    NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970];
    NSString *timeStamp = [NSString stringWithFormat:@"%.0f",nowTime];
    [para setObject:timeStamp forKey:@"timestamp"];
    NSString *signatureString = [AppUtils generateSignatureString:parameters Method:@"PUT" URI:uri Key:SignatureAPPKey];
    NSString *signature = [AppUtils sha1:signatureString];
    [para setObject:signature forKey:@"sign"];
    
    NSString *url = [NSString stringWithFormat:@"%@%@",API_BASE,uri];
    [requestManager PUT:url parameters:para success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation,responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSDictionary *responseObject = operation.responseObject;
        
        if (isNotify) {
            if (responseObject == nil) {
                [AppUtils showInfo:NetWorkConnectFailedDescription];
                failed(operation, error);
            }else{
                NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
                if (code % 2 != 0) {
                    [AppUtils showInfo:[responseObject objectForKey:@"msg"]];
                }else{
                    [AppUtils showInfo:@"服务器接口崩溃"];
                }
                errors(operation, error);
            }
        }else{
            if (responseObject == nil) {
                failed(operation, error);
            }else{
                errors(operation, error);
            }
        }
    }];
}


- (void)downloadFileWithOption:(NSDictionary *)paramDic
                 withInferface:(NSString*)requestURI
                     savedPath:(NSString*)savedPath
               downloadSuccess:(ApiSuccessCallback)success
               downloadFailure:(ApiFailedCallback)failure
                      progress:(ApiDownloadFileProgress)progress
{
    AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
    NSString *url = [NSString stringWithFormat:@"%@%@",API_BASE,requestURI];
    NSMutableURLRequest *request = [serializer requestWithMethod:@"POST" URLString:url parameters:paramDic error:nil];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setOutputStream:[NSOutputStream outputStreamToFileAtPath:savedPath append:NO]];
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        float p = (float)totalBytesRead / totalBytesExpectedToRead;
        progress(p);
    }];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation,responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(operation,error);
    }];
}
@end
