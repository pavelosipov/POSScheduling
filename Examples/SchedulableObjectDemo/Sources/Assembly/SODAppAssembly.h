//
//  SODAppAssembly.h
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 14.03.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import <POSRx/POSRx.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SODAccountRepository;
@protocol SODAppMonitor;
@protocol SODDropboxAuthenticator;
@protocol SODTracker;

/// All application services.
@interface SODAppAssembly : POSSchedulableObject

// Domain services
@property (nonatomic, readonly) id<SODAccountRepository> accountRepository;
@property (nonatomic, readonly) id<SODDropboxAuthenticator> dropboxAuthenticator;

// Infrastructure services
@property (nonatomic, readonly) id<SODTracker> tracker;

// Technical
@property (nonatomic, readonly) RACTargetQueueScheduler *backgroundScheduler;

/// The designated initializer.
+ (instancetype)assemblyWithAppMonitor:(id<SODAppMonitor>)appMonitor;

/// Hidden deadly initializers.
POSRX_SCHEDULABLE_INIT_RECURSIVELY_UNAVAILABLE

@end

NS_ASSUME_NONNULL_END
