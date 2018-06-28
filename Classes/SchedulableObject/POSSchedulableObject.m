//
//  POSSchedulableObject.m
//  POSScheduling
//
//  Created by Pavel Osipov on 11.01.15.
//  Copyright © 2015 Pavel Osipov. All rights reserved.
//

#import "POSSchedulableObject.h"
#import "RACTargetQueueScheduler+POSScheduling.h"

#ifndef POS_ENABLE_RUNTIME_CHECKS
#   ifdef DEBUG
#       define POS_ENABLE_RUNTIME_CHECKS 1
#   endif
#endif

NS_ASSUME_NONNULL_BEGIN

@interface POSSchedulableObject ()
@property (nonatomic) RACTargetQueueScheduler *scheduler;
@end

@implementation POSSchedulableObject

- (instancetype)init {
    return [self initWithScheduler:[RACTargetQueueScheduler pos_mainThreadScheduler]];
}

- (instancetype)initWithScheduler:(RACTargetQueueScheduler *)scheduler {
    return [self initWithScheduler:scheduler safetyPredicate:nil];
}

- (instancetype)initWithScheduler:(RACTargetQueueScheduler *)scheduler
                  safetyPredicate:(nullable POSSafetyPredicate)safetyPredicate {
    POS_CHECK(scheduler);
    if (self = [super init]) {
        _scheduler = scheduler;
        [self p_protectForScheduler:scheduler predicate:safetyPredicate];
    }
    return self;
}

#pragma mark - POSSchedulable

- (RACSignal<__kindof id<POSSchedulable>> *)schedule {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        return [self.scheduler schedule:^{
            [subscriber sendNext:self];
            [subscriber sendCompleted];
        }];
    }];
}

- (void)scheduleBlock:(void (^)(id<POSSchedulable> schedulable))block {
    POS_CHECK(block);
    [self.scheduler schedule:^{
        block(self);
    }];
}

#pragma mark - Private

- (void)p_protectForScheduler:(RACTargetQueueScheduler *)scheduler
                    predicate:(nullable POSSafetyPredicate)predicate {
#if POS_ENABLE_RUNTIME_CHECKS
    [self
     pos_protectForScheduler:scheduler
     predicate:^BOOL(SEL selector, POSSelectorAttributes attributes) {
         if (pos_protocolContainsSelector(@protocol(POSSchedulable), selector, YES, YES)) {
             return NO;
         }
         return predicate ? predicate(selector, attributes) : YES;
     }];
#endif
}

@end

NS_ASSUME_NONNULL_END
