//
//  POSTaskSubclassingTests.m
//  POSScheduling
//
//  Created by Pavel Osipov on 16.04.16.
//  Copyright © 2016 Pavel Osipov. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <POSScheduling/POSScheduling.h>
#import <POSAllocationTracker/POSAllocationTracker.h>

@interface POSFooTask : POSTask
@property (nonatomic, readonly) RACSignal *preExecSignal;
@property (nonatomic, readonly) RACSignal *execSignal;
@property (nonatomic, readonly) RACSignal *postExecSignal;
@end

@interface POSFooTask ()
@property (nonatomic) RACSubject *preExecSubject;
@property (nonatomic) RACSubject *execSubject;
@property (nonatomic) RACSubject *postExecSubject;
@end

@implementation POSFooTask

- (instancetype)initWithExecutionBlock:(RACSignal<id> *(^)(id))executionBlock
                             scheduler:(RACTargetQueueScheduler *)scheduler
                              executor:(id<POSTaskExecutor>)executor {
    if (self = [super initWithExecutionBlock:executionBlock scheduler:scheduler executor:executor]) {
        _preExecSignal = [RACSubject subject];
        _execSignal = [RACSubject subject];
        _postExecSignal = [RACSubject subject];
    }
    return self;
}

@end

@interface POSTaskSubclassingTests : XCTestCase

@end

@implementation POSTaskSubclassingTests

- (void)setUp {
    [super setUp];
    XCTAssert([POSAllocationTracker instanceCountForClass:POSTask.class] == 0);
    XCTAssert([POSAllocationTracker instanceCountForClass:RACDisposable.class] == 0);
}

- (void)tearDown {
    XCTAssert([POSAllocationTracker instanceCountForClass:POSTask.class] == 0);
    XCTAssert([POSAllocationTracker instanceCountForClass:RACDisposable.class] == 0);
    [super tearDown];
}

- (void)testTaskSubclass {
    XCTestExpectation *expectation = [self expectationWithDescription:@"expectation"];
    POSFooTask *fooTask = [POSFooTask createTask:^RACSignal *(id task) {
        [(id)[task preExecSignal] sendNext:@YES];
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [(id)[task execSignal] sendNext:@YES];
            [subscriber sendCompleted];
            [(id)[task postExecSignal] sendNext:@YES];
            return nil;
        }];
    }];
    __block BOOL preReceived = NO;
    [[fooTask.preExecSignal take:1] subscribeNext:^(id x) {
        preReceived = YES;
    }];
    __block BOOL execReceived = NO;
    [[fooTask.execSignal take:1] subscribeNext:^(id x) {
        execReceived = YES;
    }];
    __block BOOL postReceived = NO;
    [[fooTask.preExecSignal take:1] subscribeNext:^(id x) {
        postReceived = YES;
    }];
    [[fooTask execute] subscribeCompleted:^{
        XCTAssertTrue(preReceived);
        XCTAssertTrue(execReceived);
        XCTAssertTrue(postReceived);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

@end
