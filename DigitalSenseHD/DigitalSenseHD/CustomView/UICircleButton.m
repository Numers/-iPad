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
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImage *pullHighlightImage = [UIImage imageNamed:@"PullBtnHighlight"];
        [self setImage:pullHighlightImage forState:UIControlStateHighlighted];
        
        UIImage *pullNormalImage = [UIImage imageNamed:@"PullBtnNormal"];
        [self setImage:pullNormalImage forState:UIControlStateNormal];
        
        [self addTarget:self action:@selector(touchDown) forControlEvents:UIControlEventTouchDown];
        if (_longPress == nil) {
            _longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longTouch:)];
            [_longPress setMinimumPressDuration:0.5];
            [self addGestureRecognizer:_longPress];
        }

    }
    return self;
}

-(void)touchDown
{
    [self setHighlighted:YES];
    if ([_delegate respondsToSelector:@selector(beginTrack)]) {
        [_delegate beginTrack];
    }
}
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
        NSInteger count = temp / (WidthPerSecond * 2 / 3);
        if (count > 0) {
            beginLocation = location;
            if ([_delegate respondsToSelector:@selector(moveRightOneUnit)]) {
                [_delegate moveRightOneUnit];
            }
        }
    }else{
        CGFloat temp = beginLocation.x - location.x;
        NSInteger count = temp / (WidthPerSecond * 2 / 3);
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
    [self setHighlighted:NO];
    if ([_delegate respondsToSelector:@selector(endTrack)]) {
        [_delegate endTrack];
    }
}

- (void)cancelTrackingWithEvent:(nullable UIEvent *)event
{
     NSLog(@"cancelTracking");
    [self setHighlighted:NO];
    if ([_delegate respondsToSelector:@selector(endTrack)]) {
        [_delegate endTrack];
    }
}

-(void)longTouch:(UILongPressGestureRecognizer *)longPress
{
    switch (longPress.state) {
        case UIGestureRecognizerStatePossible: {
            
            break;
        }
        case UIGestureRecognizerStateBegan: {
            [self beganTouch:longPress];
            break;
        }
        case UIGestureRecognizerStateChanged: {
            [self movedTouch:longPress];
            break;
        }
        case UIGestureRecognizerStateEnded: {
            [self endedTouch:longPress];
            break;
        }
        case UIGestureRecognizerStateCancelled: {
            
            break;
        }
        case UIGestureRecognizerStateFailed: {
            
            break;
        }
    }
}

-(void)beganTouch:(UILongPressGestureRecognizer *)press
{
    _prePoint = [press locationInView:self];
}

-(void)movedTouch:(UILongPressGestureRecognizer *)press
{
    CGPoint now = [press locationInView:self];
    if (now.x > _prePoint.x) {
        CGFloat temp = now.x - _prePoint.x;
        NSInteger count = temp / (WidthPerSecond * 2 / 3);
        if (count > 0) {
            _prePoint = now;
            if ([_delegate respondsToSelector:@selector(moveRightOneUnit)]) {
                [_delegate moveRightOneUnit];
            }
        }
    }else{
        CGFloat temp = _prePoint.x - now.x;
        NSInteger count = temp / (WidthPerSecond * 2 / 3);
        if (count > 0) {
            _prePoint = now;
            if ([_delegate respondsToSelector:@selector(moveLeftOneUnit)]) {
                [_delegate moveLeftOneUnit];
            }
        }
    }

}

-(void)endedTouch:(UILongPressGestureRecognizer *)press
{
    [self setHighlighted:NO];
    _prePoint = [press locationInView:self];
    if ([_delegate respondsToSelector:@selector(endTrack)]) {
        [_delegate endTrack];
    }
}

@end
