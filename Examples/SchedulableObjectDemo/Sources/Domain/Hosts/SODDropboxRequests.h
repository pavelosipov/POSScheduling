//
//  SODDropboxRequests.h
//  SchedulableObjectDemo
//
//  Created by Osipov on 15/06/16.
//  Copyright © 2016 Pavel Osipov. All rights reserved.
//

#import <POSRx/POSRx.h>
#import <POSJSONParsing/POSJSONParsing.h>

NS_ASSUME_NONNULL_BEGIN

typedef __nullable id (^SODDropboxRPCPayloadHandler)(POSJSONMap *JSON, NSError **error);

@interface SODDropboxRPC : NSObject

+ (POSHTTPRequest *)path:(NSString *)path
          payloadHandler:(nullable SODDropboxRPCPayloadHandler)handler;

+ (POSHTTPRequest *)path:(NSString *)path
                  params:(nullable NSDictionary *)params
          payloadHandler:(nullable SODDropboxRPCPayloadHandler)handler;

@end

NS_ASSUME_NONNULL_END
