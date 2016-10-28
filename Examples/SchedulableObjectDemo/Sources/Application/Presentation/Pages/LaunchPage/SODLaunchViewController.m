//
//  SODLaunchViewController.m
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 26.10.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import "SODLaunchViewController.h"
#import "SODLaunchView.h"

NS_ASSUME_NONNULL_BEGIN

@implementation SODLaunchViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    SODLaunchView *launchView = [[SODLaunchView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:launchView];
}

#pragma mark UIViewController

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (BOOL)shouldAutorotate {
    return ![self isViewLoaded];
}

@end

NS_ASSUME_NONNULL_END
