//
//  SODDropboxHost.m
//  SchedulableObjectDemo
//
//  Created by Osipov on 15/06/16.
//  Copyright © 2016 Pavel Osipov. All rights reserved.
//

#import "SODDropboxHost.h"
#import "SODAccount.h"
#import "SODAccountRepository.h"
#import "SODCredentials.h"
#import "SODLogging.h"
#import "NSError+SODAuth.h"

NS_ASSUME_NONNULL_BEGIN

@interface SODDropboxHost ()
@property (nonatomic, readonly) NSURL *baseURL;
@property (nonatomic, readonly) SODAccount *account;
@property (nonatomic, readonly) id<SODAccountRepository> accountRepository;
@property (nonatomic, readonly) id<SODTracker> tracker;
@end

@implementation SODDropboxHost

- (instancetype)initWithID:(NSString *)ID
                       URL:(NSURL *)baseURL
                   account:(SODAccount *)account
         accountRepository:(id<SODAccountRepository>)accountRepository
                   gateway:(id<POSHTTPGateway>)gateway
                   tracker:(nullable id<SODTracker>)tracker {
    POSRX_CHECK(baseURL.host);
    POSRX_CHECK(account);
    POSRX_CHECK(accountRepository);
    if (self = [super initWithID:ID gateway:gateway tracker:tracker]) {
        _account = account;
        _baseURL = baseURL;
        _accountRepository = accountRepository;
    }
    return self;
}

#pragma mark SODHost

- (nullable NSURL *)URL {
    return _baseURL;
}

- (RACSignal *)pushRequest:(POSHTTPRequest *)request
                   options:(nullable POSHTTPRequestExecutionOptions *)options {
    POSRX_CHECK(request);
    if (![_accountRepository containsAccount:_account]) {
        return [RACSignal error:[NSError sod_authErrorWithCode:@"nocreds"
                                                   description:@"Credentials has been outdated."]];
    }
    NSDictionary *oauthHeader = @{@"Authorization": [NSString stringWithFormat:@"Bearer %@", _account.credentials.accessToken]};
    options = [POSHTTPRequestExecutionOptions
               merge:options
               withHTTPOptions:[[POSHTTPRequestOptions alloc] initWithHeaderFields:oauthHeader]];
    @weakify(self);
    return [[[super pushRequest:request options:options]
            takeUntil:self.rac_willDeallocSignal]
            catch:^RACSignal *(NSError *error) {
                @strongify(self);
                if (error.sod_response.statusCode == 401) {
                    [self.accountRepository removeAccount:self.account reason:SODSignOutReasonInvalidToken];
                    return [RACSignal error:[NSError sod_authErrorWithCredentials:self.account.credentials tags:@[@"401"]]];
                }
                return [RACSignal error:error];
            }];
    return nil;
}

@end

NS_ASSUME_NONNULL_END
