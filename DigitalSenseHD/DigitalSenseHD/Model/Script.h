//
//  Script.h
//  DigitalSense
//
//  Created by baolicheng on 16/6/16.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ScriptCommand.h"
#define ScriptStateComfirmed @"ScriptStateComfirmed"
typedef enum{
    ScriptIsNormal, //未播放状态
    ScriptIsWaiting, //排队中
    ScriptIsPlaying //播放中
} ScriptState;

typedef enum{
    ScriptIsAbsoluteTime = 2, //绝对时间脚本
    ScriptIsRelativeTime = 1 //相对时间脚本
} ScriptType;
@interface Script : NSObject
@property(nonatomic, copy) NSString *scriptId;
@property(nonatomic, copy) NSString *scriptName;
@property(nonatomic, copy) NSString *sceneName;
@property(nonatomic, strong) NSMutableArray *scriptCommandList;
@property(nonatomic) NSInteger scriptTime;
@property(nonatomic) BOOL isLoop;

@property(nonatomic) ScriptState state;
@property(nonatomic) ScriptType type;

-(NSString *)commandString;
@end
