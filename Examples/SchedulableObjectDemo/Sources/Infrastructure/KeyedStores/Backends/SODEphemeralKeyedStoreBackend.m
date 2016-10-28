//
//  SODEphemeralKeyedStoreBackend.m
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 26.10.15.
//  Copyright © 2015 Pavel Osipov. All rights reserved.
//

#import "SODEphemeralKeyedStoreBackend.h"

NS_ASSUME_NONNULL_BEGIN

@interface SODEphemeralKeyedStoreBackend ()
@property (nonatomic, nullable) NSData *data;
@end

@implementation SODEphemeralKeyedStoreBackend

#pragma mark SODKeyedStoreBackend

- (BOOL)saveData:(NSData *)data error:(NSError **)error {
    POSRX_CHECK(data);
    self.data = [data copy];
    return YES;
}

- (nullable NSData *)loadData:(NSError **)error {
    return [_data copy];
}

- (BOOL)removeData:(NSError **)error {
    self.data = nil;
    return YES;
}

@end

NS_ASSUME_NONNULL_END
