//
//  SODAppDelegate.m
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 08.03.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import "SODAppDelegate.h"
#import "SODAppController.h"

NS_ASSUME_NONNULL_BEGIN

@interface SODAppDelegate ()
@property (nonatomic) RACSubject *openingURLSignal;
@property (nonatomic) SODAppController *appController;
@end

@implementation SODAppDelegate

- (instancetype)init {
    if (self = [super init]) {
        _openingURLSignal = [RACSubject subject];
        _appController = [SODAppController new];
    }
    return self;
}

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)app didFinishLaunchingWithOptions:(nullable NSDictionary *)options {
    [_appController launchWithAppDelegate:self];
    return YES;
}

- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
  sourceApplication:(nullable NSString *)sourceApp
         annotation:(id)annotation {
    // DB URL: db-hypofv40i8oxf72://2/token#access_token=1JR0ISvkeEwAAAAAAABEpT10USZtHjAe9EAY0blzJqv4YlWIqhMrH7CZDqZ3Tj8R&token_type=bearer&uid=99943969
    [_openingURLSignal sendNext:RACTuplePack(app, url, sourceApp, annotation)];
    return YES;
}

@end

NS_ASSUME_NONNULL_END
