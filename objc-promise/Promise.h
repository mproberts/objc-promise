//
//  Promise.h
//  objc-promise
//
//  Created by Michael Roberts on 2012-10-12.
//  Copyright (c) 2012 Mike Roberts. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^bound_block)(void);
typedef id (^transform_block)(id);

@class Deferred;
@class DispatchPromise;
@class Promise;

typedef void (^resolved_block)(id);
typedef void (^rejected_block)(NSError *);
typedef void (^any_block)(void);

typedef Promise *(^promise_returning_block)();
typedef Promise *(^promise_returning_arg_block)(id arg);

typedef enum {
    Incomplete = 0,
    Rejected   = 1,
    Resolved   = 2
} PromiseState;

@interface Promise : NSObject {
    NSMutableArray *_callbackBindings;
    dispatch_queue_t _queue;
    
    NSObject *_stateLock;
    PromiseState _state;
    
    id _result;
    NSError *_reason;
}

@property (readonly) id result;
@property (readonly) NSError *reason;
@property (readonly) BOOL isResolved;
@property (readonly) BOOL isRejected;

+ (Promise *)resolved:(id)result;
+ (Promise *)rejected:(NSError *)reason;

+ (Promise *)or:(NSArray *)promises;
+ (Promise *)and:(NSArray *)promises;

/**
 * Calls each supplied block with the result of the promise from the previously executed
 * block. If any promise rejects, the chain is broken. If all promises resolve, the result
 * of the last promise will be returned.
 *
 * @returns a promise which is resolved with the result of the last executed block
 */
+ (Promise *)chain:(promise_returning_arg_block)firstBlock, ... NS_REQUIRES_NIL_TERMINATION;

- (Promise *)when:(resolved_block)resolvedBlock;
- (Promise *)failed:(rejected_block)rejectedBlock;
- (Promise *)any:(any_block)anyBlock;
- (Promise *)when:(resolved_block)whenBlock failed:(rejected_block)rejectedBlock;
- (Promise *)when:(resolved_block)whenBlock failed:(rejected_block)rejectedBlock any:(any_block)anyBlock;

- (Promise *)on:(dispatch_queue_t)queue;
- (Promise *)onMainQueue;

- (Promise *)timeout:(NSTimeInterval)interval;
- (Promise *)timeout:(NSTimeInterval)interval leeway:(NSTimeInterval)leeway;

- (Promise *)transform:(transform_block)block;

- (id)wait:(NSTimeInterval)timeout;

@end

@interface Promise (Private)

- (void)executeBlock:(bound_block)block;

@end

