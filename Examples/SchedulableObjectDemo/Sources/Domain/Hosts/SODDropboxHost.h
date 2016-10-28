//
//  SODDropboxHost.h
//  SchedulableObjectDemo
//
//  Created by Osipov on 15/06/16.
//  Copyright © 2016 Pavel Osipov. All rights reserved.
//

#import "SODHost.h"

NS_ASSUME_NONNULL_BEGIN

@class SODAccount;
@protocol SODAccountRepository;

/// Performs all requests to Dropbox hosts and handles Dropbox-specific errors.
/// Signals returned by pushRequests methods emit nonnull POSJSONMap objects or nothing.
@interface SODDropboxHost : SODHost

/// The designated initializer.
- (instancetype)initWithID:(NSString *)ID
                       URL:(NSURL *)baseURL
                   account:(SODAccount *)account
         accountRepository:(id<SODAccountRepository>)accountRepository
                   gateway:(id<POSHTTPGateway>)gateway
                   tracker:(nullable id<SODTracker>)tracker;

/// Hidden base class initializer.
- (instancetype)initWithID:(NSString *)ID
                   gateway:(id<POSHTTPGateway>)gateway
                   tracker:(nullable id<SODTracker>)tracker NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
