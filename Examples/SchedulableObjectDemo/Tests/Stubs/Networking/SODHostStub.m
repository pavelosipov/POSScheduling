//
//  SODHostStub.m
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 25.06.16.
//  Copyright © 2016 Pavel Osipov. All rights reserved.
//

#import "SODHostStub.h"
#import "SODHTTPGatewayStub.h"
#import <POSRx/NSString+POSRx.h>

NS_ASSUME_NONNULL_BEGIN

@implementation SODHostStub

- (instancetype)init {
    return [self initWithResponseEmitter:nil];
}

+ (instancetype)new {
    return [[self alloc] init];
}

- (instancetype)initWithDataEmitter:(NSData *(^)(id<POSHTTPRequest>))emitter {
    POSRX_CHECK(emitter);
    return [self initWithResponseEmitter:^POSHTTPResponse * _Nonnull(id<POSHTTPRequest> request, NSURL *hostURL) {
        NSURL *responseURL = request.method ? [hostURL posrx_URLByAppendingMethod:request.method] : hostURL;
        return [[POSHTTPResponse alloc]
                initWithData:emitter(request)
                metadata:[[NSHTTPURLResponse alloc]
                          initWithURL:responseURL
                          statusCode:200
                          HTTPVersion:@"1.1"
                          headerFields:nil]];
    }];
}

- (instancetype)initWithResponseEmitter:(nullable SODHostStubResponseEmitter)emitter {
    self = [super
            initWithID:@"stub"
            gateway:[[SODHTTPGatewayStub alloc]
                     initWithRequestHandler:^RACSignal *(id<POSHTTPRequest> request, NSURL *hostURL) {
                         if (emitter) {
                             return [RACSignal return:emitter(request, hostURL)];
                         } else {
                             return [RACSignal return:[[POSHTTPResponse alloc] initWithStatusCode:200]];
                         }
                     }]
            tracker:nil];
    return self;
}

- (nullable NSURL *)URL {
    return [@"https://stub.org" posrx_URL];
}

@end

NS_ASSUME_NONNULL_END
