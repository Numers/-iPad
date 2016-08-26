//
//  FlipReadyView.h
//  DigitalSenseHD
//
//  Created by baolicheng on 16/8/26.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FlipReadyView : UIView
-(void)showInView:(UIView *)view completion:(void (^)(BOOL isFinished))completion;
-(void)hidden:(void (^)(BOOL isFinished))completion;
@end
