//
//  NSError+SODTrackable.m
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 27.01.16.
//  Copyright (c) 2016 Pavel Osipov. All rights reserved.
//

#import "NSError+SODTrackable.h"
#import "NSString+SODInfrastructure.h"
#import <POSRx/NSException+POSRx.h>

NS_ASSUME_NONNULL_BEGIN

// Public constants
NSString * const kSODErrorDomain = @"com.github.pavelosipov.SchedulableObjectDemo.ErrorDomain";
NSString * const kSODCancelErrorCategory = @"Cancel";
NSString * const kSODInternalErrorCategory = @"Internal";
NSString * const kSODSystemErrorCategory = @"System";
NSString * const kSODUserErrorCategory = @"User";

// Public keys
NSString * const kSODTrackableDescriptionKey = @"VerboseDescription";
NSString * const kSODTrackableParamsKey = @"TrackableParams";
NSString * const kSODTrackableTagsKey = @"TrackableTags";
NSString * const kSODTrackableRateLimitKey = @"RateLimit";

// Private keys
static NSString * const kSODCategoryKey = @"Category";
static NSString * const kSODCancelRequestorKey = @"CancelRequestor";
static NSString * const kSODIncidentIdentifierKey = @"IncidentIdentifier";

@implementation NSError (SODTrackable)

+ (NSError *)sod_errorWithCategory:(NSString *)category {
    return [self sod_errorWithCategory:category userInfo:nil];
}

+ (NSError *)sod_errorWithCategory:(NSString *)category userInfo:(nullable NSDictionary *)userInfo {
    NSMutableDictionary *info = userInfo ? [userInfo mutableCopy] : [NSMutableDictionary new];
    info[kSODCategoryKey] = category;
    if (!info[NSLocalizedDescriptionKey]) {
        info[NSLocalizedDescriptionKey] = [category sod_localizedWith:@"NSError"];
    }
    return [[NSError alloc] initWithDomain:kSODErrorDomain code:(category.hash % 1000) userInfo:info];
}

+ (NSError *)sod_incidentWithCategory:(NSString *)category userInfo:(nullable NSDictionary *)userInfo {
    NSMutableDictionary *info = userInfo ? [userInfo mutableCopy] : [NSMutableDictionary new];
    info[kSODIncidentIdentifierKey] = SODGenerateTrackableIdentifier();
    return [self sod_errorWithCategory:category userInfo:info];
}

+ (NSError *)sod_systemIncidentWithReason:(nullable NSError *)reason rateLimit:(nullable NSNumber *)rateLimit {
    NSMutableDictionary *info = [NSMutableDictionary new];
    if (reason) {
        info[NSUnderlyingErrorKey] = reason;
    }
    if (rateLimit) {
        info[kSODTrackableRateLimitKey] = rateLimit;
    }
    return [self sod_incidentWithCategory:kSODSystemErrorCategory userInfo:info];
}

#pragma mark Public

- (NSString *)sod_category {
    return self.userInfo[kSODCategoryKey] ?: self.domain;
}

- (nullable NSString *)sod_incidentIdentifier {
    return self.userInfo[kSODIncidentIdentifierKey];
}

- (nullable NSNumber *)sod_cancelRequestor {
    return self.userInfo[kSODCancelRequestorKey];
}

+ (NSError *)sod_cancelErrorWithRequestor:(NSInteger)requestor {
    return [self sod_cancelErrorWithRequestor:requestor reason:nil];
}

+ (NSError *)sod_cancelErrorWithRequestor:(NSInteger)requestor format:(nullable NSString *)format, ... {
    NSMutableDictionary *userInfo = [NSMutableDictionary new];
    userInfo[kSODCancelRequestorKey] = @(requestor);
    if (format) {
        va_list args;
        va_start(args, format);
        userInfo[kSODTrackableDescriptionKey] = [[NSString alloc] initWithFormat:format arguments:args];
        va_end(args);
    }
    return [self sod_errorWithCategory:kSODCancelErrorCategory userInfo:userInfo];
}

+ (NSError *)sod_cancelErrorWithRequestor:(NSInteger)requestor reason:(nullable NSError *)reason {
    NSMutableDictionary *userInfo = [NSMutableDictionary new];
    userInfo[kSODCancelRequestorKey] = @(requestor);
    userInfo[NSUnderlyingErrorKey] = reason;
    return [self sod_errorWithCategory:kSODCancelErrorCategory userInfo:userInfo];
}

+ (NSError *)sod_internalErrorWithFormat:(nullable NSString *)format, ... {
    NSMutableDictionary *userInfo = [NSMutableDictionary new];
    if (format) {
        va_list args;
        va_start(args, format);
        userInfo[kSODTrackableDescriptionKey] = [[NSString alloc] initWithFormat:format arguments:args];
        va_end(args);
    }
    return [self sod_errorWithCategory:kSODInternalErrorCategory userInfo:userInfo];
}

+ (NSError *)sod_systemErrorWithReason:(nullable NSError *)reason {
    NSDictionary *userInfo;
    if (reason) {
        userInfo = @{NSUnderlyingErrorKey : reason};
    }
    return [self sod_errorWithCategory:kSODSystemErrorCategory userInfo:userInfo];
}

+ (NSError *)sod_systemErrorWithFormat:(nullable NSString *)format, ... {
    NSMutableDictionary *userInfo = [NSMutableDictionary new];
    if (format) {
        va_list args;
        va_start(args, format);
        userInfo[kSODTrackableDescriptionKey] = [[NSString alloc] initWithFormat:format arguments:args];
        va_end(args);
    }
    return [self sod_errorWithCategory:kSODSystemErrorCategory userInfo:userInfo];
}

+ (NSError *)sod_userErrorWithTags:(nullable NSArray<NSString *> *)tags message:(NSString *)message {
    POSRX_CHECK(message);
    NSMutableDictionary *userInfo = [NSMutableDictionary new];
    userInfo[kSODTrackableTagsKey] = tags;
    userInfo[kSODTrackableDescriptionKey] = message;
    userInfo[NSLocalizedDescriptionKey] = message;
    return [self sod_errorWithCategory:kSODUserErrorCategory userInfo:userInfo];
}

+ (NSError *)sod_userErrorWithTags:(nullable NSArray<NSString *> *)tags messageFormat:(NSString *)format, ... {
    POSRX_CHECK(format);
    NSMutableDictionary *userInfo = [NSMutableDictionary new];
    userInfo[kSODTrackableTagsKey] = tags;
    va_list args;
    va_start(args, format);
    NSString *localizedDescription = [[NSString alloc] initWithFormat:format arguments:args];
    userInfo[kSODTrackableDescriptionKey] = localizedDescription;
    userInfo[NSLocalizedDescriptionKey] = localizedDescription;
    va_end(args);
    return [self sod_errorWithCategory:kSODUserErrorCategory userInfo:userInfo];
}

#pragma mark SODTrackable

- (SODTrackableType)type {
    return SODTrackableTypeError | (self.trackingIdentifier ? SODTrackableTypeIncident : 0);
}

- (NSString *)name {
    return self.sod_category;
}

- (nullable NSArray<NSString *> *)tags {
    if ([self.domain isEqualToString:kSODErrorDomain]) {
        return self.userInfo[kSODTrackableTagsKey];
    }
    return @[@(self.code).stringValue];
}

- (nullable NSString *)message {
    NSString *message = self.userInfo[kSODTrackableDescriptionKey];
    if (!message) {
        message = [self.userInfo[NSUnderlyingErrorKey] message];
    }
    if (!message) {
        message = self.localizedDescription;
    }
    return message;
}

- (nullable NSString *)trackingIdentifier {
    return self.sod_incidentIdentifier;
}

- (nullable NSDictionary<NSString *,id<NSObject>> *)params {
    return self.userInfo[kSODTrackableParamsKey];
}

- (nullable NSNumber *)rateLimit {
    return self.userInfo[kSODTrackableRateLimitKey] ?: [self.underlyingTrackable rateLimit];
}

- (nullable id<SODTrackable>)underlyingTrackable {
    return self.userInfo[NSUnderlyingErrorKey];
}

@end

NS_ASSUME_NONNULL_END
