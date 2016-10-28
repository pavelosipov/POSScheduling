//
//  UIDevice+SODInfrastructure.h
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 30.03.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIDevice (SODInfrastructure)

/// @return Human readable name of the platform, for ex. "iPhone 5s (GSM)"
+ (NSString *)sod_platformName;

@end

NS_ASSUME_NONNULL_END
