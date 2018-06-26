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

- (void)testSelectorsForClassShouldReturnDerivedMethods {
    RACSequence *mockSels = [POSSchedulableObject selectorsForClass:[EmptyMock class]];
    RACSequence *baseSels = [POSSchedulableObject selectorsForClass:[NSObject class]];
    XCTAssertTrue([[mockSels array] count] == [[baseSels array] count]);
}

- (void)testSelectorsForProtocolShouldReturnNSObjectProtocolSelectors {
    RACSequence *sels = [POSSchedulableObject selectorsForProtocol:@protocol(NSObject)];
    XCTAssert([[sels array] count] > 0);
}

- (void)testSelectorsForClassShouldContainSelectorsFromClass {
    RACSequence *sels = [POSSchedulableObject selectorsForClass:[TestA class]];
    XCTAssertTrue([[sels array] containsObject:[NSValue valueWithPointer:@selector(a)]]);
}

- (void)testSelectorsForProtocolShouldContainSelectorsFromProtocol {
    RACSequence *sels = [POSSchedulableObject selectorsForProtocol:@protocol(TestingA)];
    XCTAssertTrue([[sels array] containsObject:[NSValue valueWithPointer:@selector(a)]]);
}

- (void)testSelectorsForClassShouldNotContainNonexistingSelectors {
    RACSequence *sels = [POSSchedulableObject selectorsForClass:[TestA class]];
    XCTAssertFalse([[sels array] containsObject:[NSValue valueWithPointer:NSSelectorFromString(@"nonexistingSel")]]);
}

- (void)testSelectorsForProtocolShouldNotContainNonexistingSelectors {
    RACSequence *sels = [POSSchedulableObject selectorsForProtocol:@protocol(TestingA)];
    XCTAssertFalse([[sels array] containsObject:[NSValue valueWithPointer:NSSelectorFromString(@"nonexistingSel")]]);
}

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
    SchedulableObject *schedulable1 = [[SchedulableObject alloc] initWithScheduler:[RACTargetQueueScheduler pos_scheduler]];
    SchedulableObject *schedulable2 = [[SchedulableObject alloc]
                                       initWithScheduler:[RACTargetQueueScheduler pos_scheduler]
                                       options:[[POSScheduleProtectionOptions
                                                defaultOptionsForClass:[SchedulableObject class]]
                                                exclude:[POSSchedulableObject selectorsForProtocol:@protocol(SafeProtocol)]]];
    SchedulableObject *schedulable3 = [[SchedulableObject alloc] initWithScheduler:[RACTargetQueueScheduler pos_scheduler]];
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
