//
//  SODEphemeralKeyedStoreBackend.h
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 26.10.15.
//  Copyright © 2015 Pavel Osipov. All rights reserved.
//

#import "SODKeyedStoreBackend.h"

/// Keyed store, which stores all its data in the RAM.
@interface SODEphemeralKeyedStoreBackend : NSObject <SODKeyedStoreBackend>

@end
