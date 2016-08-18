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
#import "GlobalVar.h"

@implementation RealCellView
-(void)setScriptCommand:(ScriptCommand *)command
{
    if (command.type == RealCommand) {
        currentCommand = command;
        self.center = CGPointMake(self.center.x, maxHeight * [self powerFixed:command.power]);
        [self setBackgroundColor:[UIColor colorFromHexString:command.color]];
    }
}

-(void)setMaxHeight:(CGFloat)height WithMaxCenterY:(CGFloat)aCenterY WithMinCenterY:(CGFloat)iCenterY
{
    maxHeight = height;
    maxCenterY = aCenterY;
    minCenterY = iCenterY;
}

-(CGFloat)powerFixed:(CGFloat)power
{
    return 0.5;
}
#pragma -mark TouchEvent
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint previoisPoint = [touch previousLocationInView:self];
    CGPoint currentPoint = [touch locationInView:self];
    
    CGFloat vectorDy = previoisPoint.y - currentPoint.y;
    CGFloat vectorDx = previoisPoint.x - currentPoint.x;

    if (fabs(vectorDx) > fabs(vectorDy)) {
        NSInteger temp = fabs(vectorDx) / WidthPerSecond;
        if (vectorDx > 0) {
            if ([_delegate respondsToSelector:@selector(minusWidthWithSpaceCount:)]) {
                [_delegate minusWidthWithSpaceCount:temp];
            }
        }else{
            if ([_delegate respondsToSelector:@selector(addWidthWithSpaceCount:)]) {
                [_delegate addWidthWithSpaceCount:temp];
            }
        }
        
    }else{
        CGFloat centerY = self.center.y - vectorDy;
        if (centerY < minCenterY || centerY > maxCenterY) {
            return;
        }else{
            self.center = CGPointMake(self.center.x, centerY);
            currentCommand.power = centerY / maxHeight;
        }
    }
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CGFloat fixedPower = [self powerFixed:currentCommand.power];
    CGFloat centerY = maxHeight * fixedPower;
    currentCommand.power = fixedPower;
    self.center = CGPointMake(self.center.x, centerY);
}
@end
