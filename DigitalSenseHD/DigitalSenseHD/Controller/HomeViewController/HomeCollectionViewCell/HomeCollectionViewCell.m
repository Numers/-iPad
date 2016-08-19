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

#define RealCellHeight 60.0f
#define RealCellLeftMargin 10.0f
@interface HomeCollectionViewCell()<RealCellViewProtocol,UIGestureRecognizerDelegate>
{
    RealCellView *realCellView;
    UIImageView *smellIconImageView;
    
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
        
//        [self sendSubviewToBack:realCellView];
        
        [realCellView setHidden:YES];
        [smellIconImageView setHidden:YES];
    }
    return self;
}

-(void)inilizedView
{
    currentCommand = nil;
    [realCellView setHidden:YES];
    [smellIconImageView setHidden:YES];
}

-(void)setupWithScriptCommand:(ScriptCommand *)command
{
    currentCommand = command;
    currentCommand.power = [AppUtils powerFixed:command.power];
    if (command.type == SpaceCommand) {
        [realCellView setHidden:YES];
        [smellIconImageView setHidden:YES];
    }else if (command.type == VirtualCommand){
        [realCellView setHidden:YES];
        [smellIconImageView setHidden:NO];
        UIImage *smellImage = [UIImage imageNamed:[command.smellImage stringByReplacingOccurrencesOfString:@"Image" withString:@"IconImage"]];
        [smellIconImageView setImage:smellImage];
        [smellIconImageView setFrame:CGRectMake(0, 0, smellImage.size.width, smellImage.size.height)];
        [smellIconImageView setImage:smellImage];
        [smellIconImageView setCenter:CGPointMake(smellIconImageView.frame.size.width / 2.0f, self.frame.size.height * currentCommand.power)];
    }else if (command.type == RealCommand){
        [realCellView setHidden:NO];
        [smellIconImageView setHidden:NO];
        UIImage *smellImage = [UIImage imageNamed:[command.smellImage stringByReplacingOccurrencesOfString:@"Image" withString:@"IconImage"]];
        [smellIconImageView setImage:smellImage];
        [smellIconImageView setFrame:CGRectMake(0, 0, smellImage.size.width, smellImage.size.height)];
        [realCellView setScriptCommand:command];
        [self setNeedsDisplay];
    }
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
}

#pragma -mark RealCellViewProtocol
-(void)addWidthWithSpaceCount:(NSInteger)spaceCount
{
    
}

-(void)minusWidthWithSpaceCount:(NSInteger)spaceCount
{
    
}

-(void)drawRect:(CGRect)rect
{
    if (currentCommand && currentCommand.type == RealCommand) {
        [smellIconImageView setCenter:CGPointMake(smellIconImageView.frame.size.width / 2.0f, self.frame.size.height * currentCommand.power)];
        [realCellView setFrame:CGRectMake(RealCellLeftMargin, self.frame.size.height * currentCommand.power - RealCellHeight / 2.0f, self.frame.size.width - RealCellLeftMargin, RealCellHeight)];
    }
}
@end
