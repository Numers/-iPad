//
//  CustomLewReorderableLayout.h
//  DigitalSenseHD
//
//  Created by baolicheng on 16/8/12.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol CustomLewReorderableLayoutDataSource<UICollectionViewDataSource>

@required

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;

@optional

- (CGFloat)reorderingItemAlpha:(UICollectionView * )collectionview inSection:(NSInteger)section; //Default 0.

- (UIEdgeInsets)scrollTrigerEdgeInsetsInCollectionView:(UICollectionView *)collectionView;

- (UIEdgeInsets)scrollTrigerPaddingInCollectionView:(UICollectionView *)collectionView;

- (CGFloat)scrollSpeedValueInCollectionView:(UICollectionView *)collectionView;

@end

@protocol CustomLewReorderableLayoutDelegate <UICollectionViewDelegateFlowLayout>

@optional

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath willMoveToIndexPath:(NSIndexPath *)toIndexPath;

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath didMoveToIndexPath:(NSIndexPath *)toIndexPath;

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath;

- (BOOL)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath canMoveToIndexPath:(NSIndexPath *)toIndexPath;

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout willBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath;

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout didBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath;

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout willEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath;

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout didEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath;

-(void)collectionView:(UICollectionView *)collectionView TouchLocation:(CGPoint)location didEndTouch:(void (^)(BOOL isPushBack))completion;

-(void)collectionView:(UICollectionView *)collectionView PanLocation:(CGPoint)location PanTranslation:(CGPoint)translation didChanged:(void (^)(void))completion;

-(void)collectionView:(UICollectionView *)collectionView PanLocation:(CGPoint)location PanTranslation:(CGPoint)translation didMoveout:(void (^)(void))completion;

-(void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout longTouchCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

@class SmellFakeView;
@interface CustomLewReorderableLayout : UICollectionViewFlowLayout<UIGestureRecognizerDelegate>

@property (nonatomic, weak)id<CustomLewReorderableLayoutDelegate> delegate;
@property (nonatomic, weak)id<CustomLewReorderableLayoutDataSource> dataSource;
@property (nonatomic, strong)UILongPressGestureRecognizer *longPress;
@property (nonatomic, strong)UIPanGestureRecognizer *panGesture;

-(void)setCellFakeViewOnScreen:(SmellFakeView *)cellFakeViewOnScreen;
-(void)setCellFakeIndexPath:(NSIndexPath *)indexPath;
@end
