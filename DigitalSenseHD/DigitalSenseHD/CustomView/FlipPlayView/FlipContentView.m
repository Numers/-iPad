//
//  FlipContentView.m
//  DigitalSenseHD
//
//  Created by baolicheng on 16/8/22.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import "FlipContentView.h"
#import "UIColor+HexString.h"
#import "ScriptCommand.h"
@interface FlipContentView()
{
    UILabel *lblTime;
    UIImageView *circleImageView;
}
@end
@implementation FlipContentView
-(instancetype)initWithFrame:(CGRect)frame
{
    self  = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
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

-(void)setupWithScriptCommand:(ScriptCommand *)command
{
    [lblTime setText:[NSString stringWithFormat:@"%lds",command.duration]];
    [lblTime sizeToFit];
    [self setBackgroundColor:[UIColor colorFromHexString:command.color]];
}

-(void)drawRect:(CGRect)rect
{
    [circleImageView setCenter:CGPointMake(self.frame.size.width - circleImageView.frame.size.width / 2.0f - 5, self.frame.size.height / 2.0f)];
    [lblTime setCenter:CGPointMake(self.frame.size.width / 2.0f, self.frame.size.height / 2.0f)];
}
@end
