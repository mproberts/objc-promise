//
//  JoinedPromiseTests.m
//  objc-promise
//
//  Created by Michael Roberts on 2012-10-16.
//  Copyright (c) 2012 Mike Roberts. All rights reserved.
//

#import "JoinedPromiseTests.h"

@implementation JoinedPromiseTests

- (void)setUp
{
    [super setUp];
    
    callback = [[PromiseTestCallback alloc] init];
}

- (void)tearDown
{
    [super tearDown];
    
    [callback release];
    callback = nil;
}

- (void)testAndSuccess
{
    Deferred *defer1 = [Deferred deferred];
    Deferred *defer2 = [Deferred deferred];
    Deferred *defer3 = [Deferred deferred];
    
    Promise *andAll = [Promise and:@[defer1, defer2, defer3]];
    
    [andAll when:callback.whenBlock];
    
    [defer1 resolve:@1];
    STAssertEquals(callback.whenCallCount, 0, @"Only 1 resolved");
    
    [defer2 resolve:@2];
    STAssertEquals(callback.whenCallCount, 0, @"Only 2 resolved");
    
    [defer3 resolve:@3];
    STAssertEquals(callback.whenCallCount, 1, @"All 3 resolved");
}

- (void)testAndRejection
{
    Deferred *defer1 = [Deferred deferred];
    Deferred *defer2 = [Deferred deferred];
    Deferred *defer3 = [Deferred deferred];
    
    Promise *andAll = [Promise and:@[defer1, defer2, defer3]];
    
    [andAll when:callback.whenBlock
          failed:callback.failedBlock];
    
    [defer1 reject:[NSError errorWithDomain:@"Whoops" code:999 userInfo:nil]];
    STAssertEquals(callback.failedCallCount, 1, @"Only 1 resolved");
    
    [defer2 resolve:@2];
    STAssertEquals(callback.whenCallCount, 0, @"Only 2 resolved");
    
    [defer3 resolve:@3];
    STAssertEquals(callback.whenCallCount, 0, @"All 3 resolved");
}

- (void)testOrSuccess
{
    Deferred *defer1 = [Deferred deferred];
    Deferred *defer2 = [Deferred deferred];
    Deferred *defer3 = [Deferred deferred];
    
    Promise *orAll = [Promise or:@[defer1, defer2, defer3]];
    
    [orAll when:callback.whenBlock];
    
    [defer1 resolve:@1];
    STAssertEquals(callback.whenCallCount, 1, @"Only 1 resolved");
    
    [defer2 resolve:@2];
    STAssertEquals(callback.whenCallCount, 1, @"Only 2 resolved");
    
    [defer3 resolve:@3];
    STAssertEquals(callback.whenCallCount, 1, @"All 3 resolved");
}

- (void)testOrRejection
{
    Deferred *defer1 = [Deferred deferred];
    Deferred *defer2 = [Deferred deferred];
    Deferred *defer3 = [Deferred deferred];
    
    Promise *orAll = [Promise or:@[defer1, defer2, defer3]];
    
    [orAll when:callback.whenBlock
         failed:callback.failedBlock];
    
    [defer1 reject:[NSError errorWithDomain:@"Whoops" code:999 userInfo:nil]];
    STAssertEquals(callback.failedCallCount, 0, @"Only 1 resolved");
    
    [defer2 reject:[NSError errorWithDomain:@"Whoops" code:999 userInfo:nil]];
    STAssertEquals(callback.failedCallCount, 0, @"Only 2 resolved");
    
    [defer3 reject:[NSError errorWithDomain:@"Whoops" code:999 userInfo:nil]];
    STAssertEquals(callback.failedCallCount, 1, @"All 3 resolved");
}

@end
