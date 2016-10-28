//
//  SODNetworkMonitor.m
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 04.11.13.
//  Copyright (c) 2013 Pavel Osipov. All rights reserved.
//

#import "SODNetworkMonitor.h"
#import "SODNetworkStatus.h"
#import "SODLogging.h"
#import <GCNetworkReachability/GCNetworkReachability.h>

NS_ASSUME_NONNULL_BEGIN

NS_INLINE SODNetworkStatus SODNetworkStatusFromReachabilityStatus(GCNetworkReachabilityStatus reachabilityStatus) {
    switch (reachabilityStatus) {
        case GCNetworkReachabilityStatusNotReachable: return SODNetworkStatusOffline;
        case GCNetworkReachabilityStatusWiFi:         return SODNetworkStatusWiFi;
        case GCNetworkReachabilityStatusWWAN:         return SODNetworkStatusCellular;
    }
}

@interface SODNetworkMonitor ()
@property (nonatomic, nullable) GCNetworkReachability *networkReachability;
@property (nonatomic) RACSignal *networkStatusSignal;
@property (nonatomic) SODNetworkStatus networkStatus;
@end

@implementation SODNetworkMonitor

- (instancetype)initWithScheduler:(RACTargetQueueScheduler *)scheduler
                          options:(nullable POSScheduleProtectionOptions *)options {
    if (self = [super initWithScheduler:scheduler options:options]) {
        _networkStatus = SODNetworkStatusOffline;
        _networkStatusSignal = RACObserve(self, networkStatus);
    }
    return self;
}

- (void)activate {
    _networkReachability = [GCNetworkReachability reachabilityForInternetConnection];
    self.networkStatus = SODNetworkStatusFromReachabilityStatus(_networkReachability.currentReachabilityStatus);
    @weakify(self);
    [_networkReachability startMonitoringNetworkReachabilityWithHandler:^(GCNetworkReachabilityStatus status) {
        @strongify(self);
        self.networkStatus = SODNetworkStatusFromReachabilityStatus(status);
    }];
}

- (void)setNetworkStatus:(SODNetworkStatus)networkStatus {
    if (_networkStatus == networkStatus) {
        return;
    }
    [self willChangeValueForKey:@keypath(self.networkStatus)];
    DDLogInfo(@"%@ -> %@", self, SODStringFromNetworkStatus(networkStatus));
    _networkStatus = networkStatus;
    [self didChangeValueForKey:@keypath(self.networkStatus)];
}

#pragma mark NSObject

- (NSString *)description {
    return [NSString stringWithFormat:@"%@:%@", [self class], SODStringFromNetworkStatus(_networkStatus)];
}

@end

NS_ASSUME_NONNULL_END
