//
//  SODAccountInfo.m
//  SchedulableObjectDemo
//
//  Created by Osipov on 15/06/16.
//  Copyright © 2016 Pavel Osipov. All rights reserved.
//

#import "SODAccountInfo.h"

NS_ASSUME_NONNULL_BEGIN

@implementation SODAccountInfo

- (instancetype)initWithEmail:(NSString *)email
                  displayName:(nullable NSString *)displayName
                    avatarURL:(nullable NSURL *)avatarURL {
    POSRX_CHECK(email);
    if (self = [super init]) {
        _email = [email.lowercaseString copy];
        _avatarURL = avatarURL;
        if (displayName) {
            _displayName = [displayName copy];
        } else {
            _displayName = [[email componentsSeparatedByString:@"@"] firstObject] ?: email;
        }
    }
    return self;
}

@end

NS_ASSUME_NONNULL_END
