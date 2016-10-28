//
//  SODDropboxAuthenticator.h
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 08.03.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import <POSRx/POSRx.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SODAppMonitor;

/// Authenticates user in the Cloud and sends request to the service.
@protocol SODDropboxAuthenticator <POSSchedulable>

/// NSURL of OAuth service.
@property (nonatomic, readonly) NSURL *oauthURL;

/// @brief Starts user interaction to perform sign in procedure.
/// @return Signal of nonnull SODAccount.
- (RACSignal *)listenForSignIn;

@end

/// Default implementation of SODAccountProvider protocol.
@interface SODDropboxAuthenticator : POSSchedulableObject <SODDropboxAuthenticator>

/// The designated initializer.
- (instancetype)initWithDropboxAppKey:(NSString *)appKey
                           appMonitor:(id<SODAppMonitor>)appMonitor;

/// Hidden deadly initializers.
POSRX_SCHEDULABLE_INIT_RECURSIVELY_UNAVAILABLE

@end

NS_ASSUME_NONNULL_END
