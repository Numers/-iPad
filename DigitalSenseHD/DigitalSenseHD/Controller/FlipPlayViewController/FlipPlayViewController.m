//
//  FlipPlayViewController.m
//  DigitalSenseHD
//
//  Created by baolicheng on 16/8/22.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import "FlipPlayViewController.h"
#import "RelativeTimeScript.h"

#import "HomeCollectionViewCell.h"
#import "SmellView.h"
#import "FlipPlayBackView.h"
#import "FlipReadyView.h"
#import "Smell.h"

#import "GlobalVar.h"

#import "ScriptExecuteManager.h"
#import "BluetoothMacManager.h"
#import "BluetoothProcessManager.h"

#import "CAShapeLayer+FlipBackViewMask.h"
#import "UIImage+GIF.h"
#import "SmokeView.h"

#define FlipPlayViewCollectionViewCellIdentify @"FlipPlayViewCollectionViewCellIdentify"

@interface FlipPlayViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>
{
    RelativeTimeScript *currentScript;
    FlipReadyView *flipReadyView;
    
    UISwipeGestureRecognizer *swipeGestureRecognizer;
    BOOL isShare; //yes分享，NO删除
    
    NSArray *smellList;
    
    NSArray *pageSmellList;
    NSInteger currentSelectPage;
    
    BOOL isLoop;
    BOOL needLoop;
    
    NSLock *lock;//icon设置线程互斥锁
    NSLock *eruptLock;//气味发散图片设置互斥锁
    NSInteger lowPowerScriptCommandCount;
    NSInteger normalPowerScriptCommandCount;
    NSInteger highPowerScriptCommandCount;
    NSInteger eruptSmokeSetCount;
}
@property(nonatomic, strong) IBOutlet UIImageView *highPowerIconImageView;
@property(nonatomic, strong) IBOutlet UIImageView *normalPowerIconImageView;
@property(nonatomic, strong) IBOutlet UIImageView *lowPowerIconImageView;
@property(nonatomic, strong) IBOutlet FlipPlayBackView *flipPlayBackView;
@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) IBOutlet UILabel *lblTime;
@property(nonatomic, strong) IBOutlet UIView *bottomBackView;
@property(nonatomic, strong) IBOutlet SmokeView *smokeView;
@end

@implementation FlipPlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.lblTime setText:@"00:00"];
    [self.lblTime setFont:[UIFont fontWithName:@"DFPHaiBaoW12-GB" size:32.0f]];
    [self.lblTime setTextColor:[UIColor whiteColor]];
    
    [_flipPlayBackView setBackgroundColor:[UIColor clearColor]];
    CAShapeLayer *layer = [CAShapeLayer createMaskLayerWithView:_flipPlayBackView];
    _flipPlayBackView.layer.mask = layer;
    
    [_smokeView setBackgroundColor:[UIColor clearColor]];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(736.0f, 0, currentScript.scriptTime * WidthPerSecond, 406.0f) collectionViewLayout:layout];
    [_collectionView setBackgroundColor:[UIColor clearColor]];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [_flipPlayBackView addSubview:_collectionView];
    
    [_collectionView registerClass:[HomeCollectionViewCell class] forCellWithReuseIdentifier:FlipPlayViewCollectionViewCellIdentify];
    
    [self.navigationController setNavigationBarHidden:YES];
    UIImage *backgroundImage = [UIImage imageNamed:@"PlayView_BackgroundImage"];
    self.view.layer.contents = (id)backgroundImage.CGImage;

    
    [self selectSmellListWithIndex:0];
    
    swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGesture)];
    swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight | UISwipeGestureRecognizerDirectionLeft;
    [self.bottomBackView addGestureRecognizer:swipeGestureRecognizer];
    
    lock = [[NSLock alloc] init];
    eruptLock = [[NSLock alloc] init];
    
    [self inilizedUIView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self registerNotifications];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    [self beginPlayScript];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma -mark Public Functions
-(void)setScript:(RelativeTimeScript *)relativeScript PageSmellList:(NSArray *)list
{
    currentScript = relativeScript;
    pageSmellList = [list copy];
}

#pragma -mark Private Functions
-(void)inilizedUIView
{
    
    [_lblTime setText:@"00:00"];
    
    needLoop = NO;
    isLoop = NO;
    lowPowerScriptCommandCount = 0;
    normalPowerScriptCommandCount = 0;
    highPowerScriptCommandCount = 0;
    eruptSmokeSetCount = 0;
}

-(void)beginPlayScript
{
    flipReadyView = [[FlipReadyView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [flipReadyView showInView:self.view completion:^(BOOL isFinished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [flipReadyView hidden:^(BOOL isFinished) {
                CGFloat firstAnimateDuraion = _flipPlayBackView.frame.size.width / WidthPerSecond;
                [UIView animateWithDuration:firstAnimateDuraion delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                    [_collectionView setFrame:CGRectMake(0, 0, _collectionView.frame.size.width, _collectionView.frame.size.height)];
                } completion:^(BOOL finished) {
                    if (finished) {
                        [self playScript];
                    }
                }];
            }];
        });
    }];
}

-(void)registerNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beginPalyScript:) name:PlayScriptNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playOverScript:) name:PlayOverScriptNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendScriptCommandNotify:) name:SendScriptCommandNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(progressChangedNotify:) name:PlayProgressSecondNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onStartScanBluetooth:) name:OnStartScanBluetooth object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCallbackBluetoothPowerOff:) name:OnCallbackBluetoothPowerOff object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCallbackScanBluetoothTimeout:) name:OnCallbackScanBluetoothTimeout object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCallbackBluetoothDisconnected:) name:OnCallbackBluetoothDisconnected object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onStartConnectToBluetooth:) name:OnStartConnectToBluetooth object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCallbackConnectToBluetoothSuccessfully:) name:OnCallbackConnectToBluetoothSuccessfully object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCallbackConnectToBluetoothTimeout:) name:OnCallbackConnectToBluetoothTimeout object:nil];
}

-(void)playScript
{
    if (currentScript) {
        [[ScriptExecuteManager defaultManager] cancelAllScripts];
        [[ScriptExecuteManager defaultManager] executeRelativeTimeScript:currentScript];
    }
}


-(void)selectSmellListWithIndex:(NSInteger)index
{
    currentSelectPage = index;
    smellList = [[pageSmellList objectAtIndex:index] copy];
    
    NSInteger j = 1;
    for (j = 1; j <= smellList.count; j++) {
        SmellView *sv = [self.view viewWithTag:j];
        if (sv) {
            sv.delegate = nil;
            [sv setHidden:YES];
        }
    }
    
    NSInteger i = 1;
    for (Smell *s in smellList) {
        SmellView *sv = [self.view viewWithTag:i];
        if (sv) {
            //            sv.delegate = self;
            [sv setHidden:NO];
            [sv setSmell:s];
        }
        i++;
    }
}

-(void)changeSmellList
{
    if (currentSelectPage == 0) {
        [self selectSmellListWithIndex:1];
    }else if (currentSelectPage == 1) {
        [self selectSmellListWithIndex:0];
    }
}

#pragma -mark Notifications
-(void)beginPalyScript:(NSNotification *)notify
{
    RelativeTimeScript *script = [notify object];
    if (currentScript) {
        if ([currentScript isEqual:script]) {
//            [self inilizedUIView];
            [UIView animateWithDuration:currentScript.scriptTime delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                [_collectionView setFrame:CGRectMake(-_collectionView.frame.size.width, 0, _collectionView.frame.size.width, _collectionView.frame.size.height)];
            } completion:^(BOOL finished) {
                
            }];
        }
    }
}

-(void)playOverScript:(NSNotification *)notify
{
    RelativeTimeScript *script = [notify object];
    if (currentScript) {
        if ([currentScript isEqual:script]) {
            if (isLoop) {
                if (needLoop) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [[ScriptExecuteManager defaultManager] executeRelativeTimeScript:currentScript];
                    });
                }else{
                    currentScript = nil;
                    if([[NSThread currentThread] isMainThread]){
                        [self.navigationController popViewControllerAnimated:YES];
                    }else{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.navigationController popViewControllerAnimated:YES];
                        });
                    }
                }
            }else{
                currentScript = nil;
                if([[NSThread currentThread] isMainThread]){
                    [self.navigationController popViewControllerAnimated:YES];
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.navigationController popViewControllerAnimated:YES];
                    });
                }
            }
        }
    }
}

-(void)sendScriptCommandNotify:(NSNotification *)notify
{
    ScriptCommand *scriptCommand = [notify object];
    if (![AppUtils isNullStr:scriptCommand.rfId]) {
        NSDictionary *dic = [notify userInfo];
        NSInteger actualTime = [[dic objectForKey:ActualTimeKey] integerValue];
        NSString *powerLevel = [AppUtils powerLevelWithPower:scriptCommand.power];
        UIImage *smellImage = [UIImage imageNamed:[scriptCommand.smellImage stringByReplacingOccurrencesOfString:@"Image" withString:@"IconImage"]];
//        UIImage *smellGifImage = [UIImage sd_animatedGIFNamed:gifName];
//        [self setEruptImage:smellGifImage];
        if ([powerLevel isEqualToString:@"highPower"]) {
            [self eruptSmokeWithDegree:0.7];
            [self setIconImage:smellImage WithGifName:@"highPower"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(actualTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self setIconImage:nil WithGifName:@"highPower"];
                [self eruptSmokeWithDegree:0.0f];
            });
        }else if ([powerLevel isEqualToString:@"normalPower"]){
            [self eruptSmokeWithDegree:0.5];
            [self setIconImage:smellImage WithGifName:@"normalPower"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(actualTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self setIconImage:nil WithGifName:@"normalPower"];
                [self eruptSmokeWithDegree:0.0f];
            });
        }else if ([powerLevel isEqualToString:@"lowPower"]){
            [self eruptSmokeWithDegree:0.3];
            [self setIconImage:smellImage WithGifName:@"lowPower"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(actualTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self setIconImage:nil WithGifName:@"lowPower"];
                [self eruptSmokeWithDegree:0.0f];
            });
        }
    }
}

//-(void)setEruptImage:(UIImage *)eruptImage
//{
//    [eruptLock lock];
//    if (eruptImage) {
//        [_smellEruptImageView setImage:eruptImage];
//        eruptImageSetCount++;
//    }else{
//        if (eruptImageSetCount == 1) {
//            eruptImageSetCount--;
//            [_smellEruptImageView setImage:nil];
//        }else{
//            eruptImageSetCount--;
//        }
//    }
//    [eruptLock unlock];
//}

-(void)eruptSmokeWithDegree:(CGFloat)degree
{
    [eruptLock lock];
    if (degree > 0) {
        [self.smokeView generateSmokeWithSmokeAmount:degree];
        eruptSmokeSetCount++;
    }else{
        if (eruptSmokeSetCount == 1) {
            eruptSmokeSetCount--;
            [self.smokeView stopSmoke];
        }else{
            eruptSmokeSetCount--;
        }
    }
    [eruptLock unlock];
}

-(void)setIconImage:(UIImage *)iconImage WithGifName:(NSString *)gifName
{
    [lock lock];
    if (iconImage) {
        if ([gifName isEqualToString:@"highPower"]) {
            [_highPowerIconImageView setImage:iconImage];
            highPowerScriptCommandCount++;
        }else if ([gifName isEqualToString:@"normalPower"]){
            [_normalPowerIconImageView setImage:iconImage];
            normalPowerScriptCommandCount++;
        }else if ([gifName isEqualToString:@"lowPower"]){
            [_lowPowerIconImageView setImage:iconImage];
            lowPowerScriptCommandCount++;
        }
    }else{
        if ([gifName isEqualToString:@"highPower"]) {
            if (highPowerScriptCommandCount == 1) {
                highPowerScriptCommandCount--;
                [_highPowerIconImageView setImage:nil];
            }else{
                highPowerScriptCommandCount--;
            }
        }else if ([gifName isEqualToString:@"normalPower"]){
            if (normalPowerScriptCommandCount == 1) {
                normalPowerScriptCommandCount--;
                [_normalPowerIconImageView setImage:nil];
            }else{
                normalPowerScriptCommandCount--;
            }
        }else if ([gifName isEqualToString:@"lowPower"]){
            if (lowPowerScriptCommandCount == 1) {
                lowPowerScriptCommandCount--;
                [_lowPowerIconImageView setImage:nil];
            }else{
                lowPowerScriptCommandCount--;
            }
        }
    }
    [lock unlock];
}

-(void)progressChangedNotify:(NSNotification *)notify
{
    NSNumber *seconds = [notify object];
    if (currentScript) {
        NSString *desc = [NSString stringWithFormat:@"%@",[AppUtils switchSecondsToTime:[seconds integerValue]]];
        [_lblTime setText:desc];
        
        
    }
}


-(void)onStartScanBluetooth:(NSNotification *)notify
{
    
}

-(void)onCallbackBluetoothPowerOff:(NSNotification *)notify
{
    UIImageView *customImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SadFaceImage"]];
    [AppUtils showCustomHudProgress:@"蓝牙已关闭" CustomView:customImageView ForView:self.view];
}

-(void)onCallbackScanBluetoothTimeout:(NSNotification *)notify
{
    
}

-(void)onCallbackBluetoothDisconnected:(NSNotification *)notify
{
    UIImageView *customImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SadFaceImage"]];
    [AppUtils showCustomHudProgress:@"设备已断开" CustomView:customImageView ForView:self.view];
}

-(void)onStartConnectToBluetooth:(NSNotification *)notify
{
    
}

-(void)onCallbackConnectToBluetoothSuccessfully:(NSNotification *)notify
{
    UIImageView *customImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SmileFaceImage"]];
    [AppUtils showCustomHudProgress:@"设备已连接" CustomView:customImageView ForView:self.view];
    
}

-(void)onCallbackConnectToBluetoothTimeout:(NSNotification *)notify
{
    UIImageView *customImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SadFaceImage"]];
    [AppUtils showCustomHudProgress:@"设备未连接" CustomView:customImageView ForView:self.view];
}
#pragma -mark GestureRecognizer
-(void)swipeGesture
{
    [self changeSmellList];
}

#pragma -mark UIButtonEvent
-(IBAction)clickStopBtn:(id)sender
{
    [_collectionView removeFromSuperview];
    if (currentScript) {
        [[ScriptExecuteManager defaultManager] cancelExecuteRelativeTimeScript:currentScript];
        if (currentScript.state == ScriptIsPlaying) {
            [[BluetoothMacManager defaultManager] writeCharacteristicWithCommandStr:@"F96600000000000055"];
            return;
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma -mark CollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return currentScript.scriptCommandList.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    HomeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:FlipPlayViewCollectionViewCellIdentify forIndexPath:indexPath];
    //    cell.delegate = self;
    //    [cell inilizedView];
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        ScriptCommand *command = [currentScript.scriptCommandList objectAtIndex:indexPath.item];
        dispatch_async(dispatch_get_main_queue(), ^{
            [cell setupWithScriptCommand:command isShowCircleButton:NO];
        });
    });
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ScriptCommand *command = [currentScript.scriptCommandList objectAtIndex:indexPath.item];
    CGFloat width = command.duration * WidthPerSecond;
    CGFloat height = collectionView.frame.size.height;
    return CGSizeMake(width, height);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}
@end
