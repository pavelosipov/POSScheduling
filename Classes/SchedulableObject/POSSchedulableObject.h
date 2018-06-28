//
//  POSSchedulableObject.h
//  POSScheduling
//
//  Created by Pavel Osipov on 11.01.15.
//  Copyright © 2015 Pavel Osipov. All rights reserved.
//

#import "POSSchedulable.h"
#import "NSObject+POSScheduling.h"
#import <POSErrorHandling/POSErrorHandling.h>

NS_ASSUME_NONNULL_BEGIN

@interface POSSchedulableObject : NSObject <POSSchedulable>

/// Schedules object inside main thread scheduler with default protection options.
- (instancetype)init;

/// Schedules object inside specified scheduler with default protection options.
- (instancetype)initWithScheduler:(RACTargetQueueScheduler *)scheduler;

/// Schedules object inside specified scheduler and excludes some selectors from thread-correctness check.
- (instancetype)initWithScheduler:(RACTargetQueueScheduler *)scheduler
                  safetyPredicate:(nullable POSSafetyPredicate)safetyPredicate NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END

#define POS_SCHEDULABLE_INIT_UNAVAILABLE \
- (instancetype)initWithScheduler:(RACTargetQueueScheduler *)scheduler NS_UNAVAILABLE; \
- (instancetype)initWithScheduler:(RACTargetQueueScheduler *)scheduler \
                  safetyPredicate:(nullable POSSafetyPredicate)safetyPredicate NS_UNAVAILABLE;

#define POS_SCHEDULABLE_INIT_RECURSIVELY_UNAVAILABLE \
POS_INIT_UNAVAILABLE \
POS_SCHEDULABLE_INIT_UNAVAILABLE
