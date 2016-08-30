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
#import "LBorderView.h"

@interface RealCellView()<UICircleButtonProtocol>
{
    UILabel *lblTime;
    UICircleButton *btnCircle;
    LBorderView *dashRectView;
}
@end
@implementation RealCellView
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.layer setCornerRadius:30.0f];
        [self.layer setMasksToBounds:YES];
        
        dashRectView = [[LBorderView alloc] init];
        dashRectView.borderType = BorderTypeDashed;
        dashRectView.dashPattern = 4;
        dashRectView.spacePattern = 4;
        dashRectView.borderWidth = 1;
        dashRectView.borderColor = [UIColor whiteColor];
        [self addSubview:dashRectView];
        
        UIImage *pullImage = [UIImage imageNamed:@"PullBtnNormal"];
        btnCircle = [[UICircleButton alloc] initWithFrame:CGRectMake(0, 0, pullImage.size.width, pullImage.size.height)];
        [btnCircle setImage:pullImage forState:UIControlStateNormal];
        btnCircle.delegate = self;
        [self addSubview:btnCircle];
        
        lblTime = [[UILabel alloc] init];
        [lblTime setTextColor:[UIColor whiteColor]];
        [lblTime setFont:[UIFont systemFontOfSize:13.0f]];
        [self addSubview:lblTime];
    }
    return self;
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self.layer setCornerRadius:frame.size.height / 2.0f];
    [self.layer setMasksToBounds:YES];
    dashRectView.cornerRadius = (frame.size.height-4)/2.0f;
}


-(void)setScriptCommand:(ScriptCommand *)command isShowCircleButton:(BOOL)isShow
{
    currentCommand = command;
    if (command.type == RealCommand) {
        [lblTime setHidden:NO];
        [btnCircle setHidden:!isShow];
        [dashRectView setHidden:YES];
        [lblTime setText:[NSString stringWithFormat:@"%lds",command.duration]];
        [lblTime sizeToFit];
        [self setBackgroundColor:[UIColor colorFromHexString:command.color]];
        [self setNeedsDisplay];
    }else if(command.type == VirtualCommand){
        [lblTime setHidden:YES];
        [btnCircle setHidden:YES];
        [dashRectView setHidden:NO];
        [self setBackgroundColor:[UIColor clearColor]];
        [self setNeedsDisplay];
    }else if (command.type == SpaceCommand){
        [lblTime setHidden:YES];
        [btnCircle setHidden:YES];
        [dashRectView setHidden:YES];
        [self setBackgroundColor:[UIColor clearColor]];
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

-(void)beginTrack
{
    if ([_delegate respondsToSelector:@selector(beginTrackCell)]) {
        [_delegate beginTrackCell];
    }
}

-(void)endTrack
{
    if ([_delegate respondsToSelector:@selector(endTrackCell)]) {
        [_delegate endTrackCell];
    }
}

-(void)drawRect:(CGRect)rect
{
    [dashRectView setFrame:CGRectMake(2, 2, self.frame.size.width-4, self.frame.size.height-4)];
    [btnCircle setCenter:CGPointMake(self.frame.size.width - btnCircle.frame.size.width / 2.0f, self.frame.size.height / 2.0f)];
    [lblTime setCenter:CGPointMake(self.frame.size.width / 2.0f, self.frame.size.height / 2.0f)];
}
@end
