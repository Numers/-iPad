//
//  PlayViewController.m
//  DigitalSenseHD
//
//  Created by baolicheng on 16/8/20.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import "PlayViewController.h"
#import "RelativeTimeScript.h"

#import "HomeCollectionViewCell.h"
#import "GraduatedLineView.h"
#import "SmellView.h"
#import "XTLoveHeartView.h"
#import "ZDProgressView.h"
#import "Smell.h"

#import "GlobalVar.h"

#import "ScriptExecuteManager.h"
#import "BluetoothMacManager.h"
#import "BluetoothProcessManager.h"

#define PlayViewCollectionViewCellIdentify @"PlayViewCollectionViewCellIdentify"
@interface PlayViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
{
    RelativeTimeScript *currentScript;
    GraduatedLineView *lineView;
    
    UISwipeGestureRecognizer *swipeGestureRecognizer;
    BOOL isShare; //yes分享，NO删除
    
    NSArray *smellList;
    
    NSArray *pageSmellList;
    NSInteger currentSelectPage;
    
    BOOL isLoop;
    BOOL needLoop;
    
    NSTimer *heartTimer;
}
@property(nonatomic, strong) IBOutlet UICollectionView *collectionView;
@property(nonatomic, strong) IBOutlet UILabel *lblTime;
@property(nonatomic, strong) IBOutlet UIView *bottomBackView;
@property(nonatomic, strong) IBOutlet UIButton *btnShareOrDelete;
@property(nonatomic, strong) IBOutlet ZDProgressView *progressView;
@end

@implementation PlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    //fontName:DFPHaiBaoW12   DFWaWaSC-W5  ||  familyName:Wawati SC     DFPHaiBaoW12-GB
    [self.lblTime setText:@"00:00"];
    [self.lblTime setFont:[UIFont fontWithName:@"DFPHaiBaoW12-GB" size:32.0f]];
    [self.lblTime setTextColor:[UIColor whiteColor]];
    
    [self.navigationController setNavigationBarHidden:YES];
    UIImage *backgroundImage = [UIImage imageNamed:@"BackgroundImage"];
    self.view.layer.contents = (id)backgroundImage.CGImage;
    
    [self.progressView setNoColor:[UIColor colorWithRed:0.514 green:0.388 blue:0.196 alpha:1.000]];
    [self.progressView setPrsColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"ProgressTrackImage"]]];
    [self.progressView setBorderColor:[UIColor colorWithRed:0.875 green:0.843 blue:0.451 alpha:1.000]];
    [self.progressView setBorderWidth:0.5f];
    [self.progressView setProgress:0.3f];
    
    [_collectionView setBackgroundColor:[UIColor clearColor]];
    [_collectionView setContentInset:UIEdgeInsetsMake(0, 10, 0, 10)];
    lineView = [[GraduatedLineView alloc] init];
    [_collectionView addSubview:lineView];
    [_collectionView sendSubviewToBack:lineView];
    
    [_collectionView registerClass:[HomeCollectionViewCell class] forCellWithReuseIdentifier:PlayViewCollectionViewCellIdentify];
    
    [self selectSmellListWithIndex:0];
    [self setIsShare:YES];
    
    swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGesture)];
    swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight | UISwipeGestureRecognizerDirectionLeft;
    [self.bottomBackView addGestureRecognizer:swipeGestureRecognizer];
    
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
-(void)setIsShare:(BOOL)share
{
    isShare = share;
    if (share) {
        [_btnShareOrDelete setImage:[UIImage imageNamed:@"ShareBtn"] forState:UIControlStateNormal];
    }else{
        [_btnShareOrDelete setImage:[UIImage imageNamed:@"DeleteBtn"] forState:UIControlStateNormal];
    }
}

-(void)setScript:(RelativeTimeScript *)relativeScript PageSmellList:(NSArray *)list
{
    currentScript = relativeScript;
    pageSmellList = [list copy];
}

#pragma -mark Private Functions
-(void)inilizedUIView
{
    
    [_lblTime setText:@"00:00"];
    [_progressView setProgress:0.0f];
    
    needLoop = NO;
    isLoop = NO;
}

-(void)beginPlayScript
{
    [AppUtils showCustomHudProgress:@"ready" CustomView:nil ForView:self.view];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [AppUtils showCustomHudProgress:@"go" CustomView:nil ForView:self.view];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self playScript];
        });
    });
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

-(void)generateHeartView
{
    XTLoveHeartView *heart = [[XTLoveHeartView alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    [self.view addSubview:heart];
    [self.view bringSubviewToFront:heart];
    CGPoint fountainSource = CGPointMake(_collectionView.frame.origin.x - 20, _collectionView.frame.origin.y);
    heart.center = fountainSource;
    [heart animateInView:self.view];
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
            [self inilizedUIView];
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
        heartTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(generateHeartView) userInfo:nil repeats:YES];
        [heartTimer fire];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(actualTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (heartTimer) {
                if ([heartTimer isValid]) {
                    [heartTimer invalidate];
                }
            }
        });
        
    }
}

-(void)progressChangedNotify:(NSNotification *)notify
{
    NSNumber *seconds = [notify object];
    if (currentScript) {
        CGFloat progress;
        if (currentScript.scriptTime == 0) {
            progress = 0.0f;
        }else{
            progress = 1.0f * [seconds integerValue] / currentScript.scriptTime;
        }
        
        [_progressView setProgress:progress];
        
        NSString *desc = [NSString stringWithFormat:@"%@",[AppUtils switchSecondsToTime:[seconds integerValue]]];
        [_lblTime setText:desc];
        
        [_collectionView setContentOffset:CGPointMake([seconds integerValue] * WidthPerSecond, 0) animated:YES];
    }
}


-(void)onStartScanBluetooth:(NSNotification *)notify
{
    
}

-(void)onCallbackBluetoothPowerOff:(NSNotification *)notify
{
    UIImageView *customImageView = [[UIImageView alloc] initWithImage:nil];
    [AppUtils showCustomHudProgress:@"蓝牙已关闭" CustomView:customImageView ForView:self.view];
}

-(void)onCallbackScanBluetoothTimeout:(NSNotification *)notify
{
    
}

-(void)onCallbackBluetoothDisconnected:(NSNotification *)notify
{
    UIImageView *customImageView = [[UIImageView alloc] initWithImage:nil];
    [AppUtils showCustomHudProgress:@"设备已断开" CustomView:customImageView ForView:self.view];
}

-(void)onStartConnectToBluetooth:(NSNotification *)notify
{
    
}

-(void)onCallbackConnectToBluetoothSuccessfully:(NSNotification *)notify
{
    UIImageView *customImageView = [[UIImageView alloc] initWithImage:nil];
    [AppUtils showCustomHudProgress:@"设备已连接" CustomView:customImageView ForView:self.view];
    
}

-(void)onCallbackConnectToBluetoothTimeout:(NSNotification *)notify
{
    UIImageView *customImageView = [[UIImageView alloc] initWithImage:nil];
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
    if (currentScript) {
        [[ScriptExecuteManager defaultManager] cancelExecuteRelativeTimeScript:currentScript];
        [[BluetoothMacManager defaultManager] writeCharacteristicWithCommandStr:@"F96600000000000055"];
    }
}
#pragma -mark CollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return currentScript.scriptCommandList.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    HomeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:PlayViewCollectionViewCellIdentify forIndexPath:indexPath];
//    cell.delegate = self;
    //    [cell inilizedView];
    
    
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            ScriptCommand *command = [currentScript.scriptCommandList objectAtIndex:indexPath.item];
            dispatch_async(dispatch_get_main_queue(), ^{
                [cell setupWithScriptCommand:command];
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
