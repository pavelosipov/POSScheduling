//
//  SODEnvironment.m
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 30.03.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import "SODEnvironment.h"
#import "UIDevice+SODInfrastructure.h"

NS_ASSUME_NONNULL_BEGIN

@interface SODEnvironment ()
@property (nonatomic, readonly) NSBundle *bundle;
@end

@implementation SODEnvironment

- (instancetype)initWithBundle:(NSBundle *)bundle {
    POSRX_CHECK(bundle);
    if (self = [super init]) {
        _bundle = bundle;
    }
    return self;
}

- (NSString *)fullVersion {
    NSString* version = _bundle.infoDictionary[@"CFBundleShortVersionString"];
    NSString* buildNumber = nil;
    buildNumber = SODIsDebugMode() ? @"dev" : _bundle.infoDictionary[@"CFBundleVersion"];
    return [NSString stringWithFormat:@"%@.%@%@", version, buildNumber, [self.class p_versionSuffix]];
}

- (NSString *)userAgent {
    NSString *software = [NSString stringWithFormat:@"%@ %@",
                          [UIDevice currentDevice].systemName,
                          [UIDevice currentDevice].systemVersion];
    return [NSString stringWithFormat:@"%@/%@ (%@; %@)",
            _bundle.infoDictionary[@"CFBundleExecutable"],
            [self fullVersion],
            [UIDevice sod_platformName],
            software];
}

#pragma mark - Private

+ (NSString *)p_versionSuffix {
#if defined(ALPHA)
    return @" Alpha";
#elif defined(BETA)
    return @" Beta";
#else
    return @"";
#endif
}

@end

BOOL SODIsDebugMode() {
#ifdef DEBUG
    return YES;
#else
    return NO;
#endif
}

NS_ASSUME_NONNULL_END
