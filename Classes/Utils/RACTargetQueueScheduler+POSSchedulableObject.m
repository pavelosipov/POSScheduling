//
//  RACTargetQueueScheduler+POSSchedulableObject.m
//  POSSchedulableObject
//
//  Created by Pavel Osipov on 29.10.15.
//  Copyright © 2015 Pavel Osipov. All rights reserved.
//

#import "RACTargetQueueScheduler+POSSchedulableObject.h"

@implementation RACTargetQueueScheduler (POSSchedulableObject)

+ (RACTargetQueueScheduler *)pos_scheduler {
    return (id)[RACScheduler scheduler];
}

+ (RACTargetQueueScheduler *)pos_mainThreadScheduler {
    return (id)[RACScheduler mainThreadScheduler];
}

@end
