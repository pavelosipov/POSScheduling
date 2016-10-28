//
//  POSSchedulableObject.m
//  POSSchedulableObject
//
//  Created by Pavel Osipov on 11.01.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import "POSSchedulableObject.h"
#import "NSException+POSSchedulableObject.h"
#import "RACTargetQueueScheduler+POSSchedulableObject.h"
#import <Aspects/Aspects.h>
#import <objc/runtime.h>

#ifndef POS_ENABLE_RUNTIME_CHECKS
#   ifdef DEBUG
#       define POS_ENABLE_RUNTIME_CHECKS 1
#   endif
#endif

static char kPOSQueueSchedulerKey;

@interface POSScheduleProtectionOptions ()
@property (nonatomic) RACSequence *includedSelectors;
@property (nonatomic) RACSequence *excludedSelectors;
@end

@implementation POSScheduleProtectionOptions

+ (instancetype)defaultOptionsForClass:(Class)aClass {
    return [self.class include:[POSSchedulableObject selectorsForClass:aClass nonatomicOnly:YES predicate:nil]
                       exclude:[POSSchedulableObject selectorsForClass:[NSObject class]]];
}

+ (instancetype)include:(RACSequence *)includes exclude:(RACSequence *)excludes {
    POSScheduleProtectionOptions *options = [[POSScheduleProtectionOptions alloc] init];
    options.includedSelectors = includes;
    options.excludedSelectors = excludes;
    return options;
}

- (instancetype)include:(RACSequence *)includes {
    _includedSelectors = _includedSelectors ? [_includedSelectors concat:includes] : includes;
    return self;
}

- (instancetype)exclude:(RACSequence *)excludes {
    _excludedSelectors = _excludedSelectors ? [_excludedSelectors concat:excludes] : excludes;
    return self;
}

@end

@interface POSSchedulableObject ()
@property (nonatomic) RACTargetQueueScheduler *scheduler;
@end

@implementation POSSchedulableObject

- (instancetype)init {
    return [self initWithScheduler:[RACTargetQueueScheduler pos_mainThreadScheduler]];
}

- (instancetype)initWithScheduler:(RACTargetQueueScheduler *)scheduler {
    return [self initWithScheduler:scheduler options:nil];
}

- (instancetype)initWithScheduler:(RACTargetQueueScheduler *)scheduler options:(POSScheduleProtectionOptions *)options {
    POS_CHECK(scheduler);
    if (self = [super init]) {
#if POS_ENABLE_RUNTIME_CHECKS
        [self.class
         protect:self
         forScheduler:scheduler
         options:(options ?:
                  [[POSScheduleProtectionOptions
                    defaultOptionsForClass:[self class]]
                   exclude:[self.class selectorsForProtocol:@protocol(POSSchedulable)]])];
#endif
        _scheduler = scheduler;
    }
    return self;
}

- (RACSignal *)schedule {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        return [self.scheduler schedule:^{
            [subscriber sendNext:self];
            [subscriber sendCompleted];
        }];
    }];
}

- (void)scheduleBlock:(void (^)(id _Nonnull))block {
    POS_CHECK(block);
    [self.scheduler schedule:^{
        block(self);
    }];
}

#pragma mark - POSSchedulableObject

+ (BOOL)protect:(id<NSObject>)object
   forScheduler:(RACTargetQueueScheduler *)scheduler {
    return [self.class protect:object
                  forScheduler:scheduler
                       options:[POSScheduleProtectionOptions defaultOptionsForClass:[object class]]];
}

+ (BOOL)protect:(id<NSObject>)object
   forScheduler:(RACTargetQueueScheduler *)scheduler
        options:(POSScheduleProtectionOptions *)options {
    if (!options.includedSelectors) {
        return YES;
    }
    dispatch_queue_set_specific(scheduler.queue, &kPOSQueueSchedulerKey, (__bridge void *)scheduler, NULL);
    NSMutableArray *protectingSelectors = [[options.includedSelectors array] mutableCopy];
    if (options.excludedSelectors) {
        [protectingSelectors removeObjectsInArray:[options.excludedSelectors array]];
    }
    for (NSValue *selectorValue in protectingSelectors) {
        SEL selector = (SEL)[selectorValue pointerValue];
        NSString *selectorName = NSStringFromSelector(selector);
        if ([selectorName rangeOfString:@"init"].location != NSNotFound ||
            [selectorName rangeOfString:@".cxx_destruct"].location != NSNotFound ||
            [selectorName rangeOfString:@"aspects__"].location != NSNotFound) {
            continue;
        }
#if !defined(__arm64__)
        // Prevent adding hooks on 32 bit arch for methods which return C structs.
        // Additional info is here https://github.com/steipete/Aspects/issues/64
        Method method = class_getInstanceMethod(object.class, selector);
        const char *encoding = method_getTypeEncoding(method);
        BOOL methodReturnsStructValue = encoding[0] == _C_STRUCT_B;
        if (methodReturnsStructValue) {
            continue;
        }
#endif
        NSError *error;
        @weakify(object);
        id hooked = [(id)object aspect_hookSelector:selector withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo> aspectInfo) {
            @strongify(object);
            RACScheduler *currentScheduler = (__bridge RACScheduler *)dispatch_get_specific(&kPOSQueueSchedulerKey);
            if (!currentScheduler) {
                currentScheduler = [RACScheduler currentScheduler];
            }
            if ([aspectInfo instance] == object && currentScheduler != scheduler) {
                @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                               reason:[NSString stringWithFormat:@"Incorrect scheduler to invoke '%@'.", selectorName]
                                             userInfo:nil];
            }
        } error:&error];
        if (!hooked) {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                           reason:[error localizedDescription]
                                         userInfo:nil];
        }
    }
    return YES;
}

+ (RACSequence *)selectorsForClass:(Class)aClass {
    return [[self.class p_selectorsSetForClass:aClass nonatomicOnly:NO predicate:nil] rac_sequence];
}

+ (RACSequence *)selectorsForClass:(Class)aClass
                     nonatomicOnly:(BOOL)nonatomicOnly
                         predicate:(BOOL (^ _Nullable)(SEL))predicate {
    return [[self.class p_selectorsSetForClass:aClass nonatomicOnly:nonatomicOnly predicate:predicate] rac_sequence];
}

+ (RACSequence *)selectorsForProtocol:(Protocol *)aProtocol {
    return [[self.class p_selectorsSetForProtocol:aProtocol] rac_sequence];
}

#pragma mark - Private

+ (NSSet *)p_selectorsSetForClass:(Class)aClass
                    nonatomicOnly:(BOOL)nonatomicOnly
                        predicate:(BOOL (^ __nullable)(SEL))predicate {
    Class base = class_getSuperclass(aClass);
    NSSet *baseSelectors =
    base ? [self p_selectorsSetForClass:base nonatomicOnly:nonatomicOnly predicate:predicate] : [NSSet set];
    unsigned int methodCount = 0;
    Method *methods = class_copyMethodList(aClass, &methodCount);
    NSMutableSet *selectors = [NSMutableSet setWithCapacity:methodCount];
    for (unsigned int i = 0; i < methodCount; ++i) {
        SEL selector = method_getName(methods[i]);
        if (nonatomicOnly) {
            objc_property_t property = class_getProperty(
                                                         aClass,
                                                         NSStringFromSelector(selector).UTF8String);
            if (property && !property_copyAttributeValue(property, "N")) {
                continue;
            }
        }
        if (predicate && !predicate(selector)) {
            continue;
        }
        [selectors addObject:[NSValue valueWithPointer:method_getName(methods[i])]];
    }
    free(methods);
    [selectors unionSet:baseSelectors];
    return selectors;
}

+ (NSSet *)p_selectorsSetForProtocol:(Protocol *)aProtocol {
    unsigned int methodCount = 0;
    NSMutableSet *selectors = [NSMutableSet setWithCapacity:methodCount];
    struct objc_method_description *methods = protocol_copyMethodDescriptionList(aProtocol, YES, YES, &methodCount);
    for (unsigned int i = 0; i < methodCount; ++i) {
        [selectors addObject:[NSValue valueWithPointer:methods[i].name]];
    }
    free(methods);
    return selectors;
}

@end
