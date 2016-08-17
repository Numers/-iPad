//
//  CollectionViewOperationManager.h
//  DigitalSenseHD
//
//  Created by baolicheng on 16/8/15.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import <Foundation/Foundation.h>

#define FakeViewCenterChangedNotify @"SmellFakeViewCenterChangedNotify"
@class Smell;
@interface CollectionViewOperationManager : NSObject
@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) NSMutableArray *commandList;
@property(nonatomic, strong) Smell *insertSmell;
@property(nonatomic, strong) NSIndexPath *insertIndexPath;
@property (readwrite, nonatomic, strong) NSLock *lock;

-(instancetype)initWithCommandArray:(NSMutableArray *)arr WithInsertIndexPath:(NSIndexPath *)indexPath WithInsertSmell:(Smell *)smell;
-(void)insertOperation:(NSIndexPath *)indexPath;
-(void)moveLeftOperation:(NSIndexPath *)indexPath;
-(void)moveRightOperation:(NSIndexPath *)indexPath;
@end
