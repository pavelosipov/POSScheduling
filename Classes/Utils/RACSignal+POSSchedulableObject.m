//
//  RACSignal+POSSchedulableObject.m
//  POSSchedulableObject
//
//  Created by Pavel Osipov on 13.06.16.
//  Copyright © 2016 Pavel Osipov. All rights reserved.
//

#import "RACSignal+POSSchedulableObject.h"

@implementation RACSignal (POSSchedulableObject)

- (id)pos_await {
    __block id result = nil;
    __block BOOL done = NO;
    [[self take:1] subscribeNext:^(id value) {
        result = value;
        done = YES;
    } error:^(NSError *e) {
        done = YES;
    }];
    if (result) {
        return result;
    }
    NSRunLoop *runLoop = NSRunLoop.currentRunLoop;
    while ([runLoop runMode:NSDefaultRunLoopMode beforeDate:NSDate.date] && !done) {}
    return result;
}

@end
