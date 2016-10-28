//
//  SODHostStub.h
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 25.06.16.
//  Copyright © 2016 Pavel Osipov. All rights reserved.
//

#import "SODHost.h"

NS_ASSUME_NONNULL_BEGIN

typedef  POSHTTPResponse * _Nonnull (^SODHostStubResponseEmitter)(id<POSHTTPRequest> request, NSURL *hostURL);

@interface SODHostStub : SODHost

- (instancetype)init;
+ (instancetype)new;

- (instancetype)initWithDataEmitter:(NSData *(^)(id<POSHTTPRequest> request))emitter;

- (instancetype)initWithResponseEmitter:(nullable SODHostStubResponseEmitter)emitter;

- (instancetype)initWithID:(NSString *)ID
                   gateway:(id<POSHTTPGateway>)gateway
                   tracker:(nullable id<SODTracker>)tracker NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
