//
//  SODAccountRepository.h
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 03.06.16.
//  Copyright © 2016 Pavel Osipov. All rights reserved.
//

#import <POSRx/POSRx.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SODKeyedStore;
@protocol SODTracker;
@class SODAccount;

/// Possible sign out reasons.
typedef NS_ENUM(NSInteger, SODSignOutReason) {
    SODSignOutReasonInvalidToken
};

/// Provides all signed in accounts in the app.
@protocol SODAccountRepository <POSSchedulable>

/// Signal of nonnull NSArray<SODAccount *>.
@property (atomic, readonly) RACSignal *accountsSignal;

/// Checks account availability.
- (BOOL)containsAccount:(SODAccount *)account;

/// Stores account.
- (void)addAccount:(SODAccount *)account;

/// Removes account.
- (void)removeAccount:(SODAccount *)account
               reason:(SODSignOutReason)reason;

@end

/// Default implementation of SODAccountProvider protocol.
@interface SODAccountRepository : POSSchedulableObject <SODAccountRepository>

/// The designated initializer.
- (instancetype)initWithScheduler:(RACTargetQueueScheduler *)scheduler
                       keyedStore:(id<SODKeyedStore>)keyedStore
                          tracker:(nullable id<SODTracker>)tracker;


/// Hidden deadly initializers.
POSRX_SCHEDULABLE_INIT_RECURSIVELY_UNAVAILABLE

@end

NS_ASSUME_NONNULL_END
