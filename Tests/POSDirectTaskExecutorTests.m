//
//  POSDirectExecutorTests.m
//  POSScheduling
//
//  Created by Pavel Osipov on 13/05/16.
//  Copyright © 2016 Pavel Osipov. All rights reserved.
//

#import <POSScheduling/POSScheduling.h>
#import <POSAllocationTracker/POSAllocationTracker.h>
#import <XCTest/XCTest.h>

@interface POSDirectTaskExecutorTests : XCTestCase
@property (nonatomic) POSDirectTaskExecutor *executor;
@end

@implementation POSDirectTaskExecutorTests

- (void)setUp {
    [super setUp];
    [POSAllocationTracker resetAllCounters];
    self.executor = [[POSDirectTaskExecutor alloc] init];
}

- (void)tearDown {
    self.executor = nil;
    [self checkMemoryLeaks];
    [super tearDown];
}

- (void)checkMemoryLeaks {
    XCTAssert([POSAllocationTracker instanceCountForClass:POSDirectTaskExecutor.class] == 0);
    XCTAssert([POSAllocationTracker instanceCountForClass:POSTask.class] == 0);
    XCTAssert([POSAllocationTracker instanceCountForClass:RACSignal.class] == 0);
    XCTAssert([POSAllocationTracker instanceCountForClass:RACDisposable.class] == 0);
}

- (void)testExecutorShouldRetainTaskUntilCompletion {
    XCTestExpectation *expectation = [self expectationWithDescription:@"e"];
    POSTask *task = [POSTask
                     createTask:^RACSignal *(POSTask *task) {
                         return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                             return [RACScheduler.mainThreadScheduler schedule:^{
                                 [RACScheduler.mainThreadScheduler schedule:^{
                                     [subscriber sendCompleted];
                                 }];
                             }];
                         }];
                     }
                     scheduler:self.executor.scheduler
                     executor:self.executor];
    [[task execute] subscribeCompleted:^{
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testExecutorShouldRetainTaskUntilCompletion2 {
    XCTestExpectation *expectation = [self expectationWithDescription:@"e"];
    POSTask *task = [POSTask
                     createTask:^RACSignal *(POSTask *task) {
                         return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                             return [RACScheduler.mainThreadScheduler schedule:^{
                                 [RACScheduler.mainThreadScheduler schedule:^{
                                     [subscriber sendCompleted];
                                 }];
                             }];
                         }];
                     }];
    [[self.executor submitTask:task] subscribeCompleted:^{
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testExecutorShouldExecuteTaskWithoutSubscription {
    XCTestExpectation *expectation = [self expectationWithDescription:@"e"];
    POSTask *task = [POSTask createTask:^RACSignal *(POSTask *task) {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendCompleted];
            return [RACDisposable disposableWithBlock:^{
                [expectation fulfill];
            }];
        }];
    }];
    [self.executor submitTask:task];
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testExecutorShouldExecuteBlockWithoutSubscription {
    XCTestExpectation *expectation = [self expectationWithDescription:@"e"];
    [self.executor submitExecutionBlock:^RACSignal *(POSTask *task) {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendCompleted];
            return [RACDisposable disposableWithBlock:^{
                [expectation fulfill];
            }];
        }];
    }];
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testExecutorMemoryLeaksWhenExecutingInfiniteTask {
    XCTestExpectation *expectation = [self expectationWithDescription:@"e"];
    [self.executor submitTask:[POSTask createTask:^RACSignal *(POSTask *task) {
        return [RACSignal never];
    }]];
    dispatch_async(dispatch_get_main_queue(), ^{
        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

@end
