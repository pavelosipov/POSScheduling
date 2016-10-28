//
//  NSString+SODInfrastructure.m
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 16.03.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import "NSString+SODInfrastructure.h"

NS_ASSUME_NONNULL_BEGIN

@implementation NSString (SODInfrastructure)

- (NSString *)sod_localized {
    return [self sod_localizedWith:@"Localizable"];
}

- (NSString *)sod_localizedWith:(NSString *)table {
     return [[NSBundle mainBundle] localizedStringForKey:self value:self table:table];
}

@end

NS_ASSUME_NONNULL_END
