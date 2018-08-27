//
//  POSSchedulable.h
//  POSScheduling
//
//  Created by Pavel Osipov on 12.01.15.
//  Copyright © 2015 Pavel Osipov. All rights reserved.
//

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wstrict-prototypes"
#   import <ReactiveObjC/ReactiveObjC.h>
#   import <ReactiveObjC/RACAnnotations.h>
#pragma clang diagnostic pop

NS_ASSUME_NONNULL_BEGIN

@protocol POSSchedulable <NSObject>

@property (nonatomic, readonly) RACTargetQueueScheduler *scheduler;

///
/// @return  Signal with this nonnull object delivered in the object's scheduler.
///
- (RACSignal<__kindof id<POSSchedulable>> *)schedule;

///
/// @brief   Schedules that object in the object's scheduler.
///
- (void)scheduleBlock:(void (^)(id<POSSchedulable> schedulable))block;

///
/// @brief   Schedules that object in the object's scheduler and performs selector.
///
- (void)invokeScheduled:(SEL)selector;

///
/// @brief   Schedules that object in the object's scheduler and performs selector.
///
- (void)invokeScheduled:(SEL)selector withArguments:(nullable id)argument, ... NS_REQUIRES_NIL_TERMINATION;

///
/// @brief   Schedules method invokation of this object in correct sheduler
///          and returns signal, which calls its callbacks in current scheduler.
///          Method supports both synchronous and asynchronous methods.
///
/// @remarks Selector must return RACSignal.
///
- (RACSignal *)autoschedule:(SEL)selector RAC_WARN_UNUSED_RESULT;

///
/// @brief   Schedules parameterized method invokation of this object in correct sheduler
///          and returns signal, which calls its callbacks in current scheduler.
///          Method supports both synchronous and asynchronous methods.
///
/// @remarks Selector must return RACSignal.
///
- (RACSignal *)autoschedule:(SEL)selector
              withArguments:(nullable id)argument, ... NS_REQUIRES_NIL_TERMINATION RAC_WARN_UNUSED_RESULT;

@end

NS_ASSUME_NONNULL_END
