//
//  SODHTTPPOST.m
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 15.04.16.
//  Copyright © 2016 Pavel Osipov. All rights reserved.
//

#import "SODHTTPPOST.h"

NS_ASSUME_NONNULL_BEGIN

@implementation SODHTTPPOST

+ (POSHTTPRequest *)body:(NSData *)body dataHandler:(SODHTTPRequestResponseDataHandler)handler {
    return [self p_path:nil body:body dataHandler:handler];
}

+ (POSHTTPRequest *)namedParams:(NSDictionary *)params dataHandler:(SODHTTPRequestResponseDataHandler)handler {
    POSRX_CHECK(params);
    POSRX_CHECK(handler);
    return [self p_path:nil namedParams:params dataHandler:handler];
}

+ (POSHTTPRequest *)path:(NSString *)path
             namedParams:(NSDictionary *)params
             dataHandler:(SODHTTPRequestResponseDataHandler)handler {
    POSRX_CHECK(path);
    POSRX_CHECK(params);
    POSRX_CHECK(handler);
    return [self p_path:path namedParams:params dataHandler:handler];
}

+ (POSHTTPRequest *)path:(NSString *)path JSONParams:(NSDictionary *)params {
    POSRX_CHECK(path);
    POSRX_CHECK(params);
    POSHTTPRequest *request = [[POSHTTPRequest alloc]
                               initWithType:POSHTTPRequestTypePOST
                               method:[POSHTTPRequestMethod path:path query:nil]
                               body:[params posrx_URLJSONBody]
                               headerFields:@{@"content-type": @"application/json"}];
    return request;
}

+ (POSHTTPRequest *)path:(NSString *)path
              JSONParams:(nullable NSDictionary *)params
         responseHandler:(nullable SODHTTPRequestResponseHandler)handler {
    POSRX_CHECK(path);
    POSHTTPRequest *request = [[POSHTTPRequest alloc]
                               initWithType:POSHTTPRequestTypePOST
                               method:[POSHTTPRequestMethod path:path query:nil]
                               body:[params posrx_URLJSONBody]
                               headerFields:@{@"content-type": @"application/json"}];
    if (handler) {
        request.sod_responseHandler = handler;
    }
    return request;
}

+ (POSHTTPRequest *)path:(NSString *)path namedParams:(NSDictionary *)params {
    POSRX_CHECK(path);
    POSRX_CHECK(params);
    POSHTTPRequest *request = [[POSHTTPRequest alloc]
                               initWithType:POSHTTPRequestTypePOST
                               method:[POSHTTPRequestMethod path:path query:nil]
                               body:[params posrx_URLQueryBody]
                               headerFields:@{@"content-type": @"application/json"}];
    return request;
}

#pragma mark Private

+ (POSHTTPRequest *)p_path:(nullable NSString *)path
               namedParams:(nullable NSDictionary *)params
               dataHandler:(nullable SODHTTPRequestResponseDataHandler)handler {
    return [self p_path:path body:[params posrx_URLQueryBody] dataHandler:handler];
}

+ (POSHTTPRequest *)p_path:(nullable NSString *)path
                      body:(nullable NSData *)body
               dataHandler:(nullable SODHTTPRequestResponseDataHandler)handler {
    POSHTTPRequest *request = [[POSHTTPRequest alloc]
                               initWithType:POSHTTPRequestTypePOST
                               method:(path ? [POSHTTPRequestMethod path:path query:nil] : nil)
                               body:body
                               headerFields:nil];
    if (handler) {
        request.sod_responseDataHandler = handler;
    }
    return request;
}

@end

NS_ASSUME_NONNULL_END
