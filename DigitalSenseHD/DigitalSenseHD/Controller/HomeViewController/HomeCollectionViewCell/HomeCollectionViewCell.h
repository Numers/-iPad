//
//  HomeCollectionViewCell.h
//  DigitalSenseHD
//
//  Created by baolicheng on 16/8/12.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ScriptCommand;
@protocol HomeCollectionViewCellProtocol <NSObject>

-(void)willAddWidthWithCommand:(ScriptCommand *)command;
-(void)willMinusWidthWithCommand:(ScriptCommand *)command;

@end
@interface HomeCollectionViewCell : UICollectionViewCell
@property(nonatomic,assign) id<HomeCollectionViewCellProtocol> delegate;
-(void)inilizedView;
-(void)setupWithScriptCommand:(ScriptCommand *)command;
@end
