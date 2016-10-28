//
//  SODTrackableEvent.h
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 22.01.16.
//  Copyright © 2016 Pavel Osipov. All rights reserved.
//

#import "SODTrackable.h"
#import <POSRx/POSRx.h>

NS_ASSUME_NONNULL_BEGIN

/// Represents some nondestructive event.
@interface SODTrackableEvent : NSObject <SODTrackable>

@property (nonatomic, readonly, nullable) NSDictionary<NSString *, id<NSObject>> *userInfo;

- (instancetype)initWithArea:(NSString *)area
                        tags:(nullable NSArray<NSString *> *)tags
                      params:(nullable NSDictionary *)params
                     message:(nullable NSString *)message
                   rateLimit:(nullable NSNumber *)rateLimit
                    userInfo:(nullable NSDictionary *)userInfo;

+ (instancetype)eventNamed:(NSString *)name;
+ (instancetype)eventNamed:(NSString *)name params:(nullable NSDictionary *)params;
+ (instancetype)eventWithArea:(NSString *)area tags:(nullable NSArray<NSString *> *)tags;

POSRX_INIT_UNAVAILABLE

@end

#define sod_TRACKABLE_EVENT_INIT_UNAVAILABLE \
- (instancetype)initWithArea:(NSString *)area \
                        tags:(nullable NSArray<NSString *> *)tags \
                      params:(nullable NSDictionary *)params \
                     message:(nullable NSString *)message \
                   rateLimit:(nullable NSNumber *)rateLimit NS_UNAVAILABLE; \
+ (instancetype)eventNamed:(NSString *)name NS_UNAVAILABLE; \
+ (instancetype)eventNamed:(NSString *)name params:(nullable NSDictionary *)params NS_UNAVAILABLE; \
+ (instancetype)eventWithArea:(NSString *)area tags:(nullable NSArray<NSString *> *)tags NS_UNAVAILABLE;

NS_ASSUME_NONNULL_END
