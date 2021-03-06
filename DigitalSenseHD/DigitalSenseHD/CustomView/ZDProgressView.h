//
//  ZDProgressView.h
//  PE
//
//  Created by 杨志达 on 14-6-20.
//  Copyright (c) 2014年 PE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZDProgressView : UIView

@property (nonatomic,strong) NSString *text;
@property (nonatomic,strong) UIFont *textFont;
@property (nonatomic,assign) CGFloat progress;
@property (nonatomic,assign) CGFloat cornerRadius;
@property (nonatomic,assign) CGFloat borderWidth;

@property (nonatomic,strong) UIColor *noColor;
@property (nonatomic,strong) UIColor *prsColor;
@property(nonatomic, strong) UIColor *borderColor;

@end
