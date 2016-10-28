//
//  SODNetworkMonitor.h
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 26.08.14.
//  Copyright (c) 2014 Pavel Osipov. All rights reserved.
//

#import <POSRx/POSRx.h>

NS_ASSUME_NONNULL_BEGIN

/// Notifies about network status changes.
@protocol SODNetworkMonitor <POSSchedulable>

/// Emits value from SODNetworkStatus enum.
@property (nonatomic, readonly) RACSignal *networkStatusSignal;

/// Starts monitoring.
- (void)activate;

@end

/// Default implementation of SODNetworkMonitor protocol
@interface SODNetworkMonitor : POSSchedulableObject <SODNetworkMonitor>

@end

NS_ASSUME_NONNULL_END
