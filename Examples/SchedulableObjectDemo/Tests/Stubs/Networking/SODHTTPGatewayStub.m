//
//  SODHTTPGatewayStub.m
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 25.06.16.
//  Copyright © 2015 Pavel Osipov. All rights reserved.
//

#import "SODHTTPGatewayStub.h"

NS_ASSUME_NONNULL_BEGIN

@interface SODHTTPGatewayStub ()
@property (nonatomic, copy) RACSignal *(^requestHandler)(id<POSHTTPRequest> request, NSURL *hostURL);
@end

@implementation SODHTTPGatewayStub

- (instancetype)initWithRequestHandler:(RACSignal *(^)(id<POSHTTPRequest>, NSURL *))requestHandler {
    POSRX_CHECK(requestHandler);
    if (self = [super initWithScheduler:RACTargetQueueScheduler.pos_mainThreadScheduler]) {
        _requestHandler = [requestHandler copy];
    }
    return self;
}

#pragma mark POSHTTPGateway

- (NSURLSession *)foregroundSession {
    return nil;
}

- (nullable NSURLSession *)backgroundSession {
    return nil;
}

- (id<POSTask>)taskForRequest:(id<POSHTTPRequest>)request
                       toHost:(NSURL *)hostURL
                      options:(nullable POSHTTPRequestExecutionOptions *)options {
    return [POSTask createTask:^RACSignal *(id _) {
        return self.requestHandler(request, hostURL);
    } scheduler:self.scheduler];
}

- (void)recoverBackgroundUploadRequestsUsingBlock:(void(^)(NSArray *uploadRequests))block {
    if (block) {
        block(NSArray.new);
    }
}

- (RACSignal *)invalidateCancelingRequests:(BOOL)cancelPendingRequests {
    return [RACSignal empty];
}

@end

NS_ASSUME_NONNULL_END
