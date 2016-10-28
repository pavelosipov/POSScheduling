//
//  SODAccountAssembly.h
//  SchedulableObjectDemo
//
//  Created by Osipov on 15/06/16.
//  Copyright © 2016 Pavel Osipov. All rights reserved.
//

#import <POSRx/POSRx.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SODAccountInfoProvider;

@class SODAccount;
@class SODAppAssembly;

@protocol SODAccountAssembly <POSSchedulable>

@property (nonatomic, readonly) SODAppAssembly *app;
@property (nonatomic, readonly) SODAccount *account;

/// @scheduler Background
@property (nonatomic, readonly) id<SODAccountInfoProvider> accountInfoProvider;

/// @scheduler Background
@property (nonatomic, readonly) id<POSHTTPGateway> gateway;

@end

NS_ASSUME_NONNULL_END
