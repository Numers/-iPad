//
//  RealCellView.h
//  DigitalSenseHD
//
//  Created by baolicheng on 16/8/12.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ScriptCommand;
@protocol RealCellViewProtocol <NSObject>
-(void)addWidthWithSpaceCount:(NSInteger)spaceCount;
-(void)minusWidthWithSpaceCount:(NSInteger)spaceCount;
-(void)beginTrackCell;
-(void)endTrackCell;
@end
@interface RealCellView : UIView
{
    CGFloat maxCenterY;
    CGFloat minCenterY;
    CGFloat maxHeight;
    ScriptCommand *currentCommand;
}
@property(nonatomic,assign) id<RealCellViewProtocol> delegate;
-(void)setScriptCommand:(ScriptCommand *)command;
-(void)setMaxHeight:(CGFloat)height WithMaxCenterY:(CGFloat)aCenterY WithMinCenterY:(CGFloat)iCenterY;
@end
