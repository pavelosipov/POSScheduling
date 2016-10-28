//
//  NSString+SODInfrastructure.h
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 16.03.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (SODInfrastructure)

/// @return Localized string from Localizable.strings table.
- (NSString *)sod_localized;

/// @return Localized string from specified table.
- (NSString *)sod_localizedWith:(NSString *)table;

@end

NS_ASSUME_NONNULL_END
