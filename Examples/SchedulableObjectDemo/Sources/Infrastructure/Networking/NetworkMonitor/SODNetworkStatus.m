//
//  SODNetworkStatus.m
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 04.04.13.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import "SODNetworkStatus.h"
#import <POSRx/NSException+POSRx.h>

@implementation NSNumber (SODNetworkStatus)

- (SODNetworkStatus)sod_networkStatus {
    const int value = self.intValue;
    POSRX_CHECK(value >= SODNetworkStatusOffline && value <= SODNetworkStatusCellular);
    return value;
}

@end
