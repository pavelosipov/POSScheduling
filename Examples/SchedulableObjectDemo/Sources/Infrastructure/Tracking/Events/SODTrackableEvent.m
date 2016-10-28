//
//  SODTrackableEvent.m
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 22.01.16.
//  Copyright © 2016 Pavel Osipov. All rights reserved.
//

#import "SODTrackableEvent.h"

NS_ASSUME_NONNULL_BEGIN

@interface SODTrackableEvent ()
@property (nonatomic) NSString *name;
@property (nonatomic, nullable) NSString *message;
@property (nonatomic, nullable) NSArray<NSString *> *tags;
@property (nonatomic, nullable) NSDictionary<NSString *, id<NSObject>> *params;
@property (nonatomic, nullable) NSNumber *rateLimit;
@end

@implementation SODTrackableEvent

#pragma mark Lifecycle

- (instancetype)initWithArea:(NSString *)area
                        tags:(nullable NSArray<NSString *> *)tags
                      params:(nullable NSDictionary *)params
                     message:(nullable NSString *)message
                   rateLimit:(nullable NSNumber *)rateLimit
                    userInfo:(nullable NSDictionary *)userInfo {
    POSRX_CHECK(area);
    if (self = [super init]) {
        _name = area;
        _message = message;
        _tags = tags;
        _params = params;
        _rateLimit = rateLimit;
        _userInfo = userInfo;
    }
    return self;
}

+ (instancetype)eventNamed:(NSString *)name {
    return [[SODTrackableEvent alloc] initWithArea:name tags:nil params:nil message:nil rateLimit:nil userInfo:nil];
}

+ (instancetype)eventNamed:(NSString *)name params:(nullable NSDictionary *)params {
    return [[SODTrackableEvent alloc] initWithArea:name tags:nil params:params message:nil rateLimit:nil userInfo:nil];
}

+ (instancetype)eventWithArea:(NSString *)area tags:(nullable NSArray<NSString *> *)tags {
    return [[SODTrackableEvent alloc] initWithArea:area tags:tags params:nil message:nil rateLimit:nil userInfo:nil];
}

#pragma mark SODTrackable

- (SODTrackableType)type {
    return SODTrackableTypeEvent | (self.trackingIdentifier ? SODTrackableTypeIncident : 0);
}

- (nullable NSString *)trackingIdentifier {
    return nil;
}

- (nullable id<SODTrackable>)underlyingTrackable {
    return nil;
}

#pragma mark NSObject

- (NSString *)description {
    NSMutableDictionary *state = [NSMutableDictionary new];
    state[@"tags"] = _tags;
    state[@"params"] = _params;
    state[@"message"] = _message;
    state[@"userInfo"] = _userInfo;
    return [NSString stringWithFormat:@"%@:%@", [super description], state];
}

@end

NS_ASSUME_NONNULL_END
