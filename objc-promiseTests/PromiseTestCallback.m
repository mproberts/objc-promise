//
//  PromiseTestCallback.m
//  objc-promise
//
//  Created by Michael Roberts on 2012-10-15.
//  Copyright (c) 2012 Mike Roberts. All rights reserved.
//

#import "PromiseTestCallback.h"

@implementation PromiseTestCallback

@synthesize thenBlock = _thenBlock, failedBlock = _failedBlock, anyBlock = _anyBlock;
@synthesize thenCallCount = _thenCount, failedCallCount = _failedCount, anyCallCount = _anyCount;

- (id)init
{
    if (self = [super init]) {
        __block PromiseTestCallback *this = self;
        
        _thenBlock = Block_copy(^(id result){
            this->_thenCount++;
        });
        
        _failedBlock = Block_copy(^(NSError *reason){
            this->_failedCount++;
        });
        
        _anyBlock = Block_copy(^{
            this->_anyCount++;
        });
    }
    
    return self;
}

- (void)dealloc
{
    Block_release(_thenBlock);
    Block_release(_failedBlock);
    Block_release(_anyBlock);
    
    [super dealloc];
}

@end
