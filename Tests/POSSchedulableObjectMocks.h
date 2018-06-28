//
//  POSSchedulableObjectMocks.h
//  POSScheduling
//
//  Created by Pavel Osipov on 25.05.15.
//  Copyright © 2015 Pavel Osipov. All rights reserved.
//

#import <POSScheduling/POSScheduling.h>

@protocol Empty <NSObject>
@end

@interface EmptyMock : NSObject
@end

@protocol TestingA <NSObject>
- (void)a;
@end

@interface TestA : NSObject <TestingA>
@end

@protocol SafeProtocol <NSObject>
- (void)safeMethod;
@end

@interface SchedulableObject : POSSchedulableObject <SafeProtocol>

- (CGSize)preferedSize;

- (RACSignal<NSNumber *> *)unsafeMethod;

- (RACSignal<NSNumber *> *)unsafeMethodWithArg:(NSNumber *)value;

- (RACSignal<NSNumber *> *)unsafeMethodWithArg1:(NSNumber *)arg1
                                           arg2:(NSNumber *)arg2
                                           arg3:(NSNumber *)arg3
                                           arg4:(NSNumber *)arg4
                                           arg5:(NSNumber *)arg5;

@end
