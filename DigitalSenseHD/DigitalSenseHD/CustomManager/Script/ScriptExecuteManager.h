//
//  ScriptExecuteManager.h
//  DigitalSense
//
//  Created by baolicheng on 16/6/16.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import <Foundation/Foundation.h>
#define PlayScriptNotification @"PlayScriptNotification"
#define PlayOverScriptNotification @"PlayOverScriptNotification"
#define PlayOverAllScriptsNotification @"PlayOverAllScriptsNotification"
#define SendScriptCommandNotification @"SendScriptCommandNotification"
#define PlayProgressSecondNotification @"PlayProgressSecondNotification"

#define ActualTimeKey @"ActualTime"
@class Script;
@interface ScriptExecuteManager : NSObject
{
    NSMutableArray *scriptQueue; //相对时间脚本队列
    NSMutableArray *scriptCommandQueue;  //指令队列
    
    Script *currentPlayingScript; //当前播放的脚本
    NSTimer *timer; //计时器
}
+(id)defaultManager;
/**
 *  @author RenRenFenQi, 16-06-16 16:06:34
 *
 *  执行相对时间脚本
 *
 *  @param script 脚本
 */
-(void)executeRelativeTimeScript:(Script *)script;

/**
 *  @author RenRenFenQi, 16-06-17 10:06:43
 *
 *  取消排队中的相对时间脚本
 *
 *  @param script 脚本
 */
-(void)cancelExecuteRelativeTimeScript:(Script *)script;

/**
 *  @author RenRenFenQi, 16-07-27 11:07:53
 *
 *  取消播放所有相对时间脚本
 */
-(void)cancelAllScripts;
@end
