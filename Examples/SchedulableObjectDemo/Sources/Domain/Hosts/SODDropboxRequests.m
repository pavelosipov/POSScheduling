//
//  SODDropboxRequests.m
//  SchedulableObjectDemo
//
//  Created by Osipov on 15/06/16.
//  Copyright © 2016 Pavel Osipov. All rights reserved.
//

#import "SODDropboxRequests.h"
#import "SODHTTPPOST.h"
#import "NSError+SODAuth.h"

NS_ASSUME_NONNULL_BEGIN

@implementation SODDropboxRPC

+ (POSHTTPRequest *)path:(NSString *)path
          payloadHandler:(nullable SODDropboxRPCPayloadHandler)handler {
    POSRX_CHECK(path);
    return [self path:path params:nil payloadHandler:handler];
}

+ (POSHTTPRequest *)path:(NSString *)path
                    params:(nullable NSDictionary *)params
            payloadHandler:(nullable SODDropboxRPCPayloadHandler)handler {
    POSRX_CHECK(path);
    return [SODHTTPPOST
            path:path
            JSONParams:params
            responseHandler:[self p_responseHandlerWithPayloadHandler:handler]];
}

#pragma mark Private

+ (SODHTTPRequestResponseHandler)p_responseHandlerWithPayloadHandler:(nullable SODDropboxRPCPayloadHandler)payloadHandler {
    return ^__nullable id(POSHTTPResponse *response, NSError **error) {
        NSString *requestID = response.metadata.allHeaderFields[@"X-Dropbox-Request-Id"];
        if (![response.metadata sod_contains2XXStatusCode]) {
            NSString *extraInfo = nil;
            if (response.data) {
                extraInfo = [[NSString alloc] initWithData:response.data encoding:NSUTF8StringEncoding];
            }
            SODAssignError(error, [NSError
                                   sod_responseErrorWithResponse:response.metadata
                                   tags:@[@"badcode", @(response.metadata.statusCode).stringValue]
                                   format:extraInfo]);
            return nil;
        }
        POSJSONMap *JSON = response.data ? [[POSJSONMap alloc] initWithData:response.data] : nil;
        NSString *errorCode = [[JSON tryExtract:@"error"] asString];
        if (errorCode) {
            NSString *description = [[JSON tryExtract:@"error_description"] asString] ?: requestID;
            SODAssignError(error, [NSError
                                   sod_responseErrorWithResponse:response.metadata
                                   tags:@[@"badcode", @(response.metadata.statusCode).stringValue, errorCode]
                                   format:description]);
            return nil;
        }
        if (!payloadHandler) {
            return JSON;
        }
        if (!JSON) {
            SODAssignError(error, [NSError
                                   sod_responseErrorWithResponse:response.metadata
                                   tags:@[@"nodata"]
                                   format:requestID]);
            return nil;
        }
        return payloadHandler(JSON, error);
    };
}

@end

NS_ASSUME_NONNULL_END
