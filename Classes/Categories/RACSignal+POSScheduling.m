//
//  RACSignal+POSScheduling.m
//  POSScheduling
//
//  Created by Pavel Osipov on 13.06.16.
//  Copyright © 2016 Pavel Osipov. All rights reserved.
//

#import "RACSignal+POSScheduling.h"

NS_ASSUME_NONNULL_BEGIN

@implementation RACSignal (POSScheduling)

- (nullable id)pos_await {
    __block id result = nil;
    __block BOOL done = NO;
    [[self take:1] subscribeNext:^(id _Nullable value) {
        result = value;
        done = YES;
    } error:^(NSError *e) {
        done = YES;
    }];
    if (done) {
        return result;
    }
    NSRunLoop *runLoop = NSRunLoop.currentRunLoop;
    while ([runLoop runMode:NSDefaultRunLoopMode beforeDate:NSDate.date] && !done) {}
    return result;
}

@end

NS_ASSUME_NONNULL_END
