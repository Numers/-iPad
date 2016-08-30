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
        self.layer.shadowOffset = CGSizeMake(0, 0);
        self.layer.shadowOpacity = 0;
        self.layer.shadowColor = [UIColor yellowColor].CGColor;
        self.layer.shadowRadius = 5.0;
        self.layer.shouldRasterize = false;
        
        self.fakeImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.fakeImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.fakeImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self.fakeImageView setImage:[self getViewImage:view]];
        [self addSubview:self.fakeImageView];
    }
    return self;
}

- (void)pushFowardViewWithScale:(CGFloat)scale completion:(void(^)(BOOL isFinished))completion{
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.center = self.originalCenter;
        self.toBackViewCenter = self.originalCenter;
        self.transform = CGAffineTransformMakeScale(scale, scale);
    
        CABasicAnimation *shadowAnimation = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
        shadowAnimation.fromValue = @(0);
        shadowAnimation.toValue = @(0.7);
        shadowAnimation.removedOnCompletion = NO;
        shadowAnimation.fillMode = kCAFillModeForwards;
        [self.layer addAnimation:shadowAnimation forKey:@"applyShadow"];
    } completion:^(BOOL finished) {
        if (completion) {
            completion(finished);
        }
    }];
}

- (void)pushBackView:(void(^)(BOOL isFinished))completion{
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.transform = CGAffineTransformIdentity;
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

-(void)hiddenView:(void (^)(BOOL isFinished))completion
{
    [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.transform = CGAffineTransformMakeScale(0.01, 1.0);
    } completion:^(BOOL finished) {
        completion(finished);
    }];
}

-(void)startEarthQuake
{
    earthquakeRepeat = YES;
    //创建动画
    CAKeyframeAnimation * keyAnimaion = [CAKeyframeAnimation animation];
    keyAnimaion.keyPath = @"transform.rotation";
    keyAnimaion.values = @[@(-2 / 180.0 * M_PI),@(2 /180.0 * M_PI),@(-2/ 180.0 * M_PI)];//度数转弧度
    keyAnimaion.delegate = self;
    
    keyAnimaion.removedOnCompletion = NO;
    keyAnimaion.fillMode = kCAFillModeForwards;
    keyAnimaion.duration = 0.15;
    keyAnimaion.repeatCount = MAXFLOAT;
    [self.layer addAnimation:keyAnimaion forKey:@"earthquake"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (earthquakeRepeat) {
        [self startEarthQuake];
    }
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
    earthquakeRepeat = NO;
    [self.layer removeAnimationForKey:@"earthquake"];
    if (self.fakeImageView) {
        [self.fakeImageView removeFromSuperview];
    }
}
@end
