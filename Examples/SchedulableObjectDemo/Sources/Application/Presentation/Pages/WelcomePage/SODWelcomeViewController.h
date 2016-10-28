//
//  SODWelcomeViewController.h
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 08.03.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <POSRx/POSRx.h>

NS_ASSUME_NONNULL_BEGIN

@class SODAppAssembly;

@interface SODWelcomeViewController : UIViewController

- (instancetype)initWithAssembly:(SODAppAssembly *)assembly;

- (void)linkDropboxAccount;

POSRX_INIT_UNAVAILABLE

@end

NS_ASSUME_NONNULL_END
