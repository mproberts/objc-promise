//
//  Promise.m
//  objc-promise
//
//  Created by Michael Roberts on 2012-10-12.
//  Copyright (c) 2012 Mike Roberts. All rights reserved.
//

#import "Promise.h"

typedef void (^bound_block)(void);

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
        block();
    }
    
    return blockWasBound;
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

@end
