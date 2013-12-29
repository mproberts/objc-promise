//
//  Promise.m
//  objc-promise
//
//  Created by Michael Roberts on 2012-10-12.
//  Copyright (c) 2012 Mike Roberts. All rights reserved.
//

#import "Promise.h"
#import "Deferred.h"

@implementation Promise (Private)

- (id)initWithQueue:(dispatch_queue_t)queue
{
    if (self = [super init]) {
        _callbackBindings = [[NSMutableArray alloc] init];
        _state = Incomplete;

        if (queue) {
            _queue = queue;
        }

        _stateLock = [[NSObject alloc] init];
        _result = nil;
    }
    
    return self;
}

- (BOOL)bindOrCallBlock:(bound_block)block
{
    BOOL blockWasBound = NO;
    
    @synchronized (_stateLock) {
        if (_state == Incomplete) {
            [_callbackBindings addObject:[block copy]];
            
            blockWasBound = YES;
        }
    }
    
    if (!blockWasBound) {
        [self executeBlock:block];
    }
    
    return blockWasBound;
}

- (void)executeBlock:(bound_block)block
{
    // dispatch the result asynchronously if a queue is bound
    if (_queue) {
        dispatch_async(_queue, block);
    } else {
        block();
    }
}

- (void)chainTo:(Deferred *)deferred
{
    [self when:^(id result){
        [deferred resolve:result];
    } failed:^(NSError *error){
        [deferred reject:error];
    }];
}

@end

@implementation Promise

@synthesize result = _result, reason = _reason;
@dynamic isResolved, isRejected;

+ (Promise *)resolved:(id)result
{
    Deferred *deferred = [[Deferred alloc] init];
    
    [deferred resolve:result];
    
    return [deferred promise];
}

+ (Promise *)rejected:(NSError *)reason
{
    Deferred *deferred = [[Deferred alloc] init];
    
    [deferred reject:reason];
    
    return [deferred promise];
}

+ (Promise *)chain:(promise_returning_arg_block)firstBlock, ... NS_REQUIRES_NIL_TERMINATION
{
    va_list args;
    va_start(args, firstBlock);
    
    Deferred *chainedResult = [Deferred deferred];
    
    // load each block into the list
    NSMutableArray *eachResultArray = [NSMutableArray array];
    promise_returning_arg_block block = firstBlock;
    
    while (block) {
        [eachResultArray addObject:block];
        
        block = va_arg(args, promise_returning_arg_block);
    }
    
    va_end(args);
    
    // resolve block called from within the chain
    __block resolved_block refResolveBlock = nil;
    resolved_block resolveBlock = ^(id result) {
        if (eachResultArray.count == 0) {
            [chainedResult resolve:result];
        }
        else {
            promise_returning_arg_block nextBlock = [eachResultArray firstObject];
            
            [eachResultArray removeObjectAtIndex:0];
            
            Promise *nextPromise = nextBlock(result);
            
            [nextPromise when:refResolveBlock
                       failed:^(NSError *err) {
                // we're done here, break the chain
                [chainedResult reject:err];
            }];
        }
    };
    
    refResolveBlock = resolveBlock;
    
    // kick off the chain
    resolveBlock(nil);
    
    return [chainedResult promise];
}

- (id)init
{
    return [self initWithQueue:nil];
}

- (BOOL)isResolved
{
    return _state == Resolved;
}

- (BOOL)isRejected
{
    return _state == Rejected;
}

+ (Promise *)or:(NSArray *)promises
{
    NSUInteger count = promises.count;
    __block NSUInteger rejectedCount = 0;
    Deferred *deferred = [[Deferred alloc] init];
    
    // any promise resolves our deferred
    for (Promise *promise in promises) {
        [promise when:^(id result) {
            [deferred resolve:result];
        } failed:^(NSError *error){
            rejectedCount++;
            
            // all promises have resolved, resolve our promise
            if (rejectedCount == count) {
                [deferred reject:error];
            }
        }];
    }
    
    return [deferred promise];
}

+ (Promise *)and:(NSArray *)promises
{
    NSUInteger count = promises.count;
    __block int resolvedCount = 0;
    Deferred *deferred = [[Deferred alloc] init];
    
    // any promise resolves our deferred
    for (Promise *promise in promises) {
        [promise when:^(id result) {
            resolvedCount++;
            
            // all promises have resolved, resolve our promise
            if (resolvedCount == count) {
                [deferred resolve:result];
            }
        } failed:^(NSError *error){
            [deferred reject:error];
        }];
    }
    
    return [deferred promise];
}

- (Promise *)when:(resolved_block)resolvedBlock
{
    __block Promise *this = self;
    
    [this bindOrCallBlock:^{
        if (this.isResolved) {
            resolvedBlock(this.result);
        }
    }];
    
    return this;
}

- (Promise *)failed:(rejected_block)rejectedBlock
{
    __block Promise *this = self;
    
    [this bindOrCallBlock:^{
        if (this.isRejected) {
            rejectedBlock(this.reason);
        }
    }];
    
    return this;
}

- (Promise *)any:(any_block)anyBlock
{
    __block Promise *this = self;
    
    [this bindOrCallBlock:^{
        anyBlock();
    }];
    
    return this;
}

- (Promise *)when:(resolved_block)whenBlock failed:(rejected_block)rejectedBlock
{
    [self when:whenBlock];
    [self failed:rejectedBlock];
    
    return self;
}

- (Promise *)when:(resolved_block)whenBlock failed:(rejected_block)rejectedBlock any:(any_block)anyBlock
{
    [self when:whenBlock];
    [self failed:rejectedBlock];
    [self any:anyBlock];
    
    return self;
}

- (Promise *)on:(dispatch_queue_t)queue
{
    Deferred *deferred = [[Deferred alloc] initWithQueue:queue];
    
    [self chainTo:deferred];
    
    return deferred;
}

- (Promise *)onMainQueue
{
    return [self on:dispatch_get_main_queue()];
}

- (Promise *)timeout:(NSTimeInterval)interval
{
    return [self timeout:interval leeway:0.0];
}

- (Promise *)timeout:(NSTimeInterval)interval leeway:(NSTimeInterval)leeway
{
    Deferred *toTimeout = [[Deferred alloc] initWithQueue:_queue];
    
    [self chainTo:toTimeout];
    
    dispatch_queue_t queue = _queue;
    
    // use the current dispatch queue if no queue is bound
    if (queue == nil) {
        queue = dispatch_get_main_queue();
    }
    
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    
    dispatch_time_t intervalInNanoseconds = (dispatch_time_t)(NSEC_PER_SEC * interval);
    
    void (^eventHandler)(void) = ^{
        dispatch_source_cancel(timer);
        
        [toTimeout reject:[NSError errorWithDomain:@"Timeout" code:100 userInfo:nil]];
    };
    
    dispatch_source_set_timer(timer, dispatch_walltime(NULL, intervalInNanoseconds), intervalInNanoseconds, leeway);
    dispatch_source_set_event_handler(timer, eventHandler);
    dispatch_resume(timer);
    
    return [toTimeout promise];
}

- (Promise *)transform:(transform_block)block
{
    Deferred *transformed = [Deferred deferred];
    __block transform_block transformBlock = block;
    
    [self when:^(id result) {
        [transformed resolve:transformBlock(result)];
    } failed:^(NSError *error) {
        [transformed reject:error];
    } any:^{
    }];
    
    return [transformed promise];
}

- (id)wait:(NSTimeInterval)timeout
{
    __block BOOL waiting = YES;
    NSCondition *waitCondition = [[NSCondition alloc] init];
    
    [self when:^(id result) {
        [waitCondition lock];
        waiting = NO;
        [waitCondition signal];
        [waitCondition unlock];
    }];
    
    [waitCondition lock];
    if (!waiting) {
        [waitCondition waitUntilDate:[NSDate dateWithTimeIntervalSinceNow:timeout]];
    }
    [waitCondition unlock];
    
    return self.result;
}

@end
