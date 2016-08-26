//
//  FlipReadyView.m
//  DigitalSenseHD
//
//  Created by baolicheng on 16/8/26.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import "FlipReadyView.h"
@interface FlipReadyView()
{
    UIImageView *textImageView;
}
@end
@implementation FlipReadyView
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor colorWithWhite:0.000 alpha:0.600]];
        textImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ReadyGoImage"]];
        textImageView.center = CGPointMake(frame.size.width / 2.0f, frame.size.height / 2.0f);
        [self addSubview:textImageView];
    }
    return self;
}

-(void)showInView:(UIView *)view completion:(void (^)(BOOL isFinished))completion
{
    [view addSubview:self];
    [view setCenter:CGPointMake(view.frame.size.width / 2.0f, view.frame.size.height / 2.0f)];
    completion(YES);
}

-(void)hidden:(void (^)(BOOL isFinished))completion
{
    [self setHidden:YES];
    [self removeFromSuperview];
    completion(YES);
}
@end
