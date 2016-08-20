//
//  BluetoothMacManager.h
//  IntelligentMask
//
//  Created by baolicheng on 16/3/24.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import <Foundation/Foundation.h>
#define BluetoothDeliveryDataNotify @"BluetoothDeliverryDataNotify"
#define kBluetoothPowerOnNotify @"KBluetoothPowerOnNotify"
#define kBluetoothPowerOffNotify @"KBluetoothPowerOffNotify"

#define LastConnectDeviceNameKey @"LastConnectDeviceNameKey"
typedef enum{
    MacAddress = 0xFF,
    OpenDeviceTime = 0xFE,
    CloseDeviceTime = 0xFD,
    WakeUpDevice = 0xFC,
    SleepDevice = 0xFB,
    BottleInfo = 0xFA,
    EmitSmell = 0xF9,
    EmitCustomSmell = 0xF2,
    EmitRelativeTimeSmell = 0xF5,
    EmitAbsoluteDateTimeSmell = 0xF6,
    EmitAbsoluteWeekTimeSmell = 0xF3,
    BottleInfoCompletely = 0xF7
} CommandType;

typedef enum{
    CommandMacAddress,
    CommandOpenDeviceTime,
    CommandCloseDeviceTime,
    CommandWakeUpDevice,
    CommandSleepDevice,
    CommandBottleInfo
} BluetoothCommand;

typedef enum{
    CallbackSuccess = 1,
    CallbackTimeout,
    CallbackDisconnect,
    CallbackBluetoothPowerOff,
    CallbackDidFailToConnectPeriphera,
    CallbackDidDiscoverCharacteristicsError,
    CallbackDidUpdateNotificationStateError,
    CallbackDidWriteValueError,
    CallbackDidDiscoverServicesError
}CallbackType;

typedef enum{
    ConnectToDevice = 1,
    ConnectForSearch,
    ConnectForScan
}ConnectType;
typedef void (^BluetoothCallBak)(BOOL completely,CallbackType backType, id obj, ConnectType connectType);
@protocol BluetoothManagerProtocol <NSObject>
-(void)deliveryData:(NSData *)data;
@end

@class CBPeripheral;
@interface BluetoothMacManager : NSObject
+(id)defaultManager;

-(void)setBluetoothManagerDelegate:(id<BluetoothManagerProtocol>)viewController;
/**
 *  @author RenRenFenQi, 16-01-19 14:01:35
 *
 *  启动蓝牙设备进行搜索
 */
-(void)startBluetoothDevice;

/**
 *  @author RenRenFenQi, 16-04-28 17:04:09
 *
 *  启动蓝牙设备进行搜索
 *
 *  @param type     连接类型，搜索或者直接搜索到就连接
 *  @param callBack 完成后回调
 */
-(void)startScanBluetoothDevice:(ConnectType)type callBack:(BluetoothCallBak)callBack;
/**
 *  @author RenRenFenQi, 16-01-19 15:01:05
 *
 *  取消或者订阅智能硬件设备蓝牙
 *
 *  @param isNotify YES/订阅  NO/取消订阅
 */
-(void)registerNotificationWithValue:(BOOL)isNotify;

/**
 *  @author RenRenFenQi, 16-01-19 15:01:09
 *
 *  给硬件设备发送指令
 *
 *  @param command 指令码
 */
-(void)writeCharacteristicWithCommand:(BluetoothCommand)command;

/**
 *  @author RenRenFenQi, 16-06-17 13:06:43
 *
 *  给硬件设备发送指令
 *
 *  @param commandStr 指令字符串
 */
-(void)writeCharacteristicWithCommandStr:(NSString *)commandStr;

/**
 *  @author RenRenFenQi, 16-05-31 17:05:30
 *
 *  给硬件设备发送开启设备味道指令
 *
 *  @param rfId     瓶子的RFID
 *  @param interval 开启的持续时间/单位秒
 */
-(void)writeCharacteristicWithRFID:(NSString *)rfId WithTimeInterval:(int)interval;

/**
 *  @author RenRenFenQi, 16-01-22 14:01:40
 *
 *  断开蓝牙连接
 */
-(void)stopBluetoothDevice;

/**
 *  @author RenRenFenQi, 16-01-28 15:01:26
 *
 *  蓝牙是否连接状态
 *
 *  @return YES/是 NO/否
 */
-(BOOL)isConnected;

/**
 *  @author RenRenFenQi, 16-08-04 12:08:28
 *
 *  蓝牙是否打开
 *
 *  @return YES/是 NO/否
 */
-(BOOL)isPoweredOn;

/**
 *  @author RenRenFenQi, 16-03-22 17:03:10
 *
 *  连接设备
 *
 *  @param peripheral 蓝牙设备
 */
-(void)connectToPeripheral:(CBPeripheral *)peripheral callBack:(BluetoothCallBak)callBack;

/**
 *  @author RenRenFenQi, 16-06-24 15:06:17
 *
 *  根据设备名连接设备
 *
 *  @param peripheralName 设备名
 *  @param callBack       回调函数
 */
-(void)connectToPeripheralWithName:(NSString *)peripheralName callBack:(BluetoothCallBak)callBack;
/**
 *  @author RenRenFenQi, 16-03-25 14:03:55
 *
 *  获取搜索到的所有智能设备及mac地址
 *
 *  @return 智能设备字典 @{@"peripheral":peripheral,@"mac":macAdress}
 */
-(NSArray *)returnAllSearchedPeripheralsDictionary;

/**
 *  @author RenRenFenQi, 16-06-24 15:06:46
 *
 *  获取搜索到的所有智能设备
 *
 *  @return 智能设备列表
 */
-(NSArray *)returnAllScanPeripherals;

/**
 *  @author RenRenFenQi, 16-06-24 15:06:46
 *
 *  获取搜索到的所有智能设备名字
 *
 *  @return 智能设备名字列表
 */
-(NSArray *)returnAllScanPeripheralNames;

/**
 *  @author RenRenFenQi, 16-07-19 13:07:38
 *
 *  返回当前连接的设备
 *
 *  @return 当前连接的设备
 */
-(CBPeripheral *)returnConnectedPeripheral;

/**
 *  @author RenRenFenQi, 16-06-24 18:06:11
 *
 *  判断名字与当前连接蓝牙是否匹配
 *
 *  @param name 设备
 *
 *  @return YES/匹配 NO/不匹配
 */
-(BOOL)isMatchConnectedPeripheral:(CBPeripheral *)peripheral;
@end
