//
//  ScriptCommand.h
//  DigitalSenseHD
//
//  Created by baolicheng on 16/8/12.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum {
    SpaceCommand = 1,
    VirtualCommand,
    RealCommand
}ScriptType;
@interface ScriptCommand : NSObject
@property(nonatomic) NSInteger startRelativeTime;
@property(nonatomic, copy) NSString *rfId;
@property(nonatomic, copy) NSString *smellName;
@property(nonatomic) NSInteger duration;
@property(nonatomic, copy) NSString *command;
@property(nonatomic, copy) NSString *desc;
@property(nonatomic, copy) NSString *color;

@property(nonatomic) ScriptType type;

@property(nonatomic) CGFloat power;
@end
