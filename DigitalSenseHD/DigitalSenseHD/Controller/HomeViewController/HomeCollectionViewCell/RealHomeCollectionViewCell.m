//
//  RealHomeCollectionViewCell.m
//  DigitalSenseHD
//
//  Created by baolicheng on 16/8/12.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import "RealHomeCollectionViewCell.h"
#import "RealCellView.h"

@implementation RealHomeCollectionViewCell
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _realCellView = [[RealCellView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 60)];
        [self addSubview:_realCellView];
    }
    return self;
}

-(void)setupWithScriptCommand:(ScriptCommand *)command
{
    [super setupWithScriptCommand:command];
    [self setBackgroundColor:[UIColor grayColor]];
    [_realCellView setScriptCommand:command];
}
@end
