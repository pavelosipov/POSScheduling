//
//  NSError+SODAuth.m
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 05.06.16.
//  Copyright © 2016 Pavel Osipov. All rights reserved.
//

#import "NSError+SODAuth.h"
#import <POSRx/POSRx.h>

NS_ASSUME_NONNULL_BEGIN

NSString * const kSODAuthCategory = @"Auth";
static NSString * const kSODCredentialsKey = @"Credentials";

@implementation NSError (SODAuth)

- (nullable SODCredentials *)sod_credentials {
    return self.userInfo[kSODCredentialsKey];
}

+ (NSError *)sod_authErrorWithCode:(NSString *)errorCode
                       description:(nullable NSString *)description {
    POSRX_CHECK(errorCode);
    NSMutableDictionary *userInfo = [NSMutableDictionary new];
    userInfo[kSODTrackableTagsKey] = @[errorCode];
    userInfo[kSODTrackableDescriptionKey] = description;
    return [self sod_incidentWithCategory:kSODAuthCategory userInfo:userInfo];
}

+ (NSError *)sod_authErrorWithCredentials:(nullable SODCredentials *)credentials
                                     tags:(nullable NSArray<NSString *> *)tags {
    NSMutableDictionary *userInfo = [NSMutableDictionary new];
    userInfo[kSODCredentialsKey] = credentials;
    userInfo[kSODTrackableTagsKey] = tags;
    return [self sod_errorWithCategory:kSODAuthCategory userInfo:userInfo];    
}

@end

NS_ASSUME_NONNULL_END
