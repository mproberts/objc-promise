//
//  DispatchPromise.h
//  objc-promise
//
//  Created by Michael Roberts on 2012-10-16.
//  Copyright (c) 2012 Mike Roberts. All rights reserved.
//

#import "Deferred.h"

@class Deferred;

@interface DispatchPromise : Deferred {
    dispatch_queue_t _queue;
}

- (id)initWithQueue:(dispatch_queue_t)queue;

@end
