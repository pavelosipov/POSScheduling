//
//  SODDropboxHostTests.m
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 23.06.16.
//  Copyright © 2016 Pavel Osipov. All rights reserved.
//

#import "SODAccount.h"
#import "SODAccountRepository.h"
#import "SODDropboxHost.h"
#import "SODDropboxRequests.h"
#import "SODEphemeralKeyedStoreBackend.h"
#import "SODKeyedStore.h"
#import "SODHTTPGatewayStub.h"
#import "SODHTTPGET.h"
#import "NSError+SODAuth.h"
#import <POSAllocationTracker/POSAllocationTracker.h>
#import <XCTest/XCTest.h>

@interface SODDropboxHostTests : XCTestCase
@property (nonatomic) id<SODAccountRepository> accountRepository;
@property (nonatomic) id<SODHost> host;
@end

@implementation SODDropboxHostTests

- (void)setUp {
    [super setUp];
    self.accountRepository = [[SODAccountRepository alloc]
                              initWithScheduler:[RACTargetQueueScheduler pos_mainThreadScheduler]
                              keyedStore:[[SODKeyedStore alloc]
                                          initWithBackend:[SODEphemeralKeyedStoreBackend new]
                                          error:nil]
                              tracker:nil];
}

- (void)setUpHostWithAccount:(SODAccount *)account
                gatewayBlock:(RACSignal *(^)(id<POSHTTPRequest>, NSURL *))requestHandler {
    self.host = [[SODDropboxHost alloc]
                 initWithID:@"db"
                 URL:[@"https://api.dropbox.com" posrx_URL]
                 account:account
                 accountRepository:self.accountRepository
                 gateway:[[SODHTTPGatewayStub alloc] initWithRequestHandler:requestHandler]
                 tracker:nil];
}

- (void)tearDown {
    self.accountRepository = nil;
    self.host = nil;
    [self checkMemoryLeaks];
    [super tearDown];
}

- (void)checkMemoryLeaks {
    XCTAssert([POSAllocationTracker instanceCountForClass:SODDropboxHost.class] == 0);
    XCTAssert([POSAllocationTracker instanceCountForClass:SODAccountRepository.class] == 0);
    XCTAssert([POSAllocationTracker instanceCountForClass:RACDisposable.class] == 0);
    [super tearDown];
}

- (void)testRequestShouldFailWhenAccountIsInvalid {
    XCTestExpectation *expectation = [self expectationWithDescription:@"e"];
    [self
     setUpHostWithAccount:[[SODAccount alloc] initWithCloudType:SODCloudTypeDropbox ID:@"1" credentials:nil]
     gatewayBlock:^RACSignal *(id<POSHTTPRequest> request, NSURL *hostURL) {
         return [RACSignal never];
     }];
    [[_host pushRequest:SODHTTPGET.empty] subscribeError:^(NSError *error) {
        XCTAssertEqualObjects(error.sod_category, kSODAuthCategory);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testHostShouldInvalidateAccountWhenReceiveResponseWithHTTPStatus401 {
    XCTestExpectation *expectation = [self expectationWithDescription:@"e"];
    __block NSArray<SODAccount *> *actualAccounts;
    [_accountRepository.accountsSignal subscribeNext:^(NSArray<SODAccount *> *accounts) {
        actualAccounts = accounts;
    }];
    SODAccount *account = [[SODAccount alloc] initWithCloudType:SODCloudTypeDropbox ID:@"1" credentials:nil];
    [_accountRepository addAccount:account];
    [self setUpHostWithAccount:account gatewayBlock:^RACSignal *(id<POSHTTPRequest> request, NSURL *hostURL) {
        return [RACSignal return:[[POSHTTPResponse alloc] initWithStatusCode:401]];
    }];
    [[_host pushRequest:[SODDropboxRPC path:@"/foo" payloadHandler:nil]] subscribeError:^(NSError *error) {
        XCTAssertEqualObjects(error.sod_category, kSODAuthCategory);
        XCTAssertTrue(actualAccounts.count == 0);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testHostShouldProxyErrorResponses {
    XCTestExpectation *expectation = [self expectationWithDescription:@"e"];
    __block NSArray<SODAccount *> *actualAccounts;
    [_accountRepository.accountsSignal subscribeNext:^(NSArray<SODAccount *> *accounts) {
        actualAccounts = accounts;
    }];
    SODAccount *account = [[SODAccount alloc] initWithCloudType:SODCloudTypeDropbox ID:@"1" credentials:nil];
    [_accountRepository addAccount:account];
    [self setUpHostWithAccount:account gatewayBlock:^RACSignal *(id<POSHTTPRequest> request, NSURL *hostURL) {
        return [RACSignal return:[[POSHTTPResponse alloc] initWithStatusCode:500]];
    }];
    [[_host pushRequest:[SODDropboxRPC path:@"/foo" payloadHandler:nil]] subscribeError:^(NSError *error) {
        XCTAssertEqualObjects(error.sod_category, kSODResponseErrorCategory);
        XCTAssertTrue(actualAccounts.count == 1);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testHostShouldNotLeakDealingWithInfiniteResponses {
    XCTestExpectation *expectation = [self expectationWithDescription:@"e"];
    SODAccount *account = [[SODAccount alloc] initWithCloudType:SODCloudTypeDropbox ID:@"1" credentials:nil];
    [_accountRepository addAccount:account];
    [self setUpHostWithAccount:account gatewayBlock:^RACSignal *(id<POSHTTPRequest> request, NSURL *hostURL) {
        return [RACSignal never];
    }];
    [[_host pushRequest:[SODDropboxRPC path:@"/foo" payloadHandler:nil]] replayLast];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.host = nil;
        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testDropboxRequestShoudDetectErrorResponses {
    XCTestExpectation *expectation = [self expectationWithDescription:@"e"];
    SODAccount *account = [[SODAccount alloc] initWithCloudType:SODCloudTypeDropbox ID:@"1" credentials:nil];
    [_accountRepository addAccount:account];
    [self setUpHostWithAccount:account gatewayBlock:^RACSignal *(id<POSHTTPRequest> request, NSURL *hostURL) {
        NSData *data = [@"{"
                        "\"error\":\"invalid_request\","
                        "\"error_description\":\"Client has issued malformed or illegal request\""
                        "}"
                        dataUsingEncoding:NSUTF8StringEncoding];
        return [RACSignal return:[[POSHTTPResponse alloc] initWithData:data]];
    }];
    [[_host pushRequest:[SODDropboxRPC path:@"/foo" payloadHandler:nil]] subscribeError:^(NSError *error) {
        XCTAssertEqualObjects(error.sod_category, kSODResponseErrorCategory);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testDropboxRequestShoudParseJSONResponses {
    XCTestExpectation *expectation = [self expectationWithDescription:@"e"];
    SODAccount *account = [[SODAccount alloc] initWithCloudType:SODCloudTypeDropbox ID:@"1" credentials:nil];
    [_accountRepository addAccount:account];
    [self setUpHostWithAccount:account gatewayBlock:^RACSignal *(id<POSHTTPRequest> request, NSURL *hostURL) {
        NSData *data = [@"{\"value\":1}" dataUsingEncoding:NSUTF8StringEncoding];
        return [RACSignal return:[[POSHTTPResponse alloc] initWithData:data]];
    }];
    [[_host pushRequest:[SODDropboxRPC path:@"/foo" payloadHandler:nil]] subscribeNext:^(POSJSONMap *JSON) {
        XCTAssertEqualObjects([[JSON extract:@"value"] asNumber], @1);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testDropboxRequestShoudProxyGoodResponsesToPayloadHandler {
    XCTestExpectation *expectation = [self expectationWithDescription:@"e"];
    SODAccount *account = [[SODAccount alloc] initWithCloudType:SODCloudTypeDropbox ID:@"1" credentials:nil];
    [_accountRepository addAccount:account];
    [self setUpHostWithAccount:account gatewayBlock:^RACSignal *(id<POSHTTPRequest> request, NSURL *hostURL) {
        NSData *data = [@"{\"value\":1}" dataUsingEncoding:NSUTF8StringEncoding];
        return [RACSignal return:[[POSHTTPResponse alloc] initWithData:data]];
    }];
    [[_host pushRequest:[SODDropboxRPC path:@"/foo" payloadHandler:^id(POSJSONMap *JSON, NSError **error) {
        return [[JSON extract:@"value"] asNumber];
    }]] subscribeNext:^(NSNumber *value) {
        XCTAssertEqualObjects(value, @1);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

@end
