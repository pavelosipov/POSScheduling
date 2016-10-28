//
//  SODAppMonitor.h
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 14.03.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import <ReactiveCocoa/ReactiveCocoa.h>

NS_ASSUME_NONNULL_BEGIN

/// Thread-safe service.
@protocol SODAppMonitor <NSObject>

/// Emits RACTuple in main thread with AppDelegate callback parametes when application is opened with some URL.
@property (nonatomic, readonly) RACSignal *openingURLSignal;

@end

NS_ASSUME_NONNULL_END
