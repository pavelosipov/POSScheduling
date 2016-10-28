//
//  SODHTTPRequest+SOD.m
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 28.09.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import "POSHTTPRequest+SOD.h"
#import "NSError+SODHost.h"
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - POSHTTPRequest (SOD)

static char kSODHTTPRequestResponseHandlerKey;
static char kSODHTTPRequestResponseDataHandlerKey;
static char kSODHTTPRequestResponseMetadataHandlerKey;

@implementation POSHTTPRequest (SOD)

- (nullable SODHTTPRequestResponseHandler)sod_responseHandler {
    SODHTTPRequestResponseHandler handler = objc_getAssociatedObject(self, &kSODHTTPRequestResponseHandlerKey);
    if (handler) {
        return handler;
    }
    return [^id(POSHTTPResponse *response, NSError **error) {
        SODHTTPRequestResponseMetadataHandler metadataHandler = self.sod_responseMetadataHandler;
        if (!metadataHandler(response.metadata, error)) {
            return nil;
        }
        if (self.sod_responseDataHandler) {
            if (!response.data) {
                SODAssignError(error, [NSError sod_responseErrorWithResponse:response.metadata tags:@[@"nodata"] format:nil]);
                return nil;
            }
            return self.sod_responseDataHandler(response.data, error);
        }
        return response;
    } copy];
}

- (nullable SODHTTPRequestResponseMetadataHandler)sod_responseMetadataHandler {
    SODHTTPRequestResponseMetadataHandler handler = objc_getAssociatedObject(self, &kSODHTTPRequestResponseMetadataHandlerKey);
    if (handler) {
        return handler;
    }
    return [^BOOL(NSHTTPURLResponse *metadata, NSError **error) {
        if (![metadata sod_contains2XXStatusCode]) {
            SODAssignError(error, [NSError
                                   sod_responseErrorWithResponse:metadata
                                   tags:@[@"badcode", @(metadata.statusCode).stringValue]
                                   format:nil]);
            return NO;
        }
        return YES;
    } copy];
}

- (void)sod_setResponseMetadataHandler:(nullable SODHTTPRequestResponseMetadataHandler)handler {
    objc_setAssociatedObject(self, &kSODHTTPRequestResponseMetadataHandlerKey, handler, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)sod_setResponseHandler:(nullable SODHTTPRequestResponseHandler)handler {
    objc_setAssociatedObject(self, &kSODHTTPRequestResponseHandlerKey, handler, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (nullable SODHTTPRequestResponseDataHandler)sod_responseDataHandler {
    return objc_getAssociatedObject(self, &kSODHTTPRequestResponseDataHandlerKey);
}

- (void)sod_setResponseDataHandler:(nullable SODHTTPRequestResponseDataHandler)handler {
    objc_setAssociatedObject(self, &kSODHTTPRequestResponseDataHandlerKey, handler, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end

#pragma mark - NSHTTPURLResponse (SOD)

@implementation NSHTTPURLResponse (SOD)

- (BOOL)sod_contains2XXStatusCode {
    return self.statusCode / 100 == 2;
}

@end

NS_ASSUME_NONNULL_END
