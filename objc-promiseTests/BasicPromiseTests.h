//
//  BasicPromiseTests.h
//  objc-promise
//
//  Created by Michael Roberts on 2012-10-13.
//  Copyright (c) 2012 Mike Roberts. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "PromiseTestCallback.h"
#import "Deferred.h"

@interface BasicPromiseTests : SenTestCase {
    PromiseTestCallback *callback;
}

- (void)setUp;
- (void)tearDown;

- (void)testPromiseThen;
- (void)testPromiseFailed;
- (void)testCalledOnceOnly;
- (void)testResolvedBeforeBinding;
- (void)testPromiseResolveCallsOnlyThenAndDone;

@end
