//
//  DispatchPromise.m
//  objc-promise
//
//  Created by Michael Roberts on 2012-10-16.
//  Copyright (c) 2012 Mike Roberts. All rights reserved.
//

#import "DispatchPromise.h"

@implementation DispatchPromise

- (id)initWithQueue:(dispatch_queue_t)queue
{
    if (self = [super init]) {
        _queue = [queue retain];
    }
    
    return self;
}

- (void)dealloc
{
    [_queue release];
    _queue = nil;
    
    [super dealloc];
}

- (void)executeBlock:(bound_block)block
{
    dispatch_async(_queue, block);
}

@end
