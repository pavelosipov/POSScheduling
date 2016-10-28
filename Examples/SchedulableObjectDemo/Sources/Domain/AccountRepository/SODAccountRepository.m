//
//  SODAccountRepository.m
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 03.06.16.
//  Copyright © 2016 Pavel Osipov. All rights reserved.
//

#import "SODAccountRepository.h"
#import "SODAccount.h"
#import "SODKeyedStore.h"
#import "SODTracker.h"
#import "SODTrackableEvent.h"
#import "NSError+SODAuth.h"

NS_ASSUME_NONNULL_BEGIN

static NSString * const kSODAccountPersistentKey = @"accounts";

#pragma mark -

static NSString *SODStringFromSignOutReason(SODSignOutReason reason) {
    switch (reason) {
        case SODSignOutReasonInvalidToken: return @"invalid_token";
    }
}

#pragma mark -

@interface SODAccountRepository ()
@property (nonatomic, readonly) id<SODTracker> tracker;
@property (nonatomic, readonly) id<SODKeyedStore> keyedStore;
@property (atomic) NSArray<SODAccount *> *accounts;
@property (atomic) RACSignal *accountsSignal;
@end

@implementation SODAccountRepository

- (instancetype)initWithScheduler:(RACTargetQueueScheduler *)scheduler
                       keyedStore:(id<SODKeyedStore>)keyedStore
                          tracker:(nullable id<SODTracker>)tracker {
    POSRX_CHECK(keyedStore);
    if (self = [super initWithScheduler:scheduler]) {
        NSArray *accounts = [keyedStore objectForKey:kSODAccountPersistentKey];
        _accounts = accounts ?: [NSArray new];
        _tracker = tracker;
        _keyedStore = keyedStore;
        _accountsSignal = RACObserve(self, accounts);
    }
    return self;
}

#pragma mark SODAccountProvider

- (BOOL)containsAccount:(SODAccount *)account {
    return [_accounts indexOfObjectPassingTest: ^BOOL(SODAccount *existingAccount, NSUInteger idx, BOOL *stop) {
        return (existingAccount.cloudType == account.cloudType &&
                [existingAccount.ID isEqualToString:account.ID]);
    }] != NSNotFound;
}

- (void)addAccount:(SODAccount *)account {
    POSRX_CHECK(account);
    if ([self containsAccount:account]) {
        return;
    }
    NSArray *accounts = [_accounts arrayByAddingObject:account];
    NSError *error;
    if (![_keyedStore setObject:accounts forKey:kSODAccountPersistentKey error:&error]) {
        [_tracker track:[NSError sod_errorWithCategory:kSODAuthCategory
                                              userInfo:@{NSUnderlyingErrorKey: error}]];
    }
    [_tracker track:[SODTrackableEvent
                     eventWithArea:kSODAuthCategory
                     tags:@[@"sign_in", SODStringFromCloudType(account.cloudType)]]];
    self.accounts = accounts;
}

- (void)removeAccount:(SODAccount *)account
               reason:(SODSignOutReason)reason {
    POSRX_CHECK(account);
    NSArray *accounts = [_accounts filteredArrayUsingPredicate:
                         [NSPredicate predicateWithBlock:^BOOL(SODAccount *existingAccount, NSDictionary<NSString *,id> *bindings) {
        return account != existingAccount;
    }]];
    if (accounts.count == _accounts.count) {
        return;
    }
    NSError *error;
    if (![_keyedStore setObject:accounts forKey:kSODAccountPersistentKey error:&error]) {
        [_tracker track:[NSError sod_errorWithCategory:kSODAuthCategory
                                              userInfo:@{NSUnderlyingErrorKey: error}]];
    }
    [_tracker track:[SODTrackableEvent
                     eventWithArea:kSODAuthCategory
                     tags:@[@"sign_out",
                            SODStringFromCloudType(account.cloudType),
                            SODStringFromSignOutReason(reason)]]];
    self.accounts = accounts;
}

@end

NS_ASSUME_NONNULL_END
