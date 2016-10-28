//
//  SODCredentials.m
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 02.06.16.
//  Copyright © 2016 Pavel Osipov. All rights reserved.
//

#import "SODCredentials.h"

NS_ASSUME_NONNULL_BEGIN

@implementation SODCredentials

- (instancetype)initWithAccessToken:(NSString *)accessToken {
    POSRX_CHECK(accessToken);
    if (self = [super init]) {
        _accessToken = [accessToken copy];
    }
    return self;
}

#pragma mark NSCoding

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self initWithAccessToken:[aDecoder decodeObjectForKey:@"accessToken"]];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_accessToken forKey:@"accessToken"];
}

#pragma mark NSObject

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    if ([self class] != [object class]) {
        return NO;
    }
    SODCredentials *other = object;
    if (![_accessToken isEqualToString:other.accessToken]) {
        return NO;
    }
    return YES;
}

- (NSUInteger)hash {
    NSUInteger result = 0;
    result ^= _accessToken.hash;
    return result;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@{access_token=%@}",
            super.description,
            _accessToken];
}

@end

NS_ASSUME_NONNULL_END
