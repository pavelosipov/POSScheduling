//
//  SODDropboxAccountAssembly.m
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 02.06.16.
//  Copyright © 2016 Pavel Osipov. All rights reserved.
//

#import "SODDropboxAccountAssembly.h"
#import "SODAccount.h"
#import "SODDropboxAccountInfoProvider.h"
#import "SODCredentials.h"
#import "SODAppAssembly.h"
#import "SODDropboxHost.h"

NS_ASSUME_NONNULL_BEGIN

@interface SODDropboxAccountAssembly ()
@property (nonatomic) SODAppAssembly *app;
@property (nonatomic) SODAccount *account;
@property (nonatomic) id<SODAccountInfoProvider> accountInfoProvider;
@property (nonatomic) id<SODHost> dropboxHost;
@property (nonatomic) id<POSHTTPGateway> gateway;
@end

@implementation SODDropboxAccountAssembly

- (instancetype)initWithAppAssembly:(SODAppAssembly *)assembly
                            account:(SODAccount *)account {
    POSRX_CHECK(assembly);
    POSRX_CHECK(account);
    if (self = [super initWithScheduler:assembly.scheduler]) {
        _app = assembly;
        _account = account;
    }
    return self;
}

#pragma mark SODAccountAssembly

- (id<SODAccountInfoProvider>)accountInfoProvider {
    if (_accountInfoProvider) {
        return _accountInfoProvider;
    }
    self.accountInfoProvider = [[SODDropboxAccountInfoProvider alloc]
                                initWithHost:self.dropboxHost
                                accountID:self.account.ID];
    return _accountInfoProvider;
}

- (id<POSHTTPGateway>)gateway {
    if (_gateway) {
        return _gateway;
    }
    self.gateway = [[POSHTTPGateway alloc]
                    initWithScheduler:self.app.backgroundScheduler
                    backgroundSessionIdentifier:nil];
    return _gateway;
}

#pragma mark Private

- (id<SODHost>)dropboxHost {
    if (_dropboxHost) {
        return _dropboxHost;
    }
    self.dropboxHost = [[SODDropboxHost alloc]
                        initWithID:@"db_meta"
                        URL:[@"https://api.dropboxapi.com/2" posrx_URL]
                        account:self.account
                        accountRepository:self.app.accountRepository
                        gateway:self.gateway
                        tracker:self.app.tracker];
    return _dropboxHost;
}

@end

NS_ASSUME_NONNULL_END
