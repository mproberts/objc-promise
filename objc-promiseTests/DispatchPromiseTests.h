//
//  DispatchPromiseTests.h
//  objc-promise
//
//  Created by Michael Roberts on 2012-10-16.
//  Copyright (c) 2012 Mike Roberts. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "Deferred.h"
#import "PromiseTestCallback.h"

@interface DispatchPromiseTests : SenTestCase

- (void)testQueueDispatch;
- (void)testFailedDispatch;

@end
