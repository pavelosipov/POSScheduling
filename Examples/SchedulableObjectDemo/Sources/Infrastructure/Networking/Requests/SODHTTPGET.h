//
//  SODHTTPGET.h
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 28.09.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import "POSHTTPRequest+SOD.h"

NS_ASSUME_NONNULL_BEGIN

/// Group of factory methods to create HTTP GET requests.
@interface SODHTTPGET : NSObject

+ (POSHTTPRequest *)empty;

+ (POSHTTPRequest *)path:(NSString *)path;

+ (POSHTTPRequest *)path:(NSString *)path query:(NSDictionary *)query;

+ (POSHTTPRequest *)path:(NSString *)path dataHandler:(SODHTTPRequestResponseDataHandler)dataHandler;

+ (POSHTTPRequest *)path:(NSString *)path query:(NSDictionary *)query dataHandler:(SODHTTPRequestResponseDataHandler)dataHandler;

+ (POSHTTPRequest *)query:(NSDictionary *)query;

+ (POSHTTPRequest *)query:(NSDictionary *)query dataHandler:(SODHTTPRequestResponseDataHandler)dataHandler;

+ (POSHTTPRequest *)dataHandler:(SODHTTPRequestResponseDataHandler)dataHandler;

@end

NS_ASSUME_NONNULL_END
