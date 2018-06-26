//
//  POSTaskQueue.h
//  POSScheduling
//
//  Created by Pavel Osipov on 10/05/16.
//  Copyright © 2016 Pavel Osipov. All rights reserved.
//

#import "POSTask.h"

NS_ASSUME_NONNULL_BEGIN

@protocol POSTaskQueue <POSSchedulable>

- (nullable POSTask *)dequeueTopTask;
- (void)dequeueTask:(POSTask *)task;
- (void)enqueueTask:(POSTask *)task;

@end

@interface POSTaskQueueAdapter<QueueType> : POSSchedulableObject <POSTaskQueue>

- (instancetype)initWithScheduler:(RACTargetQueueScheduler *)scheduler
                        container:(QueueType)container
              dequeueTopTaskBlock:(nullable POSTask *(^)(QueueType queue))dequeueTopTaskBlock
                 dequeueTaskBlock:(void(^)(QueueType queue, POSTask *task))dequeueTaskBlock
                 enqueueTaskBlock:(void(^)(QueueType queue, POSTask *task))enqueueTaskBlock;

POS_SCHEDULABLE_INIT_RECURSIVELY_UNAVAILABLE

@end

NS_ASSUME_NONNULL_END
