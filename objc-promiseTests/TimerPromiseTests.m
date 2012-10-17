//
//  TimerPromiseTests.m
//  objc-promise
//
//  Created by Michael Roberts on 2012-10-16.
//  Copyright (c) 2012 Mike Roberts. All rights reserved.
//

#import "TimerPromiseTests.h"

@implementation TimerPromiseTests

- (void)testTimeout
{
    __block int calls = 0;
    Deferred *deferred = [Deferred deferred];
    
    dispatch_queue_t targetQueue = dispatch_queue_create("Test Queue", DISPATCH_QUEUE_SERIAL);
    
    [[[deferred on:targetQueue] timeout:0.1]
     failed:^(NSError *error){
        ++calls;
    }];
    
    usleep(90000);
    STAssertEquals(calls, 0, @"No timeout yet");
    
    usleep(20000);
    STAssertEquals(calls, 1, @"Should timeout");
    
    dispatch_release(targetQueue);
}

@end
