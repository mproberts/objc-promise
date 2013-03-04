//
//  Deferred.m
//  objc-promise
//
//  Created by Michael Roberts on 2012-10-12.
//  Copyright (c) 2012 Mike Roberts. All rights reserved.
//

#import "Deferred.h"

@implementation Deferred (Private)

- (void)transitionToState:(PromiseState)state
{
    NSArray *blocksToExecute = nil;
    BOOL shouldComplete = NO;
    
    @synchronized (_stateLock) {
        if (_state == Incomplete) {
            _state = state;
            
            shouldComplete = YES;
            
            blocksToExecute = _callbackBindings;
            
            _callbackBindings = nil;
        }
    }
    
    if (shouldComplete) {
        for (bound_block block in blocksToExecute) {
            [self executeBlock:block];
        }
    }
}

@end

@implementation Deferred

- (id)init
{
    if (self = [super init]) {
    }
    
    return self;
}

+ (Deferred *)deferred
{
    return [[Deferred alloc] init];
}

- (Promise *)promise
{
    return self;
}

- (Promise *)resolve:(id)result
{
    _result = result;
    
    [self transitionToState:Resolved];
    
    return [self promise];
}

- (Promise *)reject:(NSError *)reason
{
    _reason = reason;
    
    [self transitionToState:Rejected];
    
    return [self promise];
}

@end
