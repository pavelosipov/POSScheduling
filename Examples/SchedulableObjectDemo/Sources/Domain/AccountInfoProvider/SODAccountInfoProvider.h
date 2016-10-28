//
//  SODAccountInfoProvider.h
//  SchedulableObjectDemo
//
//  Created by Osipov on 15/06/16.
//  Copyright © 2016 Pavel Osipov. All rights reserved.
//

#import <POSRx/POSRx.h>

NS_ASSUME_NONNULL_BEGIN

/// Providers info about account.
@protocol SODAccountInfoProvider <POSSchedulable>

/// @return Signal of nonnull SODAccountInfo.
- (RACSignal *)fetchAccountInfo;

@end

NS_ASSUME_NONNULL_END
