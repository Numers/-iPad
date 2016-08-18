//
//  SmellView.m
//  DigitalSenseHD
//
//  Created by baolicheng on 16/8/11.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import "SmellView.h"
#import "Smell.h"

@implementation SmellView
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
    if ([self.delegate respondsToSelector:@selector(longTouchWithTag:)]) {
        [self.delegate longTouchWithTag:self.tag];
    }
}

-(void)movedTouch:(UILongPressGestureRecognizer *)press
{
    CGPoint now = [press locationInView:self];
    CGPoint translation;
    translation.x = now.x - _prePoint.x;
    translation.y = now.y - _prePoint.y;
    if ([self.delegate respondsToSelector:@selector(panLocationChanged:)]) {
        [self.delegate panLocationChanged:translation];
    }
    _prePoint = now;
}

-(void)endedTouch:(UILongPressGestureRecognizer *)press
{
    _prePoint = [press locationInView:self];
    if ([self.delegate respondsToSelector:@selector(longTouchEnded)]) {
        [self.delegate longTouchEnded];
    }
}


-(void)setSmell:(Smell *)smell
{
    [self.smellImageView setImage:[UIImage imageNamed:smell.smellImage]];
    
    if (_longPress == nil) {
        _longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longTouch:)];
        [self addGestureRecognizer:_longPress];
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
