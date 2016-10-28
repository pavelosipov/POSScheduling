//
//  NSError+SODTrackable.h
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 27.01.16.
//  Copyright (c) 2016 Pavel Osipov. All rights reserved.
//

#import "SODTrackable.h"

NS_ASSUME_NONNULL_BEGIN

/// Domain for all trackable errors.
FOUNDATION_EXTERN NSString * const kSODErrorDomain;

/// Category for cancellation pseudo errors.
FOUNDATION_EXTERN NSString * const kSODCancelErrorCategory;

/// Category of internal errors.
FOUNDATION_EXTERN NSString * const kSODInternalErrorCategory;

/// Category of system errors.
FOUNDATION_EXTERN NSString * const kSODSystemErrorCategory;

/// Category of user input errors.
FOUNDATION_EXTERN NSString * const kSODUserErrorCategory;

/// Key for human readable description of the problem in userInfo dictionary.
FOUNDATION_EXPORT NSString * const kSODTrackableDescriptionKey;

/// Key for NSDictionary<NSString *, id<NSObject>> with error parameters in userInfo dictionary.
FOUNDATION_EXPORT NSString * const kSODTrackableParamsKey;

/// Key for NSArray<NSString *> with trackable tags in userInfo dictionary.
FOUNDATION_EXPORT NSString * const kSODTrackableTagsKey;

/// Key for NSNumber with rate limit value in userInfo dictionary.
FOUNDATION_EXPORT NSString * const kSODTrackableRateLimitKey;

/// Possible initiators of cancel errors.
typedef NS_ENUM(NSInteger, SODCancelRequestorType) {
    SODCancelRequestorTypeApp = 0,
    SODCancelRequestorTypeUser
};

/// Represents interface with common properties in SDK.
@interface NSError (SODTrackable) <SODTrackable>

/// Unique string for each kind of the error, for example "System".
@property (nonatomic, readonly) NSString *sod_category;

/// Uniquely identifies current instance of the error.
@property (nonatomic, readonly, nullable) NSString *sod_incidentIdentifier;

/// Uniquely identifies requestor of the interruption.
@property (nonatomic, readonly, nullable) NSNumber *sod_cancelRequestor;

/// Factory method for cancel errors.
+ (NSError *)sod_cancelErrorWithRequestor:(NSInteger)requestor;

/// Factory method for cancel errors.
+ (NSError *)sod_cancelErrorWithRequestor:(NSInteger)requestor format:(nullable NSString *)format, ...;

/// Factory Factory method for cancel errors.
+ (NSError *)sod_cancelErrorWithRequestor:(NSInteger)requestor reason:(nullable NSError *)reason;

/// Factory method for internal errors.
+ (NSError *)sod_internalErrorWithFormat:(nullable NSString *)format, ...;

/// Factory method for system errors.
+ (NSError *)sod_systemErrorWithReason:(nullable NSError *)reason;

/// Factory method for system errors.
+ (NSError *)sod_systemErrorWithFormat:(nullable NSString *)format, ...;

/// Factory method for user errors.
+ (NSError *)sod_userErrorWithTags:(nullable NSArray<NSString *> *)tags message:(NSString *)message;

/// Factory method for user errors.
+ (NSError *)sod_userErrorWithTags:(nullable NSArray<NSString *> *)tags messageFormat:(NSString *)format, ...;

/// Creates trackable error without incident identifier.
+ (NSError *)sod_errorWithCategory:(NSString *)category;

/// Creates trackable error without incident identifier.
+ (NSError *)sod_errorWithCategory:(NSString *)category userInfo:(nullable NSDictionary *)userInfo;

/// Creates trackable error with incident identifier.
+ (NSError *)sod_incidentWithCategory:(NSString *)category userInfo:(nullable NSDictionary *)userInfo;

/// Creates trackable kSODSystemErrorCategory error with incident identifier.
+ (NSError *)sod_systemIncidentWithReason:(nullable NSError *)reason rateLimit:(nullable NSNumber *)rateLimit;

@end

NS_INLINE void SODAssignError(NSError **targetError, NSError *sourceError) {
    if (targetError) {
        *targetError = sourceError;
    }
}

NS_ASSUME_NONNULL_END
