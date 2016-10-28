//
//  SODAppTracker.h
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 28.01.16.
//  Copyright © 2016 Pavel Osipov. All rights reserved.
//

#import "SODTracker.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SODEnvironment;
@protocol SODKeyedStore;

@interface SODAppTracker : POSSchedulableObject <SODTracker>

/// Activates tracker.
- (void)activate;

/// @brief Registers external tracking system.
/// @param service Events handler.
- (void)addService:(id<SODTracker>)service;

/// @brief The designated initializer.
/// @param store Mandatory store to persist state between app launches.
/// @param environment Mandatory environment.
/// @return Tracker instance scheduled in the same thread as store.
- (instancetype)initWithScheduler:(RACTargetQueueScheduler *)scheduler
                            store:(id<SODKeyedStore>)store
                      environment:(id<SODEnvironment>)environment;

/// Hiding deadly initializers.
POSRX_SCHEDULABLE_INIT_RECURSIVELY_UNAVAILABLE

@end

NS_ASSUME_NONNULL_END
