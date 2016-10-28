//
//  SODAccount.m
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 02.06.16.
//  Copyright © 2016 Pavel Osipov. All rights reserved.
//

#import "SODAccount.h"
#import "SODCredentials.h"

NS_ASSUME_NONNULL_BEGIN

@implementation SODAccount

- (instancetype)initWithCloudType:(SODCloudType)cloudType
                               ID:(NSString *)ID
                      credentials:(nullable SODCredentials *)credentials {
    POSRX_CHECK_EX(SODIsValidCloudType(cloudType), @"Unknown cloud type %@", @(cloudType));
    POSRX_CHECK(ID.length > 0);
    if (self = [super init]) {
        _cloudType = cloudType;
        _ID = [ID copy];
        _credentials = credentials;
    }
    return self;
}

#pragma mark NSCoding

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self initWithCloudType:[aDecoder decodeIntegerForKey:@"cloudType"]
                                ID:[aDecoder decodeObjectForKey:@"ID"]
                       credentials:[aDecoder decodeObjectForKey:@"credentials"]];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInteger:_cloudType forKey:@"cloudType"];
    [aCoder encodeObject:_ID forKey:@"ID"];
    [aCoder encodeObject:_credentials forKey:@"credentials"];
}

@end

NS_ASSUME_NONNULL_END
