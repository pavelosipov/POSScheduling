//
//  POSTaskTests.m
//  POSScheduling
//
//  Created by Pavel Osipov on 29.05.15.
//  Copyright © 2015 Pavel Osipov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <POSScheduling/POSScheduling.h>
#import <POSAllocationTracker/POSAllocationTracker.h>

@interface POSTaskClient : NSObject
@end

@implementation POSTaskClient

- (RACSignal *)executeInfiniteTask {
    POSTask *task = [POSTask createTask:^RACSignal *(id task) {
        return [RACSignal never];
    }];
    return [[task execute] takeUntil:self.rac_willDeallocSignal];
}

@end

@interface POSTaskTests : XCTestCase
@end

@implementation POSTaskTests

- (void)setUp {
    [super setUp];
    [POSAllocationTracker resetAllCounters];
    XCTAssert([POSAllocationTracker instanceCountForClass:POSTask.class] == 0);
    XCTAssert([POSAllocationTracker instanceCountForClass:RACDisposable.class] == 0);
}

- (void)tearDown {
    XCTAssert([POSAllocationTracker instanceCountForClass:POSTask.class] == 0);
    XCTAssert([POSAllocationTracker instanceCountForClass:RACDisposable.class] == 0);
    [super tearDown];
}

- (void)testTaskExecutionSignalShouldEmitNOBeforeFirstExecution {
    POSTask *task = [POSTask createTask:^RACSignal *(POSTask *task) {
        return [RACSignal empty];
    }];
    __block BOOL executionValue = YES;
    [task.executing subscribeNext:^(NSNumber *value) {
        executionValue = [value boolValue];
    }];
    XCTAssertFalse(executionValue);
}

- (void)testTaskResetValueAfterReexecution {
    XCTestExpectation *expectation = [self expectationWithDescription:@"task completion"];
    __block int executionCount = 0;
    POSTask *task = [POSTask createTask:^RACSignal *(POSTask *task) {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            if (++executionCount == 1) {
                [subscriber sendNext:@(1)];
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:[NSError errorWithDomain:@"test" code:0 userInfo:nil]];
                [expectation fulfill];
            }
            return nil;
        }];
    }];
    [task.values subscribeNext:^(NSNumber *v) {
        XCTAssertNotNil(v);
    }];
    @weakify(task);
    [task.executing subscribeNext:^(NSNumber *executing) {
        @strongify(task);
        if (![executing boolValue] && executionCount < 2) {
            [task execute];
        }
    }];
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
        [task.values subscribeNext:^(NSNumber *value) {
            XCTAssertFalse(YES);
        }];
    }];
}

- (void)testTaskKeepLastValueUntilReexecution {
    XCTestExpectation *expectation = [self expectationWithDescription:@"document open"];
    POSTask *task = [POSTask createTask:^RACSignal *(POSTask *task) {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendNext:@(1)];
            [subscriber sendCompleted];
            [expectation fulfill];
            return nil;
        }];
    }];
    [task execute];
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
        [task.values subscribeNext:^(NSNumber *value) {
            XCTAssertEqualObjects(value, @(1));
        }];
    }];
}

- (void)testTaskResetErrorAfterReexecution {
    XCTestExpectation *expectation = [self expectationWithDescription:@"task completion"];
    __block int executionCount = 0;
    POSTask *task = [POSTask createTask:^RACSignal *(POSTask *task) {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            if (++executionCount == 1) {
                [subscriber sendError:[NSError errorWithDomain:@"test" code:0 userInfo:nil]];
            } else {
                [subscriber sendNext:@(1)];
                [subscriber sendCompleted];
                [expectation fulfill];
            }
            return nil;
        }];
    }];
    [task.errors subscribeNext:^(NSError *e) {
        XCTAssertNotNil(e);
    }];
    @weakify(task);
    [task.executing subscribeNext:^(NSNumber *executing) {
        @strongify(task);
        if (![executing boolValue] && executionCount < 2) {
            [task execute];
        }
    }];
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
        [task.errors subscribeNext:^(NSError *error) {
            XCTAssertFalse(YES);
        }];
    }];
}

- (void)testTaskKeepLastErrorUntilReexecution {
    XCTestExpectation *expectation = [self expectationWithDescription:@"error emitted"];
    POSTask *task = [POSTask createTask:^RACSignal *(POSTask *task) {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendError:[NSError errorWithDomain:@"test" code:0 userInfo:nil]];
            [expectation fulfill];
            return nil;
        }];
    }];
    [task execute];
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
        [task.errors subscribeNext:^(NSError *error) {
            XCTAssertNotNil(error);
        }];
    }];
}

- (void)testTaskSuccessfulExecutionSignal {
    XCTestExpectation *expectation = [self expectationWithDescription:@"completion emitted"];
    POSTask *task = [POSTask createTask:^RACSignal *(POSTask *task) {
        return [RACSignal return:@1];
    }];
    __block NSNumber *receivedValue;
    [[task execute] subscribeNext:^(NSNumber *value) {
        receivedValue = value;
    } completed:^{
        XCTAssertEqualObjects(@1, receivedValue);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testTaskFailedExecutionSignal {
    XCTestExpectation *expectation = [self expectationWithDescription:@"error emitted"];
    NSError *emittingError = [NSError errorWithDomain:@"com.github.pavelosipov.POSScheduling" code:0 userInfo:nil];
    POSTask *task = [POSTask createTask:^RACSignal *(POSTask *task) {
        return [RACSignal error:emittingError];
    }];
    [[task execute] subscribeError:^(NSError *error) {
        XCTAssertEqualObjects(error, emittingError);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testInfiniteTaskExecution {
    XCTestExpectation *expectation = [self expectationWithDescription:@"expectation"];
    @autoreleasepool {
        POSTaskClient *client = [POSTaskClient new];
        [[client executeInfiniteTask] subscribeCompleted:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [expectation fulfill];
            });
        }];
    }
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testTaskExecutionDisposableShouldDisposeTaskDisposable {
    XCTestExpectation *expectation = [self expectationWithDescription:@"e"];
    @weakify(expectation);
    POSTask *task = [POSTask createTask:^RACSignal *(POSTask *task) {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            return [RACDisposable disposableWithBlock:^{
                @strongify(expectation);
                [expectation fulfill];
            }];
        }];
    }];
    RACDisposable *disposable = [[task execute] subscribeCompleted:^{}];
    [[task schedule] subscribeNext:^(id x) {
        [disposable dispose];
    }];
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testTaskShouldNotLeakDisposablesAfterCancel {
    XCTestExpectation *expectation = [self expectationWithDescription:@"e"];
    __block NSInteger iterationCount = 0;
    __block NSInteger disposableCount = 0;
    POSTask *task = [POSTask createTask:^RACSignal *(POSTask *thatTask) {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            uint64_t currentDisposableCount = [POSAllocationTracker instanceCountForClass:RACDisposable.class];
            if (iterationCount > 1) {
                XCTAssertTrue(currentDisposableCount == disposableCount);
            }
            disposableCount = currentDisposableCount;
            [subscriber sendNext:@(iterationCount)];
            ++iterationCount;
            return nil;
        }];
    }];
    @weakify(task);
    @weakify(expectation);
    [task.values subscribeNext:^(NSNumber *iterationCount) {
        if (iterationCount.integerValue < 9) {
            @strongify(task);
            [task cancel];
            [task execute];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(expectation);
                [expectation fulfill];
            });
        }
    }];
    [task execute];
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

@end
