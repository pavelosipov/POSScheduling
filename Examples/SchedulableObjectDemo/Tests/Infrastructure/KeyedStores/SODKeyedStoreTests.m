//
//  SODKeyedStoreTests.m
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 26.10.15.
//  Copyright © 2015 Pavel Osipov. All rights reserved.
//

#import "SODKeyedStore.h"
#import "SODEphemeralKeyedStoreBackend.h"
#import "NSError+SODTrackable.h"
#import <XCTest/XCTest.h>

#pragma mark - Stubs

@interface SODTestAggergate : NSObject <NSCoding>
@property (nonatomic) NSString *p1;
@property (nonatomic) NSInteger p2;
@end

@interface SODBrokenStoreBackend : NSObject <SODKeyedStoreBackend>
@end

#pragma mark - Tests

@interface SODKeyedStoreTests : XCTestCase
@end

@implementation SODKeyedStoreTests

- (void)testBuiltinTypesSerialization {
    id<SODKeyedStoreBackend> backend = [SODEphemeralKeyedStoreBackend new];
    id<SODKeyedStore> keyedStore1 = [[SODKeyedStore alloc] initWithBackend:backend error:nil];
    XCTAssertNotNil(keyedStore1.allKeys);
    XCTAssertTrue(keyedStore1.allKeys.count == 0);
    [keyedStore1 setObject:@"str" forKey:@"test" error:nil];
    XCTAssertTrue(keyedStore1.allKeys.count == 1);
    XCTAssertEqualObjects(keyedStore1.allKeys[0], @"test");
    id<SODKeyedStore> keyedStore2 = [[SODKeyedStore alloc] initWithBackend:backend error:nil];
    XCTAssertTrue(keyedStore2.allKeys.count == 1);
    XCTAssertEqualObjects(keyedStore2.allKeys[0], @"test");
    XCTAssertEqualObjects([keyedStore2 objectForKey:@"test"], @"str");
}

- (void)testAggregatesSerialization {
    id<SODKeyedStoreBackend> backend = [SODEphemeralKeyedStoreBackend new];
    id<SODKeyedStore> keyedStore1 = [[SODKeyedStore alloc] initWithBackend:backend error:nil];
    SODTestAggergate *aggregate1 = [SODTestAggergate new];
    aggregate1.p1 = @"str";
    aggregate1.p2 = 2;
    [keyedStore1 setObject:aggregate1 forKey:@"agg" error:nil];
    id<SODKeyedStore> keyedStore2 = [[SODKeyedStore alloc] initWithBackend:backend error:nil];
    XCTAssertTrue(keyedStore2.allKeys.count == 1);
    XCTAssertEqualObjects(keyedStore2.allKeys[0], @"agg");
    SODTestAggergate *aggregate2 = [keyedStore2 objectForKey:@"agg"];
    XCTAssertFalse(aggregate1 == aggregate2);
    XCTAssertEqualObjects(aggregate1, aggregate2);
}

- (void)testObjectRemoving {
    id<SODKeyedStoreBackend> backend = [SODEphemeralKeyedStoreBackend new];
    id<SODKeyedStore> keyedStore = [[SODKeyedStore alloc] initWithBackend:backend error:nil];
    XCTAssertNotNil(keyedStore.allKeys);
    XCTAssertTrue(keyedStore.allKeys.count == 0);
    [keyedStore setObject:@"str1" forKey:@"1" error:nil];
    [keyedStore setObject:@"str2" forKey:@"2" error:nil];
    XCTAssertTrue(keyedStore.allKeys.count == 2);
    BOOL keysAreEquals = [keyedStore.allKeys isEqualToArray:@[@"1", @"2"]];
    XCTAssertTrue(keysAreEquals);
    [keyedStore removeObjectForKey:@"2" error:nil];
    XCTAssertTrue(keyedStore.allKeys.count == 1);
    XCTAssertEqualObjects(keyedStore.allKeys[0], @"1");
}

- (void)testObjectMassRemoving {
    id<SODKeyedStoreBackend> backend = [SODEphemeralKeyedStoreBackend new];
    id<SODKeyedStore> keyedStore = [[SODKeyedStore alloc] initWithBackend:backend error:nil];
    XCTAssertNotNil(keyedStore.allKeys);
    XCTAssertTrue(keyedStore.allKeys.count == 0);
    [keyedStore setObject:@"str1" forKey:@"1" error:nil];
    [keyedStore setObject:@"str2" forKey:@"2" error:nil];
    [keyedStore setObject:@"str3" forKey:@"3" error:nil];
    XCTAssertTrue(keyedStore.allKeys.count == 3);
    BOOL keysAreEquals = [keyedStore.allKeys isEqualToArray:@[@"1", @"2", @"3"]];
    XCTAssertTrue(keysAreEquals);
    [keyedStore removeObjectsForKeys:@[@"1", @"3"] error:nil];
    XCTAssertTrue(keyedStore.allKeys.count == 1);
    XCTAssertEqualObjects(keyedStore.allKeys[0], @"2");
}

- (void)testAllObjectsRemoving {
    id<SODKeyedStoreBackend> backend = [SODEphemeralKeyedStoreBackend new];
    id<SODKeyedStore> keyedStore = [[SODKeyedStore alloc] initWithBackend:backend error:nil];
    XCTAssertNotNil(keyedStore.allKeys);
    XCTAssertTrue(keyedStore.allKeys.count == 0);
    [keyedStore setObject:@"str1" forKey:@"1" error:nil];
    [keyedStore setObject:@"str2" forKey:@"2" error:nil];
    [keyedStore setObject:@"str3" forKey:@"3" error:nil];
    XCTAssertTrue(keyedStore.allKeys.count == 3);
    [keyedStore removeAllObjects:nil];
    XCTAssertNotNil(keyedStore.allKeys);
    XCTAssertTrue(keyedStore.allKeys.count == 0);
}

- (void)testFailureRecoveryAfterInitializationAndSaving {
    id<SODKeyedStoreBackend> backend = [SODBrokenStoreBackend new];
    NSError *initError;
    id<SODKeyedStore> keyedStore = [[SODKeyedStore alloc] initWithBackend:backend error:&initError];
    XCTAssertNotNil(initError);
    XCTAssertNotNil(keyedStore.allKeys);
    XCTAssertTrue(keyedStore.allKeys.count == 0);
    NSError *saveError;
    BOOL saved = [keyedStore setObject:@"str1" forKey:@"1" error:&saveError];
    XCTAssertFalse(saved);
    XCTAssertTrue(keyedStore.allKeys.count == 0);
    XCTAssertNil([keyedStore objectForKey:@"1"]);
}

@end

#pragma mark -

@implementation SODTestAggergate

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _p1 = [aDecoder decodeObjectForKey:@"p1"];
        _p2 = [aDecoder decodeIntegerForKey:@"p2"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_p1 forKey:@"p1"];
    [aCoder encodeInteger:_p2 forKey:@"p2"];
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    if (![object isKindOfClass:SODTestAggergate.class]) {
        return NO;
    }
    return ([_p1 isEqualToString:[object p1]] &&
            _p2 == [object p2]);
}

@end

#pragma mark - 

@implementation SODBrokenStoreBackend

- (BOOL)saveData:(NSData *)data error:(NSError **)error {
    SODAssignError(error, [NSError sod_internalErrorWithFormat:@"Dummy saving error."]);
    return NO;
}

- (NSData *)loadData:(NSError **)error {
    SODAssignError(error, [NSError sod_internalErrorWithFormat:@"Dummy loading error."]);
    return nil;
}

- (BOOL)removeData:(NSError **)error {
    SODAssignError(error, [NSError sod_internalErrorWithFormat:@"Dummy removing error."]);
    return NO;
}

@end
