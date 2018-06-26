//
//  RACTargetQueueScheduler+POSScheduling.m
//  POSScheduling
//
//  Created by Pavel Osipov on 29.10.15.
//  Copyright © 2015 Pavel Osipov. All rights reserved.
//

#import "RACTargetQueueScheduler+POSScheduling.h"

NS_ASSUME_NONNULL_BEGIN

@implementation RACTargetQueueScheduler (POSScheduling)

+ (instancetype)pos_scheduler {
    return (id)[RACScheduler scheduler];
}

+ (instancetype)pos_mainThreadScheduler {
    return (id)[RACScheduler mainThreadScheduler];
}

@end

NS_ASSUME_NONNULL_END
