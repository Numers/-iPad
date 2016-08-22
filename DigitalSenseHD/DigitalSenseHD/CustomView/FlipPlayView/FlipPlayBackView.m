//
//  FlipPlayBackView.m
//  DigitalSenseHD
//
//  Created by baolicheng on 16/8/22.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import "FlipPlayBackView.h"
#import "GlobalVar.h"
#import "FlipPlayView.h"
#import "ScriptCommand.h"

@implementation FlipPlayBackView
-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
//    [self setMaskView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)]];
}

-(void)flipWithScriptCommand:(ScriptCommand *)command
{
    FlipPlayView *playView = [[FlipPlayView alloc] initWithFrame:CGRectMake(self.frame.size.width, self.frame.size.height * [AppUtils powerFixed:command.power] - 30.0f, WidthPerSecond * command.duration, 60.0f)];
    [playView setupWithScriptCommand:command];
    [self addSubview:playView];
    
    [UIView animateWithDuration:command.duration delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        [playView setFrame:CGRectMake(-playView.frame.size.width, playView.frame.origin.y, playView.frame.size.width, playView.frame.size.height)];
    } completion:^(BOOL finished) {
        [playView removeFromSuperview];
    }];
}
@end
