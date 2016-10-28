//
//  UIViewController+SODInfrastructure.h
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 28.02.16.
//  Copyright © 2016 Pavel Osipov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (SODInfrastructure)

/// @return Signal without values, which completes when UIViewController will be closed.
- (RACSignal *)sod_presentViewController:(UIViewController *)viewControllerToPresent
                                animated:(BOOL)flag
                              completion:(void (^ __nullable)(void))completion;

@end

NS_ASSUME_NONNULL_END
