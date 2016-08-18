//
//  VirtualHomeCollectionViewCell.m
//  DigitalSenseHD
//
//  Created by baolicheng on 16/8/12.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import "VirtualHomeCollectionViewCell.h"

@implementation VirtualHomeCollectionViewCell

-(void)setupWithScriptCommand:(ScriptCommand *)command
{
    [super setupWithScriptCommand:command];
    [self setBackgroundColor:[UIColor clearColor]];
}

-(void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    
    CGContextSetLineWidth(context, 1);
    
    CGFloat lengths[2] = {5,5};
    
    CGContextSetLineDash(context, 0, lengths, 2);
    
    CGContextMoveToPoint(context, 0, 0);
    
    CGContextAddLineToPoint(context, 0, self.frame.size.height);
    
    CGContextMoveToPoint(context, self.frame.size.width - 0.5, 0);
    
    CGContextAddLineToPoint(context, self.frame.size.width - 0.5, self.frame.size.height);
    
    CGContextStrokePath(context);
}

@end
