//
//  SODDropboxAccountAssembly.h
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 02.06.16.
//  Copyright © 2016 Pavel Osipov. All rights reserved.
//

#import "SODAccountAssembly.h"

NS_ASSUME_NONNULL_BEGIN

@class SODAccount;

@interface SODDropboxAccountAssembly : POSSchedulableObject <SODAccountAssembly>

/// The designated initializer.
- (instancetype)initWithAppAssembly:(SODAppAssembly *)assembly
                            account:(SODAccount *)account;

/// Hidden deadly initializers.
POSRX_SCHEDULABLE_INIT_RECURSIVELY_UNAVAILABLE

@end

NS_ASSUME_NONNULL_END
