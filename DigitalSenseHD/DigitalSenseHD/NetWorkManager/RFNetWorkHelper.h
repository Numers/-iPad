//
//  RFNetWorkHelper.h
//  renrenfenqi
//
//  Created by baolicheng on 15/6/29.
//  Copyright (c) 2015年 RenRenFenQi. All rights reserved.
//

#ifndef renrenfenqi_RFNetWorkHelper_h
#define renrenfenqi_RFNetWorkHelper_h
#import "AFNetworking.h"
#import "GlobalVar.h"
typedef enum{
    SUCCESSREQUEST = 2000,
    NONEDATA,
    PARAMETERERROR,
    DATAEXCEPTION,
    ILLEGALREQUEST,
    UPDATEFAILED,
    WARNTYPE
}STATUSCODE;
#define TimeOut 10.0f
#define SignatureAPPKey @"RNIuYTzjt3oIDT_chVfxiUA.#B*9WYVA"
#define NetWorkConnectFailedDescription @"网络连接失败"

typedef void (^ApiSuccessCallback)(AFHTTPRequestOperation*operation, id responseObject);
typedef void (^ApiErrorCallback)(AFHTTPRequestOperation*operation, id responseObject);
typedef void (^ApiFailedCallback)(AFHTTPRequestOperation*operation, NSError *error);

typedef void (^ApiDownloadFileProgress)(float progress);
#endif
