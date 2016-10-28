//
//  SODAppController.m
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 02.04.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import "SODAppController.h"

// UI
#import "SODAppDelegate.h"
#import "SODWelcomeViewController.h"
//#import "SODBaseNavigationController.h"
#import "SODSettingsViewController.h"
#import "SODLaunchViewController.h"
#import "SODLaunchErrorViewController.h"

// Services
#import "SODAppAssembly.h"
#import "SODAccountRepository.h"
#import "SODAppMonitor.h"
#import "SODDropboxAuthenticator.h"
#import "SODDropboxAccountAssembly.h"
#import "SODTracker.h"
#import "SODTrackableEvent.h"

NS_ASSUME_NONNULL_BEGIN

@class SODAccount;

@interface SODAppController ()
@property (nonatomic) SODAppAssembly *assembly;
@property (nonatomic, weak) SODAppDelegate *appDelegate;
@property (nonatomic) UIViewController *rootViewController;
@end

@implementation SODAppController
@dynamic rootViewController;

- (void)launchWithAppDelegate:(SODAppDelegate *)appDelegate {
    POSRX_CHECK(appDelegate);
    self.appDelegate = appDelegate;
    self.rootViewController = [SODLaunchViewController new];
    self.assembly = [SODAppAssembly assemblyWithAppMonitor:appDelegate];
    [self p_trackLaunch];
    [self p_setupBindings];
}

- (UIViewController *)rootViewController {
    return _appDelegate.window.rootViewController;
}

- (void)setRootViewController:(UIViewController *)rootViewController {
    if (!_appDelegate.window) {
        _appDelegate.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        _appDelegate.window.rootViewController = rootViewController;
        _appDelegate.window.backgroundColor = [UIColor whiteColor];
        [_appDelegate.window makeKeyAndVisible];
    } else {
        _appDelegate.window.rootViewController = rootViewController;
    }
}

- (void)p_setupBindings {
    self.rootViewController = [[SODLaunchViewController alloc] init];
    [[_assembly.accountRepository.accountsSignal deliverOnMainThread] subscribeNext:^(NSArray<SODAccount *> *accounts) {
        if (!accounts.count) {
            self.rootViewController = [[SODWelcomeViewController alloc] initWithAssembly:self.assembly];;
        } else {
            self.rootViewController = [[SODSettingsViewController alloc]
                                       initWithAssembly:[[SODDropboxAccountAssembly alloc]
                                                         initWithAppAssembly:self.assembly
                                                         account:accounts.firstObject]];
        }
    }];
}

- (void)p_trackLaunch {
    [_assembly.tracker scheduleBlock:^(id<SODTracker> tracker) {
        [tracker track:[SODTrackableEvent eventNamed:@"launch"]];
    }];
}

@end

NS_ASSUME_NONNULL_END
