//
//  SODAppController.h
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 02.04.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import <POSRx/POSRx.h>

NS_ASSUME_NONNULL_BEGIN

@class SODAppDelegate;

/// Orchestrates presentation logic.
@interface SODAppController : POSSchedulableObject

/// @brief Activates presentation logic.
/// @param appDelegate Mandatory application entry point.
- (void)launchWithAppDelegate:(SODAppDelegate *)appDelegate;

@end

NS_ASSUME_NONNULL_END
