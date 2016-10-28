//
//  SODKeyedStore.h
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 25.10.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import "SODKeyedStoreBackend.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SODKeyedStore <NSObject>

/// @brief Nonnull array of keys of all objects in the store.
@property (nonatomic, readonly) NSArray *allKeys;

/// @brief Extracts objects from the store.
/// @param key Mandatory object identifier.
/// @return Object for specified key. If there is no one, returns nil.
- (nullable id)objectForKey:(NSString *)key;

/// @brief Inserts objects into the store.
/// @param object Mandatory object to insert into the store.
/// @param key Mandatory object identifier.
/// @return YES if object was set successfuly, otherwise NO.
- (BOOL)setObject:(id<NSCoding>)object forKey:(NSString *)key error:(NSError **)error;

/// @brief Insert objects from dictionary into the store.
/// @discussion Method guarantes transactional insert. All items will be inserted or neither.
/// @param dictionary Mandatory dictionary with inserting items.
/// @return YES if all items were set successfuly, otherwise NO.
- (BOOL)addObjectsFromDictionary:(NSDictionary *)dictionary error:(NSError **)error;

/// @brief Removes object from the store.
/// @param key Mandatory object identifier.
/// @return YES if object was removed successfuly or object was not found, otherwise NO.
- (BOOL)removeObjectForKey:(NSString *)key error:(NSError **)error;

/// @brief Remove objects from the store.
/// @param keys Mandatory set with keys of removing objects.
/// @return YES if all items were removed successfuly, otherwise NO.
- (BOOL)removeObjectsForKeys:(NSArray *)keys error:(NSError **)error;

/// @brief Cleanups store.
/// @return YES if store was successfuly removed from system.
- (BOOL)removeAllObjects:(NSError **)error;

@end

/// Default thread-safe implementation.
@interface SODKeyedStore : NSObject <SODKeyedStore>

/// @brief The only available designated initializer.
/// @param backend Mandatory persistence implemenation for the store.
/// @param error Optional error which indicates error during store initialization.
/// @return Nonnull store instance. Returns empty store if error occurred.
- (instancetype)initWithBackend:(id<SODKeyedStoreBackend>)backend
                          error:(NSError **)error;

POSRX_INIT_UNAVAILABLE

@end

NS_ASSUME_NONNULL_END
