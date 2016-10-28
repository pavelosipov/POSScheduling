//
//  SODEnvironment.h
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 30.03.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import <POSRx/POSRx.h>

NS_ASSUME_NONNULL_BEGIN

/// Provides general information about application.
@protocol SODEnvironment <NSObject>

/// Full version of the executable (e.g. "1.0.0.2682 Alpha")
@property (nonatomic, readonly) NSString *fullVersion;

/// User Agent of the executable.
@property (nonatomic, readonly) NSString *userAgent;

@end

@interface SODEnvironment : NSObject <SODEnvironment>

/// @brief The designated initializer.
/// @param bundle Mandatory bunadle of the current executable.
- (instancetype)initWithBundle:(NSBundle *)bundle;

POSRX_INIT_UNAVAILABLE

@end

/// @brief Determines is app executing in debug mode.
/// @return YES if app is executing in debug mode.
FOUNDATION_EXTERN BOOL SODIsDebugMode();

NS_ASSUME_NONNULL_END
