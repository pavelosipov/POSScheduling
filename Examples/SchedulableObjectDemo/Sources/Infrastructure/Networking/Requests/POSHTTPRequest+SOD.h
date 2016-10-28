//
//  SODHTTPRequest+SOD.h
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 28.09.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import <POSRx/POSRx.h>

NS_ASSUME_NONNULL_BEGIN

typedef __nullable id (^SODHTTPRequestResponseHandler)(POSHTTPResponse *response, NSError **error);
typedef BOOL (^SODHTTPRequestResponseMetadataHandler)(NSHTTPURLResponse *metadata, NSError **error);
typedef __nullable id (^SODHTTPRequestResponseDataHandler)(NSData *responseData, NSError **error);

@interface POSHTTPRequest (SOD)

/// @brief Block for handling response from HTTPGateway.
/// @remarks It is your job to validate both metadata and data.
/// @remarks Response block may signal about error in out error parameter or throwing NSException.
/// @remarks If block returns nil, then its signal completes without values.
/// @remarks Default handler will check, that status code has 2XX value and then use
///          responseDataHandler block to process data.
/// @return Value which will be emitted by signal.
@property (nonatomic, copy, nullable, setter = sod_setResponseHandler:) SODHTTPRequestResponseHandler sod_responseHandler;

/// @brief Block for handling metadata in the response from HTTPGateway.
/// @remarks Response block may signal about error in out error parameter or throwing NSException.
/// @remarks If block returns NO, then it should return error in out parameter.
/// @return YES if response handling should proceed or NO to break handling and return error.
@property (nonatomic, copy, nullable, setter = sod_setResponseMetadataHandler:) SODHTTPRequestResponseMetadataHandler sod_responseMetadataHandler;

/// @brief Block for handling data in the response from HTTPGateway.
/// @remarks Response block may signal about error in out error parameter or throwing NSException.
/// @remarks If block returns nil, then its signal completes without values.
/// @remarks Default handler returns responseData.
/// @return Value which will be emitted by signal.
@property (nonatomic, copy, nullable, setter = sod_setResponseDataHandler:) SODHTTPRequestResponseDataHandler sod_responseDataHandler;

@end


/// Helpers around NSHTTPURLResponse.
@interface NSHTTPURLResponse (SOD)

/// @return YES if status code is in range [200..299].
- (BOOL)sod_contains2XXStatusCode;

@end

NS_ASSUME_NONNULL_END
