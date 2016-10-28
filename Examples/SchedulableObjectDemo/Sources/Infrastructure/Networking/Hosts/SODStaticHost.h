//
//  SODStaticHost.h
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 11.04.16.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import "SODHost.h"

NS_ASSUME_NONNULL_BEGIN

/// Host which URL will not change during its lifetime.
@interface SODStaticHost : SODHost

/// Th designated initializer.
- (instancetype)initWithID:(NSString *)ID
                   gateway:(id<POSHTTPGateway>)gateway
                   tracker:(nullable id<SODTracker>)tracker
                       URL:(NSURL *)URL;

/// Hidden initializer of the super class.
- (instancetype)initWithID:(NSString *)ID
                   gateway:(id<POSHTTPGateway>)gateway
                   tracker:(nullable id<SODTracker>)tracker NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
