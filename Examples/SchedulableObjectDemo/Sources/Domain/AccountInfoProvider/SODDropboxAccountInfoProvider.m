//
//  SODAccountInfoProvider.m
//  SchedulableObjectDemo
//
//  Created by Osipov on 15/06/16.
//  Copyright © 2016 Pavel Osipov. All rights reserved.
//

#import "SODDropboxAccountInfoProvider.h"
#import "SODDropboxRequests.h"
#import "SODAccountInfo.h"
#import "SODHost.h"

NS_ASSUME_NONNULL_BEGIN

@interface SODDropboxAccountInfoProvider ()
@property (nonatomic, readonly) id<SODHost> host;
@property (nonatomic, readonly) NSString *accountID;
@end

@implementation SODDropboxAccountInfoProvider

- (instancetype)initWithHost:(id<SODHost>)host
                   accountID:(NSString *)accountID {
    POSRX_CHECK(host);
    POSRX_CHECK(accountID);
    if (self = [super initWithScheduler:host.scheduler]) {
        _host = host;
        _accountID = [accountID copy];
    }
    return self;
}

#pragma mark SODAccountInfoProvider

//
// https://www.dropbox.com/developers/documentation/http/documentation#users-get_account
//
- (RACSignal *)fetchAccountInfo {
    return [_host pushRequest:
            [SODDropboxRPC
             path:@"/users/get_account"
             params:@{@"account_id": _accountID}
             payloadHandler:^id(POSJSONMap *JSON, NSError **error) {
                 return [[SODAccountInfo alloc]
                         initWithEmail:[[JSON extract:@"email"] asString]
                         displayName:[[[[JSON tryExtract:@"name"] asMap] tryExtract:@"display_name"] asString]
                         avatarURL:[[JSON tryExtract:@"profile_photo_url"] asURL]];
             }]];
}

@end

NS_ASSUME_NONNULL_END
