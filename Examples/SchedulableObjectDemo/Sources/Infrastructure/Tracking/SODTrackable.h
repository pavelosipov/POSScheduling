//
//  SODTrackable.h
//  SchedulableObjectDemo
//
//  Created by Pavel Osipov on 22.01.16.
//  Copyright (c) 2016 Pavel Osipov. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSInteger, SODTrackableType) {
    SODTrackableTypeEvent    = 1 << 0,
    SODTrackableTypeError    = 1 << 1,
    SODTrackableTypeIncident = 1 << 2
};

/// Represents object, which can be tracked in the tracking services.
@protocol SODTrackable <NSObject>

/// Type of event instance.
@property (nonatomic, readonly) SODTrackableType type;

/// Unique human-readable identifier of the event in the tracking system.
@property (nonatomic, readonly) NSString *name;

/// Tags that help distinguish events with the same name.
@property (nonatomic, readonly, nullable) NSArray<NSString *> *tags;

/// Unstructured human-readable description of the event.
@property (nonatomic, readonly, nullable) NSString *message;

/// Unique identifier of the current instance of the event.
@property (nonatomic, readonly, nullable) NSString *trackingIdentifier;

/// Minimal time in seconds between events with the same name and tags.
@property (nonatomic, readonly, nullable) NSNumber *rateLimit;

/// @brief Additional event parameters.
/// @discussion Values will be be represented as text using [NSObject description]
///             method. The only exception is NSDictionary. Pairs of the dictionary
///             will be used to fill properties of the trackable event instead of the
///             dictionary text representation.
@property (nonatomic, readonly, nullable) NSDictionary<NSString *, id<NSObject>> *params;

/// Subevent
@property (nonatomic, readonly, nullable) id<SODTrackable> underlyingTrackable;

@end

NS_INLINE NSString *SODGenerateTrackableIdentifier() {
    CFUUIDRef UUID = CFUUIDCreate(NULL);
    NSString *UUIDString = (__bridge_transfer NSString *)CFUUIDCreateString(NULL, UUID);
    CFRelease(UUID);
    return UUIDString;
}

NS_INLINE NSString *SODGenerateTrackableName(id<SODTrackable> event) {
    NSString *prefix = (event.type == SODTrackableTypeEvent) ? @"event" : @"error";
    NSMutableString *result = [NSMutableString stringWithFormat:@"%@_%@", prefix, event.name];
    for (NSString *tag in event.tags) {
        [result appendFormat:@"_%@", tag];
    }
    return [result lowercaseString];
}

NS_ASSUME_NONNULL_END
