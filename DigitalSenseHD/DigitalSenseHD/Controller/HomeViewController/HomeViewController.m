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
#import "UIView+Boom.h"

#define HomeCollectionViewCellIdentify @"HomeCollectionViewCellIdentify"
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
    [self.progressView setProgress:1.0f];
    [self.progressView setHidden:YES];
    
    [self.navigationController setNavigationBarHidden:YES];
    UIImage *backgroundImage = [UIImage imageNamed:@"BackgroundImage"];
    self.view.layer.contents = (id)backgroundImage.CGImage;
    CustomLewReorderableLayout *layout = (CustomLewReorderableLayout *)[_collectionView collectionViewLayout];
    layout.delegate = self;
    layout.dataSource = self;
    
    [_collectionView setBackgroundColor:[UIColor clearColor]];
    [_collectionView setContentInset:UIEdgeInsetsMake(0, 8, 0, 10.5)];
    lineView = [[GraduatedLineView alloc] init];
    [_collectionView addSubview:lineView];
    [_collectionView sendSubviewToBack:lineView];
    
    [_collectionView registerClass:[HomeCollectionViewCell class] forCellWithReuseIdentifier:HomeCollectionViewCellIdentify];
    
    Smell *smell1 = [[Smell alloc] init];
    smell1.smellRFID = @"00000009";
    smell1.smellName = @"苹果";
    smell1.smellImage = @"AppleImage";
    smell1.smellColor = @"#bd1720";
    
    Smell *smell2 = [[Smell alloc] init];
    smell2.smellRFID = @"0000000A";
    smell2.smellName = @"香蕉";
    smell2.smellImage = @"BananaImage";
    smell2.smellColor = @"#ecbc33";
    
    Smell *smell3 = [[Smell alloc] init];
    smell3.smellRFID = @"0000000B";
    smell3.smellName = @"樱桃";
    smell3.smellImage = @"CherryImage";
    smell3.smellColor = @"#e63b45";
    
    Smell *smell4 = [[Smell alloc] init];
    smell4.smellRFID = @"0000000C";
    smell4.smellName = @"椰子";
    smell4.smellImage = @"CoconutImage";
    smell4.smellColor = @"#764624";
    
    Smell *smell5 = [[Smell alloc] init];
    smell5.smellRFID = @"0000000D";
    smell5.smellName = @"榴莲";
    smell5.smellImage = @"DurianImage";
    smell5.smellColor = @"#b8b929";
    
    Smell *smell6 = [[Smell alloc] init];
    smell6.smellRFID = @"0000000E";
    smell6.smellName = @"葡萄";
    smell6.smellImage = @"GrapeImage";
    smell6.smellColor = @"#9671b9";
    
    Smell *smell7 = [[Smell alloc] init];
    smell7.smellRFID = @"0000000F";
    smell7.smellName = @"哈密瓜";
    smell7.smellImage = @"Hami-melonImage";
    smell7.smellColor = @"#dde29e";
    
    Smell *smell8 = [[Smell alloc] init];
    smell8.smellRFID = @"00000010";
    smell8.smellName = @"柠檬";
    smell8.smellImage = @"LemonImage";
    smell8.smellColor = @"#fff442";
    
    Smell *smell9 = [[Smell alloc] init];
    smell9.smellRFID = @"00000011";
    smell9.smellName = @"荔枝";
    smell9.smellImage = @"LitchiImage";
    smell9.smellColor = @"#9f2429";
    
    Smell *smell10 = [[Smell alloc] init];
    smell10.smellRFID = @"00000012";
    smell10.smellName = @"芒果";
    smell10.smellImage = @"MangoImage";
    smell10.smellColor = @"#f8d25b";
    
    Smell *smell11 = [[Smell alloc] init];
    smell11.smellRFID = @"00000013";
    smell11.smellName = @"橙子";
    smell11.smellImage = @"OrangeImage";
    smell11.smellColor = @"#fd9927";
    
    Smell *smell12 = [[Smell alloc] init];
    smell12.smellRFID = @"00000014";
    smell12.smellName = @"木瓜";
    smell12.smellImage = @"PapayaImage";
    smell12.smellColor = @"#ecd347";
    
    Smell *smell13 = [[Smell alloc] init];
    smell13.smellRFID = @"00000015";
    smell13.smellName = @"梨";
    smell13.smellImage = @"PearImage";
    smell13.smellColor = @"#c1e245";
    
    Smell *smell14 = [[Smell alloc] init];
    smell14.smellRFID = @"00000016";
    smell14.smellName = @"菠萝";
    smell14.smellImage = @"PineappleImage";
    smell14.smellColor = @"#c1e245";
    
    Smell *smell15 = [[Smell alloc] init];
    smell15.smellRFID = @"00000017";
    smell15.smellName = @"草莓";
    smell15.smellImage = @"StrawberryImage";
    smell15.smellColor = @"#d30f1b";
    
    Smell *smell16 = [[Smell alloc] init];
    smell16.smellRFID = @"00000018";
    smell16.smellName = @"西瓜";
    smell16.smellImage = @"WatermelonImage";
    smell16.smellColor = @"#579d2e";
    
    pageSmellList = @[@[smell1,smell2,smell3,smell4,smell5,smell6,smell7,smell8],@[smell9,smell10,smell11,smell12,smell13,smell14,smell15,smell16]];
    
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
    
    [AppUtils showHudProgress:@"加载中..." ForView:self.view];
}

-(void)onCallbackBluetoothPowerOff:(NSNotification *)notify
{
    needReconnecting = YES;
    [AppUtils hidenHudProgressForView:self.view];
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
    [AppUtils hidenHudProgressForView:self.view];
    if (needReconnecting) {
        [self longTouchEnded];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"设备未连接" message:@"iPad/设备蓝牙已断开，请重新连接！" delegate:self cancelButtonTitle:@"继续编辑" otherButtonTitles:@"重新连接", nil];
        [alertView show];
    }
}

-(void)onStartConnectToBluetooth:(NSNotification *)notify
{
    
}

-(void)onCallbackConnectToBluetoothSuccessfully:(NSNotification *)notify
{
    [AppUtils hidenHudProgressForView:self.view];
    //心跳包
    testTimer = [NSTimer scheduledTimerWithTimeInterval:8 target:self selector:@selector(test) userInfo:nil repeats:YES];
    [testTimer fire];
}

-(void)onCallbackConnectToBluetoothTimeout:(NSNotification *)notify
{
    [AppUtils hidenHudProgressForView:self.view];
    if (needReconnecting) {
        [self longTouchEnded];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"设备未连接" message:@"iPad/设备蓝牙已断开，请重新连接！" delegate:self cancelButtonTitle:@"继续编辑" otherButtonTitles:@"重新连接", nil];
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
            command.type = RealCommand;
        }
        [_collectionView reloadItemsAtIndexPaths:[_collectionView indexPathsForVisibleItems]];
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
    if (smellFakeView) {
        return;
    }
    RelativeTimeScript *script = [self saveLocalRelativeTimeScript];
    if (script.scriptCommandList && script.scriptCommandList.count == 0) {
        UIImageView *customImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SadFaceImage"]];
        [AppUtils showCustomHudProgress:@"请先编辑再播放哟" CustomView:customImageView ForView:self.view];
        return;
    }
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
    if (smellFakeView) {
        return;
    }
    if (isShare) {
        [[ShareManage GetInstance] shareVideoToWeixinPlatform:0 themeUrl:@"http://www.qiweiwangguo.com/" thumbnail:[UIImage imageNamed:@"ShareThumbnailImage"] title:@"气味音乐-带你进入全新的嗅觉体验！" descript:@"气味音乐DIY，随心编辑，畅情感受，让一切味道尽在掌握，要不要来试试？"];
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

-(void)willDisableScrollView
{
    [_collectionView setScrollEnabled:NO];
}

-(void)willEnableScrollView
{
    [_collectionView setScrollEnabled:YES];
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
    [cell setupWithScriptCommand:command isShowCircleButton:YES];
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
    ScriptCommand *command = [commandList objectAtIndex:fromIndexPath.item];
    if (command && command.type != VirtualCommand) {
        return;
    }
    if (fromIndexPath.item > toIndexPath.item) {
//        if (operationManager) {
//            [operationManager moveLeftOperation:toIndexPath];
//        }
        NSLog(@"go into operation by moveLeft");
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
        NSLog(@"go into operation by moveRight");
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
    if (smellFakeView == nil) {
        return;
    }
    if (smellFakeView.originalPositionY <=0.0f) {
        return;
    }
    if ([collectionView pointInside:location withEvent:nil]) {
        completion(YES);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self changeVirtualCommandToRealCommand];
            originCommandList = [NSMutableArray arrayWithArray:[commandList copy]];
        });
    }else{
        CGPoint locationOnBtn = [collectionView convertPoint:location toView:_btnShareOrDelete];
        if ([_btnShareOrDelete pointInside:locationOnBtn withEvent:nil]) {
            if (operationManager) {
                [operationManager deleteOperation:indexPath];
            }
            originCommandList = [NSMutableArray arrayWithArray:[commandList copy]];
            completion(NO);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [_btnShareOrDelete boom];
            });
        }else{
            completion(YES);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self changeVirtualCommandToRealCommand];
                originCommandList = [NSMutableArray arrayWithArray:[commandList copy]];
            });
        }
    }
    smellFakeView = nil;
    
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
                CGPoint backCenter = [_collectionView convertPoint:center toView:[UIApplication sharedApplication].keyWindow];
                if (smellFakeView.originalPositionY > 0) {
                    CGFloat temp = backCenter.y - smellFakeView.originalPositionY;
                    [smellFakeView setToBackViewCenter:CGPointMake(backCenter.x, smellFakeView.originalCenter.y + temp)];
                }else{
                    
                }

            } completion:^(BOOL finished) {
                
            }];
        }
    }
    completion();
}

-(void)collectionView:(UICollectionView *)collectionView PanLocation:(CGPoint)location PanTranslation:(CGPoint)translation didMoveout:(void (^)(void))completion{
    CGPoint locationOnBtn = [collectionView convertPoint:location toView:_btnShareOrDelete];
    if ([_btnShareOrDelete pointInside:locationOnBtn withEvent:nil]) {
        [_btnShareOrDelete setImage:[UIImage imageNamed:@"DeleteHighlightBtn"] forState:UIControlStateNormal];
    }else{
        [_btnShareOrDelete setImage:[UIImage imageNamed:@"DeleteBtn"] forState:UIControlStateNormal];
    }
}

-(void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout longTouchCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    ScriptCommand *command = [commandList objectAtIndex:indexPath.item];
    if (command && command.type != RealCommand) {
        return;
    }
    if (smellFakeView) {
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
            [smellFakeView startEarthQuake];
        }];
        
        operationManager = [[CollectionViewOperationManager alloc] initWithCommandArray:commandList WithInsertIndexPath:indexPath WithInsertSmell:nil];
        operationManager.collectionView = self.collectionView;
    }];
}
#pragma -mark SmellViewProtocol
-(void)longTouchWithTag:(NSInteger)tag
{
    if (smellFakeView) {
        return;
    }
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
        if (smellFakeView.originalPositionY > 0) {
            return;
        }
        operationManager = nil;
        [smellFakeView pushBackView:^(BOOL isFinished) {
            [smellFakeView removeFromSuperview];
            smellFakeView = nil;
            [self changeVirtualCommandToRealCommand];
            
            originCommandList = [NSMutableArray arrayWithArray:[commandList copy]];
            
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
                ScriptCommand *virtualCommand = [commandList objectAtIndex:indexPath.item];
                if (virtualCommand) {
                    if (virtualCommand.type == VirtualCommand) {
                        CGFloat power = pointInCollectionView.y / _collectionView.frame.size.height;
                        virtualCommand.power = [AppUtils powerFixed:power];
                        HomeCollectionViewCell *cell = (HomeCollectionViewCell *)[_collectionView cellForItemAtIndexPath:indexPath];
                        [cell setupWithScriptCommand:virtualCommand isShowCircleButton:YES];
//                        [_collectionView reloadItemsAtIndexPaths:@[indexPath]];
//                        [_collectionView performBatchUpdates:^{
//                            NSLog(@"333333: %d",indexPath.item);
//                            
//                            NSLog(@"4444444: %d",indexPath.item);
//                        } completion:^(BOOL finished) {
//                            
//                        }];
                    }
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
                            [commandList removeObject:virtualCommand];
                            [_collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]]];
                            
                            for (NSInteger i = index; i < index + virtualCommand.duration; i ++ ) {
                                ScriptCommand *spaceCommand = [[ScriptCommand alloc] init];
                                spaceCommand.startRelativeTime = 0;
                                spaceCommand.rfId = @"";
                                spaceCommand.duration = 1;
                                spaceCommand.smellName = @"间隔";
                                spaceCommand.type = SpaceCommand;
                                spaceCommand.power = [AppUtils powerFixed:(arc4random() % 100) / 100.0f];
                                [commandList insertObject:spaceCommand atIndex:i];
                                [_collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:i inSection:0]]];
                            }
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
