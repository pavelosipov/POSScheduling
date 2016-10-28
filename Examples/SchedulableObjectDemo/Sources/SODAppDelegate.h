//
//  SODAppDelegate.h
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 08.03.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SODAppMonitor.h"

NS_ASSUME_NONNULL_BEGIN

@interface SODAppDelegate : UIResponder <UIApplicationDelegate, SODAppMonitor>

@property (nonatomic, nullable) UIWindow *window;

@end

NS_ASSUME_NONNULL_END
