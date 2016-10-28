//
//  NSError+SODHost.h
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 16.03.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import "NSError+SODTrackable.h"

NS_ASSUME_NONNULL_BEGIN

/// Category for host communication errors.
FOUNDATION_EXTERN NSString * const kSODHostErrorCategory;
/// Category for errors caused by bad responses.
FOUNDATION_EXTERN NSString * const kSODResponseErrorCategory;

/// Category for networking errors.
FOUNDATION_EXTERN NSString * const kSODNetworkErrorCategory;

/// Errors caused by network communications.
@interface NSError (SODHost)

/// URL of problem host.
@property (nonatomic, readonly, nullable) NSURL *sod_URL;

/// Unexpected or malformed response from Web service.
@property (nonatomic, readonly, nullable) NSHTTPURLResponse *sod_response;

/// @brief Factory method for network errors.
/// @param reason Reason of network error.
/// @return Localized error.
+ (NSError *)sod_networkErrorWithReason:(nullable NSError *)reason;

/// Factory method for internal errors.
/// @brief Factory method for unexpected or malformed responses from Web services.
/// @param response Metadata of the response.
/// @param tags Tags for error classification.
/// @param format Error description.
/// @return Localized error.
+ (NSError *)sod_responseErrorWithResponse:(nullable NSHTTPURLResponse *)response
                                      tags:(nullable NSArray<NSString *> *)tags
                                    format:(nullable NSString *)format, ...;

/// Factory method for internal errors.
/// @brief Factory method for unexpected or malformed responses from Web services.
/// @param response Metadata of the response.
/// @param reason Underlying error.
/// @return Localized error.
+ (NSError *)sod_responseErrorWithResponse:(nullable NSHTTPURLResponse *)response
                                    reason:(nullable NSError *)reason;

/// @brief Factory method for host communication errors.
/// @param hostID Host identifier.
/// @param reason Underlying error.
/// @return Localized error.
+ (NSError *)sod_hostErrorWithHostID:(NSString *)hostID
                              reason:(nullable NSError *)reason;

@end

NS_ASSUME_NONNULL_END
