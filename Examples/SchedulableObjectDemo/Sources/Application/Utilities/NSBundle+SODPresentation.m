//
//  NSBundle+SODPresentation.m
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 29.10.15.
//  Copyright © 2015 Pavel Osipov. All rights reserved.
//

#import "NSBundle+SODPresentation.h"
#import <POSRx/POSRx.h>

NS_ASSUME_NONNULL_BEGIN

@implementation NSBundle (SODPresentation)

- (NSString *)sod_dropboxAppKey {
    return [self sod_objectForKey:@"SODDropboxAppKey"];
}

- (NSString *)sod_dropboxAppSecret {
    return [self sod_objectForKey:@"SODDropboxAppSecret"];
}

#pragma mark Private

- (NSString *)sod_objectForKey:(NSString *)key {
    id value = [self objectForInfoDictionaryKey:key];
    POSRX_CHECK_EX([value isKindOfClass:[NSString class]], @"Unexpected value for key '%@': %@", key, value);
    return value;
}

@end

NS_ASSUME_NONNULL_END
