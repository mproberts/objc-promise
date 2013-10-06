# objc-promise
### A CommonJS-style promise library for iOS

Asynchronous code can offer a promise as a result instead of a complex set of callbacks with custom-designed behaviour. When you have a promise you can listen for success using a `then:` block, failure using a `failed:` block or either success or failure using an `any:` block. Any number of callback blocks can be added to a promise.

When you bind a callback to a promise it will be called exactly once as soon as the promise transitions into either the success or error state. If the promise is already in one of these states when the callback is added, the callback will be triggered immediately.

There are many helpful methods that allow you work with promises and the data they return as well as control the flow of data through your program. Check out the examples section for more information.

## Examples

### Using Promises Made by Others

```objectivec
Promise *superAwesomeData = [awesomeObject grabSomeData];

[promise then:^(NSString *secret){
	// when we know the magic word this will be fired
	NSLog(@"The magic word is %@!", secret);
} failed:^(NSError *error) {
	// something went terribly wrong
) any:^{
	// do some cleanup
}];
```

### Keeping Promises you Make to Others

```objectivec
NSData *data = ...;
Deferred *futureData = [Deferred deferred];

// a whole lot of work being done here off thread
dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
	for (int i = 0; i < 10000; ++i) {
		data = [data sha256];
	}
	
	// eventually we have a result to hand back
	[futureData resolve:data];
});

return [futureData promise];
```

### Breaking Promises you Make with Others

Notifying listeners of error states is simple, just reject a deferred object with your error.

```objectivec
Deferred *futureData = [Deferred deferred];
NSError *error = [NSError errorWithDomain:@"wrong doing" code:100 userInfo:nil];

// you can reject the promise that you make providing a reason
[futureData reject:error];
```

You can also start with a broken promise.

```objectivec
// you can also just create a promise you have no intention of keeping
Promise *falsePromise = [Promise rejected:error];
```

### Working With Dispatch Queues

Often times data will be loaded off of the main queue to improve UI responsiveness but for display, the result will always have to be forced back onto the main queue. The `onMainQueue` method creates a derived promise whose callback will always be fired on the main thread.

Similar to the `onMainQueue` method, the `on:(dispatch_queue_t)` method will force all callbacks to be fired on a specific dispatch queue.

```objectivec
Promise *webImagePromise = ...;
UIImageView *imageView = ...;

// the webImagePromise may be resolved on a different network thread
// but this callback will always fire on the main queue
[[webImagePromise onMainQueue] then:^(UIImage *webImage) {
	webImage.image = webImage;
}];
```

### Not the Type You're Looking For?

Sometimes the type of a promise returned to you will need to be changed before it can be used for its final purpose. Perhaps a string needs to be parsed into a number or data needs to be inflated into an object, for this, you can use the `transform:(transform_block)` method.

```objectivec
Promise *stringPromise = ...;
Promise *numberPromise = [arrayOfStringsPromise transform:NSNumber *^(NSString *str) {
	return [NSNumber numberWithInt:[str integerValue]];
)];

[numberPromise then:^(NSNumber *number) {
	...
}];
```

### Synchronizing the Asynchronous

If you really need to block execution (and you ***really*** should try not to) you can use the `wait:(NSTimeInterval)` method to wait for the resolution of a promise.

```objectivec
Promise *webImagePromise = ...;
UIImageView *imageView = ...;

// Never, ever do this
// Not even once
imageView.image = [webImagePromise wait:10.0];
```

## License

Source code for _objc-promise_ is Copyright © 2012 [Mike Roberts](mailto:mike@kik.com).

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS,” WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
