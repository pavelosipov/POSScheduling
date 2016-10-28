//
//  SODAppAssembly.m
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 14.03.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import "SODAppAssembly.h"
#import "SODAppTracker.h"
#import "SODAccountRepository.h"
#import "SODConsoleTracker.h"
#import "SODDropboxAuthenticator.h"
#import "SODEnvironment.h"
#import "SODKeyedStore.h"
#import "SODKeychainKeyedStoreBackend.h"
#import "SODEphemeralKeyedStoreBackend.h"
#import "SODLogging.h"
#import "NSBundle+SODPresentation.h"

NS_ASSUME_NONNULL_BEGIN

@interface SODAppAssembly ()
@property (nonatomic) id<SODAppMonitor> appMonitor;
@property (nonatomic) id<SODAccountRepository> accountRepository;
@property (nonatomic) id<SODEnvironment> environment;
@property (nonatomic) id<SODKeyedStore> secureStore;
@property (nonatomic) id<SODTracker> tracker;
@property (nonatomic) id<SODDropboxAuthenticator> dropboxAuthenticator;
@end

@implementation SODAppAssembly

- (instancetype)initWithAppMonitor:(id<SODAppMonitor>)appMonitor {
    if (self = [super init]) {
        _backgroundScheduler = [[RACTargetQueueScheduler alloc]
                                initWithName:@"com.github.pavelosipov.SchedulableObjectDemo.scheduler.bg"
                                targetQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
        _appMonitor = appMonitor;
        _environment = [[SODEnvironment alloc] initWithBundle:NSBundle.mainBundle];
    }
    return self;
}

+ (instancetype)assemblyWithAppMonitor:(id<SODAppMonitor>)appMonitor {
    POSRX_CHECK(appMonitor);
    SODAppAssembly *assembly = [[SODAppAssembly alloc] initWithAppMonitor:appMonitor];
    return assembly;
}

#pragma mark Pubic

- (id<SODAccountRepository>)accountRepository {
    if (_accountRepository) {
        return _accountRepository;
    }
    self.accountRepository = [[SODAccountRepository alloc]
                              initWithScheduler:self.backgroundScheduler
                              keyedStore:self.secureStore
                              tracker:self.tracker];
    return _accountRepository;
}

- (id<SODDropboxAuthenticator>)dropboxAuthenticator {
    if (_dropboxAuthenticator) {
        return _dropboxAuthenticator;
    }
    self.dropboxAuthenticator = [[SODDropboxAuthenticator alloc]
                                 initWithDropboxAppKey:NSBundle.mainBundle.sod_dropboxAppKey
                                 appMonitor:self.appMonitor];
    return _dropboxAuthenticator;
}

- (id<SODTracker>)tracker {
    if (_tracker) {
        return _tracker;
    }
    SODAppTracker *tracker = [[SODAppTracker alloc]
                              initWithScheduler:self.backgroundScheduler
                              store:self.secureStore
                              environment:self.environment];
    self.tracker = [[[tracker schedule] map:^id(SODAppTracker *scheduledTracker) {
        [scheduledTracker addService:[[SODConsoleTracker alloc] initWithScheduler:scheduledTracker.scheduler]];
        return scheduledTracker;
    }] posrx_await];
    return _tracker;
}

#pragma mark Private

- (id<SODKeyedStore>)secureStore {
    if (_secureStore) {
        return _secureStore;
    }
    NSError *error;
    id<SODKeyedStore> secureStore = [[SODKeyedStore alloc]
                                     initWithBackend:[[SODKeychainKeyedStoreBackend alloc]
                                                      initWithDataKey:@"root"
                                                      service:@"com.SchedulableObjectDemo"]
                                     error:&error];
    if (!secureStore) {
        DDLogError(@"%@: failed to init keychain: %@", self, error);
    }
    secureStore = [[SODKeyedStore alloc]
                   initWithBackend:[SODEphemeralKeyedStoreBackend new]
                   error:&error];
    POSRX_CHECK(secureStore);
    self.secureStore = secureStore;
    return _secureStore;
}

@end

NS_ASSUME_NONNULL_END
