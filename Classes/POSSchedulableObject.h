//
//  POSSchedulableObject.h
//  POSSchedulableObject
//
//  Created by Pavel Osipov on 11.01.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import "POSSchedulable.h"
#import "POSContracts.h"
#import "NSException+POSSchedulableObject.h"
#import "RACTargetQueueScheduler+POSSchedulableObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface POSScheduleProtectionOptions : NSObject

+ (instancetype)defaultOptionsForClass:(Class)aClass;

+ (instancetype)include:(nullable RACSequence *)includes
                exclude:(nullable RACSequence *)excludes;

- (instancetype)include:(RACSequence *)includes;
- (instancetype)exclude:(RACSequence *)excludes;

@end

@interface POSSchedulableObject : NSObject <POSSchedulable>

/// Schedules object inside main thread scheduler.
- (instancetype)init;

/// Schedules object inside specified scheduler.
- (instancetype)initWithScheduler:(RACTargetQueueScheduler *)scheduler;

/// Schedules object inside specified scheduler with custom excludes.
- (instancetype)initWithScheduler:(RACTargetQueueScheduler *)scheduler
                          options:(nullable POSScheduleProtectionOptions *)options;

+ (BOOL)protect:(id<NSObject>)object
   forScheduler:(RACTargetQueueScheduler *)scheduler;

+ (BOOL)protect:(id<NSObject>)object
   forScheduler:(RACTargetQueueScheduler *)scheduler
        options:(nullable POSScheduleProtectionOptions *)options;

+ (RACSequence *)selectorsForClass:(Class)aClass;
+ (RACSequence *)selectorsForClass:(Class)aClass
                     nonatomicOnly:(BOOL)nonatomicOnly
                         predicate:(BOOL (^ __nullable)(SEL selector))predicate;
+ (RACSequence *)selectorsForProtocol:(Protocol *)aProtocol;

@end

NS_ASSUME_NONNULL_END

#define POS_SCHEDULABLE_INIT_UNAVAILABLE \
- (instancetype)initWithScheduler:(RACTargetQueueScheduler *)scheduler NS_UNAVAILABLE; \
- (instancetype)initWithScheduler:(RACTargetQueueScheduler *)scheduler \
                          options:(nullable POSScheduleProtectionOptions *)options NS_UNAVAILABLE;

#define POS_SCHEDULABLE_INIT_RECURSIVELY_UNAVAILABLE \
POS_INIT_UNAVAILABLE \
POS_SCHEDULABLE_INIT_UNAVAILABLE
