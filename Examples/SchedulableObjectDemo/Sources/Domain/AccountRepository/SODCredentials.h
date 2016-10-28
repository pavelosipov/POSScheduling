//
//  SODCredentials.h
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 02.06.16.
//  Copyright © 2016 Pavel Osipov. All rights reserved.
//

#import <POSRx/POSRx.h>

NS_ASSUME_NONNULL_BEGIN

@interface SODCredentials : NSObject <NSCoding>

@property (nonatomic, readonly) NSString *accessToken;

- (instancetype)initWithAccessToken:(NSString *)accessToken;

POSRX_INIT_UNAVAILABLE

@end

NS_ASSUME_NONNULL_END
