//
//  SODHTTPGatewayStub.h
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 25.06.16.
//  Copyright © 2015 Pavel Osipov. All rights reserved.
//

#import <POSRx/POSRx.h>

NS_ASSUME_NONNULL_BEGIN

@interface SODHTTPGatewayStub : POSSchedulableObject <POSHTTPGateway>

- (instancetype)initWithRequestHandler:(RACSignal *(^)(id<POSHTTPRequest> request, NSURL *hostURL))requestHandler;

POSRX_SCHEDULABLE_INIT_RECURSIVELY_UNAVAILABLE

@end

NS_ASSUME_NONNULL_END
