//
//  SODUserDefaultsKeyedStoreBackend.h
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 23.09.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import "SODKeyedStoreBackend.h"

NS_ASSUME_NONNULL_BEGIN

@interface SODUserDefaultsKeyedStoreBackend : NSObject <SODKeyedStoreBackend>

/// @brief The only designated initializer.
/// @param userDefaults Mandatory UserDefaults instance.
/// @param dataKey Mandatory key specified place for data persisting.
- (instancetype)initWithUserDefaults:(NSUserDefaults *)userDefaults
                             dataKey:(NSString *)dataKey;

POSRX_INIT_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
