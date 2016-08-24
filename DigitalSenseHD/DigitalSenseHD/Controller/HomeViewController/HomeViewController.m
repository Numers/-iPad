//
//  HomeViewController.m
//  DigitalSenseHD
//
//  Created by baolicheng on 16/8/10.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import "HomeViewController.h"
#import "SmellView.h"
#import "SmellFakeView.h"
#import "ZDProgressView.h"
#import "GraduatedLineView.h"
#import "Smell.h"
#import "RelativeTimeScript.h"

#import "CustomLewReorderableLayout.h"
#import "ScriptCommand.h"
#import "GlobalVar.h"

#import "HomeCollectionViewCell.h"
#import "PlayViewController.h"
#import "FlipPlayViewController.h"

#import "CollectionViewOperationManager.h"
#import "BluetoothProcessManager.h"
#import "BluetoothMacManager.h"
#import "ShareManage.h"

#import "UINavigationController+WXSTransition.h"

#define HomeCollectionViewCellIdentify @"HomeCollectionViewCellIdentify"
//#define SpaceCellIdentify @"SpaceHomeCellIdentify"
//#define VirtualCellIdentify @"VirtualHomeCellIdentify"
//#define RealCellIdentify @"RealHomeCellIdentify"
@interface HomeViewController ()<SmellViewProtocol,CustomLewReorderableLayoutDataSource,CustomLewReorderableLayoutDelegate,HomeCollectionViewCellProtocol,UIAlertViewDelegate>
{
    NSArray *smellList;
    
    NSArray *pageSmellList;
    NSInteger currentSelectPage;
    NSMutableArray *originCommandList;
    NSMutableArray *commandList;
    SmellFakeView *smellFakeView;
    
    GraduatedLineView *lineView;
    
    CollectionViewOperationManager *operationManager;
    
    UISwipeGestureRecognizer *swipeGestureRecognizer;
    
    BOOL isShare; //yes分享，NO删除
    
    NSTimer *testTimer;
    BOOL needReconnecting;
}

@property(nonatomic, strong) IBOutlet UICollectionView *collectionView;
@property(nonatomic, strong) IBOutlet UILabel *lblTime;
@property(nonatomic, strong) IBOutlet UIView *bottomBackView;
@property(nonatomic, strong) IBOutlet UIButton *btnShareOrDelete;
@property(nonatomic, strong) IBOutlet ZDProgressView *progressView;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    //fontName:DFPHaiBaoW12   DFWaWaSC-W5  ||  familyName:Wawati SC     DFPHaiBaoW12-GB
    [self.lblTime setText:@"00:00"];
    [self.lblTime setFont:[UIFont fontWithName:@"DFPHaiBaoW12-GB" size:32.0f]];
    [self.lblTime setTextColor:[UIColor whiteColor]];
    
    [self.progressView setNoColor:[UIColor colorWithRed:0.514 green:0.388 blue:0.196 alpha:1.000]];
    [self.progressView setPrsColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"ProgressTrackImage"]]];
    [self.progressView setBorderColor:[UIColor colorWithRed:0.875 green:0.843 blue:0.451 alpha:1.000]];
    [self.progressView setBorderWidth:0.5f];
    [self.progressView setProgress:0.0f];
    
    [self.navigationController setNavigationBarHidden:YES];
    UIImage *backgroundImage = [UIImage imageNamed:@"BackgroundImage"];
    self.view.layer.contents = (id)backgroundImage.CGImage;
    CustomLewReorderableLayout *layout = (CustomLewReorderableLayout *)[_collectionView collectionViewLayout];
    layout.delegate = self;
    layout.dataSource = self;
    
    [_collectionView setBackgroundColor:[UIColor clearColor]];
    [_collectionView setContentInset:UIEdgeInsetsMake(0, 10, 0, 10)];
    lineView = [[GraduatedLineView alloc] init];
    [_collectionView addSubview:lineView];
    [_collectionView sendSubviewToBack:lineView];
    
    [_collectionView registerClass:[HomeCollectionViewCell class] forCellWithReuseIdentifier:HomeCollectionViewCellIdentify];
//    [_collectionView registerClass:[SpaceHomeCollectionViewCell class] forCellWithReuseIdentifier:SpaceCellIdentify];
//    [_collectionView registerClass:[VirtualHomeCollectionViewCell class] forCellWithReuseIdentifier:VirtualCellIdentify];
//    [_collectionView registerClass:[RealHomeCollectionViewCell class] forCellWithReuseIdentifier:RealCellIdentify];
    
    Smell *smell1 = [[Smell alloc] init];
    smell1.smellRFID = @"00000010";
    smell1.smellName = @"苹果";
    smell1.smellImage = @"AppleImage";
    smell1.smellColor = @"#037F00";
    
    Smell *smell2 = [[Smell alloc] init];
    smell2.smellRFID = @"00000002";
    smell2.smellName = @"香蕉";
    smell2.smellImage = @"BananaImage";
    smell2.smellColor = @"#000000";
    
    Smell *smell3 = [[Smell alloc] init];
    smell3.smellRFID = @"00000003";
    smell3.smellName = @"猕猴桃";
    smell3.smellImage = @"KiwifruitImage";
    smell3.smellColor = @"#000000";
    
    Smell *smell4 = [[Smell alloc] init];
    smell4.smellRFID = @"00000004";
    smell4.smellName = @"葡萄";
    smell4.smellImage = @"GrapeImage";
    smell4.smellColor = @"#000000";
    
    Smell *smell5 = [[Smell alloc] init];
    smell5.smellRFID = @"00000005";
    smell5.smellName = @"草莓";
    smell5.smellImage = @"StrawberryImage";
    smell5.smellColor = @"#000000";
    
    Smell *smell6 = [[Smell alloc] init];
    smell6.smellRFID = @"00000006";
    smell6.smellName = @"西瓜";
    smell6.smellImage = @"WatermelonImage";
    smell6.smellColor = @"#000000";
    
    Smell *smell7 = [[Smell alloc] init];
    smell7.smellRFID = @"00000007";
    smell7.smellName = @"桔子";
    smell7.smellImage = @"OrangeImage";
    smell7.smellColor = @"#000000";
    
    Smell *smell8 = [[Smell alloc] init];
    smell8.smellRFID = @"00000008";
    smell8.smellName = @"芒果";
    smell8.smellImage = @"LemonImage";
    smell8.smellColor = @"#000000";
    pageSmellList = @[@[smell1,smell2,smell3,smell4,smell5,smell6,smell7,smell8],@[smell1,smell3,smell2,smell7,smell4,smell5,smell6,smell8]];
    
    [self selectSmellListWithIndex:0];
    [self setIsShare:YES];
    
    commandList = [NSMutableArray array];
    for (NSInteger i = 0; i < 60; i++) {
        ScriptCommand *command = [[ScriptCommand alloc] init];
        command.startRelativeTime = i;
        command.rfId = @"";
        command.duration = 1;
        command.smellName = @"间隔";
        command.type = SpaceCommand;
        command.power = (arc4random() % 100) / 100.0f;
        [commandList addObject:command];
    }
    
    originCommandList = [commandList copy];
    
    swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGesture)];
    swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight | UISwipeGestureRecognizerDirectionLeft;
    [self.bottomBackView addGestureRecognizer:swipeGestureRecognizer];
    
    needReconnecting = YES;
    [[BluetoothProcessManager defatultManager] registerNotify];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self registerNotifications];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [lineView setCenter:CGPointMake((lineView.frame.size.width - 20)/ 2.0f, 0)];
    [_collectionView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma -mark notification
-(void)smellFakeViewCenterChanged:(NSNotification *)notify
{
    NSDictionary *dic = [notify userInfo];
    if (dic) {
        CGFloat centerX = [[dic objectForKey:@"centerX"] floatValue];
        CGFloat centerY = [[dic objectForKey:@"centerY"] floatValue];
        if (centerX > 0 || centerY > 0) {
            CGPoint backCenter = [_collectionView convertPoint:CGPointMake(centerX, centerY) toView:[UIApplication sharedApplication].keyWindow];
            if (smellFakeView.originalPositionY > 0) {
                CGFloat temp = backCenter.y - smellFakeView.originalPositionY;
                [smellFakeView setToBackViewCenter:CGPointMake(backCenter.x, smellFakeView.originalCenter.y + temp)];
            }else{
                [smellFakeView setToBackViewCenter:backCenter];
            }
            
            if (operationManager) {
                CustomLewReorderableLayout *layout = (CustomLewReorderableLayout *)[self.collectionView collectionViewLayout];
                [layout setCellFakeIndexPath:operationManager.insertIndexPath];
            }
        }else{
            operationManager = nil;
        }
    }
}

-(void)onStartScanBluetooth:(NSNotification *)notify
{
    if (testTimer) {
        if ([testTimer isValid]) {
            [testTimer invalidate];
            testTimer = nil;
        }
    }
}

-(void)onCallbackBluetoothPowerOff:(NSNotification *)notify
{
    if (testTimer) {
        if ([testTimer isValid]) {
            [testTimer invalidate];
            testTimer = nil;
        }
    }
}

-(void)onCallbackScanBluetoothTimeout:(NSNotification *)notify
{
    
}

-(void)onCallbackBluetoothDisconnected:(NSNotification *)notify
{
    if (needReconnecting) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"设备未连接" message:@"iPad/设备蓝牙已断开，请重新连接！" delegate:self cancelButtonTitle:@"继续游戏" otherButtonTitles:@"重新连接", nil];
        [alertView show];
    }
}

-(void)onStartConnectToBluetooth:(NSNotification *)notify
{
    
}

-(void)onCallbackConnectToBluetoothSuccessfully:(NSNotification *)notify
{
    //心跳包
    testTimer = [NSTimer scheduledTimerWithTimeInterval:8 target:self selector:@selector(test) userInfo:nil repeats:YES];
    [testTimer fire];
}

-(void)onCallbackConnectToBluetoothTimeout:(NSNotification *)notify
{
    if (needReconnecting) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"设备未连接" message:@"iPad/设备蓝牙已断开，请重新连接！" delegate:self cancelButtonTitle:@"继续游戏" otherButtonTitles:@"重新连接", nil];
        [alertView show];
    }
}
#pragma -mark GestureRecognizer
-(void)swipeGesture
{
    [self changeSmellList];
}
#pragma -mark privateFunction
-(void)registerNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(smellFakeViewCenterChanged:) name:FakeViewCenterChangedNotify object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onStartScanBluetooth:) name:OnStartScanBluetooth object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCallbackBluetoothPowerOff:) name:OnCallbackBluetoothPowerOff object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCallbackScanBluetoothTimeout:) name:OnCallbackScanBluetoothTimeout object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCallbackBluetoothDisconnected:) name:OnCallbackBluetoothDisconnected object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onStartConnectToBluetooth:) name:OnStartConnectToBluetooth object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCallbackConnectToBluetoothSuccessfully:) name:OnCallbackConnectToBluetoothSuccessfully object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCallbackConnectToBluetoothTimeout:) name:OnCallbackConnectToBluetoothTimeout object:nil];
}

/**
 *  @author RenRenFenQi, 16-07-26 10:07:04
 *
 *  心跳包
 */
-(void)test
{
    if ([[BluetoothMacManager defaultManager] isConnected]) {
        [[BluetoothMacManager defaultManager] writeCharacteristicWithCommandStr:@""];
    }
}

-(void)setIsShare:(BOOL)share
{
    isShare = share;
    if (share) {
        [_btnShareOrDelete setImage:[UIImage imageNamed:@"ShareBtn"] forState:UIControlStateNormal];
    }else{
        [_btnShareOrDelete setImage:[UIImage imageNamed:@"DeleteBtn"] forState:UIControlStateNormal];
    }
}

-(void)changeVirtualCommandToRealCommand
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.type == %d",VirtualCommand];
    NSArray *filterArr = [commandList filteredArrayUsingPredicate:predicate];
    if (filterArr) {
        for (ScriptCommand *command in filterArr) {
            NSInteger index = [commandList indexOfObject:command];
            command.type = RealCommand;
            [_collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]]];
        }
    }
}

-(ScriptCommand *)searchVirtualCommand
{
    ScriptCommand *virtualCommand = nil;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.type == %d",VirtualCommand];
    NSArray *filterArr = [commandList filteredArrayUsingPredicate:predicate];
    if (filterArr && filterArr.count > 0) {
        virtualCommand = [filterArr objectAtIndex:0];
    }
    return virtualCommand;
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
            sv.delegate = self;
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

-(ScriptCommand *)searchFirstSpaceAfterIndex:(NSInteger)index
{
    ScriptCommand *command = nil;
    if ((index + 1) < commandList.count) {
        for (NSInteger i = index+1; i < commandList.count; i++) {
            ScriptCommand *tempCommand = [commandList objectAtIndex:i];
            if (tempCommand.type == SpaceCommand) {
                command = tempCommand;
                break;
            }
        }
    }
    return command;
}

-(NSInteger)doWithScriptCommandList:(NSArray *)scriptCommandList
{
    if (scriptCommandList.count == 0) {
        return 0;
    }
    
    ScriptCommand *previousCommand = nil;
    for (ScriptCommand *command in scriptCommandList) {
        if (previousCommand == nil) {
            command.startRelativeTime = 0;
        }else{
            command.startRelativeTime = previousCommand.startRelativeTime + previousCommand.duration;
        }
        //组成command命令
        if (![AppUtils isNullStr:command.rfId]) {
            CGFloat power =  command.power * 10;
            NSInteger iPower = [AppUtils floatToInt:power WithMaxValue:10];
            NSString *commandStr = [NSString stringWithFormat:@"F266%@%04lX%02lX55",command.rfId,(long)command.duration,(long)iPower];
            command.command = commandStr;
        }else{
            command.command = @"";
        }
        previousCommand = command;
    }
    
    NSInteger allTime = 0;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.type == %d",RealCommand];
    NSArray *filterArr = [commandList filteredArrayUsingPredicate:predicate];
    if (filterArr && filterArr.count > 0) {
        ScriptCommand *lastRealCommand = [filterArr lastObject];
        allTime = lastRealCommand.startRelativeTime + lastRealCommand.duration;
    }else{
        allTime = 0;
    }
    return allTime;
}

-(RelativeTimeScript *)dowithCacheDataFromLocal
{
    RelativeTimeScript *script = nil;
    NSString *macAddress = [[NSUserDefaults standardUserDefaults] objectForKey:KMY_BlutoothMacAddress_Key];
    if (macAddress) {
        NSString *jsonStr = [[NSUserDefaults standardUserDefaults] objectForKey:macAddress];
        if (jsonStr == nil) {
            return nil;
        }
        NSData *jsonStrData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonStrData options:kNilOptions error:&error];
        if (error == nil) {
            script = [[RelativeTimeScript alloc] init];
            script.scriptId = [dic objectForKey:@"scriptId"];
            script.scriptName = [dic objectForKey:@"scriptName"];
            script.sceneName = [dic objectForKey:@"sceneName"];
            script.scriptTime = [[dic objectForKey:@"scriptTime"] integerValue];
            script.isLoop = [[dic objectForKey:@"isLoop"] boolValue];
            script.state = (ScriptState)[[dic objectForKey:@"state"] integerValue];
            script.type = (ScriptType)[[dic objectForKey:@"type"] integerValue];
            NSString *scriptCommand = [dic objectForKey:@"scriptCommand"];
            if (scriptCommand) {
                NSError *error;
                NSArray *commandArray = [NSJSONSerialization JSONObjectWithData:[scriptCommand dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
                if (error == nil) {
                    for (NSDictionary *commandDic in commandArray) {
                        ScriptCommand *command = [[ScriptCommand alloc] init];
                        command.startRelativeTime = [[commandDic objectForKey:@"startRelativeTime"] integerValue];
                        command.rfId = [commandDic objectForKey:@"rfid"];
                        command.smellName = [commandDic objectForKey:@"smellName"];
                        command.duration = [[commandDic objectForKey:@"duration"] integerValue];
                        command.command = [commandDic objectForKey:@"command"];
                        command.desc = [commandDic objectForKey:@"description"];
                        command.color = [commandDic objectForKey:@"color"];
                        command.power = [[commandDic objectForKey:@"power"] floatValue];
                        [script.scriptCommandList addObject:command];
                    }
                }
            }
        }
        
    }
    return script;
}

-(NSString *)commandStringWithCommandList:(NSArray *)subCommandList
{
    NSString *jsonStr = nil;
    if (subCommandList && subCommandList.count > 0) {
        NSMutableArray *commandDicArray = [[NSMutableArray alloc] init];
        for (ScriptCommand *command in subCommandList) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setObject:@(command.startRelativeTime) forKey:@"startRelativeTime"];
            if (command.rfId) {
                [dic setObject:command.rfId forKey:@"rfid"];
            }
            
            if (command.smellName) {
                [dic setObject:command.smellName forKey:@"smellName"];
            }
            
            [dic setObject:@(command.duration) forKey:@"duration"];
            
            if (command.command) {
                [dic setObject:command.command forKey:@"command"];
            }
            
            if (command.desc) {
                [dic setObject:command.desc forKey:@"description"];
            }
            
            if (command.color) {
                [dic setObject:command.color forKey:@"color"];
            }
            
            [dic setObject:@(command.power) forKey:@"power"];
            [commandDicArray addObject:dic];
        }
        NSError *error;
        NSData *jsonStrData = [NSJSONSerialization dataWithJSONObject:commandDicArray options:NSJSONWritingPrettyPrinted error:&error];
        if (error == nil) {
            jsonStr = [[NSString alloc] initWithData:jsonStrData encoding:NSUTF8StringEncoding];
        }
        
    }
    return jsonStr;
}

-(NSString *)jsonStrWithRelativeTimeScript:(RelativeTimeScript *)script
{
    if (script == nil) {
        return nil;
    }
    NSString *jsonStr = nil;
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:script.scriptId forKey:@"scriptId"];
    [dic setObject:script.scriptName forKey:@"scriptName"];
    [dic setObject:script.sceneName forKey:@"sceneName"];
    [dic setObject:@(script.scriptTime) forKey:@"scriptTime"];
    [dic setObject:@(script.isLoop) forKey:@"isLoop"];
    [dic setObject:@(script.state) forKey:@"state"];
    [dic setObject:@(script.type) forKey:@"type"];
    NSString *commandJsonStr = [self commandStringWithCommandList:script.scriptCommandList];
    if (commandJsonStr) {
        [dic setObject:commandJsonStr forKey:@"scriptCommand"];
    }
    NSError *error;
    NSData *jsonStrData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    if (error == nil) {
        jsonStr = [[NSString alloc] initWithData:jsonStrData encoding:NSUTF8StringEncoding];
        if (jsonStr) {
            NSString *macAddress = [[NSUserDefaults standardUserDefaults] objectForKey:KMY_BlutoothMacAddress_Key];
            if (macAddress) {
                [[NSUserDefaults standardUserDefaults] setObject:jsonStr forKey:macAddress];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
    }
    return jsonStr;
}

-(RelativeTimeScript *)saveLocalRelativeTimeScript
{
    RelativeTimeScript *script = [[RelativeTimeScript alloc] init];
    script.scriptId = @"10000";
    script.scriptName = @"自定义脚本";
    script.sceneName = @"气味王国";
    script.state =  ScriptIsNormal;
    script.type =  ScriptIsRelativeTime;
    script.isLoop = NO;
    
    script.scriptTime = [self doWithScriptCommandList:commandList];
    script.scriptCommandList = [self generateScriptCommandList:commandList];
    [self jsonStrWithRelativeTimeScript:script];
    return script;
}

-(NSMutableArray *)generateScriptCommandList:(NSMutableArray *)list
{
    NSMutableArray *arr;
    if (list) {
        arr = [NSMutableArray arrayWithArray:[list copy]];
        for (NSInteger i = arr.count - 1; i >= 0 ; i--) {
            ScriptCommand *command = [arr lastObject];
            if (command.type == RealCommand) {
                break;
            }else{
                [arr removeObject:command];
            }
        }
    }else{
        arr = [NSMutableArray array];
    }
    return arr;
}

#pragma -mark ButtonEvent
-(IBAction)clickPlayBtn:(id)sender
{
    RelativeTimeScript *script = [self saveLocalRelativeTimeScript];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    PlayViewController *playVC = [storyboard instantiateViewControllerWithIdentifier:@"PlayViewIdentify"];
//    [playVC setScript:script PageSmellList:pageSmellList];
//    [self.navigationController wxs_pushViewController:playVC makeTransition:^(WXSTransitionProperty *transition) {
//        transition.animationType = WXSTransitionAnimationTypeFragmentShowFromRight;
//        transition.animationTime = 1.0f;
//        transition.backGestureEnable = NO;
//    }];
    
    FlipPlayViewController *playVC = [storyboard instantiateViewControllerWithIdentifier:@"FlipPlayViewIdentify"];
    [playVC setScript:script PageSmellList:pageSmellList];
    [self.navigationController wxs_pushViewController:playVC makeTransition:^(WXSTransitionProperty *transition) {
        transition.animationType = WXSTransitionAnimationTypeFragmentShowFromRight;
        transition.animationTime = 1.0f;
        transition.backGestureEnable = NO;
    }];

}

-(IBAction)clickShareBtn:(id)sender
{
    if (isShare) {
        [[ShareManage GetInstance] shareVideoToWeixinPlatform:0 themeUrl:@"http://www.qiweiwangguo.com/" thumbnail:[UIImage imageNamed:@"ShareThumbnailImage"] title:@"气味王国" descript:@"气味王国test"];
    }
}
#pragma -mark HomeCollectionViewCellProtocol
-(void)willAddWidthWithCommand:(ScriptCommand *)command
{
    if (command == nil || command.type != RealCommand) {
        return;
    }
    
    if (command.duration >= 5) {
        return;
    }
    NSInteger index = [commandList indexOfObject:command];
    ScriptCommand *spaceCommand = [self searchFirstSpaceAfterIndex:index];
    if (spaceCommand == nil) {
        return;
    }
    NSInteger spaceIndex = [commandList indexOfObject:spaceCommand];
    [_collectionView performBatchUpdates:^{
        command.duration += 1;
        [_collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]]];
        [commandList removeObject:spaceCommand];
        [_collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:spaceIndex inSection:0]]];
    } completion:^(BOOL finished) {
        NSInteger scriptTime = [self doWithScriptCommandList:commandList];
        [_lblTime setText:[AppUtils switchSecondsToTime:scriptTime]];
    }];
}

-(void)willMinusWidthWithCommand:(ScriptCommand *)command
{
    if (command == nil || command.type != RealCommand) {
        return;
    }
    
    if (command.duration <= 2) {
        return;
    }
    NSInteger index = [commandList indexOfObject:command];
    ScriptCommand *spaceCommand = [[ScriptCommand alloc] init];
    spaceCommand.startRelativeTime = 0;
    spaceCommand.rfId = @"";
    spaceCommand.duration = 1;
    spaceCommand.smellName = @"间隔";
    spaceCommand.type = SpaceCommand;
    spaceCommand.power = [AppUtils powerFixed:(arc4random() % 100) / 100.0f];
    
    [_collectionView performBatchUpdates:^{
        command.duration -= 1;
        [_collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]]];
        
        [commandList insertObject:spaceCommand atIndex:index+1];
        [_collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index + 1 inSection:0]]];
    } completion:^(BOOL finished) {
        NSInteger scriptTime = [self doWithScriptCommandList:commandList];
        [_lblTime setText:[AppUtils switchSecondsToTime:scriptTime]];
    }];
}
#pragma -mark UICollectionViewDelegate And DataSource
- (CGFloat)scrollSpeedValueInCollectionView:(UICollectionView *)collectionView
{
    return 5.0f;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return commandList.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    HomeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:HomeCollectionViewCellIdentify forIndexPath:indexPath];
    cell.delegate = self;
//    [cell inilizedView];
    ScriptCommand *command = [commandList objectAtIndex:indexPath.item];
    [cell setupWithScriptCommand:command];
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            
//        });
//    });
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ScriptCommand *command = [commandList objectAtIndex:indexPath.item];
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

- (CGFloat)reorderingItemAlpha:(UICollectionView * )collectionview inSection:(NSInteger)section
{
    return 1.0f;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath canMoveToIndexPath:(NSIndexPath *)toIndexPath{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath willMoveToIndexPath:(NSIndexPath *)toIndexPath
{
    NSLog(@"%d,%d",fromIndexPath.item,toIndexPath.item);
    ScriptCommand *command = [commandList objectAtIndex:fromIndexPath.item];
    if (command && command.type != VirtualCommand) {
        return;
    }
    if (fromIndexPath.item > toIndexPath.item) {
//        if (operationManager) {
//            [operationManager moveLeftOperation:toIndexPath];
//        }
        
        [collectionView performBatchUpdates:^{
            [collectionView moveItemAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
            [commandList removeObjectAtIndex:fromIndexPath.item];
            [commandList insertObject:command atIndex:toIndexPath.item];
            
            CustomLewReorderableLayout *layout = (CustomLewReorderableLayout *)[collectionView collectionViewLayout];
            [layout setCellFakeIndexPath:toIndexPath];
        } completion:^(BOOL finished) {
            UICollectionViewCell *insertCell = [_collectionView cellForItemAtIndexPath:toIndexPath];
            CGPoint center = CGPointMake(insertCell.center.x, insertCell.frame.size.height * [AppUtils powerFixed:command.power]);
            CGPoint backCenter = [collectionView convertPoint:center toView:[UIApplication sharedApplication].keyWindow];
            if (smellFakeView.originalPositionY > 0) {
                CGFloat temp = backCenter.y - smellFakeView.originalPositionY;
                [smellFakeView setToBackViewCenter:CGPointMake(backCenter.x, smellFakeView.originalCenter.y + temp)];
            }else{
                [smellFakeView setToBackViewCenter:backCenter];
            }

        }];
    }else{
        ScriptCommand *spaceCommand = [self searchFirstSpaceAfterIndex:fromIndexPath.item];
        if (spaceCommand) {
            NSInteger spaceIndex = [commandList indexOfObject:spaceCommand];
            [collectionView performBatchUpdates:^{
                [collectionView moveItemAtIndexPath:[NSIndexPath indexPathForItem:spaceIndex inSection:0] toIndexPath:fromIndexPath];
                [commandList removeObjectAtIndex:spaceIndex];
                [commandList insertObject:spaceCommand atIndex:fromIndexPath.item];
                CustomLewReorderableLayout *layout = (CustomLewReorderableLayout *)[collectionView collectionViewLayout];
                [layout setCellFakeIndexPath:[NSIndexPath indexPathForItem:fromIndexPath.item + 1 inSection:0]];
            } completion:^(BOOL finished) {
                UICollectionViewCell *insertCell = [_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:fromIndexPath.item + 1 inSection:0]];
                CGPoint center = CGPointMake(insertCell.center.x, insertCell.frame.size.height * [AppUtils powerFixed:command.power]);
                CGPoint backCenter = [collectionView convertPoint:center toView:[UIApplication sharedApplication].keyWindow];
                if (smellFakeView.originalPositionY > 0) {
                    CGFloat temp = backCenter.y - smellFakeView.originalPositionY;
                    [smellFakeView setToBackViewCenter:CGPointMake(backCenter.x, smellFakeView.originalCenter.y + temp)];
                }else{
                    [smellFakeView setToBackViewCenter:backCenter];
                }
            }];
        }
//        if (operationManager) {
//            [operationManager moveRightOperation:toIndexPath];
//        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath didMoveToIndexPath:(NSIndexPath *)toIndexPath{

}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout willBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout didBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout willEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout didEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

-(BOOL)collectionView:(UICollectionView *)collectionView canLongpressItemAtIndexPath:(NSIndexPath *)indexPath
{
    ScriptCommand *command = [commandList objectAtIndex:indexPath.item];
    if (command.type == RealCommand) {
        return YES;
    }
    return NO;
}

-(void)collectionView:(UICollectionView *)collectionView TouchLocation:(CGPoint)location atIndexPath:(NSIndexPath *)indexPath didEndTouch:(void (^)(BOOL isPushBack))completion
{
    if ([collectionView pointInside:location withEvent:nil]) {
        completion(YES);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self changeVirtualCommandToRealCommand];
        });
    }else{
        CGPoint locationOnBtn = [collectionView convertPoint:location toView:_btnShareOrDelete];
        if ([_btnShareOrDelete pointInside:locationOnBtn withEvent:nil]) {
            if (operationManager) {
                [operationManager deleteOperation:indexPath];
            }
            completion(NO);
        }else{
            completion(YES);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self changeVirtualCommandToRealCommand];
            });
        }
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self setIsShare:YES];
        if (operationManager) {
            operationManager = nil;
        }
        
        NSInteger scriptTime = [self doWithScriptCommandList:commandList];
        [_lblTime setText:[AppUtils switchSecondsToTime:scriptTime]];
    });
}

-(void)collectionView:(UICollectionView *)collectionView PanLocation:(CGPoint)location PanTranslation:(CGPoint)translation didChanged:(void (^)(void))completion{
    CGFloat panPower = [AppUtils powerFixed:location.y / collectionView.frame.size.height];
    ScriptCommand *virtualCommand = [self searchVirtualCommand];
    if (virtualCommand) {
        CGFloat virtualPower = [AppUtils powerFixed:virtualCommand.power];
        if (panPower > virtualPower || panPower < virtualPower) {
            [collectionView performBatchUpdates:^{
                virtualCommand.power = panPower;
                NSInteger index = [commandList indexOfObject:virtualCommand];
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
                [collectionView reloadItemsAtIndexPaths:@[indexPath]];
                
                UICollectionViewCell *insertCell = [_collectionView cellForItemAtIndexPath:indexPath];
                CGPoint center = CGPointMake(insertCell.center.x, insertCell.frame.size.height * [AppUtils powerFixed:virtualCommand.power]);
                [[NSNotificationCenter defaultCenter] postNotificationName:FakeViewCenterChangedNotify object:nil userInfo:@{@"centerX":@(center.x),@"centerY":@(center.y)}];
            } completion:^(BOOL finished) {
                
            }];
        }
    }
    NSIndexPath *indexPath = [collectionView indexPathForItemAtPoint:location];
    NSInteger panIndex = translation.x / WidthPerSecond;
    if (panIndex > 0) {
        
    }
    completion();
}

-(void)collectionView:(UICollectionView *)collectionView PanLocation:(CGPoint)location PanTranslation:(CGPoint)translation didMoveout:(void (^)(void))completion{
    completion();
}

-(void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout longTouchCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"长按第%ld行",indexPath.item);
    ScriptCommand *command = [commandList objectAtIndex:indexPath.item];
    if (command && command.type != RealCommand) {
        return;
    }
    smellFakeView = [[SmellFakeView alloc] initWithView:cell];
    smellFakeView.center = [self.collectionView convertPoint:cell.center toView:[UIApplication sharedApplication].keyWindow];
    smellFakeView.originalCenter = smellFakeView.center;
    
    CGPoint commandCenter = CGPointMake(cell.center.x, cell.frame.size.height * [AppUtils powerFixed:command.power]);
    CGPoint commandCenterOnScreen = [_collectionView convertPoint:commandCenter toView:[UIApplication sharedApplication].keyWindow];
    smellFakeView.originalPositionY = commandCenterOnScreen.y;
    [[UIApplication sharedApplication].keyWindow addSubview:smellFakeView];
    CustomLewReorderableLayout *layout = (CustomLewReorderableLayout *)collectionViewLayout;
    [layout setCellFakeViewOnScreen:smellFakeView];
    [smellFakeView pushFowardViewWithScale:1.0 completion:^(BOOL isFinished) {
        [collectionView performBatchUpdates:^{
            ScriptCommand *command = [commandList objectAtIndex:indexPath.item];
            command.type = VirtualCommand;
//            [collectionView reloadItemsAtIndexPaths:@[indexPath]];
        } completion:^(BOOL finished) {
            [self setIsShare:NO];
        }];
        
        operationManager = [[CollectionViewOperationManager alloc] initWithCommandArray:commandList WithInsertIndexPath:indexPath WithInsertSmell:nil];
        operationManager.collectionView = self.collectionView;
    }];
}
#pragma -mark SmellViewProtocol
-(void)longTouchWithTag:(NSInteger)tag
{
    Smell *smell = [smellList objectAtIndex:tag - 1];
    
    SmellView *sv = [self.view viewWithTag:tag];
    smellFakeView = [[SmellFakeView alloc] initWithView:sv];
    CGPoint fakeViewCenter = [self.bottomBackView convertPoint:sv.center toView:[UIApplication sharedApplication].keyWindow];
    smellFakeView.center = fakeViewCenter;
    smellFakeView.smell = smell;
    smellFakeView.originalCenter = fakeViewCenter;
    smellFakeView.originalPositionY = 0.0f;
    [[UIApplication sharedApplication].keyWindow addSubview:smellFakeView];
    [smellFakeView pushFowardViewWithScale:1.1 completion:^(BOOL isFinished) {
        
    }];
}

-(void)longTouchEnded
{
    if (smellFakeView) {
        operationManager = nil;
        [smellFakeView pushBackView:^(BOOL isFinished) {
            [smellFakeView removeFromSuperview];
            smellFakeView = nil;
            [self changeVirtualCommandToRealCommand];
            
            originCommandList = [commandList copy];
            
            NSInteger scriptTime = [self doWithScriptCommandList:commandList];
            [_lblTime setText:[AppUtils switchSecondsToTime:scriptTime]];
        }];
    }
}

-(void)panLocationChanged:(CGPoint)translation
{
    @synchronized (self) {
        if (smellFakeView) {
            CGPoint center = smellFakeView.center;
            center.x += translation.x;
            center.y += translation.y;
            smellFakeView.center = center;
            
            CGPoint pointInCollectionView = [_collectionView convertPoint:smellFakeView.center fromView:[UIApplication sharedApplication].keyWindow];
            if ([self.collectionView pointInside:pointInCollectionView withEvent:nil]) {
                NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:pointInCollectionView];
                NSLog(@"%ld",indexPath.item);
                ScriptCommand *virtualCommand = [commandList objectAtIndex:indexPath.item];
                if (virtualCommand.type == VirtualCommand) {
                    CGFloat power = pointInCollectionView.y / _collectionView.frame.size.height;
                    virtualCommand.power = [AppUtils powerFixed:power];
                    [_collectionView performBatchUpdates:^{
                        [_collectionView reloadItemsAtIndexPaths:@[indexPath]];
                    } completion:^(BOOL finished) {
                        
                    }];
                }
                
                if (operationManager == nil) {
                    operationManager = [[CollectionViewOperationManager alloc] initWithCommandArray:commandList WithInsertIndexPath:indexPath WithInsertSmell:smellFakeView.smell];
                    operationManager.collectionView = self.collectionView;
                    [operationManager insertOperation:indexPath];
                }else{
                    if (smellFakeView.center.x < smellFakeView.toBackViewCenter.x) {
                        if (operationManager) {
                            [operationManager moveLeftOperation:indexPath];
                        }
                    }else if (smellFakeView.center.x > smellFakeView.toBackViewCenter.x){
                        if (operationManager) {
                            [operationManager moveRightOperation:indexPath];
                        }
                    }
                }
                
            }else{
                if (operationManager) {
                    [smellFakeView setToBackViewCenter:smellFakeView.originalCenter];
                    operationManager = nil;
                    
                    ScriptCommand *virtualCommand = [self searchVirtualCommand];
                    if (virtualCommand) {
                        [_collectionView performBatchUpdates:^{
                            NSInteger index = [commandList indexOfObject:virtualCommand];
                            [_collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]]];
                            commandList = [NSMutableArray arrayWithArray:[originCommandList copy]];
                            
                            NSMutableArray *indexPathArr = [NSMutableArray array];
                            for (NSInteger i = index; i < index + virtualCommand.duration; i ++ ) {
                                [indexPathArr addObject:[NSIndexPath indexPathForItem:i inSection:0]];
                            }
                            [_collectionView insertItemsAtIndexPaths:indexPathArr];
                        } completion:^(BOOL finished) {
                            
                        }];
                    }
                    
                }
            }
        }
    }
}

-(void)panEnded
{
    
}

#pragma -mark UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.cancelButtonIndex) {
        needReconnecting = NO;
    }else{
        needReconnecting = YES;
        [[BluetoothProcessManager defatultManager] reconnectBluetooth];
    }
}
@end
