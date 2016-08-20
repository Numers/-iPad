//
//  DataAnalizer.h
//  IntelligentMask
//
//  Created by baolicheng on 16/1/19.
//  Copyright © 2016年 RenRenFenQi. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol DataAnalizerProtocol <NSObject>
-(void)outputData:(NSData *)data;
@end

@interface DataAnalizer : NSObject
{
    NSMutableData *cacheData;
}
@property(nonatomic, assign) id<DataAnalizerProtocol> delegate;
-(void)inputData:(NSData *)data;
@end
