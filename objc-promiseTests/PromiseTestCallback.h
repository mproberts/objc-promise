//
//  PromiseTestCallback.h
//  objc-promise
//
//  Created by Michael Roberts on 2012-10-15.
//  Copyright (c) 2012 Mike Roberts. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Deferred.h"

@interface PromiseTestCallback : NSObject {
    resolved_block _whenBlock;
    rejected_block _failedBlock;
    any_block _anyBlock;
    
    int _whenCount;
    int _failedCount;
    int _anyCount;
}

@property (nonatomic, copy) resolved_block whenBlock;
@property (nonatomic, copy) rejected_block failedBlock;
@property (nonatomic, copy) any_block anyBlock;

@property (nonatomic, readonly, assign) int whenCallCount;
@property (nonatomic, readonly, assign) int failedCallCount;
@property (nonatomic, readonly, assign) int anyCallCount;

@end
