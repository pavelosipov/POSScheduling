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
    SchedulableObject *schedulable = [[SchedulableObject alloc] initWithScheduler:[RACTargetQueueScheduler pos_scheduler]];
    XCTAssertNoThrow([schedulable conformsToProtocol:@protocol(SafeProtocol)]);
    XCTAssertThrows([schedulable methodA]);
}

- (void)testProtectObjectForSchedulerShouldPreventIndirectCallsWithinOtherSchedulers {
    SchedulableObject *schedulable = [[SchedulableObject alloc] initWithScheduler:[RACTargetQueueScheduler pos_scheduler]];
    XCTAssertNoThrow([schedulable conformsToProtocol:@protocol(SafeProtocol)]);
    XCTAssertThrows([schedulable performSelector:@selector(methodA)]);
}

- (void)testProtectOptionsBetweenDifferentClassInstancesShouldNotInterfere {
    __auto_type schedulable1 = [[SchedulableObject alloc] initWithScheduler:[RACTargetQueueScheduler pos_scheduler]];
    __auto_type schedulable2 = [[SchedulableObject alloc]
                                initWithScheduler:[RACTargetQueueScheduler pos_scheduler]
                                safetyPredicate:^BOOL(SEL selector, POSSelectorAttributes attributes) {
                                    return !pos_protocolContainsSelector(@protocol(SafeProtocol), selector, YES, YES);
                                }];
    __auto_type schedulable3 = [[SchedulableObject alloc] initWithScheduler:[RACTargetQueueScheduler pos_scheduler]];
    XCTAssertThrows([schedulable1 methodA]);
    XCTAssertNoThrow([schedulable2 methodA]);
    XCTAssertThrows([schedulable3 methodA]);
}

- (void)testProtectOptionsShouldAllowToInvokeMethodWithinValidScheduler {
    SchedulableObject *schedulable = [[SchedulableObject alloc] initWithScheduler:[RACTargetQueueScheduler pos_mainThreadScheduler]];
    XCTAssertNoThrow([schedulable methodA]);
}

- (void)testHookForMethodWithStructureReturnValueShouldNotCrash {
    SchedulableObject *schedulable = [[SchedulableObject alloc] initWithScheduler:[RACTargetQueueScheduler pos_mainThreadScheduler]];
    XCTAssertNoThrow([schedulable preferedSize]);
}

- (void)testDisabledProtectionForSchedulableProtocol {
    XCTestExpectation *expectation = [self expectationWithDescription:@"e"];
    SchedulableObject *s = [[SchedulableObject alloc]
                            initWithScheduler:[RACTargetQueueScheduler pos_scheduler]];
    [s scheduleBlock:^(SchedulableObject *scheduledObject) {
        [scheduledObject methodA];
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

@end
