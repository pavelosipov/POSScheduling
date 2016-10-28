//
//  SODWelcomeViewController.m
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 08.03.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import "SODWelcomeViewController.h"
#import "SODWelcomeComponent.h"
#import "SODAppAssembly.h"
#import "SODAccountRepository.h"
#import "SODDropboxAuthenticator.h"
#import "SODDropboxLoginViewController.h"
#import "SODTracker.h"
#import "NSError+SODTrackable.h"
#import "UIViewController+SODInfrastructure.h"

NS_ASSUME_NONNULL_BEGIN

@interface SODWelcomeViewController () <CKComponentProvider>
@property (nonatomic, readonly, weak) SODAppAssembly *assembly;
@property (nonatomic, readonly) CKComponentHostingView *rootView;
@end

@implementation SODWelcomeViewController

- (instancetype)initWithAssembly:(SODAppAssembly *)assembly {
    POSRX_CHECK(assembly);
    if (self = [super init]) {
        _assembly = assembly;
    }
    return self;
}

#pragma mark - CKComponentProvider

+ (CKComponent *)componentForModel:(nullable id<NSObject>)model
                           context:(nullable id<NSObject>)context {
    return [SODWelcomeComponent
            newWithModel:{ .signupEnabled = YES }
            context:(id)context];
}

#pragma mark - UIViewController

- (void)loadView {
    CKComponentHostingView *rootView =
    [[CKComponentHostingView alloc]
     initWithComponentProvider:self.class
     sizeRangeProvider:[CKComponentFlexibleSizeRangeProvider
                        providerWithFlexibility:CKComponentSizeRangeFlexibleWidthAndHeight]];
    [rootView updateContext:self mode:CKUpdateModeSynchronous];
    self.view = rootView;
}

- (void)linkDropboxAccount {
    id<SODDropboxAuthenticator> autheticator = self.assembly.dropboxAuthenticator;
    id<SODAccountRepository> accountRepository = self.assembly.accountRepository;
    id<SODTracker> tracker = self.assembly.tracker;
    UIViewController *authController = [[SODDropboxLoginViewController alloc]
                                        initWithAuthURL:self.assembly.dropboxAuthenticator.oauthURL];
    [[[[self sod_presentViewController:authController animated:YES completion:nil]
     then:^RACSignal *{
         return [autheticator listenForSignIn];
     }]
     deliverOn:self.assembly.backgroundScheduler]
     subscribeNext:^(SODAccount *account) {
         [accountRepository addAccount:account];
     } error:^(NSError *error) {
         [tracker track:error];
     }];
}

@end

NS_ASSUME_NONNULL_END
