//
//  SODAccount.h
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 02.06.16.
//  Copyright © 2016 Pavel Osipov. All rights reserved.
//

#import "SODCloudTypes.h"

NS_ASSUME_NONNULL_BEGIN

@class SODCredentials;

/// Represents account in the Cloud service.
@interface SODAccount : NSObject <NSCoding>

/// Type of the Cloud service.
@property (nonatomic, readonly) SODCloudType cloudType;

/// Uniquely identifies account in the cloud service.
@property (nonatomic, readonly) NSString *ID;

/// OAuth credentials.
@property (nonatomic, readonly, nullable) SODCredentials *credentials;

/// The designated initializer.
- (instancetype)initWithCloudType:(SODCloudType)cloudType
                               ID:(NSString *)ID
                      credentials:(nullable SODCredentials *)credentials;

/// Hidding deadly initializers.
POSRX_INIT_UNAVAILABLE

@end

NS_ASSUME_NONNULL_END
