//
//  POSTaskQueue.m
//  POSScheduling
//
//  Created by Pavel Osipov on 10/05/16.
//  Copyright © 2016 Pavel Osipov. All rights reserved.
//

#import "POSTaskQueue.h"

NS_ASSUME_NONNULL_BEGIN

@interface POSTaskQueueAdapter ()
@property (nonatomic, readonly) id container;
@property (nonatomic, readonly, copy) POSTask * __nullable (^dequeueTopTaskBlock)(id queue);
@property (nonatomic, readonly, copy) void (^dequeueTaskBlock)(id queue, POSTask *task);
@property (nonatomic, readonly, copy) void (^enqueueTaskBlock)(id queue, POSTask *task);
@end

@implementation POSTaskQueueAdapter

- (instancetype)initWithScheduler:(RACTargetQueueScheduler *)scheduler
                        container:(id)container
              dequeueTopTaskBlock:(nullable POSTask *(^)(id queue))dequeueTopTaskBlock
                 dequeueTaskBlock:(void(^)(id queue, POSTask *task))dequeueTaskBlock
                 enqueueTaskBlock:(void(^)(id queue, POSTask *task))enqueueTaskBlock {
    POS_CHECK(container);
    POS_CHECK(dequeueTopTaskBlock);
    POS_CHECK(dequeueTaskBlock);
    POS_CHECK(enqueueTaskBlock);
    if (self = [super initWithScheduler:scheduler]) {
        _container = container;
        _dequeueTopTaskBlock = [dequeueTopTaskBlock copy];
        _dequeueTaskBlock = [dequeueTaskBlock copy];
        _enqueueTaskBlock = [enqueueTaskBlock copy];
    }
    return self;
}

#pragma mark POSTaskQueue

- (nullable POSTask *)dequeueTopTask {
    return _dequeueTopTaskBlock(_container);
}

- (void)dequeueTask:(POSTask *)task {
    _dequeueTaskBlock(_container, task);
}

- (void)enqueueTask:(POSTask *)task {
    _enqueueTaskBlock(_container, task);
}

@end

NS_ASSUME_NONNULL_END
