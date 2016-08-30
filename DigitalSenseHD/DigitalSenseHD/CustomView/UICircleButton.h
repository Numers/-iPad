//
//  UICircleButton.h
//  DigitalSenseHD
//
//  Created by baolicheng on 16/8/20.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol UICircleButtonProtocol <NSObject>
-(void)beginTrack;
-(void)endTrack;
-(void)moveLeftOneUnit;
-(void)moveRightOneUnit;
@end
@interface UICircleButton : UIButton
{
    CGPoint beginLocation;
    CGPoint movedLocation;
    
    UILongPressGestureRecognizer *_longPress;
    CGPoint _prePoint;
}
@property(nonatomic, assign) id<UICircleButtonProtocol> delegate;
@end
