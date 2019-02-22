//
//  POSTask.m
//  POSScheduling
//
//  Created by Pavel Osipov on 26.01.15.
//  Copyright © 2015 Pavel Osipov. All rights reserved.
//

#import "POSTask.h"
#import "RACTargetQueueScheduler+POSScheduling.h"

NS_ASSUME_NONNULL_BEGIN

@interface POSTask ()
@property (nonatomic, copy, readonly) RACSignal *(^executionBlock)(POSTask *task);
@property (nonatomic, weak) id<POSTaskExecutor> executor;
@property (nonatomic) RACSignal *executing;
@property (nonatomic) RACSubject *sourceSignals;
@property (nonatomic, nullable) RACSignal *sourceSignal;
@property (nonatomic, nullable) RACDisposable *sourceSignalDisposable;
@property (nonatomic, nullable) RACDisposable *sourceSignalCleanupDisposable;
@property (nonatomic) RACSignal<NSError *> *errors;
@property (nonatomic) RACSubject<NSError *> *extraErrors;
@property (nonatomic) RACSignal *values;
@end

@implementation POSTask

- (instancetype)initWithExecutionBlock:(RACSignal<id> *(^)(id))executionBlock
                             scheduler:(RACTargetQueueScheduler *)scheduler
                              executor:(nullable id<POSTaskExecutor>)executor {
    POS_CHECK(scheduler);
    POS_CHECK(executionBlock);
    if (self = [super initWithScheduler:scheduler safetyPredicate:nil]) {
        _executionBlock = [executionBlock copy];
        _executor = executor;
        
        _sourceSignals = [RACSubject subject];
        
        RACSignal *executionSignal = [[_sourceSignals startWith:nil]
                                      takeUntil:[self rac_willDeallocSignal]];

        _executing = [[executionSignal map:^(RACSignal *signal) {
            return @(signal != nil);
        }] replayLast];
        
        _values = [[[executionSignal map:^id(RACSignal *signal) {
            return [signal catchTo:[RACSignal empty]];
        }] replayLast] switchToLatest];

        _extraErrors = [RACSubject subject];
        RACSignal *executionErrors = [[[executionSignal map:^id(RACSignal *signal) {
            return [[signal ignoreValues] catch:^(NSError *error) {
                return [RACSignal return:error];
            }];
        }] replayLast] switchToLatest];
        _errors = [[RACSignal
                    merge:@[_extraErrors, executionErrors]]
                    takeUntil:[self rac_willDeallocSignal]];
    }
    return self;
}

+ (instancetype)createTask:(RACSignal<id> *(^)(id task))executionBlock {
    return [self createTask:executionBlock scheduler:nil executor:nil];
}

+ (instancetype)createTask:(RACSignal<id> *(^)(id task))executionBlock
                 scheduler:(nullable RACTargetQueueScheduler *)scheduler {
    return [self createTask:executionBlock scheduler:scheduler executor:nil];
}

+ (instancetype)createTask:(RACSignal<id> *(^)(id task))executionBlock
                 scheduler:(nullable RACTargetQueueScheduler *)scheduler
                  executor:(nullable id<POSTaskExecutor>)executor {
    return [[self alloc] initWithExecutionBlock:executionBlock
                                      scheduler:(scheduler ?: [RACTargetQueueScheduler pos_mainThreadScheduler])
                                       executor:executor];
}

#pragma mark POSTask

- (BOOL)isExecuting {
    return _sourceSignal != nil;
}

- (RACSignal *)execute {
    if (_executor) {
        return [_executor submitTask:self];
    } else {
        return [self p_executeNow];
    }
}

- (void)cancel {
    [self cancelWithError:nil];
}

- (void)cancelWithError:(nullable NSError *)error {
    [_extraErrors sendNext:error];
    if (_executor) {
        [_executor reclaimTask:self error:error];
    } else {
        [self p_cancelNow];
    }
}

#pragma mark Properties

- (void)setSourceSignal:(nullable RACSignal *)sourceSignal {
    _sourceSignal = sourceSignal;
    [_sourceSignals sendNext:sourceSignal];
}

#pragma mark Private

- (RACSignal *)p_executeNow {
    NSParameterAssert(![self isExecuting]);
    if ([self isExecuting]) {
        return _sourceSignal;
    }
    RACSignal *signal = self.executionBlock(self);
    POS_CHECK(signal);
    RACMulticastConnection *connection = [[signal
        subscribeOn:self.scheduler]
        multicast:RACReplaySubject.subject];
    RACSignal *sourceSignal = [[connection.signal deliverOn:self.scheduler]
                               takeUntil:self.rac_willDeallocSignal];
    self.sourceSignal = sourceSignal;
    @weakify(self);
    self.sourceSignalCleanupDisposable = [self.sourceSignal subscribeError:^(NSError *error) {
        @strongify(self);
        self.sourceSignal = nil;
    } completed:^{
        @strongify(self);
        self.sourceSignal = nil;
    }];
    self.sourceSignalDisposable = [connection connect];
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [sourceSignal subscribe:subscriber];
        return [RACDisposable disposableWithBlock:^{
            [self cancel];
        }];
    }];
}

- (void)p_cancelNow {
    if ([self isExecuting]) {
        [_sourceSignalDisposable dispose];
        [_sourceSignalCleanupDisposable dispose];
        self.sourceSignalCleanupDisposable = nil;
        self.sourceSignalDisposable = nil;
        self.sourceSignal = nil;
    }
}

@end

#pragma mark -

@implementation POSBlockExecutor

- (RACSignal *)submitExecutionBlock:(RACSignal *(^)(id _))executionBlock {
    POS_CHECK([self conformsToProtocol:@protocol(POSTaskExecutor)]);
    id<POSTaskExecutor> taskExecutor = (id)self;
    return [taskExecutor submitTask:[POSTask createTask:executionBlock scheduler:self.scheduler]];
}

@end

#pragma mark -

@implementation POSDirectTaskExecutor

- (RACSignal *)submitTask:(POSTask *)task {
    return [task p_executeNow];
}

- (void)reclaimTask:(POSTask *)task error:(nullable NSError *)error {
    [task p_cancelNow];
}

@end

NS_ASSUME_NONNULL_END
