//
//  NSObject+POSScheduling.h
//  POSScheduling
//
//  Created by p.osipov on 28/06/2018.
//  Copyright © 2018 Pavel Osipov. All rights reserved.
//

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wstrict-prototypes"
#   import <ReactiveObjC/ReactiveObjC.h>
#pragma clang diagnostic pop

#ifndef POS_ENABLE_RUNTIME_CHECKS
#   ifdef DEBUG
#       define POS_ENABLE_RUNTIME_CHECKS 1
#   endif
#endif

NS_ASSUME_NONNULL_BEGIN

// Represents some properties of the selector.
typedef struct POSSelectorAttributes {
    BOOL isAtomicProperty;
} POSSelectorAttributes;

// Block for filtering protecting selectors.
typedef BOOL (^POSSafetyPredicate)(SEL selector, POSSelectorAttributes attributes);

@interface NSObject (POSScheduling)

- (void)pos_protectForScheduler:(RACTargetQueueScheduler *)scheduler
                      predicate:(nullable POSSafetyPredicate)predicate;

- (NSInvocation *)pos_invocationForSelector:(SEL)selector;

- (RACSignal *)pos_deallocSignalOnScheduler:(RACScheduler *)scheduler;

@end

#pragma mark -

FOUNDATION_EXPORT RACScheduler * _Nullable POSCurrentScheduler(void);

FOUNDATION_EXPORT BOOL pos_classContainsSelector(Class aClass, SEL selector);
FOUNDATION_EXPORT BOOL pos_protocolContainsSelector(Protocol *aProtocol, SEL selector, BOOL isRequiredMethod, BOOL isInstanceMethod);

NS_ASSUME_NONNULL_END

