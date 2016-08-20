//
//  RelativeTimeScript.m
//  DigitalSense
//
//  Created by baolicheng on 16/6/17.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import "RelativeTimeScript.h"

@implementation RelativeTimeScript
-(NSString *)commandString
{
    NSMutableString *result = [[NSMutableString alloc] init];
    [result appendFormat:@"脚本任务:%@\n",self.scriptName];
    if (self.isLoop) {
        [result appendFormat:@"播放方式:循环播放\n"];
        if (self.scriptCommandList && self.scriptCommandList.count > 0){
            NSInteger i = 0, j = 1;
            while (i >= 0) {
                ScriptCommand *lastCommand = [self.scriptCommandList lastObject];
                NSInteger baseTime = i * (lastCommand.startRelativeTime + lastCommand.duration);
                for (ScriptCommand *command in self.scriptCommandList) {
                    NSInteger startTime = baseTime + command.startRelativeTime;
                    NSInteger duration = command.duration;
                    if ((startTime + duration) >= self.scriptTime) {
                        duration = self.scriptTime - startTime;
                        i = -2;
                    }
                    
                    if (duration > 0) {
                        NSString *str = [NSString stringWithFormat:@"播放气味%ld: 【%@,%@】播放，持续%ld秒\n",(long)j,[AppUtils switchSecondsToTime:startTime],command.smellName,(long)duration];
                        [result appendString:str];
                        
                        j++;
                    }
                    
                    if (i == -2) {
                        break;
                    }
                }
                i++;
            }
        }
    }else{
        [result appendFormat:@"播放方式:单次播放\n"];
        if (self.scriptCommandList && self.scriptCommandList.count > 0) {
            NSInteger i = 1;
            for (ScriptCommand *command in self.scriptCommandList) {
                NSInteger duration = command.duration;
                if ((command.startRelativeTime + command.duration) >= self.scriptTime) {
                    duration = self.scriptTime - command.startRelativeTime;
                }
                
                if (duration > 0) {
                    NSString *str = [NSString stringWithFormat:@"播放气味%ld: 【%@,%@】播放，持续%ld秒\n",(long)i,[AppUtils switchSecondsToTime:command.startRelativeTime],command.smellName,(long)command.duration];
                    [result appendString:str];
                    i++;
                }
            }
        }

    }
    return result;
}
@end
