//
//  SODNetworkStatus.h
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 04.04.13.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(int, SODNetworkStatus) {
    SODNetworkStatusOffline = 0,
    SODNetworkStatusWiFi,
    SODNetworkStatusCellular
};

NS_INLINE NSString *SODStringFromNetworkStatus(SODNetworkStatus status) {
    switch (status) {
        case SODNetworkStatusOffline:  return @"Offline";
        case SODNetworkStatusWiFi:     return @"Wi-Fi";
        case SODNetworkStatusCellular: return @"Cellular";
    }
}

@interface NSNumber (SODNetworkStatus)
@property (nonatomic, readonly) SODNetworkStatus sod_networkStatus;
@end
