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
@property (readwrite, nonatomic, strong) NSRecursiveLock *lock; //函数互斥锁
@property (readwrite, nonatomic, strong) NSLock *operationLock; //操作互斥锁

-(instancetype)initWithCommandArray:(NSMutableArray *)arr WithInsertIndexPath:(NSIndexPath *)indexPath WithInsertSmell:(Smell *)smell;
-(void)insertOperation:(NSIndexPath *)indexPath;
-(void)moveLeftOperation:(NSIndexPath *)indexPath;
-(void)moveRightOperation:(NSIndexPath *)indexPath;
@end
