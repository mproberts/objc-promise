//
//  Promise.h
//  objc-promise
//
//  Created by Michael Roberts on 2012-10-12.
//  Copyright (c) 2012 Mike Roberts. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^bound_block)(void);

@class Deferred;
@class DispatchPromise;

typedef void (^resolved_block)(id);
typedef void (^rejected_block)(NSError *);
typedef void (^any_block)(void);

typedef enum {
    Incomplete = 0,
    Rejected   = 1,
    Resolved   = 2
} PromiseState;

@interface Promise : NSObject {
    NSMutableArray *_callbackBindings;
    
    NSObject *_stateLock;
    PromiseState _state;
    
    id _result;
    NSError *_reason;
}

@property (readonly) id result;
@property (readonly) NSError *reason;
@property (readonly) BOOL isResolved;
@property (readonly) BOOL isRejected;

+ (Promise *)or:(NSArray *)promises;
+ (Promise *)and:(NSArray *)promises;

- (Promise *)then:(resolved_block)resolvedBlock;
- (Promise *)failed:(rejected_block)rejectedBlock;
- (Promise *)any:(any_block)anyBlock;
- (Promise *)then:(resolved_block)thenBlock failed:(rejected_block)rejectedBlock;
- (Promise *)then:(resolved_block)thenBlock failed:(rejected_block)rejectedBlock any:(any_block)anyBlock;

- (Promise *)on:(dispatch_queue_t)queue;
- (Promise *)onMainQueue;

@end
