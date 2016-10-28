//
//  SODHost.m
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 22.09.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import "SODHost.h"
#import "SODTracker.h"
#import "POSHTTPRequest+SOD.h"
#import "NSError+SODHost.h"

NS_ASSUME_NONNULL_BEGIN

@interface SODHost ()
@property (nonatomic) NSString *ID;
@property (nonatomic) id<POSHTTPGateway> gateway;
@property (nonatomic, nullable) id<SODTracker> tracker;
@end

@implementation SODHost

- (instancetype)initWithID:(NSString *)ID
                   gateway:(id<POSHTTPGateway>)gateway
                   tracker:(nullable id<SODTracker>)tracker {
    POSRX_CHECK(ID.length > 0);
    POSRX_CHECK(gateway);
    if (self = [super initWithScheduler:gateway.scheduler]) {
        _ID = [ID copy];
        _gateway = gateway;
        _tracker = tracker;
    }
    return self;
}

- (nullable NSURL *)URL {
    POSRX_CHECK(!@"Should be overrided in subclasses.");
    return nil;
}

- (RACSignal *)pushRequest:(POSHTTPRequest *)request {
    return [self pushRequest:request options:nil];
}

- (RACSignal *)pushRequest:(POSHTTPRequest *)request
                   options:(nullable POSHTTPRequestExecutionOptions *)options {
    POSRX_CHECK(request);
    POSRX_CHECK(self.URL);
    @weakify(self);
    return [[[[[[_gateway taskForRequest:request toHost:self.URL options:options] execute]
            takeUntil:self.rac_willDeallocSignal]
            catch:^RACSignal *(NSError *error) {
                return [RACSignal error:
                        (error.sod_URL
                         ? [NSError sod_networkErrorWithReason:error]
                         : [NSError sod_systemErrorWithReason:error])];
            }] flattenMap:^RACSignal *(POSHTTPResponse *response) {
                @try {
                    NSError *error = nil;
                    id parsedResponse = response;
                    if (request.sod_responseHandler) {
                        parsedResponse = request.sod_responseHandler(response, &error);
                    }
                    if (error) {
                        return [RACSignal error:error];
                    }
                    if (parsedResponse) {
                        return [RACSignal return:parsedResponse];
                    }
                    return [RACSignal empty];
                } @catch (NSException *exception) {
                    return [RACSignal error:[NSError
                                             sod_responseErrorWithResponse:response.metadata
                                             tags:@[@"exception"]
                                             format:exception.reason]];
                }
            }] doError:^(NSError *error) {
                @strongify(self);
                [self.tracker track:[NSError sod_hostErrorWithHostID:self.ID reason:error]];
            }];
}

@end

NS_ASSUME_NONNULL_END
