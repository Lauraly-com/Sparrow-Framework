//
//  SPGroup.m
//  Sparrow
//
//  Created by Jérôme on 17/03/2015.
//
//

#import <Sparrow/SPGroup.h>

@implementation SPGroup
{
	NSMutableOrderedSet *_objects;
	BOOL _serial;
	BOOL _started;
	BOOL _finished;
}

#pragma mark Initialization

- (instancetype)initWithObjects:(NSArray*)objects serial:(BOOL)serial
{
	if ((self = [super init]))
	{
		_objects = [[NSMutableOrderedSet alloc] init];
		_serial = serial;
		_elapsedTime = 0.0;
		_speed = 1.0f;
		_delay = 0;
		_started = NO;
		_finished = NO;
		
		for (id object in objects)
		{
			if([object conformsToProtocol:@protocol(SPAnimatable)] && ![_objects containsObject:object])
			{
				[_objects addObject:object];
				if ([(id)object isKindOfClass:[SPEventDispatcher class]])
					[(SPEventDispatcher *)object addEventListener:@selector(onRemove:) atObject:self forType:SPEventTypeRemoveFromJuggler];
			}
		}
	}
	return self;
}

- (void)dealloc
{
	[_objects release];
	[super dealloc];
}

+ (instancetype)parallelGroupWithObjects:(NSArray*)objects
{
	return [[[SPGroup alloc] initWithObjects:objects serial:NO] autorelease];
}

+(instancetype)serialGroupWithObjects:(NSArray *)objects
{
	return [[[SPGroup alloc] initWithObjects:objects serial:YES] autorelease];
}

#pragma mark Methods

- (void)onRemove:(SPEvent *)event
{
	[self removeObject:(id<SPAnimatable>)[[event.target retain] autorelease]];
}

- (void)removeObject:(id<SPAnimatable>)object
{
	if([_objects containsObject:object])
	{
		[_objects removeObject:object];
	
		if ([(id)object isKindOfClass:[SPEventDispatcher class]])
			[(SPEventDispatcher *)object removeEventListenersAtObject:self forType:SPEventTypeRemoveFromJuggler];
	}
}


#pragma mark SPAnimatable

- (void)advanceTime:(double)seconds
{
	if(_isComplete) return;
	
	if (seconds < 0.0)
		[NSException raise:SPExceptionInvalidOperation format:@"time must be positive"];
	
	seconds *= _speed;
	
	if (seconds > 0.0)
	{
		_elapsedTime += seconds;
		
		if(_elapsedTime < _delay)
			return;
		
		if(!_started)
		{
			_started = YES;
			if (_onStart) _onStart();
		}
		
		if(_serial)
		{
			id<SPAnimatable> object = [_objects firstObject];
			if(object)
				[object advanceTime:seconds];
		}
		else
		{
			// we need work with a copy, since user-code could modify the collection while enumerating
			NSArray* objectsCopy = [[_objects array] copy];
			
			for (id<SPAnimatable> object in objectsCopy)
				[object advanceTime:seconds];
			
			[objectsCopy release];
		}

		if (_onUpdate) _onUpdate();
		
		if([_objects count] == 0)
		{
			_isComplete = YES;
			[self dispatchEventWithType:SPEventTypeRemoveFromJuggler];
			if (_onComplete) _onComplete();
		}
	}
}

@end
