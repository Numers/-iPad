//
//  SmellView.h
//  DigitalSenseHD
//
//  Created by baolicheng on 16/8/11.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Smell;
@protocol SmellViewProtocol <NSObject>
-(void)longTouchWithTag:(NSInteger)tag;
-(void)longTouchEnded;

-(void)panLocationChanged:(CGPoint)translation;
-(void)panEnded;
@end
@interface SmellView : UIView
{
    UILongPressGestureRecognizer *_longPress;
    CGPoint _prePoint;
}
@property (nonatomic, strong) IBOutlet UIImageView *smellImageView;
@property (nonatomic, strong) IBOutlet UILabel *lblSmellName;
@property(nonatomic, assign)  id<SmellViewProtocol> delegate;

-(void)setSmell:(Smell *)smell;
@end
