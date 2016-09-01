//
//  GraduatedLineView.m
//  DigitalSenseHD
//
//  Created by baolicheng on 16/8/13.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import "GraduatedLineView.h"
#import "GlobalVar.h"
#define Padding 10.5f
#define GraduatedLineColor [UIColor colorWithRed:0.518 green:0.396 blue:0.196 alpha:1.000]
#define FontColor [UIColor colorWithRed:0.984 green:0.969 blue:0.361 alpha:1.000]
@implementation GraduatedLineView
-(instancetype)init
{
    self = [super initWithFrame:CGRectMake(-Padding, 0, WidthPerSecond * 60 + 2 * Padding, 75)];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(context, GraduatedLineColor.CGColor);
    
    CGContextSetRGBFillColor (context,  0, 0, 255, 1.0);//设置填充颜色
    
    CGContextSetLineWidth(context, 2);
    
//    CGContextMoveToPoint(context, Padding, 50);
//    
//    CGContextAddLineToPoint(context, self.frame.size.width, 50);
//    
//    CGContextStrokePath(context);
    UIFont *font = [UIFont fontWithName:@"Wawati SC" size:13.0f];
    for (NSInteger i = 0; i <= 60; i++) {
        CGContextSetStrokeColorWithColor(context, GraduatedLineColor.CGColor);
        CGContextMoveToPoint(context, i * WidthPerSecond + Padding, 0);
        CGContextAddLineToPoint(context, i * WidthPerSecond + Padding, 48);
        CGContextStrokePath(context);
        //fontName:DFPHaiBaoW12   DFWaWaSC-W5  ||  familyName:Wawati SC     DFPHaiBaoW12-GB
        NSString *str = [NSString stringWithFormat:@"%lds",(long)i];
        if (i == 0) {
            str = @"0";
        }
        CGRect rectSize = [str boundingRectWithSize:CGSizeMake(100, 15) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font,NSForegroundColorAttributeName:GraduatedLineColor} context:nil];
                [str drawInRect:CGRectMake(i * WidthPerSecond + Padding - rectSize.size.width / 2.0f, 56, rectSize.size.width, rectSize.size.height) withAttributes:@{NSFontAttributeName:font,NSForegroundColorAttributeName:FontColor}];
    }
}
@end
