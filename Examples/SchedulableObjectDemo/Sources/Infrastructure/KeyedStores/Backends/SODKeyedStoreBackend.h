//
//  SODKeyedStoreBackend.h
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 25.10.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import <POSRx/POSRx.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SODKeyedStoreBackend <NSObject>

/// @brief Persists data into the store.
/// @param data Mandatory data to persist.
/// @return YES if data was saved, otherwise NO.
- (BOOL)saveData:(NSData *)data error:(NSError **)error;

/// @brief Loads data from persisting store.
/// @return NSData instance or nil if data was not saved before yet.
- (nullable NSData *)loadData:(NSError **)error;

/// @brief Removes all data from the store.
- (BOOL)removeData:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
