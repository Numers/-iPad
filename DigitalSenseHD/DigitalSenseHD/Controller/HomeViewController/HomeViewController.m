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
#import "Smell.h"

@interface HomeViewController ()<SmellViewProtocol>
{
    NSArray *smellList;
    SmellFakeView *smellFakeView;
}
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    Smell *smell1 = [[Smell alloc] init];
    smell1.smellName = @"香蕉";
    smell1.smellImage = @"FruitDefaultImage";
    
    Smell *smell2 = [[Smell alloc] init];
    smell2.smellName = @"苹果";
    smell2.smellImage = @"FruitDefaultImage";
    
    Smell *smell3 = [[Smell alloc] init];
    smell3.smellName = @"梨";
    smell3.smellImage = @"FruitDefaultImage";
    
    Smell *smell4 = [[Smell alloc] init];
    smell4.smellName = @"草莓";
    smell4.smellImage = @"FruitDefaultImage";
    
    Smell *smell5 = [[Smell alloc] init];
    smell5.smellName = @"菠萝";
    smell5.smellImage = @"FruitDefaultImage";
    
    Smell *smell6 = [[Smell alloc] init];
    smell6.smellName = @"公路";
    smell6.smellImage = @"FruitDefaultImage";
    
    Smell *smell7 = [[Smell alloc] init];
    smell7.smellName = @"黄瓜";
    smell7.smellImage = @"FruitDefaultImage";
    
    Smell *smell8 = [[Smell alloc] init];
    smell8.smellName = @"葡萄"; 
    smell8.smellImage = @"FruitDefaultImage";
    smellList = @[smell1,smell2,smell3,smell4,smell5,smell6,smell7,smell8];
    
    NSInteger i = 1;
    for (Smell *s in smellList) {
        SmellView *sv = [self.view viewWithTag:i];
        sv.delegate = self;
        [sv setSmell:s];
        i++;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma -mark SmellViewProtocol
-(void)longTouchWithTag:(NSInteger)tag
{
    Smell *smell = [smellList objectAtIndex:tag - 1];
    
    SmellView *sv = [self.view viewWithTag:tag];
    smellFakeView = [[SmellFakeView alloc] initWithView:sv];
    smellFakeView.originalCenter = sv.center;
    [self.view addSubview:smellFakeView];
    [smellFakeView pushFowardView];
}

-(void)longTouchEnded
{
    if (smellFakeView) {
        [smellFakeView pushBackView:^(BOOL isFinished) {
            [smellFakeView removeFromSuperview];
            smellFakeView = nil;
        }];
    }
}

-(void)panLocationChanged:(CGPoint)translation
{
    if (smellFakeView) {
        CGPoint center = smellFakeView.center;
        center.x += translation.x;
        center.y += translation.y;
        smellFakeView.center = center;
    }
}

-(void)panEnded
{
    
}
@end
