//
//  JoinedPromiseTests.h
//  objc-promise
//
//  Created by Michael Roberts on 2012-10-16.
//  Copyright (c) 2012 Mike Roberts. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "Deferred.h"
#import "PromiseTestCallback.h"

@interface JoinedPromiseTests : SenTestCase {
    PromiseTestCallback *callback;
}

- (void)setUp;
- (void)tearDown;

- (void)testAndSuccess;
- (void)testAndRejection;
- (void)testOrSuccess;
- (void)testOrRejection;

@end
