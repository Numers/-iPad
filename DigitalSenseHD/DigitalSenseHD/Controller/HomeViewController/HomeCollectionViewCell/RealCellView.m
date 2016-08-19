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

@interface RealCellView()
{
    UIImageView *circleImageView;
    UILabel *lblTime;
}
@end
@implementation RealCellView
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.layer setCornerRadius:30.0f];
        [self.layer setMasksToBounds:YES];
        circleImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PullBtn"]];
        [self addSubview:circleImageView];
        
        lblTime = [[UILabel alloc] init];
        [lblTime setTextColor:[UIColor whiteColor]];
        [lblTime setFont:[UIFont systemFontOfSize:13.0f]];
        [self addSubview:lblTime];
    }
    return self;
}

-(void)setScriptCommand:(ScriptCommand *)command
{
    if (command.type == RealCommand) {
        currentCommand = command;
        [lblTime setText:[NSString stringWithFormat:@"%lds",command.duration]];
        [lblTime sizeToFit];
        [self setBackgroundColor:[UIColor colorFromHexString:command.color]];
        [self setNeedsDisplay];
    }
}

-(void)setMaxHeight:(CGFloat)height WithMaxCenterY:(CGFloat)aCenterY WithMinCenterY:(CGFloat)iCenterY
{
    maxHeight = height;
    maxCenterY = aCenterY;
    minCenterY = iCenterY;
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
        
    }
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
}

-(void)drawRect:(CGRect)rect
{
    [circleImageView setCenter:CGPointMake(self.frame.size.width - circleImageView.frame.size.width / 2.0f - 5, self.frame.size.height / 2.0f)];
    [lblTime setCenter:CGPointMake(self.frame.size.width / 2.0f, self.frame.size.height / 2.0f)];
}
@end
