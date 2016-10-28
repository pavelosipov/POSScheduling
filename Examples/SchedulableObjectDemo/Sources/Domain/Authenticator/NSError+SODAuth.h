//
//  NSError+SODAuth.h
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 05.06.16.
//  Copyright © 2016 Pavel Osipov. All rights reserved.
//

#import "NSError+SODHost.h"

NS_ASSUME_NONNULL_BEGIN

@class SODCredentials;

/// Category of authentication errors.
FOUNDATION_EXTERN NSString * const kSODAuthCategory;

@interface NSError (SODAuth)

/// Outdated credentials.
@property (nonatomic, readonly, nullable) SODCredentials *sod_credentials;

+ (NSError *)sod_authErrorWithCode:(NSString *)errorCode
                       description:(nullable NSString *)description;

+ (NSError *)sod_authErrorWithCredentials:(nullable SODCredentials *)credentials
                                     tags:(nullable NSArray<NSString *> *)tags;

@end

NS_ASSUME_NONNULL_END
