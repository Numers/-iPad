//
//  CollectionViewOperationManager.m
//  DigitalSenseHD
//
//  Created by baolicheng on 16/8/15.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import "CollectionViewOperationManager.h"
#import "Smell.h"
#import "ScriptCommand.h"

@implementation CollectionViewOperationManager
-(instancetype)initWithCommandArray:(NSMutableArray *)arr WithInsertIndexPath:(NSIndexPath *)indexPath WithInsertSmell:(Smell *)smell
{
    self = [super init];
    if (self) {
        NSAssert((arr != nil) && (arr.count > 0), @"数组传入不能为空");
        if (arr) {
            _commandList = arr;
        }
        _insertIndexPath = indexPath;
        _insertSmell = smell;
        self.lock = [[NSRecursiveLock alloc] init];
        self.operationLock = [[NSLock alloc] init];
    }
    return self;
}

+(NSThread *)operationThread
{
    static NSThread *_operationThread = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
//        _operationThread = [[NSThread alloc] initWithTarget:self selector:@selector(operationThreadEntryPoint:) object:nil];
//        [_operationThread start];
        _operationThread = [NSThread mainThread];
    });
    return _operationThread;
}

+(void)operationThreadEntryPoint:(id)__unused object
{
    @autoreleasepool {
        [[NSThread currentThread] setName:@"OperationCollectionViewCell"];
        
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop addPort:[NSMachPort port] forMode:NSRunLoopCommonModes];
        [runLoop run];
    }
}

-(void)insertOperation:(NSIndexPath *)indexPath
{
    [self.lock lock];
    [self performSelector:@selector(insertOperationCollectionView:) onThread:[[self class] operationThread] withObject:indexPath waitUntilDone:NO];
    [self.lock unlock];
}

-(void)insertOperationCollectionView:(NSIndexPath *)indexPath
{
    [self.lock lock];
    CGPoint center = CGPointZero;
    ScriptCommand *command = [self isExistVirtualCommand];
    if (command) {
        
    }else{
        if (indexPath && _insertSmell) {
            ScriptCommand *virtualCommand = [[ScriptCommand alloc] init];
            virtualCommand.rfId = _insertSmell.smellRFID;
            virtualCommand.duration = 3;
            virtualCommand.smellName = _insertSmell.smellName;
            virtualCommand.color = _insertSmell.smellColor;
            virtualCommand.smellImage = _insertSmell.smellImage;
            virtualCommand.type = VirtualCommand;

            ScriptCommand *curCommand = [_commandList objectAtIndex:indexPath.item];
            if (curCommand.type == SpaceCommand) {
                if ([self hasEnoughSpaceWithDuration:virtualCommand.duration afterIndexPath:indexPath]) {
                    if (_collectionView) {
                
                        [_collectionView performBatchUpdates:^{
                            [self.operationLock lock];
                            [self deleteSpaceWithIndex:indexPath.item withCount:virtualCommand.duration];
                            NSMutableArray *deleteIndexPath = [NSMutableArray array];
                            for (NSInteger i = indexPath.item; i < indexPath.item + virtualCommand.duration; i++) {
                                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
                                [deleteIndexPath addObject:indexPath];
                            }
                            
                            [_collectionView deleteItemsAtIndexPaths:deleteIndexPath];
                            
                            [_commandList insertObject:virtualCommand atIndex:indexPath.item];
                            [_collectionView insertItemsAtIndexPaths:@[indexPath]];
                            _insertIndexPath = indexPath;
                            [self.operationLock unlock];
                        } completion:^(BOOL finished) {
                            
                        }];
                    }
                }
            }else if(curCommand.type == RealCommand){
                
            }
            
            if ([_commandList containsObject:virtualCommand]) {
                NSInteger virtualIndex = [_commandList indexOfObject:virtualCommand];
                UICollectionViewCell *insertCell = [_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:virtualIndex inSection:0]];
                center = insertCell.center;
            }
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:FakeViewCenterChangedNotify object:nil userInfo:@{@"centerX":@(center.x),@"centerY":@(center.y)}];
    [self.lock unlock];
}

-(void)moveLeftOperation:(NSIndexPath *)indexPath
{
    [self.lock lock];
    [self performSelector:@selector(moveLeftOperationCollectionView:) onThread:[[self class] operationThread] withObject:indexPath waitUntilDone:NO];
    [self.lock unlock];
}

-(void)moveLeftOperationCollectionView:(NSIndexPath *)indexPath
{
    [self.lock lock];
    CGPoint center = CGPointZero;
    ScriptCommand *virtualCommand = [self isExistVirtualCommand];
    if (virtualCommand == nil) {
        [self.lock unlock];
        return;
    }
    
    if ([_commandList indexOfObject:virtualCommand] != _insertIndexPath.item) {
        NSLog(@"空格不一致");
        [self.lock unlock];
        return;
    }
    if (![indexPath isEqual:_insertIndexPath]) {
        ScriptCommand *command = [_commandList objectAtIndex:indexPath.item];
        if (command.type == SpaceCommand) {
            if ([self isNearFromIndexPath:indexPath toIndexPath:_insertIndexPath]) {
                ScriptCommand *insertCommand = [_commandList objectAtIndex:_insertIndexPath.item];
                if ([self hasEnoughSpaceWithDuration:insertCommand.duration afterIndexPath:indexPath]) {
                    [_collectionView performBatchUpdates:^{
                        [self.operationLock lock];
                        [_collectionView moveItemAtIndexPath:_insertIndexPath toIndexPath:indexPath];
                        [_commandList removeObject:insertCommand];
                        [_commandList insertObject:insertCommand atIndex:indexPath.item];
                        _insertIndexPath = indexPath;
                        [self.operationLock unlock];
                    } completion:^(BOOL finished) {
                        
                    }];
                }
            }else{
                ScriptCommand *insertCommand = [_commandList objectAtIndex:_insertIndexPath.item];
                if ([self hasEnoughSpaceWithDuration:insertCommand.duration afterIndexPath:indexPath]) {
                    [_collectionView performBatchUpdates:^{
                        [self.operationLock lock];
                        //
                        [_commandList removeObjectAtIndex:_insertIndexPath.item];
                        [_collectionView deleteItemsAtIndexPaths:@[_insertIndexPath]];
                        
                        NSMutableArray *spaceArr = [NSMutableArray array];
                        for (NSInteger i = indexPath.item; i < indexPath.item + insertCommand.duration; i++) {
                            ScriptCommand *spaceCommand = [_commandList objectAtIndex:i];
                            [spaceArr addObject:spaceCommand];
                        }

                        NSMutableArray *indexPathArr = [NSMutableArray array];
                        for (NSInteger j = _insertIndexPath.item ; j < _insertIndexPath.item + insertCommand.duration; j ++) {
                            [indexPathArr addObject:[NSIndexPath indexPathForItem:j inSection:0]];
                        }
                        
                        [_commandList insertObjects:spaceArr atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(_insertIndexPath.item, insertCommand.duration)]];
                        [_collectionView insertItemsAtIndexPaths:indexPathArr];
                        
                        
                        
                        
                        //
                        NSMutableArray *indexPathArr1 = [NSMutableArray array];
                        for (NSInteger j = indexPath.item ; j < indexPath.item + insertCommand.duration; j ++) {
                            [indexPathArr1 addObject:[NSIndexPath indexPathForItem:j inSection:0]];
                        }
                        [_commandList removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(indexPath.item, insertCommand.duration)]];
                        [_collectionView deleteItemsAtIndexPaths:indexPathArr1];
                        [_commandList insertObject:insertCommand atIndex:indexPath.item];
                        [_collectionView insertItemsAtIndexPaths:@[indexPath]];
                        _insertIndexPath = indexPath;
                        [self.operationLock unlock];
                    } completion:^(BOOL finished) {
                        
                    }];
                }
            }
        }
    }
    if ([_commandList containsObject:virtualCommand]) {
        NSInteger virtualIndex = [_commandList indexOfObject:virtualCommand];
        UICollectionViewCell *insertCell = [_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:virtualIndex inSection:0]];
        center = insertCell.center;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:FakeViewCenterChangedNotify object:nil userInfo:@{@"centerX":@(center.x),@"centerY":@(center.y)}];
    [self.lock unlock];
}

-(void)moveRightOperation:(NSIndexPath *)indexPath
{
    [self.lock lock];
    [self performSelector:@selector(moveRightOperaitonCollectionView:) onThread:[[self class] operationThread] withObject:indexPath waitUntilDone:NO];
    [self.lock unlock];
}

-(void)moveRightOperaitonCollectionView:(NSIndexPath *)indexPath
{
    [self.lock lock];
    CGPoint center = CGPointZero;
    NSLog(@"%ld,%ld",indexPath.item,_insertIndexPath.item);
    ScriptCommand *virtualCommand = [self isExistVirtualCommand];
    if (virtualCommand == nil) {
        [self.lock unlock];
        return;
    }
    
    if ([_commandList indexOfObject:virtualCommand] != _insertIndexPath.item) {
        NSLog(@"空格不一致");
        [self.lock unlock];
        return;
    }
    if (![indexPath isEqual:_insertIndexPath]) {
        ScriptCommand *command = [_commandList objectAtIndex:indexPath.item];
        if (command.type == SpaceCommand) {
            if ([self isNearFromIndexPath:indexPath toIndexPath:_insertIndexPath]) {
                ScriptCommand *insertCommand = [_commandList objectAtIndex:_insertIndexPath.item];
                if ([self hasEnoughSpaceWithDuration:insertCommand.duration beforeIndexPath:indexPath]) {
                    [_collectionView performBatchUpdates:^{
                        [self.operationLock lock];
                        [_commandList removeObject:insertCommand];
                        [_commandList insertObject:insertCommand atIndex:indexPath.item];
                        [_collectionView moveItemAtIndexPath:_insertIndexPath toIndexPath:indexPath];
                        _insertIndexPath = indexPath;
                        [self.operationLock unlock];
                    } completion:^(BOOL finished) {
                        
                    }];
                }
            }else{
                ScriptCommand *insertCommand = [_commandList objectAtIndex:_insertIndexPath.item];
                if ([self hasEnoughSpaceWithDuration:insertCommand.duration beforeIndexPath:indexPath]) {
                    [_collectionView performBatchUpdates:^{
                        [self.operationLock lock];
                        //
                        [_commandList removeObjectAtIndex:_insertIndexPath.item];
                        [_collectionView deleteItemsAtIndexPaths:@[_insertIndexPath]];
                        NSMutableArray *spaceArr = [NSMutableArray array];
                        for (NSInteger i = indexPath.item - insertCommand.duration + 1; i <= indexPath.item; i++) {
                            ScriptCommand *spaceCommand = [_commandList objectAtIndex:i];
                            [spaceArr addObject:spaceCommand];
                        }
                        
                        NSMutableArray *indexPathArr1 = [NSMutableArray array];
                        for (NSInteger j = _insertIndexPath.item ; j < _insertIndexPath.item + insertCommand.duration; j ++) {
                            [indexPathArr1 addObject:[NSIndexPath indexPathForItem:j inSection:0]];
                        }
                        [_commandList insertObjects:spaceArr atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(_insertIndexPath.item, insertCommand.duration)]];
                        [_collectionView insertItemsAtIndexPaths:indexPathArr1];
                        
                        
                        
                        NSMutableArray *indexPathArr = [NSMutableArray array];
                        for (NSInteger j = indexPath.item; j < indexPath.item + insertCommand.duration; j ++) {
                            [indexPathArr addObject:[NSIndexPath indexPathForItem:j inSection:0]];
                        }
                        [_commandList removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(indexPath.item, insertCommand.duration)]];
                        [_collectionView deleteItemsAtIndexPaths:indexPathArr];
                        [_commandList insertObject:insertCommand atIndex:indexPath.item];
                        [_collectionView insertItemsAtIndexPaths:@[indexPath]];
                        
                        _insertIndexPath = indexPath;
                        [self.operationLock unlock];
                    } completion:^(BOOL finished) {
                        
                    }];
                }
            }
        }
    }
    if ([_commandList containsObject:virtualCommand]) {
        NSInteger virtualIndex = [_commandList indexOfObject:virtualCommand];
        UICollectionViewCell *insertCell = [_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:virtualIndex inSection:0]];
        center = insertCell.center;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:FakeViewCenterChangedNotify object:nil userInfo:@{@"centerX":@(center.x),@"centerY":@(center.y)}];
    [self.lock unlock];
}

-(ScriptCommand *)isExistVirtualCommand
{
    ScriptCommand *command = nil;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.type == %d",VirtualCommand];
    NSArray *filterArr = [_commandList filteredArrayUsingPredicate:predicate];
    if (filterArr && filterArr.count > 0) {
        command = [filterArr objectAtIndex:0];
    }
    return command;
}

-(BOOL)isNearFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    if (((fromIndexPath.item + 1) == toIndexPath.item) || ((fromIndexPath.item - 1) == toIndexPath.item)) {
        return YES;
    }
    return NO;
}

-(BOOL)hasEnoughSpaceWithDuration:(NSInteger)duration afterIndexPath:(NSIndexPath *)indexPath
{
    BOOL result = YES;
    NSInteger spaceDuration = 0;
    for (NSInteger i = indexPath.item; i < indexPath.item + duration; i++) {
        if (i >= _commandList.count) {
            break;
        }
        
        ScriptCommand *command = [_commandList objectAtIndex:i];
        if (command.type == RealCommand) {
            spaceDuration = 0;
            result = NO;
            break;
        }
        spaceDuration += command.duration;
        if (spaceDuration >= duration) {
            break;
        }
    }
    
    if (spaceDuration >= duration) {
        result = YES;
    }else{
        result = NO;
    }
    return result;
}

-(BOOL)hasEnoughSpaceWithDuration:(NSInteger)duration beforeIndexPath:(NSIndexPath *)indexPath
{
    BOOL result = YES;
    NSInteger spaceDuration = 0;
    for (NSInteger i = indexPath.item; i > (indexPath.item - duration); i--) {
        if (i< 0) {
            break;
        }
        
        ScriptCommand *command = [_commandList objectAtIndex:i];
        if (command.type == RealCommand) {
            spaceDuration = 0;
            result = NO;
            break;
        }
        
        spaceDuration += command.duration;
        if (spaceDuration >= duration) {
            break;
        }
    }
    
    if (spaceDuration >= duration) {
        result = YES;
    }else{
        result = NO;
    }
    return result;
}

-(void)deleteSpaceWithIndex:(NSInteger)index withCount:(NSInteger)count
{
    NSRange range = NSMakeRange(index, count);
    [_commandList removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
}
@end
