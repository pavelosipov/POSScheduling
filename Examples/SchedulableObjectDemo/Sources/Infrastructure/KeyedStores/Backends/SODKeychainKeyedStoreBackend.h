//
//  SODKeychainKeyedStoreBackend.h
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 23.10.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import "SODKeyedStoreBackend.h"

NS_ASSUME_NONNULL_BEGIN

@interface SODKeychainKeyedStoreBackend : NSObject <SODKeyedStoreBackend>

/// The convenience initializer.
/// @param dataKey Manadatory key for all data for in keychain.
/// @param service Manadatory parameter for specifying kSecAttrService argument in keychain query.
- (instancetype)initWithDataKey:(NSString *)dataKey
                        service:(NSString *)service;

/// The designated initializer.
/// @param dataKey Manadatory key for all data for in keychain.
/// @param service Manadatory parameter for specifying kSecAttrService argument in keychain query.
/// @param accessGroup Optional parameter for specifying kSecAttrAccessGroup argument in keychain query.
- (instancetype)initWithDataKey:(NSString *)dataKey
                        service:(NSString *)service
                    accessGroup:(nullable NSString *)accessGroup;

POSRX_INIT_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
