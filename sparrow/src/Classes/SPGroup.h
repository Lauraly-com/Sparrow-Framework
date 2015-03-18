//
//  SPGroup.h
//  Sparrow
//
//  Created by Jérôme Cabanis on 17/03/2015.
//  Copyright 2015 Lauraly. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>
#import <Sparrow/SPAnimatable.h>
#import <Sparrow/SPEventDispatcher.h>

/** ------------------------------------------------------------------------------------------------
 
 The SPGroup takes objects that implement SPAnimatable (e.g. `SPTween`s) and executes them, just like 
 SPJuggler does but objects can be animated sequentially or in parallel.
 
 A SPGroup can be added to a SPJuggler or to an other SPGroup

 Furthermore, an object can request to be removed from the SPGroup by dispatching an
 `SPEventTypeRemoveFromJuggler` event and SPGroup dispach `SPEventTypeRemoveFromJuggler` event.

 SPGroup provide block-based callbacks that are executed in certain phases of it's life time:
 
 - `onStart`:    Invoked once when the group starts.
 - `onUpdate`:   Invoked every time it is advanced.
 - `onComplete`: Invoked when all objects are completed.
 
 ------------------------------------------------------------------------------------------------- */


@interface SPGroup : SPEventDispatcher <SPAnimatable>

+ (instancetype)parallelGroupWithObjects:(NSArray*)objects;
+ (instancetype)serialGroupWithObjects:(NSArray*)objects;

/// Removes an object from the group. Use this function if the object does not dispatch `SPEventTypeRemoveFromJuggler` events
- (void)removeObject:(id<SPAnimatable>)object;

/// ----------------
/// @name Properties
/// ----------------

/// The delay before the group is started.
@property (nonatomic, assign) double delay;

/// The total life time of the group.
@property (nonatomic, readonly) double elapsedTime;

/// The speed factor adjusts how fast the group's animatables run.
/// For example, a speed factor of 2.0 means the group runs twice as fast.
@property (nonatomic, assign) float speed;

/// Indicates if the group execution is complete.
@property (nonatomic, readonly) BOOL isComplete;

/// A block that will be called when the group starts (after a possible delay).
@property (nonatomic, copy) SPCallbackBlock onStart;

/// A block that will be called each time the group is advanced.
@property (nonatomic, copy) SPCallbackBlock onUpdate;

/// A block that will be called when the group execution is complete.
@property (nonatomic, copy) SPCallbackBlock onComplete;


@end
