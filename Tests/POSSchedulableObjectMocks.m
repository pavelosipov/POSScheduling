//
//  POSSchedulableObjectMocks.m
//  POSScheduling
//
//  Created by Pavel Osipov on 25.05.15.
//  Copyright © 2015 Pavel Osipov. All rights reserved.
//

#import "POSSchedulableObjectMocks.h"

@implementation EmptyMock
@end

@implementation TestA
- (void)a {}
@end

@implementation SchedulableObject

- (void)safeMethod {}

- (CGSize)preferedSize {
    return CGSizeMake(0.0, 0.0);
}

- (RACSignal<NSNumber *> *)unsafeMethod {
    return [RACSignal return:@777];
}

- (RACSignal<NSNumber *> *)unsafeMethodWithArg:(NSNumber *)value {
    return [RACSignal return:value];
}

- (RACSignal<NSNumber *> *)unsafeMethodWithArg1:(NSNumber *)arg1
                                           arg2:(NSNumber *)arg2
                                           arg3:(NSNumber *)arg3
                                           arg4:(NSNumber *)arg4
                                           arg5:(NSNumber *)arg5 {
    return [RACSignal return:[RACFiveTuple pack:arg1 :arg2 :arg3 :arg4 :arg5]];
}

@end
