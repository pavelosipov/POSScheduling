//
//  NSObject+POSScheduling.m
//  POSScheduling
//
//  Created by p.osipov on 28/06/2018.
//  Copyright © 2018 Pavel Osipov. All rights reserved.
//

#import "NSObject+POSScheduling.h"

#import <Aspects/Aspects.h>
#import <POSErrorHandling/POSErrorHandling.h>
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

static char kPOSSchedulerQueueKey;

NS_INLINE RACScheduler * _Nullable POSCurrentScheduler() {
    RACScheduler *queueScheduler = (__bridge RACScheduler *)dispatch_get_specific(&kPOSSchedulerQueueKey);
    return queueScheduler ?: [RACScheduler currentScheduler];
}

typedef void (^POSSelectorEnumerationBlock)(SEL selector, POSSelectorAttributes attributes);
static void pos_enumerateSelectors(Class aClass, POSSelectorEnumerationBlock block);

static BOOL pos_isTechnicalSelector(SEL selector);
static BOOL pos_isHooksIncompatibleSelector(Class aClass, SEL selector);

#pragma mark -

@implementation NSObject (POSScheduling)

- (NSInvocation *)pos_invocationForSelector:(SEL)selector {
    POS_CHECK(selector != NULL);
    NSMethodSignature *methodSignature = [self methodSignatureForSelector:selector];
    POS_CHECK_EX(methodSignature != nil, @"%@ does not respond to %@", self, NSStringFromSelector(selector));
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    invocation.selector = selector;
    invocation.target = self;
    return invocation;
}

- (RACSignal *)pos_deallocSignalOnScheduler:(RACScheduler *)scheduler {
    RACSignal *signal = objc_getAssociatedObject(self, _cmd);
    if (signal != nil) {
        return signal;
    }
    RACReplaySubject *subject = [RACReplaySubject subject];
    [self.rac_deallocDisposable addDisposable:[RACDisposable disposableWithBlock:^{
        RACScheduler *currentScheduler = POSCurrentScheduler();
        if (currentScheduler == scheduler) {
            [subject sendCompleted];
        } else {
            [scheduler schedule:^{
                [subject sendCompleted];
            }];
        }
    }]];
    objc_setAssociatedObject(self, _cmd, subject, OBJC_ASSOCIATION_RETAIN);
    return subject;
}

- (void)pos_protectForScheduler:(RACTargetQueueScheduler *)scheduler
                      predicate:(nullable POSSafetyPredicate)outerPredicate {
    __auto_type mandatoryPredicate = ^BOOL(SEL selector, POSSelectorAttributes attributes) {
        return !(pos_isTechnicalSelector(selector) ||
                 pos_isHooksIncompatibleSelector(self.class, selector) ||
                 pos_classContainsSelector(NSObject.class, selector) ||
                 attributes.isAtomicProperty);
    };
    [self p_pos_protectForScheduler:scheduler predicate:^BOOL(SEL selector, POSSelectorAttributes attributes) {
        if (!mandatoryPredicate(selector, attributes)) {
            return NO;
        }
        return outerPredicate != nil ? outerPredicate(selector, attributes) : YES;
    }];
}

- (void)p_pos_protectForScheduler:(RACTargetQueueScheduler *)scheduler
                        predicate:(POSSafetyPredicate)predicate {
    POS_CHECK(scheduler);
    dispatch_queue_set_specific(scheduler.queue, &kPOSSchedulerQueueKey, (__bridge void *)scheduler, NULL);
    pos_enumerateSelectors(self.class, ^(SEL selector, POSSelectorAttributes attributes) {
        if (!predicate(selector, attributes)) return;
        NSError *error;
        @weakify(self);
        id hooked = [(id)self
            aspect_hookSelector:selector
            withOptions:AspectPositionBefore
            usingBlock:^(id<AspectInfo> aspectInfo) {
                @strongify(self);
                RACScheduler *currentScheduler = POSCurrentScheduler();
                POS_CHECK_EX(currentScheduler == scheduler,
                             @"Incorrect scheduler to invoke '%@'.", NSStringFromSelector(selector));
            }
            error:&error];
        POS_CHECK_EX(hooked, error.localizedDescription);
    });
}

@end

#pragma mark - Public Functions

BOOL pos_protocolContainsSelector(Protocol *aProtocol, SEL selector, BOOL isRequiredMethod, BOOL isInstanceMethod) {
    struct objc_method_description method = protocol_getMethodDescription(aProtocol, selector, YES, YES);
    return !(method.name == NULL && method.types == NULL);
}

BOOL pos_classContainsSelector(Class aClass, SEL selector) {
    return class_getInstanceMethod(aClass, selector) != nil;
}

#pragma mark - Private Functions

void pos_enumerateSelectors(Class aClass, POSSelectorEnumerationBlock block) {
    Class base = class_getSuperclass(aClass);
    if (base != nil) {
        pos_enumerateSelectors(base, block);
    }
    unsigned int methodCount = 0;
    Method *methods = class_copyMethodList(aClass, &methodCount);
    for (unsigned int i = 0; i < methodCount; ++i) {
        SEL selector = method_getName(methods[i]);
        objc_property_t property = class_getProperty(aClass, NSStringFromSelector(selector).UTF8String);
        block(selector, (POSSelectorAttributes) {
            .isAtomicProperty = (property && !property_copyAttributeValue(property, "N"))
        });
    }
    free(methods);
}

BOOL pos_isTechnicalSelector(SEL selector) {
    NSString *selectorName = NSStringFromSelector(selector);
    return ([selectorName rangeOfString:@"init"].location != NSNotFound ||
            [selectorName rangeOfString:@".cxx_destruct"].location != NSNotFound ||
            [selectorName rangeOfString:@"aspects__"].location != NSNotFound);
}

BOOL pos_isHooksIncompatibleSelector(Class aClass, SEL selector) {
#if !defined(__arm64__)
    // Prevent adding hooks on 32 bit arch for methods which return C structs.
    // Additional info is here https://github.com/steipete/Aspects/issues/64
    Method method = class_getInstanceMethod(aClass, selector);
    const char *encoding = method_getTypeEncoding(method);
    BOOL methodReturnsStructValue = encoding[0] == _C_STRUCT_B;
    if (methodReturnsStructValue) {
        return YES;
    }
#endif
    return NO;
}

NS_ASSUME_NONNULL_END
