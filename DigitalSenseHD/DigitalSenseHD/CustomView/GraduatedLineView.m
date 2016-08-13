//
//  GraduatedLineView.m
//  DigitalSenseHD
//
//  Created by baolicheng on 16/8/13.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import "GraduatedLineView.h"
#define GraduatedLineColor [UIColor blueColor]
#define LineIntervalPerSecond 40.0f
@implementation GraduatedLineView
-(instancetype)init
{
    self = [super initWithFrame:CGRectMake(0, 0, LineIntervalPerSecond * 60 + 30, 50)];
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
    
    CGContextMoveToPoint(context, 15, self.frame.size.height - 20);
    
    CGContextAddLineToPoint(context, self.frame.size.width - 15, self.frame.size.height - 20);
    
    CGContextStrokePath(context);
    
    for (NSInteger i = 0; i <= 60; i++) {
        CGContextMoveToPoint(context, i * LineIntervalPerSecond + 15, self.frame.size.height - 20);
        CGContextAddLineToPoint(context, i * LineIntervalPerSecond + 15, self.frame.size.height - 25);
        CGContextStrokePath(context);
        
        NSString *str = [NSString stringWithFormat:@"%ld",(long)i];
        CGRect rect = [str boundingRectWithSize:CGSizeMake(100, 15) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13.0f],NSForegroundColorAttributeName:GraduatedLineColor} context:nil];
        [str drawInRect:CGRectMake(i * LineIntervalPerSecond + 15 - rect.size.width / 2.0f, self.frame.size.height - 15, rect.size.width, rect.size.height) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13.0f],NSForegroundColorAttributeName:GraduatedLineColor}];
    }
}
@end
