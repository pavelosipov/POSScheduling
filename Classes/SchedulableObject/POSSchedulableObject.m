//
//  POSSchedulableObject.m
//  POSScheduling
//
//  Created by Pavel Osipov on 11.01.15.
//  Copyright © 2015 Pavel Osipov. All rights reserved.
//

#import "POSSchedulableObject.h"
#import "RACTargetQueueScheduler+POSScheduling.h"

#import <ReactiveObjC/NSInvocation+RACTypeParsing.h>
#import <objc/runtime.h>

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

- (void)scheduleSelector:(SEL)selector {
    [self scheduleBlock:^(id<POSSchedulable> this) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [this performSelector:selector];
#pragma clang diagnostic pop
    }];
}

- (void)scheduleSelector:(SEL)selector withArguments:(nullable id)firstArg, ... {
    static const NSInteger kMaxArgCount = 16;
    static char argKeys[kMaxArgCount];
    NSInvocation *invocation = [self pos_invocationForSelector:selector];
    va_list args;
    va_start(args, firstArg);
    NSInteger argIndex = 2;
    for (id arg = firstArg; arg != nil; arg = va_arg(args, id), ++argIndex) {
        NSParameterAssert(argIndex < kMaxArgCount);
        [invocation setArgument:&arg atIndex:argIndex];
        objc_setAssociatedObject(invocation, &argKeys[argIndex], arg, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    va_end(args);
    [self scheduleBlock:^(id<POSSchedulable> this) {
        [invocation invokeWithTarget:this];
    }];
}

- (RACSignal *)autoschedule:(SEL)selector {
    return [self p_autoscheduleInvocation:[self pos_invocationForSelector:selector]];
}

- (RACSignal *)autoschedule:(SEL)selector withArguments:(nullable id)firstArg, ... {
    static const NSInteger kMaxArgCount = 16;
    static char argKeys[kMaxArgCount];
    NSInvocation *invocation = [self pos_invocationForSelector:selector];
    va_list args;
    va_start(args, firstArg);
    NSInteger argIndex = 2;
    for (id arg = firstArg; arg != nil; arg = va_arg(args, id), ++argIndex) {
        NSParameterAssert(argIndex < kMaxArgCount);
        [invocation setArgument:&arg atIndex:argIndex];
        objc_setAssociatedObject(invocation, &argKeys[argIndex], arg, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    va_end(args);
    return [self p_autoscheduleInvocation:invocation];
}

#pragma mark - Private

- (RACSignal *)p_autoscheduleInvocation:(NSInvocation *)invocation {
    RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber> subscriber) {
        RACSerialDisposable *disposable = [[RACSerialDisposable alloc] init];
        [self scheduleBlock:^(id<POSSchedulable> this) {
            if ([disposable isDisposed]) {
                return;
            }
            [invocation invokeWithTarget:this];
            id<NSObject> invokationResult = invocation.rac_returnValue;
            if ([invokationResult isKindOfClass:[RACSignal class]]) {
                disposable.disposable = [(RACSignal *)invokationResult subscribe:subscriber];
            } else {
                [subscriber sendNext:invokationResult];
                [subscriber sendCompleted];
            }
        }];
        return disposable;
    }];
    return [signal deliverOn:[RACScheduler currentScheduler]];
}

- (void)p_protectForScheduler:(RACTargetQueueScheduler *)scheduler
                    predicate:(nullable POSSafetyPredicate)predicate {
#if POS_ENABLE_RUNTIME_CHECKS
    [self
     pos_protectForScheduler:scheduler
     predicate:^BOOL(SEL selector, POSSelectorAttributes attributes) {
         if (pos_protocolContainsSelector(@protocol(POSSchedulable), selector, YES, YES)) {
             return NO;
         }
         if (selector == @selector(p_autoscheduleInvocation:) ||
             selector == @selector(scheduleSelector:) ||
             selector == @selector(scheduleSelector:withArguments:)) {
             return NO;
         }
         return predicate ? predicate(selector, attributes) : YES;
     }];
#endif
}

@end

NS_ASSUME_NONNULL_END
