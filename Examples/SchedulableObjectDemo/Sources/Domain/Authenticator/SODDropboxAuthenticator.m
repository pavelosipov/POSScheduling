//
//  SODDropboxAuthenticator.m
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 08.03.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import "SODDropboxAuthenticator.h"
#import "SODAccount.h"
#import "SODAppMonitor.h"
#import "SODCredentials.h"
#import "NSError+SODAuth.h"

NS_ASSUME_NONNULL_BEGIN

@interface SODDropboxAuthenticator ()
@property (nonatomic, readonly) NSString *appKey;
@property (nonatomic, readonly) id<SODAppMonitor> appMonitor;
@end

@implementation SODDropboxAuthenticator

- (instancetype)initWithDropboxAppKey:(NSString *)appKey
                           appMonitor:(id<SODAppMonitor>)appMonitor {
    POSRX_CHECK(appKey.length > 0);
    POSRX_CHECK(appMonitor);
    if (self = [super init]) {
        _appKey = [appKey copy];
        _appMonitor = appMonitor;
    }
    return self;
}

#pragma mark SODDropboxAuthenticator

- (NSURL *)oauthURL {
    return [[@"https://www.dropbox.com" posrx_URL] posrx_URLByAppendingMethod:
            [POSHTTPRequestMethod
             path:@"/1/oauth2/authorize"
             query:@{@"response_type": @"token",
                     @"client_id": _appKey,
                     @"redirect_uri": [NSString stringWithFormat:@"%@://2/token", self.p_redirectURLScheme],
                     @"disable_signup": @"true"}]];
}

- (RACSignal *)listenForSignIn {
    return [[[_appMonitor.openingURLSignal
            filter:^BOOL(RACTuple *args) {
                return [[args.second scheme] isEqualToString:self.p_redirectURLScheme];
            }]
            take:1]
            tryMap:^id(RACTuple *args, NSError **error) {
                return [self p_extractAccountFromRedirectURL:args.second error:error];
            }];
}

#pragma mark Private

- (NSString *)p_redirectURLScheme {
    return [NSString stringWithFormat:@"db-%@", _appKey];
}

- (SODAccount *)p_extractAccountFromRedirectURL:(NSURL *)redirectURL
                                          error:(NSError **)error {
    NSMutableDictionary<NSString *, NSString *> *pairs = [NSMutableDictionary new];
    NSArray<NSString *> *components = [redirectURL.fragment componentsSeparatedByString:@"&"];
    for (NSString *component in components) {
        NSArray<NSString *> *pair = [component componentsSeparatedByString:@"="];
        POSRX_CHECK_EX(pair.count == 2, @"Invalid pair '%@' in redirectURL '%@'.", pair, redirectURL);
        pairs[pair[0]] = pair[1];
    }
    if (pairs[@"error"]) {
        NSString *description = [pairs[@"error_description"] stringByReplacingOccurrencesOfString:@"+" withString:@" "];
        SODAssignError(error, [NSError sod_authErrorWithCode:pairs[@"error"] description:description]);
        return nil;
    }
    NSString *token = [pairs[@"access_token"] posrx_percentDecoded];
    if (!token) {
        SODAssignError(error, [NSError sod_authErrorWithCode:@"access_token_not_found" description:nil]);
        return nil;
    }
    NSString *accountID = [pairs[@"account_id"] posrx_percentDecoded];
    if (!accountID) {
        SODAssignError(error, [NSError sod_authErrorWithCode:@"account_id_not_found" description:nil]);
        return nil;
    }
    return [[SODAccount alloc]
            initWithCloudType:SODCloudTypeDropbox
            ID:accountID
            credentials:[[SODCredentials alloc] initWithAccessToken:token]];
}

@end

NS_ASSUME_NONNULL_END
