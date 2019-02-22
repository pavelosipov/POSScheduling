//
//  POSSequentialTaskExecutor.m
//  POSScheduling
//
//  Created by Pavel Osipov on 10/05/16.
//  Copyright © 2016 Pavel Osipov. All rights reserved.
//

#import "POSSequentialTaskExecutor.h"
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^POSReclaimBlock)(NSError * _Nullable error);

@interface POSTask (POSConcurrentTaskExecutor)

@property (nonatomic, nullable, setter = pos_setSubscriber:) id<RACSubscriber> pos_subscriber;
@property (nonatomic, nullable, setter = pos_setReclaimBlock:) POSReclaimBlock pos_reclaimBlock;

- (void)pos_reclaimWithError:(nullable NSError *)error;

@end

#pragma mark -

@interface POSSequentialTaskExecutor ()

@property (nonatomic, readonly) id<POSTaskExecutor> underlyingExecutor;
@property (nonatomic, readonly) id<POSTaskQueue> pendingTasks;
@property (nonatomic, readonly) NSMutableArray<id<POSTask>> *mutableExecutingTasks;
@property (nonatomic, readonly) RACSubject *executingTasksCountSubject;

@end

@implementation POSSequentialTaskExecutor

- (instancetype)initWithScheduler:(RACTargetQueueScheduler *)scheduler
                        taskQueue:(nullable id<POSTaskQueue>)taskQueue {
    POS_CHECK(scheduler);
    return [self initWithUnderlyingExecutor:[[POSDirectTaskExecutor alloc] initWithScheduler:scheduler]
                                  taskQueue:taskQueue];
}

- (instancetype)initWithUnderlyingExecutor:(id<POSTaskExecutor>)executor
                                 taskQueue:(nullable id<POSTaskQueue>)taskQueue {
    typedef NSMutableArray<POSTask *> Queue_t;
    POS_CHECK(executor);
    if (self = [super initWithScheduler:executor.scheduler safetyPredicate:nil]) {
        _executingTasksCountSubject = [RACSubject subject];
        _underlyingExecutor = executor;
        _pendingTasks = taskQueue ?: [[POSTaskQueueAdapter<Queue_t *> alloc]
                                      initWithScheduler:executor.scheduler
                                      container:[Queue_t new]
                                      dequeueTopTaskBlock:^POSTask *(Queue_t *queue) {
                                          POSTask *task = queue.firstObject;
                                          [queue removeObject:task];
                                          return task;
                                      } dequeueTaskBlock:^(Queue_t *queue, POSTask *task) {
                                          [queue removeObject:task];
                                      } enqueueTaskBlock:^(Queue_t *queue, POSTask *task) {
                                          [queue addObject:task];
                                      }];
        _maxExecutingTasksCount = 1;
        _mutableExecutingTasks = [NSMutableArray array];
    }
    return self;
}

#pragma mark POSTaskExecutor

- (RACSignal *)submitTask:(POSTask *)task {
    POS_CHECK(![task isExecuting]);
    POS_CHECK(task.pos_reclaimBlock == nil);
    RACSignal *executeSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        task.pos_subscriber = subscriber;
        return [RACDisposable disposableWithBlock:^{
            [task pos_reclaimWithError:nil];
        }];
    }];
    [_pendingTasks enqueueTask:task];
    @weakify(self);
    @weakify(task);
    task.pos_reclaimBlock = ^(NSError * _Nullable error) {
        @strongify(self);
        @strongify(task);
        task.pos_reclaimBlock = nil;
        task.pos_subscriber = nil;
        [self.pendingTasks dequeueTask:task];
    };
    [self p_scheduleProcessPendingTasks];
    return executeSignal;
}

- (void)reclaimTask:(POSTask *)task error:(nullable NSError *)error {
    [task pos_reclaimWithError:error];
}

#pragma mark Public

- (void)setMaxExecutingTasksCount:(NSInteger)count {
    if (count > _maxExecutingTasksCount) {
        [self p_scheduleProcessPendingTasks];
    }
    _maxExecutingTasksCount = count;
}

- (NSArray *)executingTasks {
    return [_mutableExecutingTasks copy];
}


- (NSUInteger)executingTasksCount {
    return [_mutableExecutingTasks count];
}

- (RACSignal *)executingTasksCountSignal {
    return [_executingTasksCountSubject takeUntil:self.rac_willDeallocSignal];
}

- (void)executePendingTasks {
    while (_mutableExecutingTasks.count < _maxExecutingTasksCount) {
        POSTask *task = [_pendingTasks dequeueTopTask];
        if (!task) {
            break;
        }
        [self p_addExecutingTask:task];
        id<RACSubscriber> taskSubscriber = task.pos_subscriber;
        task.pos_subscriber = nil;
        @weakify(self);
        @weakify(task);
        RACDisposable *executionDisposable = [[[_underlyingExecutor
            submitTask:task]
            takeUntil:[self pos_deallocSignalOnScheduler:self.scheduler]]
            subscribeNext:^(id value) {
                [taskSubscriber sendNext:value];
            }
            error:^(NSError *error) {
                @strongify(task);
                [task pos_reclaimWithError:error];
                [taskSubscriber sendError:error];
            }
            completed:^{
                @strongify(task);
                [task pos_reclaimWithError:nil];
                [taskSubscriber sendCompleted];
            }];
        task.pos_reclaimBlock = ^(NSError * _Nullable error) {
            @strongify(self);
            @strongify(task);
            task.pos_reclaimBlock = nil;
            [executionDisposable dispose];
            [self p_removeExecutingTask:task];
            [self.underlyingExecutor reclaimTask:task error:error];
            [self p_scheduleProcessPendingTasks];
        };
    }
}

#pragma mark Private

- (void)p_scheduleProcessPendingTasks {
    [[self schedule] subscribeNext:^(POSSequentialTaskExecutor *this) {
        [this executePendingTasks];
    }];
}

- (void)p_addExecutingTask:(id<POSTask>)task {
    [_mutableExecutingTasks addObject:task];
    [_executingTasksCountSubject sendNext:@(_mutableExecutingTasks.count)];
}

- (void)p_removeExecutingTask:(id<POSTask>)task {
    [_mutableExecutingTasks removeObject:task];
    [_executingTasksCountSubject sendNext:@(_mutableExecutingTasks.count)];
}

@end

#pragma mark -

static char kPOSTaskSubscriberKey;
static char kPOSTaskReclaimBlockKey;

@implementation POSTask (POSConcurrentTaskExecutor)

- (void)pos_reclaimWithError:(nullable NSError *)error {
    if (self.pos_reclaimBlock) {
        self.pos_reclaimBlock(error);
    }
}

- (nullable id<RACSubscriber>)pos_subscriber {
    return objc_getAssociatedObject(self, &kPOSTaskSubscriberKey);
}

- (void)pos_setSubscriber:(nullable id<RACSubscriber>)subscriber {
    objc_setAssociatedObject(self, &kPOSTaskSubscriberKey, subscriber, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (nullable POSReclaimBlock)pos_reclaimBlock {
    return objc_getAssociatedObject(self, &kPOSTaskReclaimBlockKey);
}

- (void)pos_setReclaimBlock:(nullable POSReclaimBlock)block {
    objc_setAssociatedObject(self, &kPOSTaskReclaimBlockKey, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end

NS_ASSUME_NONNULL_END
