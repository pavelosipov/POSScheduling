//
//  NSError+SODHost.m
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 16.03.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import "NSError+SODHost.h"
#import "NSString+SODInfrastructure.h"
#import <POSRx/NSException+POSRx.h>

NS_ASSUME_NONNULL_BEGIN

/// Categories of host communication errors.
NSString * const kSODHostErrorCategory = @"Host";
NSString * const kSODResponseErrorCategory = @"Response";

/// Category for networking errors.
NSString * const kSODNetworkErrorCategory = @"Network";

/// Custom properties.
static NSString * const kSODResponseErrorKey = @"Response";

@implementation NSError (SODHost)

#pragma mark Properties

- (nullable NSURL *)sod_URL {
    NSError *error = self;
    while (error) {
        NSURL *hostURL = error.userInfo[NSURLErrorKey];
        if (hostURL) {
            return hostURL;
        }
        error = error.userInfo[NSUnderlyingErrorKey];
    }
    return nil;
}

- (nullable NSHTTPURLResponse *)sod_response {
    return self.userInfo[kSODResponseErrorKey];
}

#pragma mark Factory Methods

+ (NSError *)sod_networkErrorWithReason:(nullable NSError *)reason {
    if (reason.code == NSURLErrorCancelled) {
        return [self sod_cancelErrorWithRequestor:SODCancelRequestorTypeApp];
    }
    NSMutableDictionary *userInfo = [NSMutableDictionary new];
    userInfo[NSUnderlyingErrorKey] = reason;
    if ([reason p_isSSLError]) {
        userInfo[kSODTrackableRateLimitKey] = @(60);
    }
    userInfo[kSODTrackableTagsKey] = [self p_tagsForNetworkError:reason];
    return [self sod_errorWithCategory:kSODNetworkErrorCategory userInfo:userInfo];
}

+ (NSError *)sod_responseErrorWithResponse:(nullable NSHTTPURLResponse *)response
                                      tags:(nullable NSArray<NSString *> *)tags
                                    format:(nullable NSString *)format, ... {
    NSMutableDictionary *userInfo = [NSMutableDictionary new];
    userInfo[kSODResponseErrorKey] = response;
    userInfo[kSODTrackableTagsKey] = tags;
    if (format) {
        va_list args;
        va_start(args, format);
        userInfo[kSODTrackableDescriptionKey] = [[NSString alloc] initWithFormat:format arguments:args];
        va_end(args);
    }
    return [self sod_errorWithCategory:kSODResponseErrorCategory userInfo:userInfo];
}

+ (NSError *)sod_responseErrorWithResponse:(nullable NSHTTPURLResponse *)response
                                    reason:(nullable NSError *)reason {
    NSMutableDictionary *userInfo = [NSMutableDictionary new];
    userInfo[kSODResponseErrorKey] = response;
    userInfo[NSUnderlyingErrorKey] = reason;
    return [self sod_errorWithCategory:kSODResponseErrorCategory userInfo:userInfo];    
}

+ (NSError *)sod_hostErrorWithHostID:(NSString *)hostID
                              reason:(nullable NSError *)reason {
    POSRX_CHECK(hostID);
    NSMutableDictionary *userInfo = [NSMutableDictionary new];
    userInfo[NSUnderlyingErrorKey] = reason;
    userInfo[kSODTrackableTagsKey] = @[hostID];
    NSString *host = reason.sod_response.URL.host;
    if (host) {
        userInfo[kSODTrackableParamsKey] = @{@"host": host};
    }
    return [self sod_errorWithCategory:kSODHostErrorCategory userInfo:userInfo];
}

#pragma mark Private

+ (NSArray *)p_tagsForNetworkError:(NSError *)error {
    NSMutableArray *tags = [NSMutableArray new];
    if ([error isKindOfClass:[NSError class]]) {
        if ([error p_isSSLError]) {
            [tags addObject:@"ssl"];
            [tags addObject:@(error.code).stringValue];
        } else {
            switch (error.code) {
                case NSURLErrorTimedOut:
                    [tags addObject:@"timeout"];
                    break;
                case NSURLErrorNotConnectedToInternet:
                    [tags addObject:@"offline"];
                    break;
                default:
                    [tags addObject:@"uncategorized"];
                    [tags addObject:@(error.code).stringValue];
                    break;
            }
        }
    }
    return tags;
}

- (BOOL)p_isSSLError {
    switch (self.code) {
        case NSURLErrorSecureConnectionFailed:
        case NSURLErrorServerCertificateHasBadDate:
        case NSURLErrorServerCertificateUntrusted:
        case NSURLErrorServerCertificateHasUnknownRoot:
        case NSURLErrorServerCertificateNotYetValid:
        case NSURLErrorClientCertificateRejected:
        case NSURLErrorClientCertificateRequired:
        case NSURLErrorCannotLoadFromNetwork:
            return YES;
        default:
            return NO;
    }
}

@end

NS_ASSUME_NONNULL_END
