//
//  POSTask.h
//  POSScheduling
//
//  Created by Pavel Osipov on 26.01.15.
//  Copyright © 2015 Pavel Osipov. All rights reserved.
//

#import "POSSchedulableObject.h"

NS_ASSUME_NONNULL_BEGIN

@protocol POSTaskExecutor;

/// Task represents restartable and cancelable unit of work.
@protocol POSTask <POSSchedulableObject>

/// Emits YES when task is about to start and NO when task is about to finish.
/// Always emits some value on subscription.
@property (nonatomic, readonly) RACSignal<NSNumber *> *executing;

/// Emits values from source signal and keeps the last one until reexecution.
@property (nonatomic, readonly) RACSignal *values;

/// Emits errors from source signal and keeps the last one until reexecution.
@property (nonatomic, readonly) RACSignal<NSError *> *errors;

/// @return YES if task is executing right now.
- (BOOL)isExecuting;

/// Launches task directly or schedules it within specified executor.
- (RACSignal *)execute;

/// Interrupts task without emitting errors.
- (void)cancel;

/// Interrupts task and emits error.
- (void)cancelWithError:(nullable NSError *)error;

@end

#pragma mark -

@interface POSTask<__covariant ValueType> : POSSchedulableObject <POSTask>

/// Redefinition of the protocol property with more precise type of the signal.
@property (nonatomic, readonly) RACSignal<ValueType> *values;

/// Redefinition of the protocol property with more precise type of the signal.
- (RACSignal<ValueType> *)execute;

/// Creates self-executable task with implicit UI scheduler.
+ (instancetype)createTask:(RACSignal<ValueType> *(^)(id task))executionBlock;

/// Creates self-executable task.
+ (instancetype)createTask:(RACSignal<ValueType> *(^)(id task))executionBlock
                 scheduler:(nullable RACTargetQueueScheduler *)scheduler;

/// Creates task which should be scheduled and executed only within specified executor.
+ (instancetype)createTask:(RACSignal<ValueType> *(^)(id task))executionBlock
                 scheduler:(nullable RACTargetQueueScheduler *)scheduler
                  executor:(nullable id<POSTaskExecutor>)executor;

/// The designated initializer.
- (instancetype)initWithExecutionBlock:(RACSignal<ValueType> *(^)(id task))executionBlock
                             scheduler:(RACTargetQueueScheduler *)scheduler
                              executor:(nullable id<POSTaskExecutor>)executor NS_DESIGNATED_INITIALIZER;

/// Preventing usage of base initializers.
POS_SCHEDULABLE_INIT_RECURSIVELY_UNAVAILABLE

@end

#pragma mark -

/// Specifies protocol which should be impleme
@protocol POSTaskExecutor <POSSchedulableObject>

/// @return Signal which will emit emits values about task execution.
- (RACSignal *)submitTask:(POSTask *)task;

/// Prevents task execution if it doesn't executed yet.
- (void)reclaimTask:(POSTask *)task error:(nullable NSError *)error;

@end

#pragma mark -

@protocol POSBlockExecutor <POSSchedulableObject>

/// @return Signal which will emit emits values about task execution.
- (RACSignal *)submitExecutionBlock:(RACSignal *(^)(id task))executionBlock;

@end

/// Implements submitTaskWithExecutionBlock method.
@interface POSBlockExecutor : POSSchedulableObject <POSBlockExecutor>
@end

#pragma mark -

/// The minimal implementation of executors which executes task immediately after push.
/// This executor should be used as a base class for more complicated executors.
@interface POSDirectTaskExecutor : POSBlockExecutor <POSTaskExecutor>
@end

NS_ASSUME_NONNULL_END
