//
//  BasicPromiseTests.m
//  objc-promise
//
//  Created by Michael Roberts on 2012-10-13.
//  Copyright (c) 2012 Mike Roberts. All rights reserved.
//

#import "BasicPromiseTests.h"

@implementation BasicPromiseTests

- (void)setUp
{
    [super setUp];
    
    callback = [[PromiseTestCallback alloc] init];
}

- (void)tearDown
{
    [super tearDown];
    
    callback = nil;
}

- (void)testPromiseWhen
{
    Deferred *deferred = [Deferred deferred];
    Promise *promise = [deferred promise];
    
    [promise when:callback.whenBlock];
    
    STAssertEquals(callback.whenCallCount, 0, @"when not called synchronously");
    
    [deferred resolve:@"A"];
    
    STAssertEquals(callback.whenCallCount, 1, @"when should be called");
}

- (void)testPromiseFailed
{
    Deferred *deferred = [Deferred deferred];
    Promise *promise = [deferred promise];
    
    [promise failed:callback.failedBlock];
    
    STAssertEquals(callback.failedCallCount, 0, @"Failed not called synchronously");
    
    [deferred reject:[NSError errorWithDomain:@"B" code:9001 userInfo:nil]];
    
    STAssertEquals(callback.failedCallCount, 1, @"Failed should be called");
}

- (void)testCalledOnceOnly
{
    Deferred *deferred = [Deferred deferred];
    Promise *promise = [deferred promise];
    
    [promise when:callback.whenBlock
           failed:callback.failedBlock
              any:callback.anyBlock];
    
    STAssertEquals(callback.whenCallCount, 0, @"when not called synchronously");
    
    [deferred resolve:@"First"];
    STAssertEquals(callback.whenCallCount, 1, @"when should be called");
    STAssertEquals(callback.anyCallCount, 1, @"Any should be called");
    
    [deferred resolve:@"Second"];
    STAssertEquals(callback.whenCallCount, 1, @"when should be called only once");
    
    [deferred reject:[NSError errorWithDomain:@"Third is an error" code:9001 userInfo:nil]];
    STAssertEquals(callback.whenCallCount, 1, @"Promise cannot change state");
    STAssertEquals(callback.failedCallCount, 0, @"Promise cannot change state");
    STAssertEquals(callback.anyCallCount, 1, @"Promise cannot change state");
}

- (void)testResolvedBeforeBinding
{
    Deferred *deferred = [Deferred deferred];
    Promise *promise = [deferred promise];
    
    [deferred resolve:@"First"];
    
    [promise when:callback.whenBlock];
    STAssertEquals(callback.whenCallCount, 1, @"Should be called immediately upon binding");
    
    [promise when:callback.whenBlock];
    STAssertEquals(callback.whenCallCount, 2, @"Should be called again");
}

- (void)testPromiseResolveCallsOnlyWhenAndDone
{
    Deferred *deferred = [Deferred deferred];
    Promise *promise = [deferred promise];
    
    [promise when:callback.whenBlock
           failed:callback.failedBlock
              any:callback.anyBlock];
    
    STAssertEquals(callback.whenCallCount, 0, @"when not called synchronously");
    STAssertEquals(callback.failedCallCount, 0, @"Failed not called");
    STAssertEquals(callback.anyCallCount, 0, @"Done not called synchronously");
    
    [deferred resolve:@"Test"];
    
    STAssertEquals(callback.whenCallCount, 1, @"when should be called");
    STAssertEquals(callback.failedCallCount, 0, @"Failed should not be called");
    STAssertEquals(callback.anyCallCount, 1, @"Done should be called");
}

@end
