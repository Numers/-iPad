//
//  RealCellView.m
//  DigitalSenseHD
//
//  Created by baolicheng on 16/8/12.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import "RealCellView.h"
#import "ScriptCommand.h"
#import "UIColor+HexString.h"

@implementation RealCellView
-(void)setScriptCommand:(ScriptCommand *)command
{
    if (command.type == RealCommand) {
        [self setBackgroundColor:[UIColor colorFromHexString:command.color]];
    }
}
@end
