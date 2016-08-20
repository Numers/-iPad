//
//  PlayViewController.h
//  DigitalSenseHD
//
//  Created by baolicheng on 16/8/20.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RelativeTimeScript;
@interface PlayViewController : UIViewController

-(void)setScript:(RelativeTimeScript *)relativeScript PageSmellList:(NSArray *)list;
@end
