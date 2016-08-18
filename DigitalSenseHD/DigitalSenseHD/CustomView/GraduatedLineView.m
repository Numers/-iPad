//
//  GraduatedLineView.m
//  DigitalSenseHD
//
//  Created by baolicheng on 16/8/13.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import "GraduatedLineView.h"
#import "GlobalVar.h"
#define GraduatedLineColor [UIColor colorWithRed:0.984 green:0.969 blue:0.361 alpha:1.000]
@implementation GraduatedLineView
-(instancetype)init
{
    self = [super initWithFrame:CGRectMake(-10, 0, WidthPerSecond * 60 + 20, 30)];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    
//    CGContextSetStrokeColorWithColor(context, GraduatedLineColor.CGColor);
//    
//    CGContextSetRGBFillColor (context,  0, 0, 255, 1.0);//设置填充颜色
//    
//    CGContextSetLineWidth(context, 2);
//    
//    CGContextMoveToPoint(context, 10, self.frame.size.height - 20);
//    
//    CGContextAddLineToPoint(context, self.frame.size.width, self.frame.size.height - 20);
//    
//    CGContextStrokePath(context);
    UIFont *font = [UIFont fontWithName:@"Wawati SC" size:13.0f];
    for (NSInteger i = 0; i <= 60; i++) {
//        CGContextMoveToPoint(context, i * WidthPerSecond + 10, self.frame.size.height - 20);
//        CGContextAddLineToPoint(context, i * WidthPerSecond + 10, self.frame.size.height - 25);
//        CGContextStrokePath(context);
        //fontName:DFPHaiBaoW12   DFWaWaSC-W5  ||  familyName:Wawati SC     DFPHaiBaoW12-GB
        NSString *str = [NSString stringWithFormat:@"%lds",(long)i];
        if (i == 0) {
            str = @"0";
        }
        CGRect rect = [str boundingRectWithSize:CGSizeMake(100, 15) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font,NSForegroundColorAttributeName:GraduatedLineColor} context:nil];
//        [str drawInRect:CGRectMake(i * WidthPerSecond + 10 - rect.size.width / 2.0f, self.frame.size.height - 15, rect.size.width, rect.size.height) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13.0f],NSForegroundColorAttributeName:GraduatedLineColor}];
                [str drawInRect:CGRectMake(i * WidthPerSecond + 10 - rect.size.width / 2.0f, 10, rect.size.width, rect.size.height) withAttributes:@{NSFontAttributeName:font,NSForegroundColorAttributeName:GraduatedLineColor}];
    }
}
@end
