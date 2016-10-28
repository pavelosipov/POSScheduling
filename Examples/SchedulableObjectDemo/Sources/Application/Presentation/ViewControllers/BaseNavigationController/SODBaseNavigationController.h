//
//  SODBaseNavigationController.h
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 04.04.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SODAppAssembly;

@interface SODBaseNavigationController : UINavigationController

@property (nonatomic, readonly) SODAppAssembly *assembly;

/// The designated initializer.
- (instancetype)initWithRootViewController:(UIViewController *)rootViewController
                                  assembly:(SODAppAssembly *)assembly;

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController NS_UNAVAILABLE;

@end
