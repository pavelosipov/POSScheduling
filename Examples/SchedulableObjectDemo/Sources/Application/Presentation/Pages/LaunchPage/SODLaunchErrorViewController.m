//
//  SODLaunchErrorViewController.m
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 26.10.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import "SODLaunchErrorViewController.h"
#import "NSString+SODInfrastructure.h"
#import <POSRx/POSRx.h>

NS_ASSUME_NONNULL_BEGIN

@interface SODLaunchErrorViewController ()
@property (nonatomic) NSError *error;
@end

@implementation SODLaunchErrorViewController

- (instancetype)initWithError:(NSError *)error {
    POSRX_CHECK(error);
    if (self = [super init]) {
        _error = error;
    }
    return self;
}

#pragma mark UIViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.view.backgroundColor = [UIColor blackColor];
    [self p_setupMessageView];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - Private

- (void)p_setupMessageView {
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:self.view.bounds];
    messageLabel.backgroundColor = [UIColor blackColor];
    messageLabel.textColor = [UIColor whiteColor];
    messageLabel.text = [@"LaunchFailureMessage" sod_localized];
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.center = CGPointMake(self.view.bounds.size.width / 2.0,
                                      self.view.bounds.size.height / 2.0);
    [self.view addSubview:messageLabel];
}

@end

NS_ASSUME_NONNULL_END
