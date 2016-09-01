//
//  CAShapeLayer+FlipBackViewMask.m
//  DigitalSenseHD
//
//  Created by baolicheng on 16/8/22.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import "CAShapeLayer+FlipBackViewMask.h"

@implementation CAShapeLayer (FlipBackViewMask)
+(instancetype)createMaskLayerWithView:(UIView *)view Padding:(UIEdgeInsets)edgeInsets
{
    CGFloat viewWidth = CGRectGetWidth(view.frame);
    CGFloat viewHeight = CGRectGetHeight(view.frame);
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(edgeInsets.left, edgeInsets.top, viewWidth - edgeInsets.left - edgeInsets.right, viewHeight-edgeInsets.top - edgeInsets.bottom)];
    static CAShapeLayer *layer;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        layer = [CAShapeLayer layer];
        layer.path = path.CGPath;
    });
    return layer;
}
@end
