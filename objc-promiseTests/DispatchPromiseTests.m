//
//  DispatchPromiseTests.m
//  objc-promise
//
//  Created by Michael Roberts on 2012-10-16.
//  Copyright (c) 2012 Mike Roberts. All rights reserved.
//

#import "DispatchPromiseTests.h"

@implementation DispatchPromiseTests

- (void)testQueueDispatch
{
    __block int calls = 0;
    Deferred *deferred = [Deferred deferred];
    NSCondition *condition = [[NSCondition alloc] init];
    
    dispatch_queue_t targetQueue = dispatch_queue_create("Test Queue", DISPATCH_QUEUE_SERIAL);
    
    [[deferred on:targetQueue] then:^(id result){
        [condition lock];
        [condition wait];
        [condition unlock];
        ++calls;
    }];
    
    [deferred resolve:@1];
    
    STAssertEquals(calls, 0, @"The dispatch should not happen until we unblock the queue");
    
    usleep(USEC_PER_SEC * 0.05);
    [condition lock];
    [condition signal];
    [condition unlock];
    
    usleep(USEC_PER_SEC * 0.05);
    
    STAssertEquals(calls, 1, @"The queue was unblocked, calls should be set");
    
    dispatch_release(targetQueue);
}

- (void)testFailedDispatch
{
    __block int calls = 0;
    Deferred *deferred = [Deferred deferred];
    NSCondition *condition = [[NSCondition alloc] init];
    
    dispatch_queue_t targetQueue = dispatch_queue_create("Test Queue", DISPATCH_QUEUE_SERIAL);
    
    [[deferred on:targetQueue] failed:^(NSError *error){
        [condition lock];
        [condition wait];
        ++calls;
        [condition unlock];
    }];
    
    [deferred reject:[NSError errorWithDomain:@"Whoops" code:111 userInfo:nil]];
    
    STAssertEquals(calls, 0, @"The dispatch should not happen until we unblock the queue");
    
    usleep(USEC_PER_SEC * 0.05);
    [condition lock];
    [condition signal];
    [condition unlock];
    
    usleep(USEC_PER_SEC * 0.05);
    
    STAssertEquals(calls, 1, @"The queue was unblocked, calls should be set");
    
    dispatch_release(targetQueue);
}

@end
