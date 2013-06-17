//
//  PromiseTestCallback.m
//  objc-promise
//
//  Created by Michael Roberts on 2012-10-15.
//  Copyright (c) 2012 Mike Roberts. All rights reserved.
//

#import "PromiseTestCallback.h"

@implementation PromiseTestCallback

@synthesize whenBlock = _whenBlock, failedBlock = _failedBlock, anyBlock = _anyBlock;
@synthesize whenCallCount = _whenCount, failedCallCount = _failedCount, anyCallCount = _anyCount;

- (id)init
{
    if (self = [super init]) {
        __block PromiseTestCallback *this = self;
        
        self.whenBlock = ^(id result){
            this->_whenCount++;
        };
        
        self.failedBlock = ^(NSError *reason){
            this->_failedCount++;
        };
        
        self.anyBlock = ^{
            this->_anyCount++;
        };
    }
    
    return self;
}

@end
