//
//  POSSignalAwaitTests.m
//  POSSchedulableObject
//
//  Created by Pavel Osipov on 13.06.16.
//  Copyright © 2016 Pavel Osipov. All rights reserved.
//

#import <POSSchedulableObject/POSSchedulableObject.h>
#import <POSAllocationTracker/POSAllocationTracker.h>
#import <XCTest/XCTest.h>

@protocol POSFoo <POSSchedulable>
@property (nonatomic) NSString *value;
@end

@interface POSFoo : POSSchedulableObject <POSFoo>
@end

@implementation POSFoo {
    NSString *_value;
}
@synthesize value = _value;

- (instancetype)initWithScheduler:(RACTargetQueueScheduler *)scheduler value:(NSString *)value {
    if (self = [super initWithScheduler:scheduler]) {
        _value = [value copy];
    }
    return self;
}

@end


@interface POSGuyWire : POSSchedulableObject

@property (atomic, readonly) RACTargetQueueScheduler *BLScheduler;

@property (nonatomic) id<POSFoo> BL1;
@property (nonatomic) id<POSFoo> UI2;
@property (nonatomic) id<POSFoo> BL3;
@property (nonatomic) id<POSFoo> UI4;

@end

@implementation POSGuyWire

- (instancetype)init {
    if (self = [super init]) {
        _BLScheduler = [[RACTargetQueueScheduler alloc]
                        initWithName:@"bl"
                        targetQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    }
    return self;
}

- (id<POSFoo>)BL1 {
    if (!_BL1) {
        self.BL1 = [[POSFoo alloc] initWithScheduler:_BLScheduler value:@"BL1"];
    }
    return _BL1;
}

- (id<POSFoo>)UI2 {
    if (!_UI2) {
        self.UI2 = [[[self.BL1 schedule] map:^id(id<POSFoo> BL1) {
            return [[POSFoo alloc]
                    initWithScheduler:RACTargetQueueScheduler.pos_mainThreadScheduler
                    value:[NSString stringWithFormat:@"%@.%@", BL1.value, @"UI2"]];
        }] pos_await];
    }
    return _UI2;
}

- (id<POSFoo>)BL3 {
    if (!_BL3) {
        self.BL3 = [[[[RACSignal return:self.UI2.value] deliverOn:self.BLScheduler] map:^id(NSString *value) {
            id<POSFoo> BL3 = [[POSFoo alloc] initWithScheduler:self.BLScheduler];
            BL3.value = [NSString stringWithFormat:@"%@.%@", value, @"BL3"];;
            return BL3;
        }] pos_await];
    }
    return _BL3;
}

- (id<POSFoo>)UI4 {
    if (!_UI4) {
        self.UI4 = [[[self.BL3 schedule] map:^id(id<POSFoo> BL3) {
            return [[POSFoo alloc]
                    initWithScheduler:RACTargetQueueScheduler.pos_mainThreadScheduler
                    value:[NSString stringWithFormat:@"%@.%@", BL3.value, @"UI4"]];
        }] pos_await];
    }
    return _UI4;
}

@end

@interface POSSignalAwaitTests : XCTestCase
@property (nonatomic) POSGuyWire *guyWire;
@end

@implementation POSSignalAwaitTests

- (void)setUp {
    [super setUp];
    self.guyWire = [POSGuyWire new];
}

- (void)tearDown {
    self.guyWire = nil;
    [self checkMemoryLeaks];
    [super tearDown];
}

- (void)checkMemoryLeaks {
    XCTAssert([POSAllocationTracker instanceCountForClass:POSGuyWire.class] == 0);
    XCTAssert([POSAllocationTracker instanceCountForClass:POSFoo.class] == 0);
    XCTAssert([POSAllocationTracker instanceCountForClass:RACSignal.class] == 0);
    XCTAssert([POSAllocationTracker instanceCountForClass:RACDisposable.class] == 0);
}

- (void)testGuyWire {
    XCTAssertEqualObjects(_guyWire.UI4.value, @"BL1.UI2.BL3.UI4");
}

@end
