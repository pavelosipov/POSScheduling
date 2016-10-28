//
//  SODAccountRepositoryTests.m
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 04.06.16.
//  Copyright © 2016 Pavel Osipov. All rights reserved.
//

#import "SODAccountRepository.h"
#import "SODAccount.h"
#import "SODKeyedStore.h"
#import "SODEphemeralKeyedStoreBackend.h"
#import "NSError+SODTrackable.h"
#import <POSAllocationTracker/POSAllocationTracker.h>
#import <XCTest/XCTest.h>

static NSString * const kAccountPersistentKey = @"accounts";

@interface SODAccountRepositoryTests : XCTestCase
@property (nonatomic) id<SODKeyedStore> persistentStore;
@property (nonatomic) id<SODAccountRepository> accountRepository;
@end

@implementation SODAccountRepositoryTests

- (void)setUp {
    [super setUp];
    self.persistentStore = [[SODKeyedStore alloc] initWithBackend:[SODEphemeralKeyedStoreBackend new] error:nil];
}

- (void)tearDown {
    self.persistentStore = nil;
    self.accountRepository = nil;
    [self checkMemoryLeaks];
    [super tearDown];
}

- (void)checkMemoryLeaks {
    XCTAssert([POSAllocationTracker instanceCountForClass:SODAccountRepository.class] == 0);
    XCTAssert([POSAllocationTracker instanceCountForClass:SODAccount.class] == 0);
    XCTAssert([POSAllocationTracker instanceCountForClass:SODKeyedStore.class] == 0);
    XCTAssert([POSAllocationTracker instanceCountForClass:RACDisposable.class] == 0);
    [super tearDown];
}

- (void)testStoreShouldReadAccountsOnDemand {
    XCTestExpectation *expectation = [self expectationWithDescription:@"e"];
    SODAccount *account = [[SODAccount alloc]
                           initWithCloudType:SODCloudTypeDropbox
                           ID:@"123"
                           credentials:nil];
    [_persistentStore setObject:@[account] forKey:kAccountPersistentKey error:nil];
    self.accountRepository = [[SODAccountRepository alloc]
                              initWithScheduler:[RACTargetQueueScheduler pos_mainThreadScheduler]
                              keyedStore:_persistentStore
                              tracker:nil];
    [_accountRepository.accountsSignal subscribeNext:^(NSArray<SODAccount *> *accounts) {
        XCTAssertTrue(accounts.count == 1);
        XCTAssertTrue(accounts.firstObject == account);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testStoreShouldAddAccountsToPersistentStore {
    self.accountRepository = [[SODAccountRepository alloc]
                              initWithScheduler:[RACTargetQueueScheduler pos_mainThreadScheduler]
                              keyedStore:_persistentStore
                              tracker:nil];
    SODAccount *account = [[SODAccount alloc]
                           initWithCloudType:SODCloudTypeDropbox
                           ID:@"123"
                           credentials:nil];
    __block NSArray<SODAccount *> *actualAccounts;
    [_accountRepository.accountsSignal subscribeNext:^(NSArray<SODAccount *> *accounts) {
        actualAccounts = accounts;
    }];
    [_accountRepository addAccount:account];
    NSArray<SODAccount *> *persistedAccounts = [self.persistentStore objectForKey:kAccountPersistentKey];
    XCTAssertTrue(persistedAccounts == actualAccounts);
    XCTAssertTrue(persistedAccounts.count == 1);
    XCTAssertTrue(persistedAccounts.firstObject == account);
}

- (void)testStoreShouldNotAddEqualAccounts {
    self.accountRepository = [[SODAccountRepository alloc]
                              initWithScheduler:[RACTargetQueueScheduler pos_mainThreadScheduler]
                              keyedStore:_persistentStore
                              tracker:nil];
    __block NSArray<SODAccount *> *actualAccounts;
    [_accountRepository.accountsSignal subscribeNext:^(NSArray<SODAccount *> *accounts) {
        actualAccounts = accounts;
    }];
    SODAccount *account = [[SODAccount alloc]
                           initWithCloudType:SODCloudTypeDropbox
                           ID:@"123"
                           credentials:nil];
    [_accountRepository addAccount:account];
    SODAccount *equalAccount = [[SODAccount alloc]
                                initWithCloudType:SODCloudTypeDropbox
                                ID:@"123"
                                credentials:nil];
    [_accountRepository addAccount:equalAccount];
    XCTAssertTrue(actualAccounts.count == 1);
}

- (void)testStoreShouldRemoveAccountsFromPersistentStore {
    self.accountRepository = [[SODAccountRepository alloc]
                              initWithScheduler:[RACTargetQueueScheduler pos_mainThreadScheduler]
                              keyedStore:_persistentStore
                              tracker:nil];
    SODAccount *account = [[SODAccount alloc]
                           initWithCloudType:SODCloudTypeDropbox
                           ID:@"123"
                           credentials:nil];
    __block NSArray<SODAccount *> *actualAccounts;
    [_accountRepository.accountsSignal subscribeNext:^(NSArray<SODAccount *> *accounts) {
        actualAccounts = accounts;
    }];
    [_accountRepository addAccount:account];
    [_accountRepository removeAccount:account reason:SODSignOutReasonInvalidToken];
    NSArray<SODAccount *> *persistedAccounts = [self.persistentStore objectForKey:kAccountPersistentKey];
    XCTAssertTrue(persistedAccounts == actualAccounts);
    XCTAssertTrue(persistedAccounts.count == 0);
}

@end
