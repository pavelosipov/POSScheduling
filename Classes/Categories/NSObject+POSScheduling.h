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

@end

#pragma mark -

FOUNDATION_EXTERN BOOL pos_classContainsSelector(Class aClass, SEL selector);
FOUNDATION_EXTERN BOOL pos_protocolContainsSelector(Protocol *aProtocol, SEL selector, BOOL isRequiredMethod, BOOL isInstanceMethod);

NS_ASSUME_NONNULL_END
