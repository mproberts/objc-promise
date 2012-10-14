//
//  Promise.h
//  objc-promise
//
//  Created by Michael Roberts on 2012-10-12.
//  Copyright (c) 2012 Mike Roberts. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Promise;

typedef void (^resolved_block)(id);
typedef void (^rejected_block)(NSError *);
typedef void (^any_block)(void);

typedef Promise *(^then_block)(resolved_block);
typedef Promise *(^failed_block)(rejected_block);
typedef Promise *(^done_block)(any_block);

typedef Promise *(^then_on_block)(resolved_block);
typedef Promise *(^failed_on_block)(rejected_block);
typedef Promise *(^done_on_block)(any_block);

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
    
    then_block _then;
    failed_block _failed;
    done_block _done;
}

@property (readonly) id result;
@property (readonly) NSError *reason;
@property (readonly) BOOL isResolved;
@property (readonly) BOOL isRejected;

@property (readonly) then_block then;
@property (readonly) failed_block failed;
@property (readonly) done_block done;

@end
