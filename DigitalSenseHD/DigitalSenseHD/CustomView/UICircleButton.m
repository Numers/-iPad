//
//  UICircleButton.m
//  DigitalSenseHD
//
//  Created by baolicheng on 16/8/20.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import "UICircleButton.h"
#import "GlobalVar.h"

@implementation UICircleButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(nullable UIEvent *)event
{
    NSLog(@"beginTracking");
    beginLocation = [touch locationInView:self];
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(nullable UIEvent *)event
{
    CGPoint location = [touch locationInView:self];
    if (location.x > beginLocation.x) {
        CGFloat temp = location.x - beginLocation.x;
        NSInteger count = temp / WidthPerSecond;
        if (count > 0) {
            beginLocation = location;
            if ([_delegate respondsToSelector:@selector(moveRightOneUnit)]) {
                [_delegate moveRightOneUnit];
            }
        }
    }else{
        CGFloat temp = beginLocation.x - location.x;
        NSInteger count = temp / WidthPerSecond;
        if (count > 0) {
            beginLocation = location;
            if ([_delegate respondsToSelector:@selector(moveLeftOneUnit)]) {
                [_delegate moveLeftOneUnit];
            }
        }
    }
    
    return YES;
}

- (void)endTrackingWithTouch:(nullable UITouch *)touch withEvent:(nullable UIEvent *)event
{
    NSLog(@"endTracking");
}

- (void)cancelTrackingWithEvent:(nullable UIEvent *)event
{
     NSLog(@"cancelTracking");
}
@end
