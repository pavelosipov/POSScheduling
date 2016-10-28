//
//  SODDropboxAuthenticatorTests.m
//  SchedulableObjectDemo
//
//  Created by Osipov on 14/06/16.
//  Copyright © 2016 Pavel Osipov. All rights reserved.
//

#import "SODAppMonitor.h"
#import "SODAccount.h"
#import "SODCredentials.h"
#import "SODDropboxAuthenticator.h"
#import "NSError+SODAuth.h"
#import <POSAllocationTracker/POSAllocationTracker.h>
#import <XCTest/XCTest.h>

static NSString * const kSODDBAppKey = @"dbappkey";

@interface SODMockAppMonitor : NSObject <SODAppMonitor>
@property (nonatomic) RACSubject *openingURLSignal;
@end

@implementation SODMockAppMonitor

- (instancetype)init {
    if (self = [super init]) {
        _openingURLSignal = [RACSubject subject];
    }
    return self;
}

- (RACSignal *)openingURLSignal {
    return _openingURLSignal;
}

- (void)emitRedirectURL:(NSURL *)redirectURL {
    [_openingURLSignal sendNext:RACTuplePack(nil, redirectURL, nil, nil)];
}

@end

#pragma mark -

@interface SODDropboxAuthenticatorTests : XCTestCase
@property (nonatomic) SODMockAppMonitor *appMonitor;
@property (nonatomic) id<SODDropboxAuthenticator> authenticator;
@end

@implementation SODDropboxAuthenticatorTests

- (void)setUp {
    [super setUp];
    self.appMonitor = [SODMockAppMonitor new];
    self.authenticator = [[SODDropboxAuthenticator alloc]
                          initWithDropboxAppKey:kSODDBAppKey
                          appMonitor:_appMonitor];
}

- (void)tearDown {
    self.authenticator = nil;
    self.appMonitor = nil;
    [self checkMemoryLeaks];
    [super tearDown];
}

- (void)checkMemoryLeaks {
    XCTAssert([POSAllocationTracker instanceCountForClass:SODDropboxAuthenticator.class] == 0);
    XCTAssert([POSAllocationTracker instanceCountForClass:SODMockAppMonitor.class] == 0);
    XCTAssert([POSAllocationTracker instanceCountForClass:RACSubject.class] == 0);
    XCTAssert([POSAllocationTracker instanceCountForClass:RACSignal.class] == 0);
    XCTAssert([POSAllocationTracker instanceCountForClass:RACDisposable.class] == 0);
    [super tearDown];
}

- (void)testParsingValidURL {
    XCTestExpectation *expectation = [self expectationWithDescription:@"e"];
    [[_authenticator listenForSignIn] subscribeNext:^(SODAccount *account) {
        XCTAssertTrue(account.cloudType == SODCloudTypeDropbox);
        XCTAssertEqualObjects(account.ID, @"99943969");
        XCTAssertEqualObjects(account.credentials.accessToken, @"123");
        [expectation fulfill];
    }];
    [_appMonitor emitRedirectURL:[@"db-dbappkey://2/token#access_token=123&token_type=bearer&account_id=99943969" posrx_URL]];
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testFilteringURLWithInvalidScheme {
    XCTestExpectation *expectation = [self expectationWithDescription:@"e"];
    [[_authenticator listenForSignIn] subscribeNext:^(SODAccount *account) {
        XCTAssertEqualObjects(account.credentials.accessToken, @"456");
        [expectation fulfill];
    }];
    [_appMonitor emitRedirectURL:[@"db-badappkey://2/token#access_token=123&token_type=bearer&account_id=99943969" posrx_URL]];
    [_appMonitor emitRedirectURL:[@"db-dbappkey://2/token#access_token=456&token_type=bearer&account_id=99943969" posrx_URL]];
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testParsingFailureOfURLWithoutToken {
    XCTestExpectation *expectation = [self expectationWithDescription:@"e"];
    [[_authenticator listenForSignIn] subscribeError:^(NSError *error) {
        XCTAssertEqualObjects(error.sod_category, kSODAuthCategory);
        [expectation fulfill];
    }];
    [_appMonitor emitRedirectURL:[@"db-dbappkey://2/token#token=123&token_type=bearer&account_id=99943969" posrx_URL]];
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testParsingFailureOfURLWithoutUserID {
    XCTestExpectation *expectation = [self expectationWithDescription:@"e"];
    [[_authenticator listenForSignIn] subscribeError:^(NSError *error) {
        XCTAssertEqualObjects(error.sod_category, kSODAuthCategory);
        [expectation fulfill];
    }];
    [_appMonitor emitRedirectURL:[@"db-dbappkey://2/token#access_token=123&token_type=bearer" posrx_URL]];
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testParsingError {
    XCTestExpectation *expectation = [self expectationWithDescription:@"e"];
    [[_authenticator listenForSignIn] subscribeError:^(NSError *error) {
        XCTAssertEqualObjects(error.sod_category, kSODAuthCategory);
        [expectation fulfill];
    }];
    [_appMonitor emitRedirectURL:[@"db-dbappkey://2/token#error=invalid_scope&error_description=invalid+scope" posrx_URL]];
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

@end
