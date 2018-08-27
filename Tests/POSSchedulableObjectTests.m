//
//  POSSchedulableObjectTests.m
//  POSScheduling
//
//  Created by Pavel Osipov on 25.05.15.
//  Copyright © 2015 Pavel Osipov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "POSSchedulableObjectMocks.h"

@interface POSSchedulableObjectTests : XCTestCase
@end

@implementation POSSchedulableObjectTests

- (void)testProtectObjectForSchedulerShouldPreventCallsWithinOtherSchedulers {
    SchedulableObject *schedulable = [[SchedulableObject alloc]
                                      initWithScheduler:[RACTargetQueueScheduler pos_scheduler]];
    XCTAssertNoThrow([schedulable conformsToProtocol:@protocol(SafeProtocol)]);
    XCTAssertThrows([schedulable safeMethod]);
}

- (void)testProtectObjectForSchedulerShouldPreventIndirectCallsWithinOtherSchedulers {
    SchedulableObject *schedulable = [[SchedulableObject alloc]
                                      initWithScheduler:[RACTargetQueueScheduler pos_scheduler]];
    XCTAssertNoThrow([schedulable conformsToProtocol:@protocol(SafeProtocol)]);
    XCTAssertThrows([schedulable performSelector:@selector(safeMethod)]);
}

- (void)testProtectOptionsBetweenDifferentClassInstancesShouldNotInterfere {
    __auto_type schedulable1 = [[SchedulableObject alloc] initWithScheduler:[RACTargetQueueScheduler pos_scheduler]];
    __auto_type schedulable2 = [[SchedulableObject alloc]
                                initWithScheduler:[RACTargetQueueScheduler pos_scheduler]
                                safetyPredicate:^BOOL(SEL selector, POSSelectorAttributes attributes) {
                                    return !pos_protocolContainsSelector(@protocol(SafeProtocol), selector, YES, YES);
                                }];
    __auto_type schedulable3 = [[SchedulableObject alloc] initWithScheduler:[RACTargetQueueScheduler pos_scheduler]];
    XCTAssertThrows([schedulable1 safeMethod]);
    XCTAssertNoThrow([schedulable2 safeMethod]);
    XCTAssertThrows([schedulable3 safeMethod]);
}

- (void)testProtectOptionsShouldAllowToInvokeMethodWithinValidScheduler {
    SchedulableObject *schedulable = [[SchedulableObject alloc]
                                      initWithScheduler:[RACTargetQueueScheduler pos_mainThreadScheduler]];
    XCTAssertNoThrow([schedulable safeMethod]);
}

- (void)testHookForMethodWithStructureReturnValueShouldNotCrash {
    SchedulableObject *schedulable = [[SchedulableObject alloc]
                                      initWithScheduler:[RACTargetQueueScheduler pos_mainThreadScheduler]];
    XCTAssertNoThrow([schedulable preferedSize]);
}

- (void)testDisabledProtectionForSchedulableProtocol {
    XCTestExpectation *expectation = [self expectationWithDescription:@"e"];
    SchedulableObject *s = [[SchedulableObject alloc]
                            initWithScheduler:[RACTargetQueueScheduler pos_scheduler]];
    [s scheduleBlock:^(SchedulableObject *scheduledObject) {
        [scheduledObject safeMethod];
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testAutoschedulingWithoutArguments {
    XCTestExpectation *expectation = [self expectationWithDescription:@"e"];
    SchedulableObject *s = [[SchedulableObject alloc] initWithScheduler:[RACTargetQueueScheduler pos_scheduler]];
    XCTAssertThrows([s unsafeMethod]);
    [[s autoschedule:@selector(unsafeMethod)] subscribeNext:^(NSNumber *result) {
        XCTAssertTrue([NSThread.currentThread isMainThread]);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testAutoschedulingWithArgument {
    XCTestExpectation *expectation = [self expectationWithDescription:@"e"];
    SchedulableObject *s = [[SchedulableObject alloc] initWithScheduler:[RACTargetQueueScheduler pos_scheduler]];
    XCTAssertThrows([s unsafeMethodWithArg:@1]);
    [[s autoschedule:@selector(unsafeMethodWithArg:) withArguments:@2, nil] subscribeNext:^(NSNumber *result) {
        XCTAssertTrue([NSThread.currentThread isMainThread]);
        XCTAssertTrue([result isEqual:@2]);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testAutoschedulingWithManyArguments {
    XCTestExpectation *expectation = [self expectationWithDescription:@"e"];
    SchedulableObject *s = [[SchedulableObject alloc] initWithScheduler:[RACTargetQueueScheduler pos_scheduler]];
    [[s
      autoschedule:@selector(unsafeMethodWithArg1:arg2:arg3:arg4:arg5:) withArguments:@1, @2, @3, @4, @5, nil]
      subscribeNext:^(RACFiveTuple *result) {
          XCTAssertTrue([NSThread.currentThread isMainThread]);
          XCTAssertTrue([result.first isEqual:@1]);
          XCTAssertTrue([result.second isEqual:@2]);
          XCTAssertTrue([result.third isEqual:@3]);
          XCTAssertTrue([result.fourth isEqual:@4]);
          XCTAssertTrue([result.fifth isEqual:@5]);
          [expectation fulfill];
      }];
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testAutoschedulingSynchronousVoidMethod {
    XCTestExpectation *expectation = [self expectationWithDescription:@"e"];
    SchedulableObject *s = [[SchedulableObject alloc] initWithScheduler:[RACTargetQueueScheduler pos_scheduler]];
    [[s autoschedule:@selector(unsafeMethodWithoutResultWithArg:) withArguments:@20, nil] replayLast];
    [s scheduleBlock:^(SchedulableObject *testingObject) {
        XCTAssertTrue(s.unsafeMethodLastArgument == 20);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testAutoschedulingSynchronousMethodWithIntegralResult {
    XCTestExpectation *expectation = [self expectationWithDescription:@"e"];
    SchedulableObject *s = [[SchedulableObject alloc] initWithScheduler:[RACTargetQueueScheduler pos_scheduler]];
    [[s autoschedule:@selector(unsafeMethodWithIntegralResult)] subscribeNext:^(NSNumber *result) {
        XCTAssertTrue([NSThread.currentThread isMainThread]);
        XCTAssertTrue([result isEqual:@777]);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

@end
