//
//  ScriptExecuteManager.m
//  DigitalSense
//
//  Created by baolicheng on 16/6/16.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import "ScriptExecuteManager.h"
#import "RelativeTimeScript.h"
#import "ScriptCommand.h"

#import "BluetoothMacManager.h"
static ScriptExecuteManager *scriptExecuteManager;
static NSInteger currentSecond = -1;
@implementation ScriptExecuteManager
+(id)defaultManager
{
    if (scriptExecuteManager == nil) {
        scriptExecuteManager = [[ScriptExecuteManager alloc] init];
    }
    return scriptExecuteManager;
}

/**
 *  @author RenRenFenQi, 16-06-16 16:06:34
 *
 *  执行相对时间脚本
 *
 *  @param script 脚本
 */
-(void)executeRelativeTimeScript:(Script *)script
{
    if (script) {
        script.state = ScriptIsWaiting;
        if (scriptQueue) {
            [scriptQueue addObject:script];
        }else{
            scriptQueue = [NSMutableArray arrayWithObject:script];
        }
    }
    [self playRelativeTimeScript];
}

/**
 *  @author RenRenFenQi, 16-06-17 10:06:43
 *
 *  取消排队中的相对时间脚本
 *
 *  @param script 脚本
 */
-(void)cancelExecuteRelativeTimeScript:(Script *)script
{
    if ([scriptQueue containsObject:script]) {
        [scriptQueue removeObject:script];
        script.state =  ScriptIsNormal;
    }
    
    if (script != nil) {
        if ([script isEqual:currentPlayingScript]) {
            [self playOverRelativeTimeScript];
        }
    }
}

/**
 *  @author RenRenFenQi, 16-07-27 11:07:53
 *
 *  取消播放所有相对时间脚本
 */
-(void)cancelAllScripts
{
    if (scriptQueue && scriptQueue.count > 0) {
        [scriptQueue removeAllObjects];
    }
    [self playOverRelativeTimeScript];
}
/**
 *  @author RenRenFenQi, 16-06-16 16:06:00
 *
 *  解析一个相对时间脚本
 *
 *  @param script 相对时间脚本
 */
-(void)dowithRelativeTimeScript:(Script *)script
{
    if (script == nil) {
        return;
    }
    
    if (scriptCommandQueue) {
        [scriptCommandQueue removeAllObjects];
    }else{
        scriptCommandQueue = [NSMutableArray array];
    }
    
    if (script.scriptCommandList && script.scriptCommandList.count > 0) {
        [scriptCommandQueue addObjectsFromArray:script.scriptCommandList];
    }
}

/**
 *  @author RenRenFenQi, 16-06-16 16:06:52
 *
 *  开始执行一个脚本
 */
-(void)playRelativeTimeScript
{
    if (currentPlayingScript != nil) {
        return;
    }
    
    if (scriptQueue && scriptQueue.count > 0) {
        currentSecond = -1;
        if (timer) {
            if ([timer isValid]) {
                [timer invalidate];
                timer = nil;
            }
        }
        Script *script = [scriptQueue objectAtIndex:0];
        currentPlayingScript = script;
        [self dowithRelativeTimeScript:script];
        [scriptQueue removeObjectAtIndex:0];
        timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(countTime) userInfo:nil repeats:YES];
        [timer fire];
        currentPlayingScript.state = ScriptIsPlaying;
        [[NSNotificationCenter defaultCenter] postNotificationName:PlayScriptNotification object:currentPlayingScript];
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:PlayOverAllScriptsNotification object:nil];
    }
}

-(void)countTime
{
    currentSecond++;
    if (currentSecond > currentPlayingScript.scriptTime) {
        [self playOverRelativeTimeScript];
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:PlayProgressSecondNotification object:[NSNumber numberWithInteger:currentSecond]];
        if (currentPlayingScript.isLoop) {
            ScriptCommand *command = [scriptCommandQueue lastObject];
            if ((command.startRelativeTime + command.duration) < currentSecond) {
                NSInteger tempSecond = currentSecond % (command.startRelativeTime + command.duration);
                [self searchTimeToExecuteCommand:tempSecond];
            }else{
                [self searchTimeToExecuteCommand:currentSecond];
            }
        }else{
            [self searchTimeToExecuteCommand:currentSecond];
        }
    }
}

/**
 *  @author RenRenFenQi, 16-06-16 17:06:37
 *
 *  查找时间点，如有记录则执行对应指令
 */
-(void)searchTimeToExecuteCommand:(NSInteger)second
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.startRelativeTime == %ld",second];
    NSArray *filterArr = [scriptCommandQueue filteredArrayUsingPredicate:predicate];
    if (filterArr && filterArr.count > 0) {
        ScriptCommand *command = [filterArr objectAtIndex:0];
        NSString *commandstr = command.command;
        NSInteger duration = command.duration;
        if ((currentSecond + command.duration) > currentPlayingScript.scriptTime) {
            duration = currentPlayingScript.scriptTime - currentSecond;
        }
        
        if (duration > 0) {
            if (![AppUtils isNullStr:commandstr]) {
                if([commandstr hasPrefix:@"F5"]){
                    commandstr = [NSString stringWithFormat:@"F501%@%04lX55",command.rfId,(long)duration];
                }
            }
        }else{
            return;
        }
        //往蓝牙发送command
        if ([[BluetoothMacManager defaultManager] isConnected]) {
            if (![AppUtils isNullStr:commandstr]) {
                [[BluetoothMacManager defaultManager] writeCharacteristicWithCommandStr:commandstr];
            }
        }
        
        NSDictionary *dic = [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:duration] forKey:ActualTimeKey];
        //往UI通知当前执行的命令
        [[NSNotificationCenter defaultCenter] postNotificationName:SendScriptCommandNotification object:command userInfo:dic];
    }
}
/**
 *  @author RenRenFenQi, 16-06-16 16:06:25
 *
 *  结束执行一个脚本
 */
-(void)playOverRelativeTimeScript
{
    if (timer) {
        if ([timer isValid]) {
            [timer invalidate];
            timer = nil;
        }
    }
    
    if (currentPlayingScript) {
        currentPlayingScript.state = ScriptIsNormal;
        Script *script = currentPlayingScript;
        currentPlayingScript = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:PlayOverScriptNotification object:script];
        [self playRelativeTimeScript];
    }
}

/**
 *  @author RenRenFenQi, 16-09-02 10:09:40
 *
 *  回复计时
 */
-(void)resumeTimer
{
    if (timer) {
        if (![timer isValid]) {
            return;
        }
        [timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
    }
}

/**
 *  @author RenRenFenQi, 16-09-02 10:09:57
 *
 *  暂停计时
 */
-(void)pauseTimer
{
    if (timer) {
        if (![timer isValid]) {
            return;
        }
        [timer setFireDate:[NSDate distantFuture]];
    }
}

/**
 *  @author RenRenFenQi, 16-06-17 14:06:26
 *
 *  组成相对时间播放气味指令字符串
 *
 *  @param rfId     设备RFID
 *  @param duration 播放时长
 *
 *  @return 指令字符串
 */
-(NSString *)executeRelativeTimeCommand:(NSString *)rfId WithDuration:(NSInteger)duration
{
    NSMutableString *result = [[NSMutableString alloc] initWithString:@"F501"];
    [result appendFormat:@"%@%04lX55",rfId,(long)duration];
    return [NSString stringWithString:result];
}

-(NSString *)loopExecuteRelativeTimeCommand:(NSString *)rfId WithDuration:(NSInteger)duration WithInterval:(NSInteger)interval WithTimes:(NSInteger)times
{
    NSMutableString *result = [[NSMutableString alloc] initWithString:@"F401"];
    [result appendFormat:@"%@%04lX%04lX%02lX55",rfId,(long)duration,(long)interval,(long)times];
    return [NSString stringWithString:result];
}

/**
 *  @author RenRenFenQi, 16-06-17 13:06:27
 *
 *  将一个十六进制的数字(不包含0x)转成十进制
 *
 *  @param value 十六进制数字(以十进制形式表现)
 *
 *  @return 十六进制数字的十进制格式
 */
-(NSInteger)hexIntToInteger:(NSInteger)value
{
    NSInteger tempValue1 = (value / 10) * 16;
    NSInteger tempValue2 = value % 10;
    return tempValue1 + tempValue2;
}
@end
