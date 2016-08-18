//
//  RealHomeCollectionViewCell.m
//  DigitalSenseHD
//
//  Created by baolicheng on 16/8/12.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import "RealHomeCollectionViewCell.h"
#import "RealCellView.h"
@interface RealHomeCollectionViewCell()<RealCellViewProtocol>
@end
@implementation RealHomeCollectionViewCell
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _realCellView = [[RealCellView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 60)];
        [_realCellView setMaxHeight:frame.size.height WithMaxCenterY:frame.size.height * 0.8 WithMinCenterY:frame.size.height * 0.2];
        _realCellView.delegate = self;
        [self addSubview:_realCellView];
    }
    return self;
}

-(void)setupWithScriptCommand:(ScriptCommand *)command
{
    [super setupWithScriptCommand:command];
    [self setBackgroundColor:[UIColor clearColor]];
    [_realCellView setScriptCommand:command];
}

#pragma -mark RealCellViewProtocol
-(void)addWidthWithSpaceCount:(NSInteger)spaceCount
{
    
}

-(void)minusWidthWithSpaceCount:(NSInteger)spaceCount
{
    
}
@end
