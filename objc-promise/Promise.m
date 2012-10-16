//
//  Promise.m
//  objc-promise
//
//  Created by Michael Roberts on 2012-10-12.
//  Copyright (c) 2012 Mike Roberts. All rights reserved.
//

#import "Promise.h"
#import "Deferred.h"
#import "DispatchPromise.h"

@implementation Promise (Private)

- (BOOL)bindOrCallBlock:(bound_block)block
{
    BOOL blockWasBound = NO;
    
    @synchronized (_stateLock) {
        if (_state == Incomplete) {
            [_callbackBindings addObject:Block_copy(block)];
            
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
    block();
}

- (void)chainTo:(Deferred *)deferred
{
    [self then:^(id result){
        [deferred resolve:result];
    } failed:^(NSError *error){
        [deferred reject:error];
    }];
}

@end

@implementation Promise

@synthesize result = _result, reason = _reason;
@dynamic isResolved, isRejected;

- (id)init
{
    if (self = [super init]) {
        _callbackBindings = [[NSMutableArray alloc] init];
        _state = Incomplete;
        
        _stateLock = [[NSObject alloc] init];
        _result = nil;
    }
    
    return self;
}

- (void)dealloc
{
    [_callbackBindings release];
    _callbackBindings = nil;
    
    [_stateLock release];
    _stateLock = nil;
    
    [_result release];
    _result = nil;
    
    [_reason release];
    _reason = nil;
    
    [super dealloc];
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
    int count = promises.count;
    __block int rejectedCount = 0;
    Deferred *deferred = [[Deferred alloc] init];
    
    // any promise resolves our deferred
    for (Promise *promise in promises) {
        [promise then:^(id result) {
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
    int count = promises.count;
    __block int resolvedCount = 0;
    Deferred *deferred = [[Deferred alloc] init];
    
    // any promise resolves our deferred
    for (Promise *promise in promises) {
        [promise then:^(id result) {
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

- (Promise *)then:(resolved_block)resolvedBlock
{
    __block Promise *this = self;
    
    // retain the block until we can call with the result
    Block_copy(resolvedBlock);
    
    [this bindOrCallBlock:^{
        if (this.isResolved) {
            resolvedBlock(this.result);
        }
        
        Block_release(resolvedBlock);
    }];
    
    return this;
}

- (Promise *)failed:(rejected_block)rejectedBlock
{
    __block Promise *this = self;
    
    // retain the block until we can call with the result
    Block_copy(rejectedBlock);
    
    [this bindOrCallBlock:^{
        if (this.isRejected) {
            rejectedBlock(this.reason);
        }
        
        Block_release(rejectedBlock);
    }];
    
    return this;
}

- (Promise *)any:(any_block)anyBlock
{
    __block Promise *this = self;
    
    // retain the block until we can call with the result
    Block_copy(anyBlock);
    
    [this bindOrCallBlock:^{
        anyBlock();
        
        Block_release(anyBlock);
    }];
    
    return this;
}

- (Promise *)then:(resolved_block)thenBlock failed:(rejected_block)rejectedBlock
{
    [self then:thenBlock];
    [self failed:rejectedBlock];
    
    return self;
}

- (Promise *)then:(resolved_block)thenBlock failed:(rejected_block)rejectedBlock any:(any_block)anyBlock
{
    [self then:thenBlock];
    [self failed:rejectedBlock];
    [self any:anyBlock];
    
    return self;
}

- (Promise *)on:(dispatch_queue_t)queue
{
    Deferred *deferred = [[DispatchPromise alloc] initWithQueue:queue];
    
    [self chainTo:deferred];
    
    return [deferred autorelease];
}

- (Promise *)onMainQueue
{
    return [self on:dispatch_get_main_queue()];
}

@end
