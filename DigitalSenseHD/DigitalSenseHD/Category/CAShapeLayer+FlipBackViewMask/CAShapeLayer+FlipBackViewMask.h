//
//  CAShapeLayer+FlipBackViewMask.h
//  DigitalSenseHD
//
//  Created by baolicheng on 16/8/22.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CAShapeLayer (FlipBackViewMask)
+(instancetype)createMaskLayerWithView:(UIView *)view Padding:(UIEdgeInsets)edgeInsets;
@end
