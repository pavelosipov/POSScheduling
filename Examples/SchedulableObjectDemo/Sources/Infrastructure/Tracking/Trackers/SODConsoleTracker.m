//
//  SODConsoleTracker.m
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 29.03.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import "SODConsoleTracker.h"
#import "SODLogging.h"

NS_ASSUME_NONNULL_BEGIN

@implementation SODConsoleTracker

#pragma mark SODTracker

- (RACSignal *)track:(id<SODTrackable>)event {
    return [self track:event params:nil];
}

- (RACSignal *)track:(id<SODTrackable>)event params:(nullable NSDictionary *)params {
    POSRX_CHECK(event);
    NSMutableDictionary *optionalParams = [NSMutableDictionary new];
    if (event.params) {
        [optionalParams addEntriesFromDictionary:event.params];
    }
    if (event.message) {
        optionalParams[@"message"] = [event.message stringByReplacingOccurrencesOfString:@"\"" withString:@"'"];
    }
    NSMutableString *paramsString = [NSMutableString new];
    [optionalParams enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
        [paramsString appendFormat:@" %@=\"%@\"", key, value];
    }];
    DDLogInfo(@"name=\"%@\"%@", [self p_nameForEvent:event], paramsString);
    return [RACSignal empty];
}


- (NSString *)p_nameForEvent:(id<SODTrackable>)event {
    NSMutableString *name = [NSMutableString stringWithString:(event.type == SODTrackableTypeEvent) ? @"event" : @"error"];
    id<SODTrackable> currentTrackable = event;
    while (currentTrackable) {
        [name appendFormat:@".%@", currentTrackable.name.lowercaseString];
        for (NSString *tag in currentTrackable.tags) {
            [name appendFormat:@".%@", tag.lowercaseString];
        }
        currentTrackable = currentTrackable.underlyingTrackable;
    }
    [name appendString:@"_val"];
    return name;
}

//- (void)trackTimingWithType:(SODTrackerEventType)type
//               timeInterval:(NSTimeInterval)interval
//                       name:(NSString *)name
//                      label:(NSString *)label {
//    POSRX_CHECK(name);
//    NSMutableDictionary *params = [NSMutableDictionary new];
//    NSNumberFormatter *formatter = [NSNumberFormatter new];
//    formatter.numberStyle = NSNumberFormatterDecimalStyle;
//    formatter.roundingMode = NSNumberFormatterRoundHalfUp;
//    formatter.minimumFractionDigits = 3;
//    formatter.maximumFractionDigits = 3;
//    if (label) {
//        params[@"action.label"] = label;
//    }
//    params[@"time"] = [formatter stringFromNumber:@(interval)];
//    NSMutableString *paramsString = [NSMutableString new];
//    [params enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
//        [paramsString appendFormat:@" %@=\"%@\"", key, value];
//    }];
//    DDLogInfo(@"action.type=\"%@\" action.name=\"%@\"%@", SODStringFromTrackerEventType(type), name, paramsString);
//}

@end

NS_ASSUME_NONNULL_END
