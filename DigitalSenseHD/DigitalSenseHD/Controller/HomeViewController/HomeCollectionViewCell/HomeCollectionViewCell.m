//
//  HomeCollectionViewCell.m
//  DigitalSenseHD
//
//  Created by baolicheng on 16/8/12.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import "HomeCollectionViewCell.h"
#import "RealCellView.h"
#import "ScriptCommand.h"

#import "GlobalVar.h"

#define RealCellHeight 60.0f
#define RealCellLeftMargin 10.0f
@interface HomeCollectionViewCell()<RealCellViewProtocol,UIGestureRecognizerDelegate>
{
    RealCellView *realCellView;
    UIImageView *smellIconImageView;
    UIImageView *dashImageView;
    
    ScriptCommand *currentCommand;
}
@end
@implementation HomeCollectionViewCell
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        realCellView = [[RealCellView alloc] initWithFrame:CGRectMake(RealCellLeftMargin, 0, frame.size.width - RealCellLeftMargin, RealCellHeight)];
        [realCellView setMaxHeight:frame.size.height WithMaxCenterY:frame.size.height * 0.8 WithMinCenterY:frame.size.height * 0.2];
        realCellView.delegate = self;
        [self addSubview:realCellView];
        smellIconImageView = [[UIImageView alloc] init];
        [self addSubview:smellIconImageView];
        
        dashImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"DashLineImage"]];
        [self addSubview:dashImageView];
        
//        [self sendSubviewToBack:realCellView];
        
        [self inilizedView];
    }
    return self;
}

-(void)inilizedView
{
    currentCommand = nil;
    [realCellView setHidden:YES];
    [smellIconImageView setHidden:YES];
    [dashImageView setHidden:YES];
}

-(void)setupWithScriptCommand:(ScriptCommand *)command isShowCircleButton:(BOOL)isShow
{
    currentCommand = command;
    currentCommand.power = [AppUtils powerFixed:command.power];
    if (command.type == SpaceCommand) {
        [realCellView setHidden:YES];
        [smellIconImageView setHidden:YES];
        [dashImageView setHidden:YES];
    }else if (command.type == VirtualCommand){
        [realCellView setHidden:NO];
        [smellIconImageView setHidden:YES];
        [dashImageView setHidden:NO];
        [realCellView setScriptCommand:command isShowCircleButton:isShow];
        [self setNeedsDisplay];
    }else if (command.type == RealCommand){
        [realCellView setHidden:NO];
        [smellIconImageView setHidden:NO];
        [dashImageView setHidden:YES];
        UIImage *smellImage = [UIImage imageNamed:[command.smellImage stringByReplacingOccurrencesOfString:@"Image" withString:@"IconImage"]];
        [smellIconImageView setImage:smellImage];
        [smellIconImageView setFrame:CGRectMake(0, 0, smellImage.size.width, smellImage.size.height)];
        [realCellView setScriptCommand:command isShowCircleButton:isShow];
        [self setNeedsDisplay];
    }
}

#pragma -mark RealCellViewProtocol
-(void)addWidthWithSpaceCount:(NSInteger)spaceCount
{
    NSLog(@"add width");
    if (currentCommand && currentCommand.type == RealCommand) {
        if ([_delegate respondsToSelector:@selector(willAddWidthWithCommand:)]) {
            [_delegate willAddWidthWithCommand:currentCommand];
        }
    }
}

-(void)minusWidthWithSpaceCount:(NSInteger)spaceCount
{
    NSLog(@"minus width");
    if (currentCommand && currentCommand.type == RealCommand) {
        if ([_delegate respondsToSelector:@selector(willMinusWidthWithCommand:)]) {
            [_delegate willMinusWidthWithCommand:currentCommand];
        }
    }
}

-(void)beginTrackCell
{
    if ([_delegate respondsToSelector:@selector(willDisableScrollView)]) {
        [_delegate willDisableScrollView];
    }
}

-(void)endTrackCell
{
    if ([_delegate respondsToSelector:@selector(willEnableScrollView)]) {
        [_delegate willEnableScrollView];
    }
}

-(void)drawRect:(CGRect)rect
{
    if (currentCommand) {
        [smellIconImageView setCenter:CGPointMake(smellIconImageView.frame.size.width / 2.0f + 1, self.frame.size.height * currentCommand.power)];
        [realCellView setFrame:CGRectMake(RealCellLeftMargin, self.frame.size.height * currentCommand.power - RealCellHeight / 2.0f, self.frame.size.width - RealCellLeftMargin, RealCellHeight)];
    }
    [dashImageView setFrame:CGRectMake(0, 0, 1, self.frame.size.height)];
}
@end
