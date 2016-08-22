//
//  FlipPlayViewController.h
//  DigitalSenseHD
//
//  Created by baolicheng on 16/8/22.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RelativeTimeScript;
@interface FlipPlayViewController : UIViewController
-(void)setScript:(RelativeTimeScript *)relativeScript PageSmellList:(NSArray *)list;
@end
