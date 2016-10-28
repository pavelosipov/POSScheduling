//
//  UIViewController+SODInfrastructure.m
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 28.02.16.
//  Copyright © 2016 Pavel Osipov. All rights reserved.
//

#import "UIViewController+SODInfrastructure.h"

NS_ASSUME_NONNULL_BEGIN

@implementation UIViewController (SODInfrastructure)

- (RACSignal *)sod_presentViewController:(UIViewController *)viewControllerToPresent
                                animated:(BOOL)flag
                              completion:(void (^ __nullable)(void))completion {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self presentViewController:viewControllerToPresent animated:flag completion:^{
            if (completion) {
                completion();
            }
            [subscriber sendCompleted];
        }];
        return nil;
    }];
}

@end

NS_ASSUME_NONNULL_END
