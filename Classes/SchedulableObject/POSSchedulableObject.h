//
//  POSSchedulableObject.h
//  POSScheduling
//
//  Created by Pavel Osipov on 11.01.15.
//  Copyright © 2015 Pavel Osipov. All rights reserved.
//

#import "POSSchedulable.h"
#import <POSErrorHandling/POSErrorHandling.h>

NS_ASSUME_NONNULL_BEGIN

@interface POSScheduleProtectionOptions : NSObject

+ (instancetype)defaultOptionsForClass:(Class)aClass;

+ (instancetype)include:(nullable RACSequence<NSValue *> *)includes
                exclude:(nullable RACSequence<NSValue *> *)excludes;

- (instancetype)include:(nullable RACSequence<NSValue *> *)includes;
- (instancetype)exclude:(nullable RACSequence<NSValue *> *)excludes;

@end

@interface POSSchedulableObject : NSObject <POSSchedulable>

+ (BOOL)protect:(id<NSObject>)object
   forScheduler:(RACTargetQueueScheduler *)scheduler;

+ (BOOL)protect:(id<NSObject>)object
   forScheduler:(RACTargetQueueScheduler *)scheduler
        options:(nullable POSScheduleProtectionOptions *)options;

+ (RACSequence<NSValue *> *)selectorsForClass:(Class)aClass;
+ (RACSequence<NSValue *> *)selectorsForClass:(Class)aClass
                     nonatomicOnly:(BOOL)nonatomicOnly
                         predicate:(BOOL (^ __nullable)(SEL selector))predicate;
+ (RACSequence<NSValue *> *)selectorsForProtocol:(Protocol *)aProtocol;

/// Schedules object inside main thread scheduler.
- (instancetype)init;

/// Schedules object inside specified scheduler.
- (instancetype)initWithScheduler:(RACTargetQueueScheduler *)scheduler;

/// Schedules object inside specified scheduler with custom excludes.
- (instancetype)initWithScheduler:(RACTargetQueueScheduler *)scheduler
                          options:(nullable POSScheduleProtectionOptions *)options NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END

#define POS_SCHEDULABLE_INIT_UNAVAILABLE \
- (instancetype)initWithScheduler:(RACTargetQueueScheduler *)scheduler NS_UNAVAILABLE; \
- (instancetype)initWithScheduler:(RACTargetQueueScheduler *)scheduler \
                          options:(nullable POSScheduleProtectionOptions *)options NS_UNAVAILABLE;

#define POS_SCHEDULABLE_INIT_RECURSIVELY_UNAVAILABLE \
POS_INIT_UNAVAILABLE \
POS_SCHEDULABLE_INIT_UNAVAILABLE
