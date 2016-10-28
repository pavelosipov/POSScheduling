//
//  SODAccountInfo.h
//  SchedulableObjectDemo
//
//  Created by Osipov on 15/06/16.
//  Copyright © 2016 Pavel Osipov. All rights reserved.
//

#import <POSRx/POSRx.h>

NS_ASSUME_NONNULL_BEGIN

@interface SODAccountInfo : NSObject

@property (nonatomic, readonly) NSString *email;
@property (nonatomic, readonly) NSString *displayName;
@property (nonatomic, readonly, nullable) NSURL *avatarURL;

- (instancetype)initWithEmail:(NSString *)email
                  displayName:(nullable NSString *)displayName
                    avatarURL:(nullable NSURL *)avatarURL;

POSRX_INIT_UNAVAILABLE

@end

NS_ASSUME_NONNULL_END
