//
//  SODCloudTypes.h
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 16.03.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import <POSRx/POSRx.h>

typedef NS_ENUM(NSInteger, SODCloudType) {
    SODCloudTypeDropbox = 11
};

NS_INLINE NSString *SODStringFromCloudType(SODCloudType type) {
    switch (type) {
        case SODCloudTypeDropbox: return @"Dropbox";
    }
    return nil;
}

NS_INLINE BOOL SODIsValidCloudType(NSInteger type) {
    return SODStringFromCloudType(type) != nil;
}
