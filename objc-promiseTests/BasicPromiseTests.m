//
//  BasicPromiseTests.m
//  objc-promise
//
//  Created by Michael Roberts on 2012-10-13.
//  Copyright (c) 2012 Mike Roberts. All rights reserved.
//

#import "BasicPromiseTests.h"

@implementation BasicPromiseTests

- (void)testPromiseResolveCallsOnlyThen
{
    Deferred *deferred = [[Deferred alloc] init];
    Promise *promise = [deferred promise];
    
    __block BOOL thenCalled = NO;
    __block BOOL failedCalled = NO;
    __block BOOL doneCalled = NO;
    
    [promise then:^(id result){
        thenCalled = YES;
    } failed:^(NSError *reason){
        failedCalled = YES;
    } any:^{
        doneCalled = YES;
    }];
    
    STAssertFalse(thenCalled, @"Then not called synchronously");
    STAssertFalse(failedCalled, @"Failed not called");
    STAssertFalse(doneCalled, @"Done not called synchronously");
    
    [deferred resolve:@"Test"];
    
    STAssertTrue(thenCalled, @"Then should be called");
    STAssertFalse(failedCalled, @"Failed should not be called");
    STAssertTrue(doneCalled, @"Done should be called");
    
    [deferred release];
}

@end
