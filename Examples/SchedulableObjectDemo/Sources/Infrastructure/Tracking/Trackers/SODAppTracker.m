//
//  SODAppTracker.m
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 28.01.16.
//  Copyright © 2016 Pavel Osipov. All rights reserved.
//

#import "SODAppTracker.h"
#import "SODEnvironment.h"
#import "SODKeyedStore.h"
#import "SODLogging.h"
#import "SODTrackableEvent.h"
#import "NSError+SODTrackable.h"

NS_ASSUME_NONNULL_BEGIN

@interface SODAppTracker ()
@property (nonatomic, nullable) NSDictionary *appParams;
@property (nonatomic, readonly) NSString *sessionID;
@property (nonatomic, readonly) id<SODEnvironment> environment;
@property (nonatomic, readonly) id<SODKeyedStore> persistentStore;
@property (nonatomic, readonly) NSMutableArray<id<SODTracker>> *services;
@property (nonatomic, readonly) NSMutableDictionary<NSString *, NSDate *> *limitedEvents;
@end

@implementation SODAppTracker

- (instancetype)initWithScheduler:(RACTargetQueueScheduler *)scheduler
                            store:(id<SODKeyedStore>)store
                      environment:(id<SODEnvironment>)environment {
    POSRX_CHECK(scheduler);
    POSRX_CHECK(store);
    POSRX_CHECK(environment);
    if (self = [super initWithScheduler:scheduler]) {
        _sessionID = SODGenerateTrackableIdentifier();
        _environment = environment;
        _persistentStore = store;
        _services = [NSMutableArray new];
        _limitedEvents = [NSMutableDictionary new];
    }
    return self;
}

#pragma mark Public

- (void)activate {
    [self p_setupLoggers];
    [self p_setupAppID];
}

- (void)addService:(id<SODTracker>)service {
    POSRX_CHECK(service);
    [_services addObject:service];
}

#pragma mark Tracker

- (RACSignal *)track:(id<SODTrackable>)event {
    return [self track:event params:_appParams];
}

- (RACSignal *)track:(id<SODTrackable>)event params:(nullable NSDictionary *)params {
    POSRX_CHECK(event);
    if (![self p_shouldTrackEvent:event]) {
        return [RACSignal empty];
    }
    [self p_rememberTrackDateForEvent:event];
    return [self p_broadcastEvent:event params:params];
}

#pragma mark Private

- (BOOL)p_shouldTrackEvent:(id<SODTrackable>)event {
    NSNumber *rateLimit = event.rateLimit;
    if (!rateLimit) {
        return YES;
    }
    NSDate *lastTrackDate = _limitedEvents[[self.class p_fullNameForEvent:event]];
    if (!lastTrackDate) {
        return YES;
    }
    return [[NSDate date] timeIntervalSinceDate:lastTrackDate] > rateLimit.floatValue;
}

- (RACSignal *)p_broadcastEvent:(id<SODTrackable>)event params:(nullable NSDictionary *)params {
    NSDictionary *allParams = [NSDictionary posrx_merge:_appParams with:params];
    NSMutableArray *signals = [NSMutableArray new];
    for (id<SODTracker> service in _services) {
        [signals addObject:[service track:event params:allParams]];
    }
    return [[[RACSignal combineLatest:signals] ignoreValues] replayLast];
}

- (void)p_rememberTrackDateForEvent:(id<SODTrackable>)event {
    if (event.rateLimit) {
        _limitedEvents[[self.class p_fullNameForEvent:event]] = [NSDate date];
    }
}

+ (NSString *)p_fullNameForEvent:(id<SODTrackable>)event {
    NSMutableString *fullName = [NSMutableString stringWithString:event.name];
    for (NSString *tag in event.tags) {
        [fullName appendString:tag];
    }
    return fullName;
}

- (void)p_setupAppID {
    static NSString *kAppIDKey = @"com.github.pavelosipov.SchedulableObjectDemo.AppID";
    NSString *appID = [_persistentStore objectForKey:kAppIDKey];
    if (!appID) {
        appID = SODGenerateTrackableIdentifier();
        NSError *error = nil;
        [_persistentStore setObject:appID forKey:kAppIDKey error:&error];
        if (!error) {
            [self track:[SODTrackableEvent eventNamed:@"new_user"]];
        } else {
            [self track:[NSError sod_systemErrorWithReason:error]];
        }
    }
    self.appParams = @{@"profile.appID": appID,
                       @"profile.sessionID": _sessionID};
}

- (void)p_setupLoggers {
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
}

@end

NS_ASSUME_NONNULL_END
