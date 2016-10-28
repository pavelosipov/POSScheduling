//
//  SODHTTPPOST.h
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 15.04.16.
//  Copyright © 2016 Pavel Osipov. All rights reserved.
//

#import "POSHTTPRequest+SOD.h"

NS_ASSUME_NONNULL_BEGIN

@interface SODHTTPPOST : NSObject

+ (POSHTTPRequest *)body:(NSData *)body
             dataHandler:(SODHTTPRequestResponseDataHandler)handler;

+ (POSHTTPRequest *)namedParams:(NSDictionary *)params
                    dataHandler:(SODHTTPRequestResponseDataHandler)handler;

+ (POSHTTPRequest *)path:(NSString *)path
              JSONParams:(NSDictionary *)params;

+ (POSHTTPRequest *)path:(NSString *)path
              JSONParams:(nullable NSDictionary *)params
         responseHandler:(nullable SODHTTPRequestResponseHandler)handler;

+ (POSHTTPRequest *)path:(NSString *)path
             namedParams:(NSDictionary *)params;

+ (POSHTTPRequest *)path:(NSString *)path
             namedParams:(NSDictionary *)params
             dataHandler:(SODHTTPRequestResponseDataHandler)handler;

@end

NS_ASSUME_NONNULL_END
