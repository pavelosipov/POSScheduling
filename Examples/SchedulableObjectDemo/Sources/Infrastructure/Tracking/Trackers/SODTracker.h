//
//  SODTracker.h
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 22.01.16.
//  Copyright © 2016 Pavel Osipov. All rights reserved.
//

#import "SODTrackable.h"
#import <POSRx/POSRx.h>

NS_ASSUME_NONNULL_BEGIN

/// Service for handling significant events in the app.
@protocol SODTracker <POSSchedulable>

/// @brief Handles event.
/// @param event Tracking event.
- (RACSignal *)track:(id<SODTrackable>)event;

/// @brief Handles event.
/// @param event Tracking event.
/// @param params Additional parameters.
- (RACSignal *)track:(id<SODTrackable>)event params:(nullable NSDictionary *)params;

@end

NS_ASSUME_NONNULL_END
