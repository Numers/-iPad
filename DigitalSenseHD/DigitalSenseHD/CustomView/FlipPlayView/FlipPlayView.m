//
//  FlipPlayView.m
//  DigitalSenseHD
//
//  Created by baolicheng on 16/8/22.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import "FlipPlayView.h"
#import "FlipContentView.h"
#import "ScriptCommand.h"

#define FlipContentViewLeftMargin 10.0f
@interface FlipPlayView()
{
    UIImageView *smellIconImageView;
    FlipContentView *flipContentView;
}
@end
@implementation FlipPlayView
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        flipContentView = [[FlipContentView alloc] initWithFrame:CGRectMake(FlipContentViewLeftMargin, 0, frame.size.width - FlipContentViewLeftMargin, frame.size.height)];
        [self addSubview:flipContentView];
        
        CGFloat width = frame.size.width > frame.size.height ? frame.size.height : frame.size.width;
        smellIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, width)];
        [self addSubview:smellIconImageView];
    }
    return self;
}

-(void)setupWithScriptCommand:(ScriptCommand *)command
{
    if (smellIconImageView) {
        UIImage *smellImage = [UIImage imageNamed:[command.smellImage stringByReplacingOccurrencesOfString:@"Image" withString:@"IconImage"]];
        [smellIconImageView setImage:smellImage];
    }
    
    if (flipContentView) {
        [flipContentView setupWithScriptCommand:command];
    }
}
@end
