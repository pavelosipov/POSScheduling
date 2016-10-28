//
//  SODSettingsViewController.m
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 15.06.16.
//  Copyright © 2016 Pavel Osipov. All rights reserved.
//

#import "SODSettingsViewController.h"
#import "SODAccountAssembly.h"
#import "SODAccountInfo.h"
#import "SODAccountInfoProvider.h"

@interface SODSettingsViewController ()
@property (nonatomic, readonly) id<SODAccountAssembly> assembly;
@property (nonatomic, weak) UILabel *nameLabel;
@end

@implementation SODSettingsViewController

- (instancetype)initWithAssembly:(id<SODAccountAssembly>)assembly {
    POSRX_CHECK(assembly);
    if (self = [super init]) {
        _assembly = assembly;
    }
    return self;
}

#pragma mark UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Settings";
    self.view.backgroundColor = [UIColor whiteColor];
    self.nameLabel = [self p_addRootView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[[[[_assembly.accountInfoProvider schedule]
      flattenMap:^RACStream *(id<SODAccountInfoProvider> provider) {
          return [provider fetchAccountInfo];
      }]
      deliverOnMainThread]
      takeUntil:self.rac_willDeallocSignal]
      subscribeNext:^(SODAccountInfo *accountInfo) {
          self.nameLabel.text = accountInfo.displayName;
      } error:^(NSError *error) {
          self.nameLabel.text = error.localizedDescription;
      }];
}

#pragma mark Private

- (UILabel *)p_addRootView {
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:self.view.bounds];
    nameLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.text = @"Loading...";
    [self.view addSubview:nameLabel];
    return nameLabel;
}

@end
