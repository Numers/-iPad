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

#import "UICircleButton.h"

@interface RealCellView()<UICircleButtonProtocol>
{
    UIImageView *circleImageView;
    UILabel *lblTime;
    UICircleButton *btnCircle;
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
        
        btnCircle = [[UICircleButton alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [btnCircle setBackgroundColor:[UIColor clearColor]];
        btnCircle.delegate = self;
        [self addSubview:btnCircle];
        
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

#pragma -mark UICircleButtonProtocol
-(void)moveLeftOneUnit
{
    if ([_delegate respondsToSelector:@selector(minusWidthWithSpaceCount:)]) {
        [_delegate minusWidthWithSpaceCount:1];
    }
}

-(void)moveRightOneUnit
{
    if ([_delegate respondsToSelector:@selector(addWidthWithSpaceCount:)]) {
        [_delegate addWidthWithSpaceCount:1];
    }
}

-(void)drawRect:(CGRect)rect
{
    [circleImageView setCenter:CGPointMake(self.frame.size.width - circleImageView.frame.size.width / 2.0f - 5, self.frame.size.height / 2.0f)];
    [btnCircle setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [lblTime setCenter:CGPointMake(self.frame.size.width / 2.0f, self.frame.size.height / 2.0f)];
}
@end
