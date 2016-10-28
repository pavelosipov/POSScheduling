//
//  SODFileKeyedStoreBackend.h
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 13.10.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import "SODKeyedStoreBackend.h"

NS_ASSUME_NONNULL_BEGIN

@interface SODFileKeyedStoreBackend : NSObject <SODKeyedStoreBackend>

/// The only designated initializer.
- (instancetype)initWithFilePath:(NSString *)filePath;

POSRX_INIT_UNAVAILABLE

@end

NS_ASSUME_NONNULL_END
