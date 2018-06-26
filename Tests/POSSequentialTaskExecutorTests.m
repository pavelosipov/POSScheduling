//
//  POSSequentialTaskExecutorTests.m
//  POSScheduling
//
//  Created by Pavel Osipov on 12/05/16.
//  Copyright © 2016 Pavel Osipov. All rights reserved.
//

#import <POSScheduling/POSScheduling.h>
#import <POSAllocationTracker/POSAllocationTracker.h>
#import <XCTest/XCTest.h>

@interface POSSequentialTaskExecutorTests : XCTestCase
@property (nonatomic, weak) NSMutableArray<POSTask *> *executorQueue;
@property (nonatomic) POSSequentialTaskExecutor<POSTask *> *executor;
@end

@implementation POSSequentialTaskExecutorTests

- (void)setUp {
    [super setUp];
    NSMutableArray<POSTask *> *executorQueue = [NSMutableArray<POSTask *> new];
    self.executor = [[POSSequentialTaskExecutor alloc]
                     initWithScheduler:RACTargetQueueScheduler.pos_mainThreadScheduler
                     taskQueue:[[POSTaskQueueAdapter<NSMutableArray<POSTask *> *> alloc]
                                initWithScheduler:RACTargetQueueScheduler.pos_mainThreadScheduler
                                container:executorQueue
                                dequeueTopTaskBlock:^POSTask *(NSMutableArray<POSTask *> *queue) {
                                    POSTask *task = queue.lastObject;
                                    [queue removeLastObject];
                                    return task;
                                } dequeueTaskBlock:^(NSMutableArray<POSTask *> *queue, POSTask *task) {
                                    [queue removeObject:task];
                                } enqueueTaskBlock:^(NSMutableArray<POSTask *> *queue, POSTask *task) {
                                    [queue addObject:task];
                                }]];
    self.executorQueue = executorQueue;
}

- (void)tearDown {
    self.executor = nil;
    [self checkMemoryLeaks];
    [super tearDown];
}

- (void)checkMemoryLeaks {
    XCTAssert([POSAllocationTracker instanceCountForClass:POSSequentialTaskExecutor.class] == 0);
    XCTAssert([POSAllocationTracker instanceCountForClass:POSTask.class] == 0);
    XCTAssert([POSAllocationTracker instanceCountForClass:RACSignal.class] == 0);
    XCTAssert([POSAllocationTracker instanceCountForClass:RACDisposable.class] == 0);
    [POSAllocationTracker resetAllCounters];
}

- (void)testMemoryLeaksAbsenceWhenExecutingInfiniteTask {
    XCTestExpectation *expectation = [self expectationWithDescription:@"e"];
    [_executor submitTask:[POSTask createTask:^RACSignal *(id task) {
        return [RACSignal never];
    }]];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.executor = nil;
        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testExecutorSubmitSignalShouldEmitTaskExecutionValues {
    XCTestExpectation *expectation = [self expectationWithDescription:@"e"];
    POSTask *task = [POSTask createTask:^RACSignal *(id task) {
        return [RACSignal return:@7];
    }];
    __block NSNumber *taskResult = nil;
    [[_executor submitTask:task] subscribeNext:^(id value) {
        taskResult = value;
    } completed:^{
        XCTAssertEqualObjects(taskResult, @7);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testExecutorSubmitSignalShouldEmitTaskExecutionErrors {
    XCTestExpectation *expectation = [self expectationWithDescription:@"e"];
    POSTask *task = [POSTask createTask:^RACSignal *(id task) {
        return [RACSignal error:[NSError errorWithDomain:@"ru.mail.cloud.test" code:123 userInfo:nil]];
    }];
    [[_executor submitTask:task] subscribeError:^(NSError *error) {
        XCTAssertEqualObjects(error.domain, @"ru.mail.cloud.test");
        XCTAssertTrue(error.code == 123);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testItShouldBePossibleToReexecuteTaskWhenErrorsOccurred {
    XCTestExpectation *expectation = [self expectationWithDescription:@"e"];
    __block BOOL taskShouldEmitError = YES;
    POSTask *task = [POSTask createTask:^RACSignal *(id task) {
        if (taskShouldEmitError) {
            return [RACSignal error:[NSError errorWithDomain:@"ru.mail.cloud.test" code:123 userInfo:nil]];
        } else {
            return [RACSignal return:@(1)];
        }
    }];
    [task.values subscribeNext:^(id x) {
        [expectation fulfill];
    }];
    @weakify(self);
    @weakify(task);
    [[_executor submitTask:task] subscribeError:^(NSError *error) {
        @strongify(self);
        @strongify(task);
        XCTAssertEqualObjects(error.domain, @"ru.mail.cloud.test");
        XCTAssertTrue(error.code == 123);
        taskShouldEmitError = NO;
        [self.executor submitTask:task];
    }];
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testExecutorSubmitMethodShouldExecuteTaskWithoutSubscriptions {
    XCTestExpectation *expectation = [self expectationWithDescription:@"e"];
    POSTask *task = [POSTask createTask:^RACSignal *(id task) {
        return [RACSignal return:@7];
    }];
    [task.values subscribeNext:^(id value) {
        XCTAssertEqualObjects(value, @7);
        [expectation fulfill];
    }];
    [_executor submitTask:task];
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testExecutorSubmitMethodShouldExecuteBlockWithoutSubscriptions {
    XCTestExpectation *expectation = [self expectationWithDescription:@"e"];
    [_executor submitExecutionBlock:^RACSignal *(POSTask *task) {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendCompleted];
            return [RACDisposable disposableWithBlock:^{
                [expectation fulfill];
            }];
        }];
    }];
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testExecutorSubmitMethodShouldExecuteSeveralTasksWithoutSubscriptions {
    XCTestExpectation *expectation = [self expectationWithDescription:@"e"];
    POSTask *task1 = [POSTask createTask:^RACSignal *(id task) {
        return [RACSignal return:@1];
    }];
    POSTask *task2 = [POSTask createTask:^RACSignal *(id task) {
        return [RACSignal return:@2];
    }];
    @weakify(self);
    [task1.values subscribeNext:^(id value) {
        @strongify(self);
        XCTAssertEqualObjects(value, @1);
        [self.executor submitTask:task2];
    }];
    [task2.values subscribeNext:^(id value) {
        XCTAssertEqualObjects(value, @2);
        [expectation fulfill];
    }];
    [_executor submitTask:task1];
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testExecutorShouldExecuteLimitedNumberOfTasks {
    XCTestExpectation *expectation = [self expectationWithDescription:@"e"];
    NSInteger maxExecutingTasksCount = 2;
    _executor.maxExecutingTasksCount = maxExecutingTasksCount;
    __block NSInteger taskCount = 20;
    __block NSInteger executionCount = 0;
    __block NSInteger completionCount = 0;
    for (int i = 0; i < taskCount; ++i) {
        [[_executor submitTask:[POSTask createTask:^RACSignal *(id task) {
            ++executionCount;
            XCTAssertTrue(executionCount <= maxExecutingTasksCount);
            return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                return [RACScheduler.mainThreadScheduler schedule:^{
                    [subscriber sendCompleted];
                }];
            }];
        }]] subscribeCompleted:^{
            --executionCount;
            ++completionCount;
            if (completionCount == taskCount) {
                self.executor = nil;
                [expectation fulfill];
            }
        }];
    }
    [_executor submitTask:[POSTask createTask:^RACSignal *(id task) {
        return [RACSignal never];
    }]];
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testExecutorShouldScheduleTaskExecutionAfterLimitIncrement {
    XCTestExpectation *expectation = [self expectationWithDescription:@"e"];
    _executor.maxExecutingTasksCount = 0;
    [[_executor submitTask:[POSTask createTask:^RACSignal *(id task) {
        return [RACSignal empty];
    }]] subscribeCompleted:^{
        [expectation fulfill];
    }];
    [[_executor schedule] subscribeNext:^(POSSequentialTaskExecutor *executor) {
        executor.maxExecutingTasksCount = 1;
    }];
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testExecutorShouldReclaimTaskWhenSubmitionBlockIsDisposing {
    XCTestExpectation *expectation = [self expectationWithDescription:@"e"];
    @weakify(expectation);
    RACDisposable *disposable = [[_executor submitTask:[POSTask createTask:^RACSignal *(id task) {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            return [RACDisposable disposableWithBlock:^{
                @strongify(expectation);
                [expectation fulfill];
            }];
        }];
    }]] subscribeCompleted:^{
        XCTAssertTrue(NO, @"Task should not be executed.");
    }];
    RACScheduler *scheduler = _executor.scheduler;
    [scheduler schedule:^{ // skip executor processing tasks runloop iteration.
        [scheduler schedule:^{ // skip task subscription runloop iteration.
            [disposable dispose];
        }];
    }];
    [self waitForExpectationsWithTimeout:2 handler:nil];
}

- (void)testExecutorShouldDequeueReclaimedTasks {
    RACDisposable *disposable = [[_executor submitTask:[POSTask createTask:^RACSignal *(id task) {
        return [RACSignal never];
    }]] subscribeCompleted:^{
        XCTAssertTrue(NO, @"Task should not be executed.");
    }];
    XCTAssertTrue(_executorQueue.count == 1);
    [disposable dispose];
    XCTAssertTrue(_executorQueue.count == 0);
    XCTestExpectation *expectation = [self expectationWithDescription:@"e"];
    [[_executor schedule] subscribeNext:^(POSSequentialTaskExecutor *executor) {
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:2 handler:nil];
}

- (void)testExecutorMayExecuteMultipleTasksSimultaneously {
    XCTestExpectation *expectation = [self expectationWithDescription:@"e"];
    const NSInteger submisionCount = 10;
    __block NSInteger executeCount = 0;
    __block NSInteger executeEventCount = 0;
    _executor.maxExecutingTasksCount = submisionCount;
    [_executor.executingTasksCountSignal subscribeNext:^(NSNumber *executingTasksCount) {
        ++executeEventCount;
        executeCount = executingTasksCount.unsignedIntegerValue;
        XCTAssertTrue(executeEventCount == executeCount);
    }];
    for (int i = 0; i < submisionCount; ++i) {
        POSTask *task = [POSTask createTask:^RACSignal *(id task) {
            return [RACSignal never];
        }];
        [_executor submitTask:task];
    }
    [_executor.scheduler schedule:^{ // skip executor processing tasks runloop iteration.
        XCTAssertTrue(executeCount == 10);
        XCTAssertTrue(executeEventCount == 10);
        XCTAssertTrue(self.executor.executingTasksCount == 10);
        XCTAssertTrue(self.executor.executingTasks.count == 10);
        self.executor = nil;
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testExecutorShouldRemoveCanceledTaskFromExecuteTasksArray {
    XCTestExpectation *expectation = [self expectationWithDescription:@"e"];
    @weakify(self);
    POSTask *task = [POSTask createTask:^RACSignal *(POSTask *thisTask) {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            return [RACDisposable disposableWithBlock:^{
                @strongify(self);
                XCTAssertTrue(self.executor.executingTasksCount == 0);
                XCTAssertTrue(self.executor.executingTasks.count == 0);
                [expectation fulfill];
            }];
        }];
    } scheduler:_executor.scheduler executor:_executor];
    __block NSInteger executeCount = 0;
    [_executor.executingTasksCountSignal subscribeNext:^(NSNumber *executingTasksCount) {
        executeCount = executingTasksCount.unsignedIntegerValue;
    }];
    [_executor submitTask:task];
    [_executor.scheduler schedule:^{
        XCTAssertTrue(executeCount == 1);
        XCTAssertTrue(self.executor.executingTasksCount == 1);
        XCTAssertTrue(self.executor.executingTasks.count == 1);
        [task.scheduler schedule:^{
            [task cancel];
        }];
    }];
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testTaskRestart {
    XCTestExpectation *expectation = [self expectationWithDescription:@"e"];
    __block NSUInteger executeCount = 0;
    POSTask *task = [POSTask createTask:^RACSignal *(POSTask *thisTask) {
        if (++executeCount == 1) {
            return [RACSignal never];
        } else {
            return [RACSignal return:@YES];
        }
    } scheduler:_executor.scheduler executor:_executor];
    [task.values subscribeNext:^(NSNumber *result) {
        XCTAssertTrue(result.boolValue);
        [expectation fulfill];
    }];
    [_executor submitTask:task];
    [_executor.scheduler schedule:^{
        XCTAssertTrue(executeCount == 1);
        XCTAssertTrue(self.executor.executingTasksCount == 1);
        XCTAssertTrue(self.executor.executingTasks.count == 1);
        [task cancel];
        [task execute];
    }];
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

@end
