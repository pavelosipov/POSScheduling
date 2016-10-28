//
//  SODAccountInfoProvider.h
//  SchedulableObjectDemo
//
//  Created by Osipov on 15/06/16.
//  Copyright © 2016 Pavel Osipov. All rights reserved.
//

#import "SODAccountInfoProvider.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SODHost;

/// The default implementation of SODAccountInfoProvider.
@interface SODDropboxAccountInfoProvider : POSSchedulableObject <SODAccountInfoProvider>

/// The designated initializer.
- (instancetype)initWithHost:(id<SODHost>)host
                   accountID:(NSString *)accountID;

/// Hide deadly initializers.
POSRX_SCHEDULABLE_INIT_RECURSIVELY_UNAVAILABLE

@end

NS_ASSUME_NONNULL_END
