//
//  SODBaseNavigationController.m
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 04.04.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import "SODBaseNavigationController.h"
#import <POSRx/POSRx.h>

@implementation SODBaseNavigationController

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController
                                  assembly:(SODAppAssembly *)assembly {
    POSRX_CHECK(assembly);
    if (self = [super initWithRootViewController:rootViewController]) {
        _assembly = assembly;
    }
    return self;
}

@end
