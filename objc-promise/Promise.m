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

@synthesize then = _then, failed = _failed, done = _done;
@synthesize result = _result, reason = _reason;
@dynamic isResolved, isRejected;

- (id)init
{
    if (self = [super init]) {
        // bind self reference to a block variable to ensure
        // self is not retained by the block methods it owns
        __block Promise *this = self;
        
        _callbackBindings = [[NSMutableArray alloc] init];
        _state = Incomplete;
        
        _stateLock = [[NSObject alloc] init];
        _result = nil;
        
        _then = Block_copy(^Promise *(resolved_block resolvedBlock){
            // retain the block until we can call with the result
            Block_copy(resolvedBlock);
            
            [this bindOrCallBlock:^{
                if (this.isResolved) {
                    resolvedBlock(this.result);
                }
                
                Block_release(resolvedBlock);
            }];
            
            return this;
        });
        
        _failed = Block_copy(^Promise *(rejected_block rejectedBlock){
            // retain the block until we can call with the result
            Block_copy(rejectedBlock);
            
            [this bindOrCallBlock:^{
                if (this.isRejected) {
                    rejectedBlock(this.reason);
                }
                
                Block_release(rejectedBlock);
            }];
            
            return this;
        });
        
        _done = Block_copy(^Promise *(any_block anyBlock){
            // retain the block until we can call with the result
            Block_copy(anyBlock);
            
            [this bindOrCallBlock:^{
                anyBlock();
                
                Block_release(anyBlock);
            }];
            
            return this;
        });
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
    
    Block_release(_then);
    Block_release(_failed);
    Block_release(_done);
    
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

@end
