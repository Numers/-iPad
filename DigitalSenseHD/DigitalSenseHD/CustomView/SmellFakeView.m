//
//  SmellFakeView.m
//  DigitalSenseHD
//
//  Created by baolicheng on 16/8/11.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import "SmellFakeView.h"

@implementation SmellFakeView
-(instancetype)initWithView:(UIView *)view
{
    self = [super initWithFrame:view.frame];
    if (self) {
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0, 0);
        self.layer.shadowOpacity = 0;
        self.layer.shadowRadius = 5.0;
        self.layer.shouldRasterize = false;
        
        self.originalFrame = view.frame;
        
        self.fakeImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.fakeImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.fakeImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self.fakeImageView setImage:[self getViewImage:view]];
        [self addSubview:self.fakeImageView];
    }
    return self;
}

- (void)pushFowardView{
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.center = self.originalCenter;
        self.toBackViewCenter = self.originalCenter;
        self.transform = CGAffineTransformMakeScale(1.1, 1.1);
    
        CABasicAnimation *shadowAnimation = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
        shadowAnimation.fromValue = @(0);
        shadowAnimation.toValue = @(0.7);
        shadowAnimation.removedOnCompletion = NO;
        shadowAnimation.fillMode = kCAFillModeForwards;
        [self.layer addAnimation:shadowAnimation forKey:@"applyShadow"];
    } completion:^(BOOL finished) {

    }];
}

- (void)pushBackView:(void(^)(BOOL isFinished))completion{
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.transform = CGAffineTransformIdentity;
        self.frame = self.originalFrame;
        self.center = self.toBackViewCenter;
        CABasicAnimation *shadowAnimation = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
        shadowAnimation.fromValue = @(0.7);
        shadowAnimation.toValue = @(0);
        shadowAnimation.removedOnCompletion = NO;
        shadowAnimation.fillMode = kCAFillModeForwards;
        [self.layer addAnimation:shadowAnimation forKey:@"removeShadow"];
    } completion:^(BOOL finished) {
        if (completion) {
            completion(finished);
        }
    }];
}


- (UIImage *)getViewImage:(UIView *)view{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, [UIScreen mainScreen].scale * 2);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

-(void)removeFromSuperview
{
    [super removeFromSuperview];
    if (self.fakeImageView) {
        [self.fakeImageView removeFromSuperview];
    }
}
@end
