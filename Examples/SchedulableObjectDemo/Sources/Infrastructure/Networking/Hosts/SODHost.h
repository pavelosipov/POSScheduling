//
//  SODHost.h
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 22.09.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import <POSRx/POSRx.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SODTracker;

/// Base host implementation.
@protocol SODHost <POSSchedulable>

/// Host unique identifier.
@property (nonatomic, readonly) NSString *ID;

/// URL of the host. May be nil.
@property (nonatomic, readonly, nullable) NSURL *URL;

/// @brief Sends request.
/// @param request Sending request.
/// @return Signal of response handling result.
- (RACSignal *)pushRequest:(POSHTTPRequest *)request;

/// @brief Sends request.
/// @param request Sending request.
/// @param options Custom options which will override host-specific options.
/// @return Signal of response handling result.
- (RACSignal *)pushRequest:(POSHTTPRequest *)request
                   options:(nullable POSHTTPRequestExecutionOptions *)options;

@end

/// Base implementation for Host protocol.
@interface SODHost : POSSchedulableObject <SODHost>

/// @brief The designated initializer.
/// @param ID Host identifier.
/// @param gateway Mandatory gateway.
/// @return Host instance.
- (instancetype)initWithID:(NSString *)ID
                   gateway:(id<POSHTTPGateway>)gateway
                   tracker:(nullable id<SODTracker>)tracker;

/// Hiding deadly initializers.
POSRX_SCHEDULABLE_INIT_RECURSIVELY_UNAVAILABLE

@end

NS_ASSUME_NONNULL_END
