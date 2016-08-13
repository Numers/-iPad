//
//  HomeCollectionViewCell.h
//  DigitalSenseHD
//
//  Created by baolicheng on 16/8/12.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ScriptCommand;
@interface HomeCollectionViewCell : UICollectionViewCell
-(void)setupWithScriptCommand:(ScriptCommand *)command;
@end
