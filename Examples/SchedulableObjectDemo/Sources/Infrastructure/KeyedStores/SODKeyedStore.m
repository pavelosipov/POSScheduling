//
//  SODKeyedStore.h
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 25.10.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import "SODKeyedStore.h"
#import "NSError+SODTrackable.h"

NS_ASSUME_NONNULL_BEGIN

@interface SODKeyedStore ()
@property (nonatomic) dispatch_queue_t syncQueue;
@property (nonatomic) NSDictionary *store;
@property (nonatomic) id<SODKeyedStoreBackend> storeBackend;
@end

@implementation SODKeyedStore
@dynamic allKeys;

- (instancetype)initWithBackend:(id<SODKeyedStoreBackend>)backend
                          error:(NSError **)error {
    POSRX_CHECK(backend);
    if (self = [super init]) {
        _syncQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        _storeBackend = backend;
        _store = [self p_loadStore:error];
    }
    return self;
}

#pragma mark Public

- (NSArray *)allKeys {
    __block NSArray *keys = nil;
    dispatch_sync(_syncQueue, ^{
        keys = _store.allKeys;
    });
    return keys;
}

- (nullable id)objectForKey:(NSString *)key {
    POSRX_CHECK(key);
    __block id value = nil;
    dispatch_sync(_syncQueue, ^{
        value = [_store objectForKey:key];
    });
    return value;
}

- (BOOL)setObject:(id<NSCoding>)object forKey:(NSString *)key error:(NSError **)error {
    POSRX_CHECK(object);
    POSRX_CHECK(key);
    return [self p_updateStoreWithBlock:^(NSMutableDictionary *store) {
        [store setObject:object forKey:key];
    } error:error];
}

- (BOOL)addObjectsFromDictionary:(NSDictionary *)dictionary error:(NSError **)error {
    POSRX_CHECK(dictionary);
    return [self p_updateStoreWithBlock:^(NSMutableDictionary *store) {
        [store addEntriesFromDictionary:dictionary];
    } error:error];
}

- (BOOL)removeObjectForKey:(NSString *)key error:(NSError **)error {
    POSRX_CHECK(key);
    return [self p_updateStoreWithBlock:^(NSMutableDictionary *store) {
        [store removeObjectForKey:key];
    } error:error];
}

- (BOOL)removeObjectsForKeys:(NSArray *)keys error:(NSError **)error {
    POSRX_CHECK(keys);
    return [self p_updateStoreWithBlock:^(NSMutableDictionary *store) {
        [store removeObjectsForKeys:keys];
    } error:error];
}

- (BOOL)removeAllObjects:(NSError **)error {
    __block BOOL result = NO;
    __block NSError *storeError = nil;
    dispatch_barrier_sync(_syncQueue, ^{
        result = [_storeBackend removeData:&storeError];
        if (result) {
            _store = [NSDictionary new];
        }
    });
    SODAssignError(error, storeError);
    return result;
}

#pragma mark Private

- (BOOL)p_updateStoreWithBlock:(void (^)(NSMutableDictionary *store))updateBlock error:(NSError **)error {
    __block BOOL result = NO;
    __block NSError *storeError = nil;
    dispatch_barrier_sync(_syncQueue, ^{
        NSMutableDictionary *storeCopy = [_store mutableCopy];
        updateBlock(storeCopy);
        result = [self p_saveStore:storeCopy error:&storeError];
        if (result) {
            self.store = storeCopy;
        }
    });
    SODAssignError(error, storeError);
    return result;
}

- (NSDictionary *)p_loadStore:(NSError **)error {
    @try {
        NSData *data = [_storeBackend loadData:error];
        if (!data) {
            return [NSDictionary new];
        }
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        id store = [unarchiver decodeObject];
        if (![store isKindOfClass:[NSDictionary class]]) {
            SODAssignError(error, [NSError sod_internalErrorWithFormat:@"Unexpected type of the store: %@", store]);
            return [NSDictionary new];
        }
        return [store mutableCopy];
    } @catch (NSException *exception) {
        SODAssignError(error, [NSError sod_systemErrorWithFormat:exception.reason]);
        return [NSDictionary new];
    }
}

- (BOOL)p_saveStore:(NSDictionary *)store error:(NSError **)error {
    @try {
        NSMutableData *data = [NSMutableData data];
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc ] initForWritingWithMutableData:data];
        [archiver setOutputFormat:NSPropertyListXMLFormat_v1_0];
        [archiver encodeRootObject:store];
        [archiver finishEncoding];
        return [_storeBackend saveData:data error:error];
    } @catch (NSException *exception) {
        SODAssignError(error, [NSError sod_systemErrorWithFormat:exception.reason]);
        return NO;
    }
}

@end

NS_ASSUME_NONNULL_END
