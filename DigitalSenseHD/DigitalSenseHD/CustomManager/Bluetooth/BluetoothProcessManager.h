//
//  BluetoothProcessManager.h
//  DigitalSense
//
//  Created by baolicheng on 16/7/18.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import <Foundation/Foundation.h>
#define OnStartScanBluetooth @"OnStartScanBluetooth"
#define OnCallbackBluetoothPowerOff @"OnCallbackBluetoothPowerOff"
#define OnCallbackScanBluetoothTimeout @"OnCallbackScanBluetoothTimeout"
#define OnCallbackBluetoothDisconnected @"OnCallbackBluetoothDisconnected"
#define OnStartConnectToBluetooth @"OnStartConnectToBluetooth"
#define OnCallbackConnectToBluetoothSuccessfully @"OnCallbackConnectToBluetoothSuccessfully"
#define OnCallbackConnectToBluetoothTimeout @"OnCallbackConnectToBluetoothTimeout"

@interface BluetoothProcessManager : NSObject
+(instancetype)defatultManager;

-(void)registerNotify;

-(void)startScanBluetooth;

-(void)reconnectBluetooth;

-(void)connectToBluetooth:(NSString *)deviceName WithPeripheral:(id)peripheral;
@end
