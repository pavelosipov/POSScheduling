//
//  SODKeychainKeyedStoreBackend.m
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 23.10.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import "SODKeychainKeyedStoreBackend.h"
#import "NSError+SODTrackable.h"

NS_ASSUME_NONNULL_BEGIN

@interface SODKeychainKeyedStoreBackend ()
@property (nonatomic, readonly) NSString *dataKey;
@property (nonatomic, readonly) NSString *service;
@property (nonatomic, readonly) NSString *accessGroup;
@end

@implementation SODKeychainKeyedStoreBackend

- (instancetype)initWithDataKey:(NSString *)dataKey
                        service:(NSString *)service {
    return [self initWithDataKey:dataKey service:service accessGroup:nil];
}

- (instancetype)initWithDataKey:(NSString *)dataKey
                        service:(NSString *)service
                    accessGroup:(nullable NSString *)accessGroup {
    POSRX_CHECK(dataKey);
    POSRX_CHECK(service);
    if (self = [super init]) {
        _dataKey = [dataKey copy];
        _service = [service copy];
        _accessGroup = [accessGroup copy];
    }
    return self;
}

#pragma mark SODKeyedStoreBackend

- (BOOL)saveData:(NSData *)data error:(NSError **)error {
    POSRX_CHECK(data);
    NSDictionary *query = [self p_dataKeyAttributes];
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, NULL);
    if (status == errSecSuccess) {
        NSDictionary *updateAttributes = [self p_dataKeyUpdateAttributesForData:data];
        status = SecItemUpdate((__bridge CFDictionaryRef)query,
                               (__bridge CFDictionaryRef)updateAttributes);
        if (status != errSecSuccess) {
            SODAssignError(error, [NSError sod_systemErrorWithFormat:@"Failed to update data in keychain, status=%@", @(status)]);
            return NO;
        }
        return YES;
    }
    if (status == errSecItemNotFound) {
        NSDictionary *attributes = [self p_dataKeyInsertAttributesForData:data];
        status = SecItemAdd((__bridge CFDictionaryRef)attributes, NULL);
        if (status != errSecSuccess) {
            SODAssignError(error, [NSError sod_systemErrorWithFormat:@"Failed to insert data in keychain, status=%@", @(status)]);
            return NO;
        }
        return YES;
    }
    SODAssignError(error, [NSError sod_systemErrorWithFormat:@"Failed to lookup data in keychain, status=%@", @(status)]);
    return NO;
}

- (nullable NSData *)loadData:(NSError **)error {
    NSDictionary *query = [self p_dataKeyQueryAttributes];
    CFTypeRef data = nil;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &data);
    if (status == errSecSuccess) {
        POSRX_CHECK(data);
        return CFBridgingRelease(data);
    }
    if (status == errSecItemNotFound) {
        return nil;
    }
    SODAssignError(error, [NSError sod_systemErrorWithFormat:@"Failed to lookup data in keychain, status=%@", @(status)]);
    return nil;
}

- (BOOL)removeData:(NSError **)error {
    NSDictionary *query = [self p_dataKeyQueryAttributes];
    OSStatus status = SecItemDelete((__bridge CFDictionaryRef)query);
    if (status == errSecSuccess || status == errSecItemNotFound) {
        return YES;
    }
    SODAssignError(error, [NSError sod_systemErrorWithFormat:@"Failed to delete data from keychain, status=%@", @(status)]);
    return NO;
}

#pragma mark Private

- (NSDictionary *)p_dataKeyAttributes {
    NSMutableDictionary *attributes = [NSMutableDictionary new];
    [attributes setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    [attributes setObject:_service forKey:(__bridge id)kSecAttrService];
    [attributes setObject:_dataKey forKey:(__bridge id)kSecAttrAccount];
#if !TARGET_IPHONE_SIMULATOR && defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
    if (_accessGroup) {
        [attributes setObject:_accessGroup forKey:(__bridge id)kSecAttrAccessGroup];
    }
#endif
    return attributes;
}

- (NSDictionary *)p_dataKeyQueryAttributes {
    NSMutableDictionary *attributes = [[self p_dataKeyAttributes] mutableCopy];
    [attributes setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
    [attributes setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    return attributes;
}

- (NSDictionary *)p_dataKeyUpdateAttributesForData:(NSData *)data {
    return @{(__bridge id)kSecValueData : data};
}

- (NSDictionary *)p_dataKeyInsertAttributesForData:(NSData *)data {
    NSMutableDictionary *attributes = [[self p_dataKeyAttributes] mutableCopy];
#if TARGET_OS_IPHONE || (defined(MAC_OS_X_VERSION_10_9) && MAC_OS_X_VERSION_MIN_REQUIRED >= MAC_OS_X_VERSION_10_9)
    [attributes setObject:(__bridge id)kSecAttrAccessibleAfterFirstUnlock forKey:(__bridge id)kSecAttrAccessible];
#endif
    [attributes setObject:data forKey:(__bridge id)kSecValueData];
    return attributes;
}

@end

NS_ASSUME_NONNULL_END
