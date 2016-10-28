//
//  SODFileKeyedStoreBackend.m
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 13.10.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import "SODFileKeyedStoreBackend.h"
#import "NSError+SODTrackable.h"

NS_ASSUME_NONNULL_BEGIN

@interface SODFileKeyedStoreBackend ()
@property (nonatomic, readonly) NSString *filePath;
@end

@implementation SODFileKeyedStoreBackend

- (instancetype)initWithFilePath:(NSString *)filePath {
    POSRX_CHECK(filePath);
    POSRX_CHECK([[NSURL URLWithString:filePath] isFileURL]);
    if (self = [super init]) {
        _filePath = [filePath copy];
    }
    return self;
}

#pragma mark SODKeyedStoreBackend

- (BOOL)saveData:(NSData *)data error:(NSError **)error {
    POSRX_CHECK(data);
    NSError *cocoaError = nil;
    if (![data writeToFile:_filePath options:NSDataWritingAtomic error:&cocoaError]) {
        SODAssignError(error, [NSError sod_systemErrorWithReason:cocoaError]);
        return NO;
    }
    return YES;
}

- (nullable NSData *)loadData:(NSError **)error {
    NSError *cocoaError = nil;
    NSData *data = [NSData dataWithContentsOfFile:_filePath options:NSDataReadingMappedIfSafe error:&cocoaError];
    if (cocoaError) {
        SODAssignError(error, [NSError sod_systemErrorWithReason:cocoaError]);
        return nil;
    }
    return data;
}

- (BOOL)removeData:(NSError **)error {
    NSError *cocoaError = nil;
    if (![[NSFileManager defaultManager] removeItemAtPath:_filePath error:&cocoaError]) {
        SODAssignError(error, [NSError sod_systemErrorWithReason:cocoaError]);
        return NO;
    }
    return YES;
}

@end

NS_ASSUME_NONNULL_END
